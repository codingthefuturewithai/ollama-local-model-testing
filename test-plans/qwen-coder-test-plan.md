# Test Plan: qwen2.5-coder:7b (Coding Assistant)

## Test Plan Summary

- **Model Name & Version:** qwen2.5-coder:7b
- **Primary Use Case:** Interactive coding assistance, algorithm implementation, code review and optimization
- **Key Success Criteria:**
  - Produces syntactically correct and executable code
  - Implements requirements accurately according to specifications  
  - Follows Python best practices and coding conventions
  - Provides clear, educational explanations of code logic
  - Handles edge cases and error conditions appropriately
  - Suggests meaningful optimizations and improvements

---

## Test Cases

### QC-01: Function Implementation - Binary Search Algorithm

**Description:** Test the model's ability to implement a fundamental algorithm from a clear specification.

**Prompt Text:**
```
Implement a binary search function in Python that:
1. Takes a sorted list and target value as parameters
2. Returns the index of the target if found, -1 if not found
3. Uses the standard binary search algorithm (O(log n) complexity)
4. Includes proper error handling for edge cases
5. Add docstring with complexity analysis and examples

Please provide a complete, well-documented implementation.
```

**Input Artifacts:** None (algorithm specification only)

**Expected Output:**
- Syntactically correct Python function
- Proper binary search logic with left/right pointer manipulation
- Handles empty lists, single elements, target not found
- Clear docstring with time/space complexity
- Example usage or test cases

**Validation Criteria:**
- [ ] Function runs without syntax errors
- [ ] Correctly finds target values in sorted lists
- [ ] Returns -1 for values not in list
- [ ] Handles edge cases (empty list, single element)
- [ ] Time complexity is O(log n)
- [ ] Includes comprehensive docstring

---

### QC-02: Code Refactoring - Performance Optimization

**Description:** Test the model's ability to identify and fix performance issues in existing code.

**Prompt Text:**
```
The following function has performance issues. Analyze the code and provide an optimized version:

def slow_search(arr, target):
    """Inefficient linear search implementation"""
    found_indices = []
    for i in range(len(arr)):
        for j in range(len(arr)):  # Unnecessary nested loop
            if arr[i] == target:
                found_indices.append(i)
                break
    return found_indices

Requirements:
1. Fix the performance issues
2. Explain what was wrong with the original code
3. Provide time complexity analysis for both versions
4. Ensure the function still returns all indices where target appears
```

**Input Artifacts:** `test-data/sample-code/code-samples.py` (slow_search function)

**Expected Output:**
- Identification of the unnecessary nested loop
- Corrected single-loop implementation
- Clear explanation of the performance problem
- Time complexity comparison (O(n²) vs O(n))
- Maintains correct functionality (finding all indices)

**Validation Criteria:**
- [ ] Removes unnecessary nested loop
- [ ] Correctly identifies all occurrences of target
- [ ] Explains the original performance issue
- [ ] Provides complexity analysis
- [ ] Optimized code is syntactically correct

---

### QC-03: Bug Fixing - Stack Implementation

**Description:** Test the model's debugging skills by fixing multiple bugs in a data structure implementation.

**Prompt Text:**
```
This Stack class has several bugs. Find and fix all the issues:

class BuggyStack:
    """Stack implementation with bugs"""
    def __init__(self):
        self.items = []
    
    def push(self, item):
        self.items.append(item)
    
    def pop(self):
        if len(self.items) == 0:
            return None  # Should raise exception
        return self.items.pop(0)  # Wrong end of list
    
    def peek(self):
        return self.items[0]  # Wrong end, no bounds check
    
    def is_empty(self):
        return len(self.items) > 0  # Wrong comparison

Requirements:
1. Fix all bugs while maintaining proper stack behavior (LIFO)
2. Add appropriate error handling
3. Explain each bug you found
4. Add a simple test to demonstrate correct functionality
```

**Input Artifacts:** `test-data/sample-code/code-samples.py` (BuggyStack class)

