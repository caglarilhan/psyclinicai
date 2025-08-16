def evaluate_output(test_result):
    if "failed" in test_result.lower():
        return "RETRY"
    return "SUCCESS" 