-- Vector Search
WITH embedding AS (
RANK() OVER (
	ORDER BY opinions_vector <=> azure_openai.create_embeddings(
		'text-embedding-3-small', 
		'Water leaking into the apartment from the floor above.'
	)::vector
) AS vector_rank
)
SELECT id, name,
	RANK() OVER (ORDER BY opinions_vector <=> embed_vector) AS vector_rank
FROM cases, embedding
ORDER BY opinions_vector <=> embed_vector
LIMIT 10