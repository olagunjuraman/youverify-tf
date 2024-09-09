variable "ec2_ssh_key_name" {
  description = "Name of the EC2 key pair for SSH access to worker nodes"
  type        = string
}


variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "youverify"
}

variable "cluster_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "youverify-cluster"
}