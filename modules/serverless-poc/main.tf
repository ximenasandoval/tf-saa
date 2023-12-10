resource "aws_dynamodb_table" "orders" {
  name             = "orders"
  billing_mode     = "PROVISIONED"
  read_capacity    = 5
  write_capacity   = 5
  hash_key         = "orderID"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "orderID"
    type = "S"
  }
}


resource "aws_sqs_queue" "poc_queue" {
  name       = "POC-Queue"
  depends_on = [aws_iam_role.apigateway_sqs, aws_iam_role.lambda_sqs_dynamodb]
  policy     = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "087840347552"
      },
      "Action": [
        "SQS:*"
      ],
      "Resource": "arn:aws:sqs:us-west-2:087840347552:"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.apigateway_sqs.arn}"
        ]
      },
      "Action": [
        "SQS:SendMessage"
      ],
      "Resource": "arn:aws:sqs:us-west-2:087840347552:*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.lambda_sqs_dynamodb.arn}"
        ]
      },
      "Action": [
        "SQS:ChangeMessageVisibility",
        "SQS:DeleteMessage",
        "SQS:ReceiveMessage"
      ],
      "Resource": "arn:aws:sqs:us-west-2:087840347552:*"
    }
  ]
}
POLICY
}


resource "aws_lambda_function" "poc_lambda_1" {
  filename      = "${path.module}/zip_files/lambda_1.zip"
  function_name = "POC-Lambda-1"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_sqs_dynamodb.arn
  handler       = "lambda.lambda_handler"
}

resource "aws_lambda_function" "poc_lambda_2" {
  filename      = "${path.module}/zip_files/lambda_2.zip"
  function_name = "POC-Lambda-2"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_dynamodbstreams_sns.arn
  handler       = "lambda.lambda_handler"

  environment {
    variables = {
      SNS_TOPIC = aws_sns_topic.poc_topic.arn
    }
  }
}


resource "aws_lambda_event_source_mapping" "lambda_1_trigger" {
  event_source_arn = aws_sqs_queue.poc_queue.arn
  function_name    = aws_lambda_function.poc_lambda_1.arn
}

resource "aws_lambda_event_source_mapping" "lambda_2_trigger" {
  event_source_arn  = aws_dynamodb_table.orders.stream_arn
  function_name     = aws_lambda_function.poc_lambda_2.id
  starting_position = "LATEST"
}


resource "aws_sns_topic" "poc_topic" {
  name = "POC-Topic"
}

resource "aws_sns_topic_subscription" "poc_topic_subscription" {
  topic_arn = aws_sns_topic.poc_topic.arn
  protocol  = "email"
  endpoint  = var.email
}

resource "aws_api_gateway_rest_api" "poc_api" {
  name = "POC-API"
}

resource "aws_api_gateway_method" "poc_method" {
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_rest_api.poc_api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "poc_integration" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id = aws_api_gateway_rest_api.poc_api.root_resource_id
  http_method = "POST"
  type        = "AWS"
  uri         = "arn:aws:apigateway:us-west-2:sqs:path/${data.aws_caller_identity.current.account_id}/POC-Queue"

  integration_http_method = "POST"
  passthrough_behavior    = "NEVER"
  credentials             = aws_iam_role.apigateway_sqs.arn
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = <<EOF
Action=SendMessage&MessageBody=$input.body
EOF
  }

}
