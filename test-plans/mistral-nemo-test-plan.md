# Test Plan: mistral-nemo:12b (Data Processing & Correlation)

## Test Plan Summary

- **Model Name & Version:** mistral-nemo:12b
- **Primary Use Case:** Ingesting and correlating heterogeneous data from multiple sources (CSV, emails, PDF text, spreadsheets)
- **Key Success Criteria:**
  - Accurately extracts relevant information from different data formats
  - Correctly correlates related data across multiple sources
  - Identifies patterns, trends, and relationships in complex datasets
  - Produces structured, actionable output in requested formats
  - Handles incomplete, inconsistent, or conflicting data gracefully
  - Provides insights that would require manual analysis to discover

---

## Test Cases

### MN-01: CSV Data Analysis - Sales Performance

**Description:** Test the model's ability to analyze structured CSV data and extract meaningful business insights.

**Prompt Text:**
```
Analyze the following orders CSV data and provide insights:

[INCLUDE orders.csv content]

Please provide:
1. Summary statistics (total orders, revenue, average order value)
2. Top 3 customers by order value
3. Product performance analysis
4. Geographic distribution of orders
5. Order status breakdown
6. Any notable patterns or trends you observe

Format your response as a structured business report.
```

**Input Artifacts:** `test-data/sample-csv/orders.csv`

**Expected Output Schema:**
```json
{
  "summary_statistics": {
    "total_orders": "number",
    "total_revenue": "number", 
    "average_order_value": "number"
  },
  "top_customers": ["array of customer objects"],
  "product_analysis": ["array of product performance"],
  "geographic_insights": "object",
  "status_breakdown": "object",
  "trends_identified": ["array of strings"]
}
```

**Validation Criteria:**
- [ ] Correctly calculates numerical summaries
- [ ] Identifies top customers accurately
- [ ] Analyzes product performance correctly
- [ ] Provides geographic insights
- [ ] Identifies meaningful patterns

---

### MN-02: Email Thread Correlation - Customer Support

**Description:** Test the model's ability to extract and correlate information from email conversations.

**Prompt Text:**
```
Analyze this email thread and extract key information:

[INCLUDE order-correspondence.txt content]

Extract and organize:
1. Order details (ID, customer, products, quantities, prices)
2. Timeline of communications
3. Customer concerns or requests
4. Resolution status
5. Follow-up actions needed
6. Customer satisfaction indicators

Present the analysis in a customer service summary format.
```

**Input Artifacts:** `test-data/sample-emails/order-correspondence.txt`

**Expected Output Schema:**
```json
{
  "order_details": {
    "order_id": "string",
    "customer": "object",
    "products": ["array"],
    "total_value": "number"
  },
  "communication_timeline": ["array of interactions"],
  "customer_concerns": ["array of strings"],
  "resolution_status": "string",
  "follow_up_actions": ["array of strings"],
  "satisfaction_indicators": "object"
}
```

**Validation Criteria:**
- [ ] Correctly extracts order information
- [ ] Identifies timeline sequence
- [ ] Recognizes customer concerns
- [ ] Assesses resolution status
- [ ] Suggests appropriate follow-ups

---

### MN-03: Multi-source Data Fusion - Business Intelligence

**Description:** Test the model's ability to combine and correlate data from CSV, email, and PDF sources.

**Prompt Text:**
```
Combine and analyze data from these three sources to create a comprehensive business intelligence report:

CSV DATA:
[INCLUDE orders.csv AND customers.csv content]

EMAIL DATA:
[INCLUDE business-updates.txt content]

PRODUCT SPECIFICATIONS:
[INCLUDE product-specifications.txt content]

Create a unified analysis that:
1. Correlates customer data with order patterns
2. Validates information consistency across sources
3. Identifies business performance trends
4. Highlights any discrepancies or issues
5. Provides strategic recommendations
6. Creates a executive summary dashboard

Present as a comprehensive business intelligence report.
```

**Input Artifacts:** 
- `test-data/sample-csv/orders.csv`
- `test-data/sample-csv/customers.csv` 
- `test-data/sample-emails/business-updates.txt`
- `test-data/sample-pdf-text/product-specifications.txt`

