CREATE EXTENSION IF NOT EXISTS age CASCADE;

LOAD 'age';
SET search_path = public, ag_catalog, "$user";

WITH
user_query as (
	select 'Water leaking into the apartment from the floor above.' as query_text
),
embedding_query AS (
    SELECT azure_openai.create_embeddings('text-embedding-3-small', query_text)::vector AS embedding, query_text
	FROM user_query
),
vector AS (
    SELECT cases.id, query_text,cases.data
    FROM cases, embedding_query
    WHERE (cases.data#>>'{court, id}')::integer IN (9029, 8985) -- Washington Supreme Court (9029) or Washington Court of Appeals (8985)
    ORDER BY description_vector <=> embedding
    LIMIT 50
),
json_payload AS (
    SELECT jsonb_build_object(
        'pairs', 
        jsonb_agg(
            jsonb_build_array(
                query_text, 
                LEFT(data#>>'{casebody, opinions, 0}', 8000)
            )
        )
    ) AS json_pairs
    FROM vector
),
semantic AS (
    SELECT elem.relevance::DOUBLE precision as relevance, elem.ordinality
    FROM json_payload,
         LATERAL jsonb_array_elements(
             azure_ml.invoke(
                 json_pairs,
                 deployment_name => 'bge-v2-m3-1',
                 timeout_ms => 180000
             )
         ) WITH ORDINALITY AS elem(relevance)
),
graph AS (
    SELECT *, RANK() OVER (ORDER BY graph.refs DESC) AS graph_rank
    FROM semantic
	JOIN cypher('case_graph', $$
            MATCH ()-[r]->(n)
            RETURN n.case_id, COUNT(r) AS refs
        $$) as graph_query(case_id TEXT, refs BIGINT)
	ON semantic.id = graph_query.case_id
),
rrf AS (
    SELECT *,
        COALESCE(1.0 / (60 + graph_rank), 0.0) +
        COALESCE(1.0 / (60 + semantic_rank), 0.0) AS score
    FROM graph
    LIMIT 20
)
SELECT id, name 
FROM rrf
LIMIT 10;