provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "images" {
  bucket = "company-cam-demo-bucket" 
}

resource "aws_iam_role" "lambda_role" {
  name = "companycam_lambda_role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "backend" {
  function_name = "companycam_backend"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.handler"
  runtime       = "python3.8"

  filename         = "deployment_package.zip"
  source_code_hash = filebase64sha256("deployment_package.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.images.bucket
    }
  }
}

resource "aws_api_gateway_rest_api" "companycam_api" {
  name = "CompanyCamAPI"
}

resource "aws_api_gateway_resource" "upload" {
  rest_api_id = aws_api_gateway_rest_api.companycam_api.id
  parent_id   = aws_api_gateway_rest_api.companycam_api.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "upload_post" {
  rest_api_id   = aws_api_gateway_rest_api.companycam_api.id
  resource_id   = aws_api_gateway_resource.upload.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.companycam_api.id
  resource_id             = aws_api_gateway_resource.upload.id
  http_method             = aws_api_gateway_method.upload_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.backend.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.companycam_api.id
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.companycam_api.id
  stage_name    = "prod"
}

