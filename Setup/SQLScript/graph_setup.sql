-- Create a temp table to store the cases data
-- DROP TABLE IF EXISTS public.temp_cases;
-- CREATE TABLE public.temp_cases(data jsonb);
-- \COPY public.temp_cases (data) FROM 'mslearn-pg-ai/Setup/Data/cases.csv' WITH (FORMAT csv, HEADER true);

CREATE OR REPLACE FUNCTION create_case_in_case_graph(case_id text)
RETURNS void
LANGUAGE plpgsql
VOLATILE
AS $BODY$
BEGIN

	SET search_path TO ag_catalog;
	EXECUTE format('SELECT * FROM cypher(''case_graph'', $$CREATE (:case {case_id: %s})$$) AS (a agtype);', quote_ident(case_id));
END
$BODY$;

CREATE OR REPLACE FUNCTION create_case_link_in_case_graph(id_from text, id_to text)
RETURNS void
LANGUAGE plpgsql
VOLATILE
AS $BODY$
BEGIN

	SET search_path TO ag_catalog;
	EXECUTE format('SELECT * FROM cypher(''case_graph'', $$MATCH (a:case), (b:case) WHERE a.case_id = %s AND b.case_id = %s CREATE (a)-[e:REF]->(b) RETURN e$$) AS (a agtype);', quote_ident(id_from), quote_ident(id_to));
END
$BODY$;


-- CREATION of case_graph
CREATE EXTENSION IF NOT EXISTS age CASCADE;

SELECT * FROM ag_catalog.drop_graph('case_graph', true);

SET search_path = public, ag_catalog, "$user";

SELECT create_graph('case_graph');

-- Create nodes
SELECT create_case_in_case_graph((public.temp_cases.data#>>'{id}')::text) 
FROM public.temp_cases;

SELECT * from cypher('case_graph', $$
                    MATCH (n)
                    RETURN COUNT(n.case_id)
                $$) as (case_id TEXT);

WITH edges AS (
	SELECT c1.data#>>'{id}' AS id_from, c2.data#>>'{id}' AS id_to
	FROM public.temp_cases c1
	LEFT JOIN 
	    LATERAL jsonb_array_elements(c1.data -> 'cites_to') AS cites_to_element ON true
	LEFT JOIN 
	    LATERAL jsonb_array_elements(cites_to_element -> 'case_ids') AS case_ids ON true
	JOIN public.temp_cases c2 
		ON case_ids::text = c2.data#>>'{id}'
)
SELECT public.create_case_link_in_case_graph(edges.id_from::text, edges.id_to::text) 
FROM edges;