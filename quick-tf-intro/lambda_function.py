# This is our Lambda function code written in Python
# Every time this function runs, it creates a timestamp file in S3

import json
import boto3
from datetime import datetime
import os

def lambda_handler(event, context):
    """
    This is the main function that AWS Lambda will call.
    
    'event' contains any data that was sent to trigger this function
    'context' contains information about the Lambda function itself
    """
    
    # Get the S3 bucket name from environment variables
    # Terraform sets this up for us automatically
    bucket_name = os.environ['BUCKET_NAME']
    
    # Create an S3 client - this lets us interact with S3 storage
    s3_client = boto3.client('s3')
    
    try:
        # Get the current time
        current_time = datetime.utcnow()
        
        # Create a timestamp string for the filename
        # Format: 2024-01-15_14-30-45-123
        timestamp_str = current_time.strftime("%Y-%m-%d_%H-%M-%S-%f")[:-3]
        
        # Create the filename with the timestamp
        file_name = f"timestamp_{timestamp_str}.json"
        
        # Create the content that will go inside our file
        file_content = {
            "timestamp": current_time.isoformat(),
            "message": "Hello from Lambda!",
            "function_name": context.function_name,
            "request_id": context.aws_request_id,
            "remaining_time_ms": context.get_remaining_time_in_millis(),
            "input_data": event
        }
        
        # Convert our content to a JSON string
        content_json = json.dumps(file_content, indent=2)
        
        # Upload the file to S3
        s3_client.put_object(
            Bucket=bucket_name,
            Key=file_name,
            Body=content_json,
            ContentType='application/json'
        )
        
        # Return a success message
        print(f"Successfully created file: {file_name}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'File created successfully!',
                'bucket': bucket_name,
                'filename': file_name,
                'timestamp': current_time.isoformat()
            })
        }
        
    except Exception as error:
        # If something goes wrong, log the error and return a failure message
        print(f"Error: {str(error)}")
        
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Failed to create timestamp file',
                'message': str(error)
            })
        }