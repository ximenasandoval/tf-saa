
data "archive_file" "lambda_function" {
  type        = "zip"
  source_dir  = "${path.module}/functions/"
  output_path = "${path.module}/zip_files/lambda.zip"
}


data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.transform_data_role.arn]
    }
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "${aws_s3_bucket.data_bucket.arn}",
      "${aws_s3_bucket.data_bucket.arn}/*"

    ]
  }
  depends_on = [aws_s3_bucket.data_bucket, aws_kinesis_firehose_delivery_stream.delivery_stream]
}
