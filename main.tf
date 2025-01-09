# Generate a new SSH private key for secure access to EC2 instance
resource "tls_private_key" "compose_deployment" {
  algorithm = "RSA"          # RSA algorithm for the key generation
  rsa_bits  = 4096           # Key length of 4096 bits for stronger security
}

# Import the generated public key into AWS to create an EC2 key pair
resource "aws_key_pair" "generated_key" {
  key_name   = "compose_deployment"  # Name for the AWS EC2 key pair
  public_key = tls_private_key.compose_deployment.public_key_openssh  # Public key from the generated private key
}

# Define the EC2 instance using the imported key pair for SSH access
resource "aws_instance" "app_instance" {
  ami           = "ami-0a094c309b87cc107"  # The AMI ID for the EC2 instance (Amazon Linux 2)
  instance_type = "t2.micro"               # Instance type (t2.micro is a low-cost option suitable for testing)
  
  key_name = aws_key_pair.generated_key.key_name  # Reference the generated key pair for SSH access

  tags = {
    Name = "mrojas-app-instance"  # Tag the instance with a name for identification
  }

  # Security group configuration allowing SSH (port 22) and HTTP (port 80) access
  security_groups = [aws_security_group.app_sg.name]
}

# Use 'null_resource' with remote-exec to run Ansible on the EC2 instance after creation
resource "null_resource" "docker_deploy" {
  
  # Use 'remote-exec' provisioner to connect to the EC2 instance and run commands
  provisioner "remote-exec" {
    connection {
        host = aws_instance.app_instance.public_ip  # Use the EC2 instance's public IP for connection
        user = "ec2-user"                          # Default user for Amazon Linux 2
        private_key = tls_private_key.compose_deployment.private_key_pem  # Use the generated private key for authentication
    }

    inline = ["echo 'connected!'"]  # Simple command to verify the connection (can be expanded for other tasks)
  }

  # Use 'local-exec' provisioner to run the Ansible playbook from the local machine
  provisioner "local-exec" {
    command = <<EOT
      # Run Ansible playbook with appropriate connection details and arguments
      ansible-playbook -i '${aws_instance.app_instance.public_ip},' -u ec2-user \
      --private-key=${path.module}/compose_deployment.pem \
      -e "ansible_python_interpreter=/usr/bin/python3" \
      -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" ./playbook.yml
    EOT
  }
}

# Define the security group to allow incoming traffic for SSH (port 22) and HTTP (port 80)
resource "aws_security_group" "app_sg" {
  name = "app-sg"  # Security group name
  
  # Ingress rules for allowing incoming traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from any IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP access from any IP
  }

  # Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic to any destination
  }
}

# Output the public IP of the EC2 instance to easily reference it after creation
output "instance_ip" {
  value = aws_instance.app_instance.public_ip  # EC2 instance public IP
}

# Save the private SSH key locally for future use
resource "local_file" "private_key" {
  content  = tls_private_key.compose_deployment.private_key_pem  # The private key content
  filename = "${path.module}/compose_deployment.pem"  # Save the private key in the current module path
  file_permission = "0600"  # Ensure the private key is readable only by the owner (for security)
}

# Output the private key value, marked as sensitive to prevent accidental exposure
output "private_key" {
  value     = tls_private_key.compose_deployment.private_key_pem  # Output the private key (sensitive)
  sensitive = true  # Mark as sensitive to avoid displaying in plain text
}
