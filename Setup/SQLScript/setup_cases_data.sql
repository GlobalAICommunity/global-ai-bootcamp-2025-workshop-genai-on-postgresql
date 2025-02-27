-- Setup Tables
-- Create a table to store the cases data
CREATE TABLE temp_cases(data jsonb);
\COPY temp_cases (data) FROM '/mslearn-pg-ai/Setup/Data/cases.csv'
WITH (FORMAT csv, HEADER true);

DROP TABLE cases;

CREATE TABLE cases(
    id SERIAL PRIMARY KEY,
    name TEXT,
    decision_date DATE,
	court_id INT,
    opinion TEXT
);

-- Add cases data
INSERT INTO cases
SELECT
    (data#>>'{id}')::int AS id, 
    (data#>>'{name_abbreviation}')::text AS name, 
    (data#>>'{decision_date}')::date AS decision_date, 
    (data#>>'{court,id}')::int AS court_id, 
    (data#>>'{cites_to,case_ids}')::int AS related_case_ids, 
    array_to_string(ARRAY(SELECT jsonb_path_query(data, '$.casebody.opinions[*].text')), ', ') AS opinion
FROM temp_cases;

select * FROM cases;