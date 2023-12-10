resource "aws_iam_policy" "lambda_write_dynamodb" {
  name   = "Lambda-Write-DynamoDB"
  path   = "/"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DescribeTable"
            ],
            "Resource": "*"
        }
    ]
}
POLICY

  tags = {
    Name = "Lambda-Write-DynamoDB"
  }
}

resource "aws_iam_policy" "lambda_sns_publish" {
  name   = "Lambda-SNS-Publish"
  path   = "/"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish",
                "sns:GetTopicAttributes",
                    "sns:ListTopics"
            ],
                "Resource": "*"
        }
    ]
 }
POLICY

  tags = {
    Name = "Lambda-SNS-Publish"
  }
}

resource "aws_iam_policy" "lambda_dynamodbstreams_read" {
  name   = "Lambda-DynamoDBStreams-Read"
  path   = "/"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetShardIterator",
                "dynamodb:DescribeStream",
                "dynamodb:ListStreams",
                "dynamodb:GetRecords"
            ],
            "Resource": "*"
        }
    ]
}
POLICY

  tags = {
    Name = "Lambda-DynamoDBStreams-Read"
  }
}

resource "aws_iam_policy" "lambda_read_sqs" {
  name   = "Lambda-Read_SQS"
  path   = "/"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:DeleteMessage",
                "sqs:ReceiveMessage",
                "sqs:GetQueueAttributes",
                "sqs:ChangeMessageVisibility"
            ],
            "Resource": "*"
        }
    ]
}
POLICY

  tags = {
    Name = "Lambda-DynamoDBStreams-Read"
  }
}


resource "aws_iam_role" "lambda_sqs_dynamodb" {
  name = "Lambda_SQS_DynamoDB"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.lambda_write_dynamodb.arn,
    aws_iam_policy.lambda_read_sqs.arn
  ]
}

resource "aws_iam_role" "lambda_dynamodbstreams_sns" {
  name = "Lambda_DynamoDBStreams-SNS"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.lambda_sns_publish.arn,
    aws_iam_policy.lambda_dynamodbstreams_read.arn
  ]
}

resource "aws_iam_role" "apigateway_sqs" {
  name = "APIGateway-SQS"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
  ]
}



