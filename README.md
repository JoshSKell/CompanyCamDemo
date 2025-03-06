Features:
- Serverless Architecture using AWS Lamdba
- Pre-signed URLs for secure image uploads 
- Terraform for automated infrastructure deploayment

Tech Stack:
- Backend: AWS Lamdba using Python
- API Gateway: Manages the HTTP request
- Storage: AWS S3 for Object Storage


To Start:
- run: aws configure
- Enter your AWS Access Key, Secret Key, and Region

To Deploy Infrastructure:
- terraform init
- terraform plan
- terraform apply


If any changes are made to app.py
- run make_zip.py
- terrform apply

To Upload Image
- To get Pre-Signed URL
    - curl -X POST "Imagefile Name" https://{YOUR_API_ID}.execute-api.{YOUR_REGION}.amazonaws.com/prod/upload
- Use Pre-signed URL to Upload an image
    - curl -X PUT -T {Imagefile Name} {YOUR-PRESIGNED-URL} 