**Expected Output Schema:**
```json
{
  "executive_summary": "string",
  "customer_analysis": "object",
  "product_performance": "object", 
  "trend_analysis": "object",
  "data_discrepancies": ["array"],
  "strategic_recommendations": ["array"],
  "key_metrics_dashboard": "object"
}
```

**Validation Criteria:**
- [ ] Successfully correlates data across all sources
- [ ] Identifies data consistency/inconsistency
- [ ] Provides actionable insights
- [ ] Creates coherent executive summary
- [ ] Offers strategic recommendations

---

### MN-04: Data Validation - Consistency Check

**Description:** Test the model's ability to identify data quality issues and inconsistencies across sources.

**Prompt Text:**
```
Perform a data quality audit across these datasets and identify any inconsistencies, errors, or missing information:

ORDERS DATA:
[INCLUDE orders.csv content]

CUSTOMER DATA:  
[INCLUDE customers.csv content]

EMAIL REFERENCES:
[INCLUDE order-correspondence.txt AND business-updates.txt content]

Check for:
1. Data consistency between orders and customer records
2. Email references that match or contradict CSV data
3. Missing or incomplete information
4. Potential data entry errors
5. Conflicting information across sources
6. Data quality scores and recommendations

Provide a detailed data quality report with specific examples.
```

**Input Artifacts:**
- `test-data/sample-csv/orders.csv`
- `test-data/sample-csv/customers.csv`
- `test-data/sample-emails/order-correspondence.txt`
- `test-data/sample-emails/business-updates.txt`

**Expected Output Schema:**
```json
{
  "data_quality_score": "number (0-100)",
  "consistency_issues": ["array of specific issues"],
  "missing_data": ["array of gaps identified"],
  "potential_errors": ["array of suspected errors"],
  "cross_reference_validation": "object",
  "recommendations": ["array of improvement suggestions"]
}
```

**Validation Criteria:**
- [ ] Identifies actual data inconsistencies
- [ ] Correctly cross-references information
- [ ] Provides specific examples of issues
- [ ] Offers actionable recommendations
- [ ] Assigns reasonable quality scores

---

### MN-05: Report Generation - Executive Summary

**Description:** Test the model's ability to create structured business reports from complex multi-source data.

**Prompt Text:**
```
Create an executive summary report for TechStore's Q1 2024 performance using all available data:

SALES DATA:
[INCLUDE orders.csv content]

CUSTOMER PROFILES:
[INCLUDE customers.csv content]

BUSINESS UPDATES:
[INCLUDE business-updates.txt content]

PRODUCT INFORMATION:
[INCLUDE product-specifications.txt content]

Generate a professional executive summary that includes:
1. Key performance indicators (KPIs)
2. Revenue and growth analysis
3. Customer insights and segmentation
4. Product performance highlights
5. Market trends and opportunities
6. Risk factors and challenges
7. Strategic recommendations for Q2

Format as a professional business document suitable for senior leadership.
```

**Input Artifacts:** All sample data files

**Expected Output Schema:**
```json
{
  "executive_summary": "string",
  "key_metrics": {
    "revenue": "number",
    "growth_rate": "number",
    "customer_count": "number",
    "average_order_value": "number"
  },
  "customer_insights": "object",
  "product_highlights": ["array"],
  "market_opportunities": ["array"],
  "risk_factors": ["array"],
  "q2_recommendations": ["array"]
}
```

**Validation Criteria:**
- [ ] Synthesizes information from all sources
- [ ] Provides accurate KPIs
- [ ] Offers strategic insights
- [ ] Maintains professional tone
- [ ] Includes actionable recommendations

---

### MN-06: Pattern Recognition - Trend Analysis

**Description:** Test the model's ability to identify patterns, trends, and anomalies across heterogeneous data.

**Prompt Text:**
```
Analyze all available data to identify patterns, trends, and anomalies:

TRANSACTION DATA:
[INCLUDE orders.csv content]

CUSTOMER BEHAVIOR:
[INCLUDE customers.csv content]

COMMUNICATION PATTERNS:
[INCLUDE all email files content]

PRODUCT PERFORMANCE:
[INCLUDE product-specifications.txt content]

Identify:
1. Customer behavior patterns and segments
2. Product sales trends and correlations
3. Seasonal or temporal patterns
4. Geographic trends
5. Communication pattern analysis
6. Anomalies or outliers that require attention
7. Predictive insights for future planning

Present findings with supporting evidence and confidence levels.
```

