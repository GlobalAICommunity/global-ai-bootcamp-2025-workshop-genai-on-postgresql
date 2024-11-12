CREATE OR REPLACE FUNCTION semantic_relevance(query TEXT, n INT)
RETURNS jsonb AS $$
DECLARE
    json_pairs jsonb;
	result_json jsonb;
BEGIN
	json_pairs := generate_json_pairs(query, n);
	result_json := azure_ml.invoke(
				json_pairs,
				deployment_name=>'bge-v2-m3-1',
				timeout_ms => 180000);
	RETURN (
		SELECT result_json as result
	);
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_json_pairs(query TEXT, n INT)
RETURNS jsonb AS $$
BEGIN
    RETURN (
        SELECT jsonb_build_object(
            'pairs', 
            jsonb_agg(
                jsonb_build_array(query, LEFT(text, 800))
            )
        ) AS result_json
        FROM (
            SELECT id, opinion AS text
		    FROM cases
		    ORDER BY opinions_vector <=> azure_openai.create_embeddings('text-embedding-3-small', query)::vector
		    LIMIT n
        ) subquery
    );
END $$ LANGUAGE plpgsql;

LOAD 'age';
SET search_path = public, ag_catalog, "$user";

WITH
embedding_query AS (
    SELECT azure_openai.create_embeddings('text-embedding-3-small', 'Water leaking into the apartment from the floor above.')::vector AS embedding
),
vector AS (
    SELECT cases.id, cases.name AS case_name, cases.decision_date AS date, cases.opinion, RANK() OVER (ORDER BY opinions_vector <=> embedding) AS vector_rank
    FROM cases, embedding_query
    ORDER BY opinions_vector <=> embedding
    LIMIT 60
),
semantic AS (
    SELECT * 
    FROM jsonb_array_elements(
            semantic_relevance('Water leaking into the apartment from the floor above.',
            60)
        ) WITH ORDINALITY AS elem(relevance)
),
semantic_ranked AS (
    SELECT semantic.relevance::DOUBLE PRECISION AS relevance, RANK() OVER (ORDER BY relevance DESC) AS semantic_rank,
			semantic.*, vector.*
    FROM vector
    JOIN semantic ON vector.vector_rank = semantic.ordinality
    ORDER BY semantic.relevance DESC
),
graph AS (
    SELECT graph_query.refs, semantic_ranked.vector_rank, semantic_ranked.*, graph_query.case_id from semantic_ranked
	LEFT JOIN cypher('case_graph', $$
            MATCH ()-[r]->(n)
            RETURN n.case_id, COUNT(r) AS refs
        $$) as graph_query(case_id TEXT, refs BIGINT)
	ON semantic_ranked.id = graph_query.case_id::int
),
graph_ranked AS (
    SELECT RANK() OVER (ORDER BY COALESCE(graph.refs, 0) DESC) AS graph_rank, graph.*
    FROM graph ORDER BY graph_rank DESC
),
rrf AS (
    SELECT
        COALESCE(1.0 / (60 + graph_ranked.graph_rank), 0.0) +
        COALESCE(1.0 / (60 + graph_ranked.semantic_rank), 0.0) AS score,
        graph_ranked.*
    FROM graph_ranked
    ORDER BY score DESC
    LIMIT 20
)
SELECT id, case_name, opinion
FROM rrf
LIMIT 10;