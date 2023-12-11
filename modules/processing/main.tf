
resource "aws_cloudformation_stack" "exercise_processing" {
  name          = "exercise-processing"
  template_body = file("${path.module}/exercise-processing.yml")
  capabilities  = ["CAPABILITY_NAMED_IAM"]
}


resource "aws_glue_catalog_database" "nycitytaxi" {
  name = "nycitytaxi"
}

resource "aws_glue_crawler" "nytaxicrawler" {
  name          = "nytaxicrawler"
  database_name = aws_glue_catalog_database.nycitytaxi.name
  role          = data.aws_cloudformation_export.role_name.value
  s3_target {
    path = "s3://aws-tc-largeobjects/DEV-AWS-MO-Designing_DataLakes/week3/"
  }
  provisioner "local-exec" {
    command = "aws glue start-crawler --name ${self.name}"
  }
}

resource "aws_s3_bucket" "script_bucket" {
  bucket = "xs-2023-script-bucket"
  provisioner "local-exec" {
    command = "aws s3 cp ${path.module}/glue.py s3://${self.id}/glue.py"
  }
}


resource "aws_glue_job" "nytaxiparquet" {
  name         = "nytaxiparquet"
  role_arn     = data.aws_iam_role.glue_role.arn
  glue_version = "4.0"

  command {
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.script_bucket.id}/glue.py"
  }

  provisioner "local-exec" {
    command = "aws glue start-job-run --job-name ${self.name}"
  }
}

resource "aws_glue_crawler" "nytaxiparquet" {
  name          = "nytaxiparquet"
  database_name = aws_glue_catalog_database.nycitytaxi.name
  role          = data.aws_cloudformation_export.role_name.value
  s3_target {
    path = "s3://${data.aws_cloudformation_export.bucket_name.value}"
  }
  provisioner "local-exec" {
    command = "aws glue start-crawler --name ${self.name}"
  }
  depends_on = [aws_glue_job.nytaxiparquet]
}


