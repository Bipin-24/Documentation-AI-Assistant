import streamlit as st
import json
from rag_backend import ask_question, history

st.set_page_config(
    page_title="Zeenea Documentation AI Assistant",
    page_icon="🤖",
    layout="wide"
)

st.title("🤖 Zeenea Documentation AI Assistant")

st.markdown(
    """
This chatbot can answer your questions about Zeenea.

Try asking questions like:
- *Which data sources can Zeenea connect to?*
-------------------------------------------------------------------
"""
)

# initialize session state
if "chat_history" not in st.session_state:
    st.session_state.chat_history = []

# Input question
with st.form("question_form", clear_on_submit=True):
    question = st.text_input("Ask a question:", key="input_field")
    submitted = st.form_submit_button("Submit Question")

if submitted and question.strip() != "":
    with st.spinner("Thinking..."):
        result = ask_question(question, k=10, show_context=False)

    # Save to session state
    st.session_state.chat_history.append({
        "question": question,
        "answer": result
    })

# show chat history
for i, turn in enumerate(st.session_state.chat_history):
    st.markdown(f"**Q{i+1}: {turn['question']}**")
    st.markdown(turn["answer"])

# show retrieved contexts
with st.expander("Show Retrieved Contexts"):
    for i, h in enumerate(history):
        st.markdown(f"**Question {i+1}:** {h['question']}")
        st.code(h.get("context", ""))

if st.button("Clear Conversation"):
    st.session_state.chat_history = []
