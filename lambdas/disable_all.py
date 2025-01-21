import boto3
import os

def lambda_handler(event, context):
    # Fetch the list of Lambda functions to disable
    lambda_functions = os.environ['LAMBDA_FUNCTIONS'].split(',')

    # Initialize the Lambda client
    client = boto3.client('lambda')

    for function_name in lambda_functions:
        try:
            # Update the function configuration to disable it
            response = client.put_function_concurrency(
                FunctionName=function_name,
                ReservedConcurrentExecutions=0
            )
            print(f"Successfully disabled {function_name}: {response}")
        except Exception as e:
            print(f"Failed to disable {function_name}: {str(e)}")
