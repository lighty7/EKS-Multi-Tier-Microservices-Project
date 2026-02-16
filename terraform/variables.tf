variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-microservices"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "productsdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_capacity" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_min_capacity" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_max_capacity" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "db_endpoint" {
  value = module.rds.db_endpoint
  sensitive = true
}
