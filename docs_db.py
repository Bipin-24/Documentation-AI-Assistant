from langchain_community.document_loaders import DirectoryLoader, UnstructuredMarkdownLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS

# Load all markdown files
loader = DirectoryLoader(
    "/Users/bipinpandey/zeenea.doc/enus/source",  # Replace with your actual path 
    glob="**/*.md",
    loader_cls=UnstructuredMarkdownLoader
)
docs = loader.load()
print(f"Loaded {len(docs)} documents.")

# Split documents
splitter = RecursiveCharacterTextSplitter(
    chunk_size=700,
    chunk_overlap=100
)
docs_split = []
for doc in docs:
    if len(doc.page_content) < 500:
        docs_split.append(doc)
    else:
        docs_split.extend(splitter.split_documents([doc]))

print(f"Split into {len(docs_split)} chunks.")

# Embeddings
embedding_function = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")

# Create FAISS index
faiss_db = FAISS.from_documents(docs_split, embedding_function)
faiss_db.save_local("../gemini_chatbot/zeenea_vector_db")

print("FAISS vectorstore saved to '../gemini_chatbot/zeenea_vector_db'.")
