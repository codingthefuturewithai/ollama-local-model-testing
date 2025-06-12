# Sample code files for qwen2.5-coder:7b testing

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

def slow_search(arr, target):
    """Inefficient linear search implementation"""
    found_indices = []
    for i in range(len(arr)):
        for j in range(len(arr)):  # Unnecessary nested loop
            if arr[i] == target:
                found_indices.append(i)
                break
    return found_indices

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
