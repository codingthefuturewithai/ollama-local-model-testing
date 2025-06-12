#!/usr/bin/env python3
"""
Qualitative Evaluator for Ollama Model Testing Framework

This script uses Google Gemini 2.5 Flash Preview via LangChain to automatically 
evaluate test outputs against the scoring rubrics defined in EVALUATION-METHODOLOGY.md.

The script provides structured qualitative scores (0-10 points) for:
- Correctness (accuracy, factual validity)
- Completeness (thoroughness, addressing all aspects)
- Code Quality/Insight Quality (depending on test type)

Cost: ~$0.003 per evaluation (~$0.036 for full 12-test suite)
"""

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from dotenv import load_dotenv
from langchain_core.messages import HumanMessage
from langchain_google_genai import ChatGoogleGenerativeAI

# Load environment variables
load_dotenv()

class QualitativeEvaluator:
    """Automated qualitative evaluation using Gemini 2.5 Flash Preview"""
    
    def __init__(self, api_key: Optional[str] = None):
        """Initialize the evaluator with Gemini model"""
        api_key = api_key or os.getenv('GOOGLE_API_KEY')
        if not api_key:
            raise ValueError(
                "Google API key required. Set GOOGLE_API_KEY environment variable "
                "or pass api_key parameter."
            )
        
        # Initialize Gemini 2.5 Flash Preview with thinking budget for reasoning
        self.llm = ChatGoogleGenerativeAI(
            model="models/gemini-2.5-flash-preview-04-17",
            google_api_key=api_key,
            thinking_budget=1024,  # Enable "adaptive thinking" for better evaluation
            temperature=0.1  # Low temperature for consistent scoring
        )
        
        # Load evaluation methodology
        self.evaluation_criteria = self._load_evaluation_methodology()
    
    def _load_evaluation_methodology(self) -> str:
        """Load the evaluation methodology from EVALUATION-METHODOLOGY.md"""
        try:
            methodology_path = Path(__file__).parent.parent / "EVALUATION-METHODOLOGY.md"
            with open(methodology_path, 'r', encoding='utf-8') as f:
                return f.read()
        except FileNotFoundError:
            raise FileNotFoundError(
                "EVALUATION-METHODOLOGY.md not found. Ensure it exists in the project root."
            )
    
    def _create_evaluation_prompt(self, test_info: Dict, output_content: str) -> str:
        """Create a structured evaluation prompt for the LLM"""
        
        prompt = f"""You are an expert evaluator tasked with providing objective qualitative assessment of model outputs. 

EVALUATION METHODOLOGY:
{self.evaluation_criteria}

TEST DETAILS:
- Test Type: {test_info.get('test_type', 'Unknown')}
- Model: {test_info.get('model', 'Unknown')}
- Prompt: {test_info.get('prompt', 'Not available')}
- Expected Focus: {test_info.get('description', 'General evaluation')}

MODEL OUTPUT TO EVALUATE:
{output_content}

TASK:
Evaluate this output according to the methodology above. Provide scores (0-10) for each criterion and detailed reasoning.

REQUIRED RESPONSE FORMAT (JSON):
{{
    "correctness": {{
        "score": <0-10>,
        "reasoning": "Detailed explanation of accuracy, factual validity, logical consistency"
    }},
    "completeness": {{
        "score": <0-10>,
        "reasoning": "Detailed explanation of thoroughness, addressing all aspects of the query"
    }},
    "quality": {{
        "score": <0-10>,
        "reasoning": "Detailed explanation of code quality (for coding tasks) or insight quality (for analysis tasks)"
    }},
    "overall_assessment": "Brief summary of strengths and weaknesses",
    "confidence": <0-10>
}}

Ensure scores are integers from 0-10. Be objective and consistent with the rubric. Consider the specific test type when evaluating."""
        
        return prompt
    
    def evaluate_output(self, test_info: Dict, output_content: str) -> Dict:
        """Evaluate a single test output"""
        try:
            prompt = self._create_evaluation_prompt(test_info, output_content)
            
            # Create message for the LLM
            message = HumanMessage(content=prompt)
            
            # Get evaluation from Gemini
            response = self.llm.invoke([message])
            
            # Extract and parse JSON response
            response_text = response.content.strip()
            
            # Try to extract JSON from the response
            try:
                # Look for JSON block
                if '```json' in response_text:
                    json_start = response_text.find('```json') + 7
                    json_end = response_text.find('```', json_start)
                    json_text = response_text[json_start:json_end].strip()
                elif '{' in response_text and '}' in response_text:
                    # Find the JSON object
                    json_start = response_text.find('{')
                    json_end = response_text.rfind('}') + 1
                    json_text = response_text[json_start:json_end]
                else:
                    raise ValueError("No JSON found in response")
                
                evaluation = json.loads(json_text)
                
                # Validate required fields
                required_fields = ['correctness', 'completeness', 'quality']
                for field in required_fields:
                    if field not in evaluation:
                        raise ValueError(f"Missing required field: {field}")
                    if 'score' not in evaluation[field]:
                        raise ValueError(f"Missing score in {field}")
                
                # Add metadata
                evaluation['_metadata'] = {
                    'evaluator': 'gemini-2.5-flash-preview',
                    'model_tested': test_info.get('model', 'Unknown'),
                    'test_type': test_info.get('test_type', 'Unknown'),
                    'raw_response': response_text
                }
                
                return evaluation
                
            except (json.JSONDecodeError, ValueError) as e:
                print(f"Warning: Failed to parse LLM response as JSON: {e}")
                print(f"Raw response: {response_text[:500]}...")
                
                # Return a fallback evaluation
                return {
                    'correctness': {'score': 5, 'reasoning': 'Evaluation failed - unable to parse LLM response'},
                    'completeness': {'score': 5, 'reasoning': 'Evaluation failed - unable to parse LLM response'},
                    'quality': {'score': 5, 'reasoning': 'Evaluation failed - unable to parse LLM response'},
                    'overall_assessment': 'Evaluation failed due to response parsing error',
                    'confidence': 0,
                    '_metadata': {
                        'evaluator': 'gemini-2.5-flash-preview',
                        'model_tested': test_info.get('model', 'Unknown'),
                        'test_type': test_info.get('test_type', 'Unknown'),
                        'error': str(e),
                        'raw_response': response_text
                    }
                }
        
        except Exception as e:
            print(f"Error during evaluation: {e}")
            return {
                'correctness': {'score': 0, 'reasoning': f'Evaluation failed: {str(e)}'},
                'completeness': {'score': 0, 'reasoning': f'Evaluation failed: {str(e)}'},
                'quality': {'score': 0, 'reasoning': f'Evaluation failed: {str(e)}'},
                'overall_assessment': f'Evaluation failed due to error: {str(e)}',
                'confidence': 0,
                '_metadata': {
                    'evaluator': 'gemini-2.5-flash-preview',
                    'model_tested': test_info.get('model', 'Unknown'),
                    'test_type': test_info.get('test_type', 'Unknown'),
                    'error': str(e)
                }
            }
    
    def evaluate_test_results(self, results_file: str) -> Dict:
        """Evaluate all test results in a results file"""
        # Load the results file
        with open(results_file, 'r', encoding='utf-8') as f:
            results_data = json.load(f)
        
        # Initialize qualitative results structure
        qualitative_results = {
            'test_session': results_data.get('test_session', {}),
            'quantitative_summary': results_data.get('summary', {}),
            'qualitative_evaluations': {},
            'qualitative_summary': {
                'avg_correctness': 0.0,
                'avg_completeness': 0.0,
                'avg_quality': 0.0,
                'total_tests_evaluated': 0
            }
        }
        
        total_correctness = 0
        total_completeness = 0
        total_quality = 0
        evaluated_count = 0
        
        # Check if this is a consolidated file with multiple results or a single test file
        if 'results' in results_data:
            # Consolidated format: multiple tests
            for test_name, test_data in results_data.get('results', {}).items():
                print(f"Evaluating {test_name}...")
                
                # Extract test information
                test_info = {
                    'test_type': test_data.get('test_config', {}).get('type', 'Unknown'),
                    'model': test_data.get('model', 'Unknown'),
                    'prompt': test_data.get('test_config', {}).get('prompt', 'Not available'),
                    'description': test_data.get('test_config', {}).get('description', '')
                }
                
                # Get the output content
                output_content = test_data.get('output', '')
                
                if not output_content:
                    print(f"Warning: No output found for {test_name}")
                    continue
                
                # Evaluate this test
                evaluation = self.evaluate_output(test_info, output_content)
                
                # Store the evaluation
                qualitative_results['qualitative_evaluations'][test_name] = evaluation
                
                # Update running totals
                total_correctness += evaluation['correctness']['score']
                total_completeness += evaluation['completeness']['score']
                total_quality += evaluation['quality']['score']
                evaluated_count += 1
        else:
            # Single test file format
            test_id = results_data.get('test_case', {}).get('id', 'unknown')
            print(f"Evaluating {test_id}...")
            
            # Extract test information from single test format
            test_info = {
                'test_type': results_data.get('test_case', {}).get('category', 'Unknown'),
                'model': results_data.get('model', {}).get('name', 'Unknown'),
                'prompt': results_data.get('input', {}).get('prompt', 'Not available'),
                'description': results_data.get('test_case', {}).get('description', '')
            }
            
            # Get the output content
            output_content = results_data.get('output', {}).get('content', '')
            
            if not output_content:
                print(f"Warning: No output found for {test_id}")
            else:
                # Evaluate this test
                evaluation = self.evaluate_output(test_info, output_content)
                
                # Store the evaluation
                qualitative_results['qualitative_evaluations'][test_id] = evaluation
                
                # Update running totals
                total_correctness += evaluation['correctness']['score']
                total_completeness += evaluation['completeness']['score']
                total_quality += evaluation['quality']['score']
                evaluated_count += 1
        
        # Calculate averages
        if evaluated_count > 0:
            qualitative_results['qualitative_summary'] = {
                'avg_correctness': round(total_correctness / evaluated_count, 2),
                'avg_completeness': round(total_completeness / evaluated_count, 2),
                'avg_quality': round(total_quality / evaluated_count, 2),
                'total_tests_evaluated': evaluated_count
            }
        
        return qualitative_results


