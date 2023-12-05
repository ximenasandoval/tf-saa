data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_subnet" "subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["${var.subnet_1_name}"]
  }
}

data "aws_subnet" "subnet_2" {
  filter {
    name   = "tag:Name"
    values = ["${var.subnet_2_name}"]
  }
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}"]
  }
}

data "aws_iam_policy_document" "allow_access_from_app_instance_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::087840347552:role/S3DynamoDBFullAccessRole"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.app_bucket.arn,
      "${aws_s3_bucket.app_bucket.arn}/*",
    ]
  }
}
