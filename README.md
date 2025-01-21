# Infrastructure Deployment with Terraform and Ansible

This project demonstrates how to deploy an EC2 instance using Terraform and then deploy Docker Compose on that instance using Ansible, executed by Terraform.

## Prerequisites

Before you begin, ensure you have the following installed on your local machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [AWS CLI](https://aws.amazon.com/cli/)

## Deployment Steps

### 1. Configure AWS CLI

First, configure your AWS CLI with your credentials:

```sh
aws configure