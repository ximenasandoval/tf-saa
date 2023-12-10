resource "aws_s3_bucket" "data_bucket" {
  bucket = "architecting-week2-xs-2023"
}

resource "aws_lambda_function" "lambda" {
  filename      = "${path.module}/zip_files/lambda.zip"
  function_name = "transform-data"
  runtime       = "python3.8"
  role          = aws_iam_role.transform_data_role.arn
  handler       = "lambda.lambda_handler"
  timeout       = "600"
}


resource "aws_kinesis_firehose_delivery_stream" "delivery_stream" {
  name        = "delivery-stream-put-to-s3"
  destination = "extended_s3"
  extended_s3_configuration {
    bucket_arn = aws_s3_bucket.data_bucket.arn
    role_arn   = aws_iam_role.kinesis_role.arn
    processing_configuration {
      enabled = true
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = aws_lambda_function.lambda.arn
        }
      }
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.data_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json

}

resource "aws_api_gateway_rest_api" "clickstream_api" {
  name = "clickstream-ingest-poc"
}

resource "aws_api_gateway_resource" "clickstream_resource" {

  rest_api_id = aws_api_gateway_rest_api.clickstream_api.id
  parent_id   = aws_api_gateway_rest_api.clickstream_api.root_resource_id
  path_part   = "poc"
}


resource "aws_api_gateway_method" "clickstream_method" {
  rest_api_id   = aws_api_gateway_rest_api.clickstream_api.id
  resource_id   = aws_api_gateway_resource.clickstream_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "clickstream_integration" {
  rest_api_id             = aws_api_gateway_rest_api.clickstream_api.id
  resource_id             = aws_api_gateway_resource.clickstream_resource.id
  http_method             = "POST"
  integration_http_method = "POST"
  credentials             = aws_iam_role.apigateway_firehose.arn
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:us-west-2:firehose:action/PutRecord"
  passthrough_behavior    = "NEVER"

  request_templates = {
    "application/json" = <<EOF
{
    "DeliveryStreamName": "${aws_kinesis_firehose_delivery_stream.delivery_stream.name}",
    "Record": {
        "Data": "$util.base64Encode($util.escapeJavaScript($input.json('$')).replace('\', ''))"
    }
}
EOF
  }
}
