# Generate an SSH private key for EC2 access
resource "tls_private_key" "compose_deployment" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an EC2 key pair using the public key
resource "aws_key_pair" "compose_deployment" {
  key_name   = "compose_deployment"
  public_key = tls_private_key.compose_deployment.public_key_openssh
}

# Define security group for the EC2 instance
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for application instance"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the EC2 instance
resource "aws_instance" "app_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.compose_deployment.key_name

  tags = {
    Name = "mrojas-app-instance"
  }

  security_groups = [aws_security_group.app_sg.name]
}

# Save private SSH key locally for future use
resource "local_file" "private_key" {
  content         = tls_private_key.compose_deployment.private_key_pem
  filename        = "${path.module}/compose_deployment.pem"
  file_permission = "0600" # Ensure the file has secure permissions
}

# Provision EC2 instance using Ansible
resource "null_resource" "docker_deploy" {
  depends_on = [aws_instance.app_instance]

  # Execute commands on the EC2 instance
  provisioner "remote-exec" {
    connection {
      host        = aws_instance.app_instance.public_ip
      user        = "ec2-user"
      private_key = tls_private_key.compose_deployment.private_key_pem
    }

    inline = [
      "echo 'Connected to EC2 instance!'"
    ]
  }

  # Run the Ansible playbook locally
  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -i '${aws_instance.app_instance.public_ip},' \
      -u ec2-user \
      --private-key=${path.module}/compose_deployment.pem \
      -e "ansible_python_interpreter=/usr/bin/python3" \
      -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" \
      ./playbook.yml
    EOT
  }
}
