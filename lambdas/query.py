import boto3
import json
from datetime import datetime, timedelta
import os

# Initialize DynamoDB table
DYNAMO_TABLE_NAME = os.environ['DYNAMO_TABLE_NAME']
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(DYNAMO_TABLE_NAME)

def query_dynamo(event, context):
    """
    Lambda handler for querying data from DynamoDB.
    """
    try:
        # Extract query parameters from the API Gateway event
        query_params = event.get('queryStringParameters', {})
        device_id = query_params.get('ID')
        hours = int(query_params.get('hours', 1))  # Default to 1 hour if not provided

        if not device_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Device ID (ID) is required."})
            }

        # Calculate the time range
        end_time = datetime.now(datetime.timezone.utc)
        start_time = end_time - timedelta(hours=hours)

        # Format timestamps for DynamoDB
        start_time_str = start_time.strftime('%Y-%m-%d %H:%M:%S')
        end_time_str = end_time.strftime('%Y-%m-%d %H:%M:%S')

        # Query DynamoDB
        response = table.query(
            KeyConditionExpression="#id = :id AND #ts BETWEEN :start AND :end",
            ExpressionAttributeNames={
                "#id": "ID",
                "#ts": "timestamp"
            },
            ExpressionAttributeValues={
                ":id": device_id,
                ":start": start_time_str,
                ":end": end_time_str
            }
        )

        # Return data sorted by timestamp
        items = response.get('Items', [])
        items.sort(key=lambda x: x['timestamp'])

        return {
            "statusCode": 200,
            "body": json.dumps(items)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
