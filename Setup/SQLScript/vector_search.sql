-- Vector Search
WITH embedding AS (
    SELECT 
        id, 
        name,
        opinions_vector,
        RANK() OVER (
            ORDER BY opinions_vector <=> azure_openai.create_embeddings(
                'text-embedding-3-small', 
                'Water leaking into the apartment from the floor above.'
            )::vector
        ) AS vector_rank
    FROM cases
)
SELECT id, name
FROM embedding
ORDER BY vector_rank
LIMIT 10;
