You are an AI testing engineer running inside Ollama. Your mission is to fully evaluate two models against my real-world workflows:

1. **Model A:** qwen2.5-coder:7b — for interactive coding assistance  
2. **Model B:** mistral-nemo:12b — for ingesting and correlating heterogeneous data (spreadsheets, CSVs, PDF text, email threads)

---

## Step 1: Generate a Test Plan

For each model, produce:

- **Test Plan Summary**  
  - Model name & version  
  - Primary use case  
  - Key success criteria  

- **Test Cases** (≥ 5 per model)  
  - **ID & Title**  
  - **Description**: what aspect you’re testing (e.g. “implement function from spec,” “refactor for performance,” “aggregate order data from CSV+emails”)  
  - **Prompt Text**: the exact prompt you’ll send to the model  
  - **Input Artifacts**: include—or generate—small sample files or snippets (Python code files, CSV rows, PDF-style paragraphs, email excerpts)  
  - **Expected Output**: either a specification (e.g. “the function returns correct Fibonacci numbers up to n”) or a schema (e.g. JSON with fields order_id, customer_name, total)

- **Evaluation Metrics**  
  - **Quantitative**:  
    - Latency (ms and tokens/sec)  
    - Token usage  
  - **Qualitative**:  
    - Correctness (pass/fail per case)  
    - Completeness (did it cover all fields?)  
    - Clarity (are explanations understandable?)

- **Data Collection Template**  
  - A JSON schema for logging each run’s inputs, outputs, metrics, and pass/fail flags.

---

## Step 2: Execution Instructions

For each test case, emit the exact shell commands to run under Ollama, for example:

```bash
# coding test example
ollama run qwen2.5-coder:7b \
  --prompt "/* Test #1: Implement a function that reverses a linked list in Python. */" \
  --timeout 60 \
  > outputs/test1_qwen.out

# data test example
ollama run mistral-nemo:12b \
  --prompt "Here is a CSV snippet:\n<CSV_CONTENTS>\nAnd an email thread:\n<EMAIL_CONTENTS>\nList all order IDs and customer names." \
  --timeout 120 \
  > outputs/test1_nemo.out