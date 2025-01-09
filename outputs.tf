# Output private key (sensitive)
output "private_key" {
  value     = tls_private_key.compose_deployment.private_key_pem
  sensitive = true
}

# Output EC2 instance's public IP
output "instance_ip" {
  value = aws_instance.app_instance.public_ip
}
