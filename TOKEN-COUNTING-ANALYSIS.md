# Token Counting Implementation Analysis

**Date:** June 12, 2025  
**Status:** Analysis Complete - Awaiting Approval for Implementation

## Overview

This document outlines the plan to fix misleading "token" terminology in the framework and implement proper token counting using tiktoken during the analysis phase.

## Current State Issues

- `run-tests.sh` uses `wc -w` (word count) but calls it "token_count" (misleading)
- Variables named `*_token_count` but contain word counts
- JSON output has "token_count" fields that are actually word counts
- `tokens_per_second` metric is actually words per second
- Users expect actual token counts for performance analysis

## Implementation Strategy

**Approach:** Option 2 - Post-processing token counting
- Keep simple word counting during test execution (fast)
- Add proper token counting during analysis phase (accurate)
- Use tiktoken library with `cl100k_base` encoding (GPT-4 tokenizer as universal approximation)
- Maintain backward compatibility

## Required Changes

### 1. Fix run-tests.sh Terminology (6 locations)

**Variables to rename:**
- `output_token_count` → `output_word_count`
- `input_token_count` → `input_word_count` 
- `total_tokens` → `total_words`
- `tokens_per_second` → `words_per_second`

**JSON fields to rename:**
- `"token_count"` → `"word_count"` (2 places: input and output sections)
- `"tokens_per_second"` → `"words_per_second"`

### 2. Add tiktoken dependency
- Add `tiktoken>=0.7.0` to `requirements.txt`

### 3. Create token counting script
- **New file:** `scripts/count_tokens.py`
- Use tiktoken with `cl100k_base` encoding
- Handle both text input and file input
- Command-line interface for integration

### 4. Modify analyze-results.sh 
- Add post-processing step to calculate actual tokens
- Read existing JSON files, add new token fields alongside word fields
- Generate enhanced analysis with both word and token metrics
- Support retroactive analysis of existing result files

### 5. Update analysis output format
- Keep existing word counts for backward compatibility
- Add new accurate token counts as separate fields
- Reports show both metrics clearly labeled:
  - "Word Count" vs "Token Count"
  - "Words per Second" vs "Tokens per Second"

## Files That Need Changes

1. **`scripts/run-tests.sh`** - Fix 6 misleading variable/field names
2. **`requirements.txt`** - Add tiktoken dependency  
3. **`scripts/count_tokens.py`** - New file for accurate token counting
4. **`scripts/analyze-results.sh`** - Add token analysis post-processing
5. **Existing result JSON files** - Can be retroactively enhanced

## Benefits

- ✅ Test execution stays fast (no tokenization during runs)
- ✅ Honest labeling of what's actually being measured during execution
- ✅ Accurate token metrics available during analysis
- ✅ Backward compatibility maintained
- ✅ Can retroactively analyze existing test results
- ✅ Clear separation of concerns (execution vs analysis)

## Implementation Order

1. Fix misleading terminology in `run-tests.sh`
2. Add tiktoken to `requirements.txt`
3. Create `count_tokens.py` script
4. Modify `analyze-results.sh` to add token counting
5. Test with existing result files
6. Update documentation

## Notes

- Using `cl100k_base` encoding provides reasonable token approximation across different models
- Word counts remain useful for relative performance comparisons
- Token counts provide more accurate cost/performance analysis
- Implementation maintains zero-dependency test execution while adding optional enhanced analysis

---

**Next Steps:** Awaiting approval to proceed with implementation.