**Input Artifacts:** All sample data files

**Expected Output Schema:**
```json
{
  "customer_patterns": ["array of behavioral patterns"],
  "product_trends": ["array of sales trends"],
  "temporal_analysis": "object",
  "geographic_patterns": "object", 
  "communication_insights": "object",
  "anomalies_detected": ["array of outliers"],
  "predictive_insights": ["array with confidence levels"],
  "supporting_evidence": "object"
}
```

**Validation Criteria:**
- [ ] Identifies genuine patterns in data
- [ ] Provides supporting evidence
- [ ] Recognizes meaningful anomalies
- [ ] Offers predictive insights
- [ ] Assigns appropriate confidence levels

---

## Evaluation Metrics

### Quantitative Metrics
- **Latency:** Response time in milliseconds
- **Token Usage:** Input tokens + output tokens  
- **Throughput:** Tokens per second generation rate

### Qualitative Metrics

**Correctness (Pass/Fail):**
- Accurately extracts data from source materials
- Correctly performs calculations and analysis
- Provides factually accurate correlations
- Identifies real patterns vs. false patterns

**Completeness (Complete/Partial/Incomplete):**
- Addresses all requested analysis points
- Includes data from all provided sources
- Covers specified output format requirements
- Provides comprehensive insights

**Clarity (Clear/Unclear/Confusing):**
- Presents findings in organized, logical structure
- Uses appropriate business language
- Provides clear explanations of analysis methods
- Makes insights actionable and understandable

**Data Handling Quality:**
- Manages inconsistent or incomplete data appropriately
- Recognizes data quality issues
- Provides confidence levels for uncertain conclusions
- Suggests data collection improvements

---

## Test Execution Commands

```bash
# MN-01: CSV Data Analysis
ollama run mistral-nemo:12b \
  --prompt "Analyze the following orders CSV data and provide insights: [INCLUDE orders.csv content]. Please provide: 1. Summary statistics 2. Top 3 customers by order value 3. Product performance analysis 4. Geographic distribution 5. Order status breakdown 6. Notable patterns. Format as structured business report." \
  --timeout 120 \
  > outputs/mn01_csv_analysis.out

# MN-02: Email Thread Correlation  
ollama run mistral-nemo:12b \
  --prompt "Analyze this email thread and extract key information: [INCLUDE order-correspondence.txt]. Extract: 1. Order details 2. Timeline 3. Customer concerns 4. Resolution status 5. Follow-up actions 6. Satisfaction indicators. Present as customer service summary." \
  --timeout 120 \
  > outputs/mn02_email_correlation.out

# MN-03: Multi-source Data Fusion
ollama run mistral-nemo:12b \
  --prompt "Combine and analyze data from CSV, email, and PDF sources: [INCLUDE all relevant files]. Create unified analysis with: 1. Customer-order correlations 2. Data consistency validation 3. Performance trends 4. Discrepancy highlights 5. Strategic recommendations 6. Executive dashboard." \
  --timeout 180 \
  > outputs/mn03_data_fusion.out

# MN-04: Data Validation
ollama run mistral-nemo:12b \
  --prompt "Perform data quality audit: [INCLUDE orders.csv, customers.csv, email files]. Check for: 1. Data consistency 2. Email-CSV matches 3. Missing information 4. Data entry errors 5. Conflicting information 6. Quality scores. Provide detailed report with examples." \
  --timeout 150 \
  > outputs/mn04_data_validation.out

# MN-05: Report Generation
ollama run mistral-nemo:12b \
  --prompt "Create executive summary for TechStore Q1 2024: [INCLUDE all data files]. Generate: 1. KPIs 2. Revenue analysis 3. Customer insights 4. Product highlights 5. Market trends 6. Risk factors 7. Q2 recommendations. Format for senior leadership." \
  --timeout 180 \
  > outputs/mn05_executive_report.out

# MN-06: Pattern Recognition  
ollama run mistral-nemo:12b \
  --prompt "Analyze all data for patterns and trends: [INCLUDE all files]. Identify: 1. Customer behavior patterns 2. Product trends 3. Temporal patterns 4. Geographic trends 5. Communication patterns 6. Anomalies 7. Predictive insights. Include evidence and confidence levels." \
  --timeout 180 \
  > outputs/mn06_pattern_analysis.out
```
