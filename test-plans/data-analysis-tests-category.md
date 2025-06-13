# Test Plan: Data Analysis Tests Category
**Framework Version:** 2.0 - Interactive Model Selection  
**Category:** Data Processing & Business Intelligence  
**Test Count:** 6 tests  
**Suitable for:** Any data analysis or general-purpose language model

## Overview

This test category evaluates a model's ability to process, analyze, and correlate data from multiple sources including CSV files, emails, and documents. Tests focus on business intelligence, data validation, reporting, and pattern recognition. Tests are designed to be model-agnostic and can be run with any Ollama model.

## Test Cases

### DT-01: CSV Data Analysis
**Objective:** Assess structured data processing capabilities  
**Complexity:** Medium  
**Expected Duration:** 90-120 seconds

**Test Description:**
Analyze business orders CSV data and generate insights.

**Input:** Sample orders.csv with business transaction data  
**Requirements:**
- Summary statistics (total orders, revenue, average order value)
- Top 3 customers by order value
- Product performance analysis
- Geographic distribution of orders
- Order status breakdown
- Notable patterns or trends
- Format as structured business report

**Evaluation Criteria:**
- **Correctness (40%):** Accurate data extraction and calculations
- **Completeness (30%):** All required analysis components
- **Insight Quality (30%):** Business relevance and actionable insights

---

### DT-02: Email Thread Correlation
**Objective:** Test information extraction from unstructured text  
**Complexity:** Medium  
**Expected Duration:** 90-120 seconds

**Test Description:**
Extract and organize key information from email correspondence.

**Input:** Order-related email thread  
**Requirements:**
- Order details (ID, customer, products, quantities, prices)
- Timeline of communications
- Customer concerns or requests
- Resolution status
- Follow-up actions needed
- Customer satisfaction indicators
- Present as customer service summary

**Evaluation Criteria:**
- **Correctness (40%):** Accurate information extraction
- **Completeness (30%):** All relevant details captured
- **Insight Quality (30%):** Clear organization and actionable summary

---

### DT-03: Multi-source Data Fusion
**Objective:** Evaluate cross-source data integration skills  
**Complexity:** High  
**Expected Duration:** 150-180 seconds

**Test Description:**
Combine and analyze data from CSV, email, and document sources.

**Input:** Orders CSV, customers CSV, business emails, product specifications  
**Requirements:**
- Correlate customer data with order patterns
- Validate information consistency across sources
- Identify business performance trends
- Highlight discrepancies or issues
- Provide strategic recommendations
- Create executive summary dashboard
- Present as comprehensive business intelligence report

**Evaluation Criteria:**
- **Correctness (40%):** Accurate cross-source correlations
- **Completeness (30%):** Integration of all data sources
- **Insight Quality (30%):** Strategic business intelligence and recommendations

---

### DT-04: Data Validation
**Objective:** Test data quality assessment capabilities  
**Complexity:** Medium-High  
**Expected Duration:** 120-150 seconds

**Test Description:**
Perform comprehensive data quality audit across multiple datasets.

**Input:** Orders, customers, and email data  
**Requirements:**
- Data consistency between orders and customer records
- Email references that match or contradict CSV data
- Missing or incomplete information identification
- Potential data entry errors
- Conflicting information across sources
- Data quality scores and recommendations
- Detailed report with specific examples

**Evaluation Criteria:**
- **Correctness (40%):** Accurate identification of data issues
- **Completeness (30%):** Comprehensive audit coverage
- **Insight Quality (30%):** Practical validation recommendations

---

### DT-05: Executive Report Generation
**Objective:** Assess business communication and synthesis skills  
**Complexity:** High  
**Expected Duration:** 150-180 seconds

**Test Description:**
Create executive summary for quarterly business performance.

**Input:** All available business data sources  
**Requirements:**
- Key performance indicators (KPIs)
- Revenue and growth analysis
- Customer insights and segmentation
- Product performance highlights
- Market trends and opportunities
- Risk factors and challenges
- Strategic recommendations for next quarter
- Professional business document format for senior leadership

**Evaluation Criteria:**
- **Correctness (40%):** Accurate business analysis and metrics
- **Completeness (30%):** Executive-level coverage and presentation
- **Insight Quality (30%):** Strategic thinking and actionable recommendations

---

### DT-06: Pattern Recognition & Trend Analysis
**Objective:** Test analytical thinking and predictive insights  
**Complexity:** High  
**Expected Duration:** 150-180 seconds

**Test Description:**
Identify patterns, trends, and anomalies across all data sources.

**Input:** Complete dataset including transactions, customers, communications, and products  
**Requirements:**
- Customer behavior patterns and segments
- Product sales trends and correlations
- Seasonal or temporal patterns
- Geographic trends
- Communication pattern analysis
- Anomalies or outliers requiring attention
- Predictive insights for future planning
- Present findings with supporting evidence and confidence levels

**Evaluation Criteria:**
- **Correctness (40%):** Accurate pattern identification and analysis
- **Completeness (30%):** Comprehensive analytical coverage
- **Insight Quality (30%):** Predictive value and business relevance

## Success Criteria

### Overall Category Performance
- **Excellent (9.0-10.0):** Sophisticated data analysis with strategic business insights
- **Good (7.0-8.9):** Solid analysis with actionable recommendations
- **Acceptable (5.0-6.9):** Basic data processing with some insights
- **Poor (3.0-4.9):** Limited analysis with significant accuracy issues
- **Failed (0.0-2.9):** Inability to process or analyze data effectively

### Key Indicators
- Accurate data extraction and calculation
- Proper correlation across multiple sources
- Identification of meaningful patterns and trends
- Generation of actionable business insights
- Professional presentation and formatting
- Handling of inconsistent or missing data

## Test Data Sources

### Sample Files Used
- `test-data/sample-csv/orders.csv` - Business transaction data
- `test-data/sample-csv/customers.csv` - Customer profile information
- `test-data/sample-emails/order-correspondence.txt` - Customer service emails
- `test-data/sample-emails/business-updates.txt` - Internal communications
- `test-data/sample-pdf-text/product-specifications.txt` - Product documentation

### Data Characteristics
- Realistic business scenarios
- Multiple data formats (CSV, email, documents)
- Intentional inconsistencies for validation testing
- Cross-referential information for correlation analysis
- Sufficient complexity for meaningful analysis

## Test Execution

Use the Interactive Test Runner:
```bash
./scripts/run-tests.sh
```

Select any available model and choose "Data Analysis Tests" category.

## Model Suitability

**Recommended for models specialized in:**
- Data analysis and processing
- Business intelligence
- Text analysis and information extraction
- Cross-source data correlation
- Report generation and synthesis

**Example compatible models:**
- mistral-nemo:12b
- llama3:70b
- claude-3-haiku (via API)
- Any general-purpose model with analytical capabilities

## Business Context

These tests simulate real-world business intelligence scenarios:
- **E-commerce Analysis:** Order processing and customer insights
- **Customer Service:** Email analysis and issue tracking
- **Executive Reporting:** Strategic business summaries
- **Data Quality:** Validation and consistency checking
- **Predictive Analysis:** Trend identification and forecasting

---

*Generated: June 11, 2025*  
*Framework: Ollama Interactive Testing v2.0*
