# AI on Azure PostgreSQL Flexible Server

This project demonstrates how to use AI-driven features on Azure PostgreSQL Flexible Server. It includes steps to set up the environment, populate the database with sample data, and use various AI-driven features to enhance your application.

## Lab Content

1. [Getting started with AI on Azure PostgreSQL flexible server](/Instructions/Lab_Instructions.md#getting-started-with-ai-on-azure-postgresql-flexible-server)
    1. [Connect to your database using psql in the Azure Cloud Shell](Instructions/Lab_Instructions.md#connect-to-your-database-using-psql-in-the-azure-cloud-shell)
    2. [Populate the database with sample data](Instructions/Lab_Instructions.md#populate-the-database-with-sample-data)
    3. [Install and configure the `azure_ai` extension](Instructions/Lab_Instructions.md#install-and-configure-the-azure_ai-extension)
    4. [Review the objects contained within the `azure_ai` extension](Instructions/Lab_Instructions.md#review-the-objects-contained-within-the-azure_ai-extension)
4. [Using AI-driven features in Postgres](Instructions/Lab_Instructions.md#part-2---using-ai-driven-features-in-postgres)
5. [Using different approaches to enhance results from your application](Instructions/Lab_Instructions.md#using-different-approaches-to-enhance-results-from-your-application)
6. [Using Pattern matching for queries](Instructions/Lab_Instructions.md#using-pattern-matching-for-queries)
7. [Using Full Text Search](Instructions/Lab_Instructions.md#using-full-text-search)
8. [Using Semantic Search](Instructions/Lab_Instructions.md#using-semantic-search)
9. [Using Semantic Search and DiskANN](Instructions/Lab_Instructions.md#using-semantic-search-and-diskann)
10. [Hybrid Query](Instructions/Lab_Instructions.md#hybrid-query)
11. [Optional - Improving Performance with Reranking and GraphRAG](Instructions/Lab_Instructions.md#optional---improving-performance-with-reranking-and-graphrag)
12. [What is a Reranker](Instructions/Lab_Instructions.md#what-is-a-reranker)
13. [Compare Results](Instructions/Lab_Instructions.md#compare-results)
14. [How RAG chatbot accuracy improves with different technique](Instructions/Lab_Instructions.md#how-rag-chatbot-accuracy-improves-with-different-technique)
15. [Exploring Cases RAG application](Instructions/Lab_Instructions.md#exploring-cases-rag-application)
16. [Bonus: Cognitive Services options](Instructions/Lab_Instructions.md#bonus-cognitive-services-options)

## Build Sample Application Locally

### Setting up the environment file

Since the local app uses OpenAI models, you should first deploy it for the optimal experience.

1. Copy `.env.sample` into a `.env` file.
2. To use Azure OpenAI, fill in the values of `AZURE_OPENAI_ENDPOINT` and `AZURE_OPENAI_API_KEY` based on the deployed values.

### Install dependencies
Install required Python packages and streamlit application:

```python
python3 -m venv .ignite_lab
source .ignite_lab/bin/activate
```

```bash
pip install -r requirements.txt
```

### Running the application
From root directory

```bash
cd App
streamlit run rag_chatbot_demo.py
```

When run locally run looking for website at http://localhost:8501/

![OpenAI credientials](./Instructions/instructions276019/azure-RAG-app.png)

