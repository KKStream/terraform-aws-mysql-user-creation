locals {
  environment = var.environment != "" ? var.environment : terraform.workspace
}