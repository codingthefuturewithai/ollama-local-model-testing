# Ollama Interactive Testing Framework - Evaluation Methodology

## Overview

This document defines the standardized methodology for LLM-based qualitative evaluation of Ollama model outputs. It ensures consistent, repeatable, and objective quality assessments across any model and test category.

**Important Note:** This methodology is for **qualitative assessment only**. The automated analysis script (`analyze-results.sh`) handles quantitative metrics (timing, tokens/sec, etc.) automatically.

## Evaluation Process

### Step 1: Preparation
1. Ensure test outputs are available in `outputs/` directory
2. Review test specifications in `test-plans/` to understand requirements
3. Identify test run timestamp for evaluation

### Step 2: LLM-Based Systematic Review
For each test output, an evaluating LLM must:
1. **Read Original Task** - From the test prompt and requirements
2. **Read Model Response** - From the corresponding output file
3. **Apply Scoring Criteria** - Using the standardized rubrics below
4. **Document Assessment** - Using the standard format

## Scoring Criteria

### For Coding Tests (CT-01 to CT-06)

**Correctness (0-10 points)**
- 10: Perfect implementation, algorithm is correct, handles all edge cases
- 8-9: Mostly correct, minor issues or missing 1-2 edge cases
- 6-7: Generally correct approach, some logical errors
- 4-5: Partially correct, significant issues but core logic present
- 1-3: Major errors, incorrect approach
- 0: Completely wrong or no meaningful code

**Completeness (0-10 points)**
- 10: All requested components present (code, docs, examples, tests, complexity analysis)
- 8-9: Most components present, missing 1 minor element
- 6-7: Core components present, missing some documentation or examples
- 4-5: Basic functionality present, significant gaps in requirements
- 1-3: Minimal compliance with requirements
- 0: Does not address the request

**Code Quality (0-10 points)**
- 10: Excellent style, clear naming, proper structure, follows best practices
- 8-9: Good style, minor improvements possible
- 6-7: Acceptable style, some inconsistencies
- 4-5: Poor style but readable
- 1-3: Very poor style, hard to read
- 0: Unreadable or no code provided

### For Data Analysis Tests (DT-01 to DT-06)

**Correctness (0-10 points)**
- 10: All data extracted/analyzed accurately, no factual errors
- 8-9: Mostly accurate, 1-2 minor data errors
- 6-7: Generally accurate, some interpretation issues
- 4-5: Partially accurate, several errors but core analysis correct
- 1-3: Major errors in data interpretation
- 0: Completely incorrect data analysis

**Completeness (0-10 points)**
- 10: Addresses all aspects of the request thoroughly
- 8-9: Addresses most aspects, minor gaps
- 6-7: Addresses core request, some elements missing
- 4-5: Partial response, significant gaps
- 1-3: Minimal response to request
- 0: Does not address the request

**Insight Quality (0-10 points)**
- 10: Exceptional insights, actionable recommendations, clear business value
- 8-9: Good insights with practical value
- 6-7: Some useful insights, generally helpful
- 4-5: Basic insights, limited value
- 1-3: Poor insights, little practical value
- 0: No meaningful insights provided

## Overall Scoring

**Overall Score Calculation:**
- Coding Tests: (Correctness × 0.4) + (Completeness × 0.3) + (Code Quality × 0.3)
- Data Tests: (Correctness × 0.4) + (Completeness × 0.3) + (Insight Quality × 0.3)

**Quality Ratings:**
- 9.0-10.0: EXCELLENT - Exceptional quality, ready for production use
- 7.0-8.9: GOOD - High quality with minor improvements possible
- 5.0-6.9: ACCEPTABLE - Meets basic requirements, notable limitations
- 3.0-4.9: POOR - Significant issues, requires major improvements
- 0.0-2.9: FAILED - Does not meet requirements

## Standard Evaluation Format

For each test, an evaluating LLM should document using this template:

```
TEST ID: [test_id] ([Test Name])
MODEL: [model_name]
TASK: [Brief description of what was requested]

EVALUATION:
Correctness: [score]/10 - [Detailed explanation]
Completeness: [score]/10 - [Detailed explanation]  
[Code Quality/Insight Quality]: [score]/10 - [Detailed explanation]

OVERALL SCORE: [calculated_score]/10
QUALITY RATING: [EXCELLENT/GOOD/ACCEPTABLE/POOR/FAILED]

DETAILED ASSESSMENT:
[Specific observations about the response]

STRENGTHS:
- [Specific positive aspects]

WEAKNESSES:
- [Specific areas for improvement]

VERDICT: [One-sentence summary]
```

## Test Case Specifications

### Coding Tests (CT-01 to CT-06)

