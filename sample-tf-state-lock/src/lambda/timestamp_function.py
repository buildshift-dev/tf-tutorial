import json
import os
from datetime import datetime

import boto3


def lambda_handler(event, context):
    """
    Lambda function that creates a timestamp file in S3 each time it's executed.
    """
    
    # Get the bucket name and environment from environment variables
    bucket_name = os.environ['BUCKET_NAME']
    environment = os.environ.get('ENVIRONMENT', 'unknown')
    
    # Create S3 client
    s3_client = boto3.client('s3')
    
    try:
        # Generate timestamp
        timestamp = datetime.utcnow()
        timestamp_str = timestamp.strftime("%Y-%m-%d_%H-%M-%S-%f")[:-3]  # Remove last 3 digits of microseconds
        
        # Create file name with timestamp and environment
        file_name = f"{environment}/timestamp_{timestamp_str}.json"
        
        # Create file content with enhanced metadata
        file_content = {
            "execution_time": timestamp.isoformat(),
            "environment": environment,
            "lambda_request_id": context.aws_request_id,
            "lambda_function_name": context.function_name,
            "lambda_function_version": context.function_version,
            "remaining_time_ms": context.get_remaining_time_in_millis(),
            "memory_limit_mb": context.memory_limit_in_mb,
            "log_group_name": context.log_group_name,
            "log_stream_name": context.log_stream_name,
            "event_data": event,
            "metadata": {
                "region": os.environ.get('AWS_REGION', 'unknown'),
                "runtime": "python3.11",
                "architecture": "x86_64"
            }
        }
        
        # Convert to JSON string
        content_json = json.dumps(file_content, indent=2, default=str)
        
        # Upload file to S3
        s3_client.put_object(
            Bucket=bucket_name,
            Key=file_name,
            Body=content_json,
            ContentType='application/json',
            Metadata={
                'environment': environment,
                'timestamp': timestamp.isoformat(),
                'function-name': context.function_name
            }
        )
        
        # Return success response
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Timestamp file created successfully',
                'bucket': bucket_name,
                'file_name': file_name,
                'timestamp': timestamp.isoformat(),
                'environment': environment
            })
        }
        
    except Exception as e:
        print(f"Error creating timestamp file: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Failed to create timestamp file',
                'message': str(e),
                'environment': environment
            })
        }