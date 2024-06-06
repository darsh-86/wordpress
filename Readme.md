# WordPress Deployment on AWS with Nginx Reverse Proxy

This project automates the deployment of a WordPress website on AWS, protected by an Nginx reverse proxy. The setup restricts admin login to a specific IP address, includes log rotation, and provides a script for analyzing Nginx logs.

## Prerequisites

- AWS account
- AWS CLI configured
- Terraform installed
- Docker installed
- Python installed

## AWS Resources Used

- EC2 Instance
- RDS (MySQL)
- S3 (for log storage)
- IAM (for role and policy management)

## Deployment Steps

### 1. Clone the Repository

```sh
git clone https://github.com/darsh-86/wordpress.git

