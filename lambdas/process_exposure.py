import os
import boto3

ENDPOINT = os.environ.get("AWS_ENDPOINT_URL", "http://localhost.localstack.cloud:4566")
TABLE_NAME = os.environ.get("TABLE_NAME", "RiskIndicatorsTF")
dynamodb = boto3.resource("dynamodb", endpoint_url=ENDPOINT)

def handler(event, context):
    table = dynamodb.Table(TABLE_NAME)
    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]
        print(f"Fichier detecte : s3://{bucket}/{key}")
        table.put_item(Item={"id": key, "source_bucket": bucket, "status": "PROCESSED"})
        print(f"Item ecrit dans DynamoDB ({TABLE_NAME}) pour la cle {key}")
    return {"statusCode": 200, "processed": len(event.get("Records", []))}
