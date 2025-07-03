import os
import re
from dotenv import load_dotenv
import google.generativeai as genai
from langchain_community.vectorstores import FAISS
from langchain.embeddings import HuggingFaceEmbeddings

load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel("gemini-2.5-pro")

# Embedding
embedding_function = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")

# Load vector DB
vectordb = FAISS.load_local(
    "../gemini_chatbot/zeenea_vector_db",
    embedding_function,    
    allow_dangerous_deserialization=True
)


history = []

def ask_question(question, k=5, show_context=False):

    retriever = vectordb.as_retriever(
    search_type="mmr",
    search_kwargs={"k":k, "fetch_k":50}
    )
    results = retriever.get_relevant_documents(question)
    context = "\n\n".join([r.page_content for r in results])

    if show_context:
        print("\n----- Retrieved Context -----\n")
        print(context)
        print("\n-----------------------------\n")
    

    if not context.strip():
        return (
            "I don't know based on the current documents. "
        )


    # conversation history
    conversation = ""
    for i, turn in enumerate(history):
        conversation += f"\nQ{i+1}: {turn['question']}\nA{i+1}: {turn['answer']}\n"

    # prompt
    prompt = f"""
You are a documentation assistant for Zeenea documentation. 

**Important rules:**
- Always answer based **only** on the provided context.
- If the answer is not found in the context, say "I don't know based on the current documents."
- Do not make up answers or retrieve information from external sources.

**Instructions:**
Depending on the user's question, respond in one of the following styles:

1. **For procedural or task-based questions:**
   - Provide a clear, actionable answer.
   - Include a **Step-by-Step** list in Markdown format.

2. **For general knowledge or conceptual questions:**
   - Provide a clear explanation.

**Formatting:**
- Use Markdown only.
- Do NOT wrap your answer in JSON.
- Do NOT use triple backticks.
- Just output clean text.


Below is the previous conversation:
{conversation}

Current Question:
{question}

Context:
{context}
"""

    # Gemini response
    response = model.generate_content([prompt])
    answer_text = response.text.strip()

    # save history
    history.append({
        "question": question,
        "answer": answer_text,
        "context": context
    })

    return answer_text
