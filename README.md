# AI on Azure PostgreSQL Flexible Server

This project demonstrates how to use AI-driven features on Azure PostgreSQL Flexible Server. It includes steps to set up the environment, populate the database with sample data, and use various AI-driven features to enhance your application.

## Presentation

Download [here](Presentation/Building-AI-apps-with-Postgres-Lab.pptx)

## Lab Content

1. [Part 0 - Deploy the resources on your Azure Subscription](Instructions/Lab_Instructions.md#part-0---Deploy-the-resources)
1. [Part 1 - Getting started with AI on Azure PostgreSQL flexible server](Instructions/Lab_Instructions.md#part-1---getting-started-with-ai-on-azure-postgresql-flexible-server)
    1. [Clone TechConnect Lab repo](Instructions/Lab_Instructions.md#clone-techconnect-lab-repo)
    1. [Connect to your database using psql in the Azure Cloud Shell](Instructions/Lab_Instructions.md#connect-to-your-database-using-psql-in-the-azure-cloud-shell)
    1. [Populate the database with sample data](Instructions/Lab_Instructions.md#populate-the-database-with-sample-data)
    1. [Setting up pgAdmin](Instructions/Lab_Instructions.md#setting-up-pgadmin)
    1. [Install and configure the `azure_ai` extension](Instructions/Lab_Instructions.md#install-and-configure-the-azure_ai-extension)
1. [Part 2 - Using AI-driven features in Postgres](Instructions/Lab_Instructions.md#part-2---using-ai-driven-features-in-postgres)
    1. [Using Pattern matching for queries](Instructions/Lab_Instructions.md#using-pattern-matching-for-queries)
    1. [Using Semantic Search and DiskANN](Instructions/Lab_Instructions.md#using-semantic-search-and-diskann-index)
1. [ Part 3 - How RAG chatbot accuracy improves with different technique](Instructions/Lab_Instructions.md#part-3---how-rag-chatbot-accuracy-improves-with-different-technique)
    1. [Exploring Cases RAG application](Instructions/Lab_Instructions.md#exploring-cases-rag-application)
    1. [Review Accuracy of vector search queries](Instructions/Lab_Instructions.md#review-accuracy-of-vector-search-queries)
1. [Part 4 - Improving RAG Accuracy with Advanced Techniques - Reranking and GraphRAG](Instructions/Lab_Instructions.md#part-4---improving-rag-accuracy-with-advanced-techniques---reranking-and-graphrag)
    1. [Reranker](Instructions/Lab_Instructions.md#what-is-a-reranker)
    1. [GraphRAG](Instructions/Lab_Instructions.md#what-is-graphrag)
    1. [Compare Results of RAG responses using Vector search, Reranker or GraphRAG](Instructions/Lab_Instructions.md#compare-results-of-rag-responses-using-vector-search-reranker-or-graphrag)

## Build GraphRAG Application on Azure

This will require and Azure subscription, follow our [Graph RAG solution accelerator](https://aka.ms/graphrag-legal-solution-accelerator-pg-blog)

![Graph RAG App](./Instructions/instructions282962/azure-RAG-app-demo.png)

## Build Simple RAG Application Locally

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

![Simple RAG App](./Instructions/instructions276019/azure-RAG-app.png)


