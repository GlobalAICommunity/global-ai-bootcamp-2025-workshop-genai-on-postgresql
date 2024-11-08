import streamlit as st
import json
import os
from openai import AzureOpenAI

import streamlit as st
import json
import os
from openai import AzureOpenAI

# Streamlit configuration
st.set_page_config(page_title="RAG Chatbot with PostgreSQL", page_icon="☕", layout="wide")

# Display PostgreSQL logo at the top of the page
#st.image("https://www.postgresql.org/media/img/about/press/elephant.png", width=100)
st.image("https://sqltune.files.wordpress.com/2023/07/azure-database-for-postgresql-bigger.png", width=100)

# Streamlit UI setup
st.title("US Law Dataset Chatbot")
st.subheader("Semantic Re-ranker search enhanced by RAG (Retrieval Augmented Generation) on structured data")

# Display additional description or instructions for the users
st.write(
    """
    This demo leverages **[RAG (Retrieval Augmented Generation)](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview)** on **PostgreSQL** for structured data retrieval and **Azure OpenAI** for enhanced understanding.
    Upload initial query results in JSON format, then interact with the AI chatbot to ask follow-up questions.
    """
)

# Header for the application
st.title("RAG Chatbot Demo with PostgreSQL")

# Sidebar for API key and connection settingsc
with st.sidebar:
    st.header("Configuration Settings")

    # Azure OpenAI API Configuration
    endpoint = st.text_input("Azure OpenAI Endpoint", value="{api-endpoint}")
    api_key = st.text_input("API Key", type="password", value=os.getenv("OPENAI_API_KEY", "{api-key-here}"))
    deployment = st.text_input("Model Deployment", value=os.getenv("DEPLOYMENT_NAME", "gpt-4o"))

    # Initialize Azure OpenAI Client and store in session state
    if st.button("Connect to Azure OpenAI"):
        try:
            client = AzureOpenAI(
                azure_endpoint=endpoint,
                api_key=api_key,
                api_version="2024-05-01-preview",
            )
            st.session_state.client = client  # Store client in session state
            st.success("Connected to Azure OpenAI!")
        except Exception as e:
            st.error(f"Failed to connect to Azure OpenAI: {e}")

# Check if client is available in session state
if "client" in st.session_state:
    client = st.session_state.client
else:
    client = None

# File uploader for loading initial query results
st.subheader("Step 1: Load Initial Query Results")
uploaded_file = st.file_uploader("Upload a JSON file with initial query results", type="json")

# Global variable to store initial context
if "initial_context_data" not in st.session_state:
    st.session_state.initial_context_data = None

# Load the initial query results if a file is uploaded
if uploaded_file:
    initial_context_data = json.load(uploaded_file)
    st.session_state.initial_context_data = initial_context_data  # Store in session state
    st.success("Initial query results loaded successfully!")
    st.json(st.session_state.initial_context_data)  # Display loaded JSON data

# Chatbot interaction section
st.subheader("Step 2: Ask Follow-up Questions")

# Input box for user to ask follow-up questions
followup_question = st.text_input("Enter your follow-up question based on the initial query results:")

# Initialize a session state variable to store chat history
if "chat_history" not in st.session_state:
    st.session_state.chat_history = []

# Define a function to generate responses using Azure OpenAI
def generate_response(context, question):
    # Check if the client is initialized before making a request
    if client is None:
        st.error("Azure OpenAI client is not initialized. Please connect first.")
        return "Client not initialized"
    
    # Prepare messages for the chat completion request
    messages = [
        {"role": "system", "content": "You are an AI assistant that helps answer questions based on initial context data."},
        {"role": "user", "content": f"DOCUMENT: {context} QUESTION: {question}"},
    ]

    try:
        # Generate the response using Azure OpenAI and convert to a dictionary format
        response = client.chat.completions.create(
            model=deployment,
            messages=messages,
            max_tokens=500,
            temperature=0.7,
            top_p=0.95,
            frequency_penalty=0,
            presence_penalty=0,
            stop=None,
            stream=False
        ).to_dict()  # Convert to dictionary to allow subscriptable access

        # Extract the content of the first completion choice
        # Make sure to check if 'choices' and 'message' keys are present
        if 'choices' in response and len(response['choices']) > 0:
            return response['choices'][0]['message']['content']
        else:
            return "No valid response returned by the model."
    except Exception as e:
        st.error(f"Error generating response: {e}")
        return f"Error: {e}"


# Display initial context if available
if st.session_state.initial_context_data:
    if followup_question and client is not None:
        # Generate a response based on the initial context and the follow-up question
        context_str = json.dumps(st.session_state.initial_context_data)  # Convert initial context to a string
        answer = generate_response(context=context_str, question=followup_question)

        # Store the conversation in session state
        st.session_state.chat_history.append({"user": followup_question, "ai": answer})

        # Display the chat history
        st.subheader("Chat History")
        for chat in st.session_state.chat_history:
            st.markdown(f"**User**: {chat['user']}")
            st.markdown(f"**AI**: {chat['ai']}")

# Option to clear the chat history
if st.button("Clear Chat History"):
    st.session_state.chat_history = []  # Reset chat history
    st.success("Chat history cleared!")
