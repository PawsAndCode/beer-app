import boto3
import json
import logging
from datetime import datetime, timezone, timedelta
import os

# Initialize the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB table
DYNAMO_TABLE_NAME = os.environ['DYNAMO_TABLE_NAME']
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(DYNAMO_TABLE_NAME)

def lambda_handler(event, context):
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
        end_time = datetime.now(timezone.utc)
        start_time = end_time - timedelta(hours=hours)

        # Format timestamps for DynamoDB
        start_time_str = start_time.strftime('%Y-%m-%d %H:%M:%S')
        end_time_str = end_time.strftime('%Y-%m-%d %H:%M:%S')

        logger.info(f'Received query request: {device_id}@{hours}. Will query data between {start_time_str} and {end_time_str}.')

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

        # Convert the latest items to the desired format
        formatted_items = []
        for item in items:
            formatted_item = {
                'timestamp': item['timestamp'],
                'angle': str(item['angle']),
                'battery': str(item['battery']),
                'gravity': str(item['gravity']),
                'temperature': str(item['temperature'])
            }
            formatted_items.append(formatted_item)

        # Add CORS headers to the response
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'OPTIONS,GET'
        }

        # Return a JSON response with the items and headers
        return {
            'statusCode': 200,
            'headers': headers,
            'body': json.dumps(formatted_items)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