**Expected Output:**
- Corrected pop() method to use items.pop() (last element)
- Fixed peek() to access last element with bounds checking
- Corrected is_empty() comparison logic
- Proper exception handling for empty stack operations
- Clear explanation of each bug found
- Test code demonstrating LIFO behavior

**Validation Criteria:**
- [ ] All 4 bugs are identified and fixed
- [ ] Stack follows LIFO (Last In, First Out) principle
- [ ] Proper exception handling for empty stack
- [ ] Includes test code that works correctly
- [ ] Clear explanation of each bug

---

### QC-04: Code Review - Function Analysis

**Description:** Test the model's ability to analyze code quality and suggest improvements.

**Prompt Text:**
```
Please review this function and provide suggestions for improvement:

def undocumented_function(data, threshold=10):
    result = []
    temp = 0
    for item in data:
        if isinstance(item, (int, float)):
            temp += item
            if temp > threshold:
                result.append(temp)
                temp = 0
        else:
            if temp > 0:
                result.append(temp)
            temp = 0
    return result

Provide:
1. Analysis of what the function does
2. Suggestions for better naming
3. Documentation improvements  
4. Potential edge cases or bugs
5. Overall code quality assessment
```

**Input Artifacts:** `test-data/sample-code/code-samples.py` (undocumented_function)

**Expected Output:**
- Correct analysis of function behavior (accumulator with threshold)
- Better function and variable names
- Comprehensive docstring with parameters and return value
- Identification of potential issues (empty data, negative numbers)
- Overall code quality improvements

**Validation Criteria:**
- [ ] Correctly understands function behavior
- [ ] Suggests meaningful names for function and variables
- [ ] Provides comprehensive docstring
- [ ] Identifies potential edge cases
- [ ] Offers constructive improvement suggestions

---

### QC-05: Documentation Generation - API Documentation

**Description:** Test the model's ability to generate comprehensive documentation for existing code.

**Prompt Text:**
```
Generate complete API documentation for this Fibonacci function:

def fibonacci(n):
    """Calculate fibonacci numbers up to n"""
    if n <= 0:
        return []
    elif n == 1:
        return [0]
    elif n == 2:
        return [0, 1]
    
    fib = [0, 1]
    for i in range(2, n):
        fib.append(fib[i-1] + fib[i-2])
    return fib

Include:
1. Detailed docstring with parameters, return value, and examples
2. Type hints
3. Usage examples
4. Time/space complexity analysis
5. Any potential improvements or alternative approaches
```

**Input Artifacts:** `test-data/sample-code/code-samples.py` (fibonacci function)

**Expected Output:**
- Enhanced docstring with parameter descriptions
- Proper type hints (typing.List[int])
- Multiple usage examples
- Complexity analysis (O(n) time, O(n) space)
- Discussion of alternative approaches (memoization, iterative)

**Validation Criteria:**
- [ ] Comprehensive docstring with all required sections
- [ ] Correct type hints
- [ ] Working usage examples
- [ ] Accurate complexity analysis
- [ ] Mentions alternative implementations

---

### QC-06: API Integration - REST API Client

**Description:** Test the model's ability to write code that integrates with external APIs.

**Prompt Text:**
```
Write a Python class that interacts with a REST API for user management. The class should:

1. Have methods for GET, POST, PUT, DELETE operations
2. Handle authentication with API keys
3. Include proper error handling and retries
4. Support JSON request/response data
5. Add logging for debugging
6. Include type hints and documentation

Base URL: https://api.example.com/v1/users
API Key should be passed in headers as 'X-API-Key'

Create a complete, production-ready implementation.
```

**Input Artifacts:** None (specification only)

**Expected Output:**
- Complete class with all CRUD operations
- Proper requests library usage
- Authentication header handling
- Comprehensive error handling (network, HTTP status, JSON parsing)
- Retry mechanism for failed requests
- Logging integration
- Type hints and docstrings

