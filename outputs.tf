output "user_sm_arn" {
  value = aws_secretsmanager_secret.user.arn
}

output "master_sm_arn" {
  value = aws_secretsmanager_secret.master.arn
}
