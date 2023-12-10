resource "aws_opensearch_domain" "opensearch_domain" {
  domain_name    = "water-temp-domain"
  engine_version = "OpenSearch_2.11"
  cluster_config {
    instance_type  = "t3.small.search"
    instance_count = 1
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 25
  }
  access_policies = replace(data.aws_iam_policy_document.opensearch_access.json, "\n", "")
}


resource "aws_s3_bucket" "datalake_bucket" {
  bucket = "datalake-bucket-xs-2023"
}

resource "aws_s3_bucket_policy" "datalake_bucket_policy" {
  bucket = aws_s3_bucket.datalake_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Sid    = "ExampleStmt"
      Effect = "Allow"
      Principal = {
        AWS = module.lambda_function.lambda_role_arn
      }
      Action   = "s3:*"
      Resource = aws_s3_bucket.datalake_bucket.arn
    }
  })

}

module "lambda_function" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = "upload-data"
  handler       = "lambda.handler"
  runtime       = "python3.8"

  create_package         = false
  local_existing_package = "${path.module}/functions/upload-data.zip"
  role_name              = "data-lake-week-2"

  environment_variables = {
    S3_BUCKET     = aws_s3_bucket.datalake_bucket.id
    ES_DOMAIN_URL = "https://${aws_opensearch_domain.opensearch_domain.endpoint}"
  }

  attach_policies    = true
  number_of_policies = 2
  policies = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonESFullAccess"
  ]
}

resource "aws_api_gateway_rest_api" "datalake_api" {
  name = "sensor-data"
}
resource "aws_api_gateway_method" "datalake_method" {
  rest_api_id   = aws_api_gateway_rest_api.datalake_api.id
  resource_id   = aws_api_gateway_rest_api.datalake_api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "datalake_integration" {
  rest_api_id             = aws_api_gateway_rest_api.datalake_api.id
  resource_id             = aws_api_gateway_rest_api.datalake_api.root_resource_id
  http_method             = aws_api_gateway_method.datalake_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda_function.lambda_function_invoke_arn

}
