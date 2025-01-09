# AWS EC2 Docker Deployment

This repository contains scripts and configurations to deploy Docker containers on AWS EC2 instances.

## Prerequisites

- AWS Account
- AWS CLI configured
- Docker installed
- Terraform installed

## Setup

1. **Clone the repository:**
    ```sh
    git clone https://github.com/yourusername/awsec2-docker-deployment.git
    cd awsec2-docker-deployment
    ```

2. **Configure AWS CLI:**
    ```sh
    aws configure
    ```

3. **Initialize Terraform:**
    ```sh
    terraform init
    ```

## Deployment

1. **Create an EC2 instance:**
    ```sh
    terraform apply
    ```

2. **SSH into the EC2 instance:**
    ```sh
    ssh -i path/to/your-key.pem ec2-user@your-ec2-public-dns
    ```

3. **Run Docker container:**
    ```sh
    docker run -d -p 80:80 your-docker-image
    ```

## Cleanup

1. **Destroy the infrastructure:**
    ```sh
    terraform destroy
    ```

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Contact

For any inquiries, please contact [your-email@example.com](mailto:your-email@example.com).