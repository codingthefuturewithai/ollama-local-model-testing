# Test Plan: Coding Tests Category
**Framework Version:** 2.0 - Interactive Model Selection  
**Category:** Coding & Software Development  
**Test Count:** 6 tests  
**Suitable for:** Any coding-focused language model

## Overview

This test category evaluates a model's ability to handle software development tasks including algorithm implementation, code optimization, debugging, documentation, and API integration. Tests are designed to be model-agnostic and can be run with any Ollama model.

## Test Cases

### CT-01: Binary Search Implementation
**Objective:** Assess algorithm implementation skills  
**Complexity:** Medium  
**Expected Duration:** 60-90 seconds

**Test Description:**
Implement a binary search function with proper documentation and error handling.

**Requirements:**
- Function takes sorted list and target value as parameters
- Returns index if found, -1 if not found  
- O(log n) time complexity
- Proper error handling for edge cases
- Complete docstring with examples
- Well-structured, readable code

**Evaluation Criteria:**
- **Correctness (40%):** Algorithm accuracy, proper return values
- **Completeness (30%):** All requirements addressed
- **Code Quality (30%):** Style, documentation, error handling

---

### CT-02: Performance Optimization
**Objective:** Evaluate code analysis and optimization skills  
**Complexity:** Medium-High  
**Expected Duration:** 60-90 seconds

**Test Description:**
Analyze provided inefficient code and provide optimized version with explanations.

**Input:** Slow search function with performance issues  
**Requirements:**
- Identify specific performance problems
- Provide optimized implementation
- Explain improvements and impact
- Include time complexity analysis (before vs after)
- Suggest additional optimizations

**Evaluation Criteria:**
- **Correctness (40%):** Accurate problem identification and fixes
- **Completeness (30%):** Comprehensive analysis and improvements
- **Code Quality (30%):** Clean, efficient optimized code

---

### CT-03: Bug Fixing
**Objective:** Test debugging and problem-solving abilities  
**Complexity:** Medium  
**Expected Duration:** 60-90 seconds

**Test Description:**
Find and fix all bugs in provided Python code.

**Input:** Stack implementation with multiple bugs  
**Requirements:**
- Identify all bugs in the code
- Provide corrected implementation
- Explain what each bug was and why problematic
- Test fixes with example usage
- Suggest additional improvements

**Evaluation Criteria:**
- **Correctness (40%):** Complete bug identification and fixes
- **Completeness (30%):** All issues addressed with explanations
- **Code Quality (30%):** Clean, robust corrected code

---

### CT-04: Code Review Analysis
**Objective:** Assess code review and analysis capabilities  
**Complexity:** Medium  
**Expected Duration:** 60-90 seconds

**Test Description:**
Review undocumented function and provide improvement suggestions.

**Requirements:**
- Analyze what the function does
- Suggest better naming conventions
- Recommend documentation improvements  
- Identify potential edge cases or bugs
- Overall code quality assessment

**Evaluation Criteria:**
- **Correctness (40%):** Accurate analysis and observations
- **Completeness (30%):** Comprehensive review coverage
- **Code Quality (30%):** Practical, actionable suggestions

---

### CT-05: Documentation Generation
**Objective:** Test documentation and communication skills  
**Complexity:** Medium  
**Expected Duration:** 60-90 seconds

**Test Description:**
Generate complete API documentation for a given function.

**Input:** Fibonacci function implementation  
**Requirements:**
- Detailed docstring with parameters and return values
- Add type hints
- Provide usage examples
- Include time/space complexity analysis
- Suggest potential improvements or alternatives

**Evaluation Criteria:**
- **Correctness (40%):** Accurate documentation and analysis
- **Completeness (30%):** All documentation components present
- **Code Quality (30%):** Professional, clear presentation

---

### CT-06: API Integration
**Objective:** Evaluate practical development skills  
**Complexity:** High  
**Expected Duration:** 90-120 seconds

**Test Description:**
Create a production-ready Python class for REST API interactions.

**Requirements:**
- Methods for GET, POST, PUT, DELETE operations
- Authentication with API keys
- Proper error handling and retries
- JSON request/response support
- Logging for debugging
- Type hints and complete documentation
- Base URL: https://api.example.com/v1/users
- API Key in headers as 'X-API-Key'

**Evaluation Criteria:**
- **Correctness (40%):** Functional implementation with proper API methods
- **Completeness (30%):** All requirements implemented
- **Code Quality (30%):** Production-ready code with proper error handling

## Success Criteria

### Overall Category Performance
- **Excellent (9.0-10.0):** Consistently produces high-quality, production-ready code
- **Good (7.0-8.9):** Solid implementation with minor areas for improvement  
- **Acceptable (5.0-6.9):** Functional code that meets basic requirements
- **Poor (3.0-4.9):** Significant issues requiring major improvements
- **Failed (0.0-2.9):** Non-functional or severely flawed implementations

### Key Indicators
- Syntactically correct and executable code
- Proper algorithm implementations
- Appropriate error handling
- Clear documentation and comments
- Following Python best practices
- Handling edge cases appropriately

## Test Execution

Use the Interactive Test Runner:
```bash
./scripts/interactive-test-runner.sh
```

Select any available model and choose "Coding Tests" category.

## Model Suitability

**Recommended for models specialized in:**
- Code generation and completion
- Algorithm implementation
- Software development assistance
- Technical documentation
- Programming language understanding

**Example compatible models:**
- qwen2.5-coder:7b
- codellama:13b  
- deepseek-coder:6.7b
- Any general-purpose model with coding capabilities

---

*Generated: June 11, 2025*  
*Framework: Ollama Interactive Testing v2.0*