**Validation Criteria:**
- [ ] All HTTP methods implemented correctly
- [ ] Proper authentication handling
- [ ] Comprehensive error handling
- [ ] Retry logic for resilience
- [ ] Appropriate logging
- [ ] Type hints and documentation
- [ ] Production-ready code quality

---

## Evaluation Metrics

### Quantitative Metrics
- **Latency:** Response time in milliseconds
- **Token Usage:** Input tokens + output tokens
- **Throughput:** Tokens per second generation rate

### Qualitative Metrics

**Correctness (Pass/Fail):**
- Code executes without syntax errors
- Implements requirements correctly
- Handles specified edge cases
- Follows algorithmic specifications

**Completeness (Complete/Partial/Incomplete):**
- All requested components present
- Includes documentation when requested
- Covers error handling requirements
- Provides examples when appropriate

**Clarity (Clear/Unclear/Confusing):**
- Code is readable and well-structured
- Variable and function names are meaningful
- Logic flow is easy to follow
- Explanations are understandable

**Code Quality:**
- Follows Python conventions (PEP 8)
- Uses appropriate design patterns
- Efficient algorithm choices
- Proper separation of concerns

---

## Test Execution Commands

```bash
# QC-01: Binary Search Implementation
ollama run qwen2.5-coder:7b \
  --prompt "Implement a binary search function in Python that: 1. Takes a sorted list and target value as parameters 2. Returns the index of the target if found, -1 if not found 3. Uses the standard binary search algorithm (O(log n) complexity) 4. Includes proper error handling for edge cases 5. Add docstring with complexity analysis and examples. Please provide a complete, well-documented implementation." \
  --timeout 90 \
  > outputs/qc01_binary_search.out

# QC-02: Performance Optimization  
ollama run qwen2.5-coder:7b \
  --prompt "The following function has performance issues. Analyze the code and provide an optimized version: [INCLUDE slow_search function from code-samples.py]. Requirements: 1. Fix the performance issues 2. Explain what was wrong with the original code 3. Provide time complexity analysis for both versions 4. Ensure the function still returns all indices where target appears" \
  --timeout 90 \
  > outputs/qc02_optimization.out

# QC-03: Bug Fixing
ollama run qwen2.5-coder:7b \
  --prompt "This Stack class has several bugs. Find and fix all the issues: [INCLUDE BuggyStack class from code-samples.py]. Requirements: 1. Fix all bugs while maintaining proper stack behavior (LIFO) 2. Add appropriate error handling 3. Explain each bug you found 4. Add a simple test to demonstrate correct functionality" \
  --timeout 90 \
  > outputs/qc03_debugging.out

# QC-04: Code Review
ollama run qwen2.5-coder:7b \
  --prompt "Please review this function and provide suggestions for improvement: [INCLUDE undocumented_function from code-samples.py]. Provide: 1. Analysis of what the function does 2. Suggestions for better naming 3. Documentation improvements 4. Potential edge cases or bugs 5. Overall code quality assessment" \
  --timeout 90 \
  > outputs/qc04_code_review.out

# QC-05: Documentation Generation
ollama run qwen2.5-coder:7b \
  --prompt "Generate complete API documentation for this Fibonacci function: [INCLUDE fibonacci function from code-samples.py]. Include: 1. Detailed docstring with parameters, return value, and examples 2. Type hints 3. Usage examples 4. Time/space complexity analysis 5. Any potential improvements or alternative approaches" \
  --timeout 90 \
  > outputs/qc05_documentation.out

# QC-06: API Integration
ollama run qwen2.5-coder:7b \
  --prompt "Write a Python class that interacts with a REST API for user management. The class should: 1. Have methods for GET, POST, PUT, DELETE operations 2. Handle authentication with API keys 3. Include proper error handling and retries 4. Support JSON request/response data 5. Add logging for debugging 6. Include type hints and documentation. Base URL: https://api.example.com/v1/users. API Key should be passed in headers as 'X-API-Key'. Create a complete, production-ready implementation." \
  --timeout 120 \
  > outputs/qc06_api_integration.out
```
