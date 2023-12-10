data "aws_iam_policy_document" "opensearch_access" {
  statement {
    actions = ["es:*"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values = [
        var.ip_address
      ]
    }
  }

  statement {
    actions = ["es:*"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = [module.lambda_function.lambda_role_arn]
    }
  }
}