def main():
    """Main function for command-line usage"""
    parser = argparse.ArgumentParser(description='Evaluate test outputs qualitatively using Gemini 2.5 Flash Preview')
    parser.add_argument('results_file', help='Path to the test results JSON file')
    parser.add_argument('--output', '-o', help='Output file for qualitative evaluation results')
    parser.add_argument('--api-key', help='Google API key (or use GOOGLE_API_KEY env var)')
    
    args = parser.parse_args()
    
    # Validate input file
    if not os.path.exists(args.results_file):
        print(f"Error: Results file not found: {args.results_file}")
        sys.exit(1)
    
    # Set up output file
    if args.output:
        output_file = args.output
    else:
        # Generate output filename based on input
        base_name = Path(args.results_file).stem
        output_file = Path(args.results_file).parent / f"{base_name}_qualitative.json"
    
    try:
        # Initialize evaluator
        print("Initializing Gemini 2.5 Flash Preview evaluator...")
        evaluator = QualitativeEvaluator(api_key=args.api_key)
        
        # Perform evaluation
        print(f"Evaluating results from {args.results_file}...")
        qualitative_results = evaluator.evaluate_test_results(args.results_file)
        
        # Save results
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(qualitative_results, f, indent=2, ensure_ascii=False)
        
        # Print summary
        summary = qualitative_results['qualitative_summary']
        print(f"\n=== Qualitative Evaluation Summary ===")
        print(f"Tests Evaluated: {summary['total_tests_evaluated']}")
        print(f"Average Correctness: {summary['avg_correctness']}/10")
        print(f"Average Completeness: {summary['avg_completeness']}/10")
        print(f"Average Quality: {summary['avg_quality']}/10")
        print(f"\nDetailed results saved to: {output_file}")
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