**CT-01: Binary Search Implementation**
- Required: Function implementation, O(log n) complexity, documentation, examples
- Key evaluation points: Algorithm correctness, edge case handling, code style

**CT-02: Performance Optimization**
- Required: Analysis of provided code, specific optimizations, performance impact estimates
- Key evaluation points: Accuracy of analysis, practicality of suggestions

**CT-03: Bug Fixing**
- Required: Identification of all bugs, correct fixes, explanation of issues
- Key evaluation points: Complete bug identification, correct solutions

**CT-04: Code Review**
- Required: Comprehensive analysis, security/performance/style issues, improvement suggestions
- Key evaluation points: Thoroughness, accuracy of observations

**CT-05: Documentation Generation**
- Required: Complete API documentation, usage examples, formatting
- Key evaluation points: Completeness, clarity, professional presentation

**CT-06: API Integration**
- Required: Working code, error handling, documentation, examples
- Key evaluation points: Functionality, robustness, usability

### Data Analysis Tests (DT-01 to DT-06)

**DT-01: CSV Data Analysis**
- Required: Statistical summary, customer analysis, product performance, insights
- Key evaluation points: Data accuracy, analysis depth, business relevance

**DT-02: Email Thread Correlation**
- Required: Order identification, timeline construction, issue correlation
- Key evaluation points: Information extraction accuracy, logical connections

**DT-03: Multi-source Data Fusion**
- Required: Cross-reference data sources, identify relationships, synthesize insights
- Key evaluation points: Integration accuracy, insight quality

**DT-04: Data Validation**
- Required: Identify inconsistencies, validate data quality, recommend fixes
- Key evaluation points: Issue identification accuracy, solution practicality

**DT-05: Executive Report Generation**
- Required: Professional summary, key metrics, strategic insights, formatting
- Key evaluation points: Business relevance, presentation quality

**DT-06: Pattern Recognition**
- Required: Identify trends, behavioral patterns, predictive insights
- Key evaluation points: Pattern accuracy, insight depth, actionability

## Quality Assurance

### Consistency Checks
- Compare similar tasks across test runs
- Verify scoring aligns with examples
- Document any edge cases or unusual responses

### Bias Mitigation
- Evaluate based on objective criteria, not subjective preferences
- Consider the model's intended use case
- Focus on functional requirements over style preferences

### Documentation Requirements
- Include specific examples to support scores
- Explain reasoning for borderline cases
- Note any assumptions made during evaluation

## Reporting

### Individual Test Reports
Generate individual assessments for each test using the standard format.

### Comparative Analysis
- Model-specific performance summaries
- Strength/weakness analysis by domain
- Performance trends across test categories
- Recommendations for use cases

### Final Summary
- Overall model performance assessment
- Best-fit scenarios for tested models
- Areas for improvement
- Confidence levels in assessments

## LLM Evaluation Instructions

When using an LLM to evaluate test outputs, provide these explicit instructions:

**Context Setup:**
```
You are evaluating the output of an Ollama language model against a specific test case. 
Use the standardized scoring criteria below to ensure consistent assessment.

Test Details:
- Test ID: [test_id]
- Test Category: [coding/data]
- Model Tested: [model_name]
- Original Prompt: [full_prompt_text]
- Model Output: [full_output_text]
```

**Evaluation Instructions:**
```
Evaluate this output using exactly these criteria:

For Coding Tests (CT-01 to CT-06):
1. Correctness (0-10): [criteria from above]
2. Completeness (0-10): [criteria from above]  
3. Code Quality (0-10): [criteria from above]

For Data Tests (DT-01 to DT-06):
1. Correctness (0-10): [criteria from above]
2. Completeness (0-10): [criteria from above]
3. Insight Quality (0-10): [criteria from above]

Provide your assessment in the Standard Evaluation Format.
Calculate the overall score using the specified weightings.
Be specific about strengths and weaknesses with examples.
```

## Framework Integration

**Automated Analysis Script:**
- Handles quantitative metrics (timing, tokens/sec, etc.)
- Generates analysis reports with performance data
- Cannot assess qualitative aspects

**Manual LLM Evaluation:**
- Uses this methodology for consistent qualitative assessment
- Requires evaluating LLM to see both inputs and outputs
- Produces standardized quality scores and recommendations

**Combined Reporting:**
- Quantitative metrics from automated analysis
- Qualitative scores from LLM evaluation
- Comprehensive model assessment

## Revision History

- v2.0 (2025-06-11): Updated for Interactive Testing Framework - model-agnostic with CT-*/DT-* naming
- v1.0 (2025-06-11): Initial methodology established

---

*This methodology ensures consistent, objective evaluation of model outputs while maintaining the flexibility to assess diverse task types appropriately.*
