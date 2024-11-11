-- Description: This script creates the tables and loads the data into the tables.
-- It creates a table to store the cases data and loads the data from the cases.csv file into the table.

DROP TABLE IF EXISTS cases;

-- Create a table to store the cases data
CREATE TABLE cases(
        id SERIAL PRIMARY KEY,
        name TEXT,
        decision_date DATE,
        court_id INT,
        opinion TEXT
    );

-- Create a temp table to store the cases data
CREATE TABLE temp_cases(data jsonb);
\COPY temp_cases (data) FROM 'mslearn-pg-ai/Setup/Data/cases.csv' WITH (FORMAT csv, HEADER true);

-- Insert data into the cases table
INSERT INTO cases
SELECT
        (data#>>'{id}')::int AS id, 
        (data#>>'{name_abbreviation}')::text AS name, 
        (data#>>'{decision_date}')::date AS decision_date, 
        (data#>>'{court,id}')::int AS court_id, 
        array_to_string(ARRAY(SELECT jsonb_path_query(data, '$.casebody.opinions[*].text')), ', ') AS opinion
FROM temp_cases;

