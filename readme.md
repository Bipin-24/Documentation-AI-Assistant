# Chatbot Prototype Setup Guide


### 1. Create a Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
```

### 2. Install Python Dependencies
```bash
pip install -r requirements.txt 
```

### 3. Set Gemini API Key
- Create a ```.env``` file in the project root directory

```bash
GEMINI_API_KEY=api_key_here
```

### 4. Adjust Documentation Path
- In ```docs_db.py```, you need to update the path to your local Markdown files.


### 5. Build the Vector Database
- Run docs_db.py to create the FAISS vector index:
```bash 
python docs_db.py 
```
- you should see the message "FAISS vectorstore saved".


### 6. Run the Application  
```bash 
streamlit run app.py 
```



**Notes**

- Vector Embedding: [HuggingFaceEmbeddings] (https://huggingface.co/docs/transformers/quicktour)for vector embeddings

- Chunk Size Adjustment: In ```docs_db.py``` or ```rag_backend.py```, you can adjust the chunk size if retrieval accuracy is low.

- Model Configuration:: You can change which Gemini model is used in ```app.py```
