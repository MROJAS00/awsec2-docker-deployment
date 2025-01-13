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

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH"
  default     = "0.0.0.0/0" # Replace with your specific CIDR block for better security
}
