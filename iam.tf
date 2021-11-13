resource "aws_iam_role" "lambda" {
  name               = "${var.project}-${local.environment}-${var.name}-lambda-mysql"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json

  tags = merge(var.tags, {
    Name        = "${var.project}-${local.environment}-${var.name}-role-lambda-mysql"
    Environment = "${var.project}-${local.environment}"
  })
}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${var.project}-${local.environment}-${var.name}-lambda-mysql"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_secretsmanager_secret.master.arn,
      aws_secretsmanager_secret.user.arn
    ]
  }
}
