# Ollama Model Testing Project Plan

## Project Overview

This project aims to comprehensively evaluate two Ollama models against real-world workflows:

1. **Model A:** qwen2.5-coder:7b — for interactive coding assistance  
2. **Model B:** mistral-nemo:12b — for ingesting and correlating heterogeneous data

## Attack Plan

### Phase 1: Project Structure Setup

Create the necessary directory structure and foundational files:

```
ollama-local-model-testing/
├── instructions.md (existing)
├── project-plan.md (this file)
├── test-plans/
│   ├── qwen-coder-test-plan.md
│   └── mistral-nemo-test-plan.md
├── test-data/
│   ├── sample-code/
│   ├── sample-csv/
│   ├── sample-emails/
│   └── sample-pdf-text/
├── outputs/
├── scripts/
│   └── run-tests.sh
└── schemas/
    └── test-results-schema.json
```

### Phase 2: Model A (qwen2.5-coder:7b) Test Plan

Create 6 comprehensive test cases focusing on coding scenarios:

1. **QC-01: Function Implementation** - Basic algorithm implementation from specification
2. **QC-02: Code Refactoring** - Performance optimization of existing code
3. **QC-03: Bug Fixing** - Debug and fix broken code with logical errors
4. **QC-04: Code Review** - Analyze code and suggest improvements
5. **QC-05: Documentation Generation** - Create docstrings and inline comments
6. **QC-06: API Integration** - Write code using external APIs and libraries

**Success Criteria:**
- Produces syntactically correct code
- Implements requirements accurately
- Follows Python best practices
- Provides clear explanations
- Handles edge cases appropriately

### Phase 3: Model B (mistral-nemo:12b) Test Plan

Create 6 comprehensive test cases for data processing and correlation:

1. **MN-01: CSV Data Analysis** - Extract insights and patterns from spreadsheet data
2. **MN-02: Email Thread Correlation** - Connect related information across email chains
3. **MN-03: Multi-source Data Fusion** - Combine and correlate CSV + email + PDF text
4. **MN-04: Data Validation** - Check consistency and identify discrepancies across sources
5. **MN-05: Report Generation** - Create structured summaries from heterogeneous data
6. **MN-06: Pattern Recognition** - Identify trends and anomalies across data types

**Success Criteria:**
- Accurately extracts relevant information
- Correctly correlates data across sources
- Identifies patterns and relationships
- Produces structured, actionable outputs
- Handles incomplete or inconsistent data gracefully

### Phase 4: Supporting Artifacts Creation

For each test case, generate:

- **Realistic Sample Input Files:**
  - Python code snippets with various complexity levels
  - CSV files with business data (orders, customers, products)
  - Email thread excerpts with relevant business information
  - PDF-style text paragraphs with structured information

- **Detailed Prompt Engineering:**
  - Clear, specific instructions
  - Context-appropriate formatting
  - Expected output specifications

- **Expected Output Specifications:**
  - Functional requirements for code tests
  - Data schemas for extraction tests
  - Quality criteria for both models

### Phase 5: Evaluation Framework

**Quantitative Metrics:**
- Latency (response time in milliseconds)
- Throughput (tokens per second)
- Token usage (input + output token counts)

**Qualitative Metrics:**
- Correctness (pass/fail per test case)
- Completeness (coverage of all required elements)
- Clarity (understandability of explanations and code)
- Robustness (handling of edge cases and errors)

**Data Collection:**
- JSON schema for structured result logging
- Automated timing and token counting
- Pass/fail evaluation criteria
- Human-readable test reports

### Phase 6: Execution Framework

**Shell Script Generation:**
- Individual Ollama commands for each test case
- Proper timeout configurations
- Output redirection to organized files
- Error handling and logging

**Automation Components:**
- Master test runner script
- Results aggregation system
- Performance benchmarking
- Report generation

## Implementation Order

1. **✅ Create project plan document** (this file)
2. **🔄 Setup project structure** - Create all directories and placeholder files
3. **📝 Generate sample data files** - Create realistic test artifacts
4. **📋 Write detailed test plans** - Document each test case thoroughly
5. **🔧 Create JSON schema** - Define results logging structure
6. **⚡ Generate executable commands** - Shell scripts for each test
7. **🤖 Create automation scripts** - Master runner and aggregation tools

## Success Metrics

**Project Success Indicators:**
- All test cases have clear pass/fail criteria
- Execution can be fully automated
- Results are comparable across models
- Framework is reusable for future model evaluations
- Documentation enables reproduction by others

**Timeline Estimate:**
- Phase 1-2: Setup and Model A tests (~30 minutes)
- Phase 3: Model B tests (~20 minutes)
- Phase 4-5: Artifacts and evaluation framework (~25 minutes)
- Phase 6: Execution automation (~15 minutes)
- **Total: ~90 minutes**

## Notes

- All sample data should be realistic but anonymized
- Test cases should cover both happy path and edge cases
- Prompts should be optimized for each model's strengths
- Results should be human-readable and machine-parseable
- Framework should be extensible for additional models

---

*Generated: June 11, 2025*
*Project: Ollama Model Testing Framework*
