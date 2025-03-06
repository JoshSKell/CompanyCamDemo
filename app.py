import boto3
import os
import json

s3 = boto3.client("s3")

def handler(event, context):
    print("Lambda function triggered")  

    bucket = os.environ.get("BUCKET_NAME")
    file_name = "testpic.png"  

    try:
        presigned_url = s3.generate_presigned_url(
            "put_object",
            Params={"Bucket": bucket, "Key": file_name},
            ExpiresIn=3600,
        )

        s3_image_url = f"https://{bucket}.s3.amazonaws.com/{file_name}"

        print("Generated pre-signed URL:", presigned_url)

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "upload_url": presigned_url,
                "image_url": s3_image_url
            }),
        }

    except Exception as e:
        print("Lambda Error:", str(e))

        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)}),
        }
