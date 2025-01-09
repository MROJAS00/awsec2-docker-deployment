# Define variables to allow customization of instance configuration
variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-0a094c309b87cc107"  # Default Amazon Linux 2 AMI
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Low-cost instance type for testing
}