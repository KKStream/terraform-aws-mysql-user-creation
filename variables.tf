variable "project" {
  type = string
}

variable "environment" {
  type        = string
  default     = ""
  description = "Development environment, if \"\", use terraform.workspace as the environment."
}

variable "name" {
  type = string
}

###########
# Network #
###########
variable "vpc_id" {
  type        = string
  description = "VPC for Lambda"
}
variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for Lambda"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups for Lambda"
}


############
# Database #
############
variable "db_endpoint" {
  type = string
}
variable "db_port" {
  type = number
}
variable "db_name" {
  type = string
}
variable "db_master_username" {
  type = string
}
variable "db_master_password" {
  type = string
}
variable "db_new_user_name" {
  type = string
}


############
#  Lambda  #
############
variable "package_bucket_name" {
  type        = string
  description = "For lambda zip file."
}

variable "invocation_failure_target_arn" {
  type        = string
  default     = ""
  description = "Amazon Resource Name (ARN) of the destination resource for failed asynchronous invocations"
}

variable "tags" {
  type    = map(string)
  default = {}
}


