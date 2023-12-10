data "archive_file" "lambda_function_1" {
  type        = "zip"
  source_dir  = "${path.module}/functions/function_1/"
  output_path = "${path.module}/zip_files/lambda_1.zip"
}


data "archive_file" "lambda_function_2" {
  type        = "zip"
  source_dir  = "${path.module}/functions/function_2/"
  output_path = "${path.module}/zip_files/lambda_2.zip"
}

data "aws_caller_identity" "current" {}
