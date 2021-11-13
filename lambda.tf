data "archive_file" "lambda_src" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "lambda.zip"
}

resource "aws_s3_bucket_object" "lambda_zip" {
  bucket = var.package_bucket_name
  key    = "${var.name}/${uuid()}.zip"
  source = data.archive_file.lambda_src.output_path
  etag   = data.archive_file.lambda_src.output_md5

  tags = {
    Name        = "${var.project}-${local.environment}-${var.name}-s3object-mysql"
    Environment = "${var.project}-${local.environment}"
  }
}

module "lambda" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "2.26.0"
  function_name          = "${var.project}-${local.environment}-${var.name}-mysql"
  handler                = "main.handler"
  runtime                = "python3.8"
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids
  memory_size            = 512
  attach_network_policy  = true
  lambda_role            = aws_iam_role.lambda.arn
  create_role            = false
  create_package         = false
  destination_on_failure = var.invocation_failure_target_arn
  timeout                = 60
  publish                = true
  maximum_retry_attempts = 1

  s3_existing_package = {
    bucket = aws_s3_bucket_object.lambda_zip.bucket
    key    = aws_s3_bucket_object.lambda_zip.key
  }
  environment_variables = {
    "SECRETS_RDS_MASTER_ARN" = aws_secretsmanager_secret.master.arn
    "SECRETS_RDS_USER_ARN"   = aws_secretsmanager_secret.user.arn
  }

  tags = merge(var.tags, {
    Name        = "${var.project}-${local.environment}-${var.name}-lambda-mysql"
    Environment = "${var.project}-${local.environment}"
  })
}

data "aws_lambda_invocation" "invoke_lambda" {
  function_name = module.lambda.lambda_function_name
  input = jsonencode({
    DB_ENDPOINT = var.db_endpoint
    DB_PORT     = var.db_port
    DB_NAME     = var.db_name
  })
}
