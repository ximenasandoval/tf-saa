
data "aws_cloudformation_export" "bucket_name" {
  name       = "exercise-processing-S3Bucket"
  depends_on = [aws_cloudformation_stack.exercise_processing]
}

data "aws_cloudformation_export" "role_name" {
  name       = "exercise-processing-GlueRole"
  depends_on = [aws_cloudformation_stack.exercise_processing]
}

data "aws_iam_role" "glue_role" {
  name       = data.aws_cloudformation_export.role_name.value
  depends_on = [aws_cloudformation_stack.exercise_processing]

}

resource "local_file" "python_glue_script" {
  content  = templatefile("${path.module}/glue.tpl", { bucket_name = "test" })
  filename = "${path.module}/glue.py"
}
