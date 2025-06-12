#!/bin/bash

# Test Data Integrity Checker
# Verifies all test data files are accessible and extractions work

set -e

echo "🔍 COMPREHENSIVE TEST DATA INTEGRITY CHECK"
echo "=========================================="

# Function to test code extraction
test_extraction() {
    local description="$1"
    local file="$2"
    local pattern="$3"
    
    echo -n "Testing $description... "
    
    if [[ -f "$file" ]]; then
        local result=$(sed -n "$pattern" "$file")
        if [[ -n "$result" ]]; then
            echo "✅ SUCCESS"
            echo "   Preview: $(echo "$result" | head -1 | cut -c1-60)..."
        else
            echo "❌ FAILED - No content extracted"
            return 1
        fi
    else
        echo "❌ FAILED - File not found"
        return 1
    fi
    echo ""
}

# Function to test file access
test_file() {
    local description="$1"
    local file="$2"
    
    echo -n "Testing $description... "
    
    if [[ -f "$file" ]]; then
        local lines=$(wc -l < "$file")
        echo "✅ SUCCESS ($lines lines)"
    else
        echo "❌ FAILED - File not found: $file"
        return 1
    fi
}

echo ""
echo "📁 TESTING CODING TEST DATA FILES:"
echo "=================================="

# Test all coding test data extractions
test_extraction "CT-02 slow_search function" "test-data/sample-code/code-samples.py" '/def slow_search/,/return found_indices/p'
test_extraction "CT-03 BuggyStack class" "test-data/sample-code/code-samples.py" '/class BuggyStack/,/return len(self.items) > 0/p'
test_extraction "CT-04 undocumented_function" "test-data/sample-code/code-samples.py" '/def undocumented_function/,/return result/p'
test_extraction "CT-05 fibonacci function" "test-data/sample-code/code-samples.py" '/def fibonacci/,/return fib/p'

echo ""
echo "📊 TESTING DATA ANALYSIS TEST FILES:"
echo "==================================="

# Test all data analysis files
test_file "DT-01 Orders CSV" "test-data/sample-csv/orders.csv"
test_file "DT-02 Email correspondence" "test-data/sample-emails/order-correspondence.txt"
test_file "DT-03 Customers CSV" "test-data/sample-csv/customers.csv"
test_file "DT-03 Business updates" "test-data/sample-emails/business-updates.txt"
test_file "DT-03 Product specifications" "test-data/sample-pdf-text/product-specifications.txt"

echo ""
echo "🎯 SUMMARY:"
echo "==========="
echo "✅ All test data files are accessible"
echo "✅ All code extractions work correctly"
echo "✅ Framework is ready for testing"
echo ""
echo "🚀 The CT-03 and CT-04 issues have been FIXED!"
echo "   - CT-03 now correctly extracts BuggyStack class"
echo "   - CT-04 now correctly extracts undocumented_function"
echo ""
echo "You can now run clean tests with:"
echo "   ./scripts/interactive-test-runner.sh"
