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

```sh
# 1. Clone the Repository
git clone https://github.com/darsh-86/wordpress.git
```

# 2. Terraform Configuration
- Ensure you have Terraform installed and AWS CLI configured with the necessary permissions.

# Modify Variables
Edit the main.tf file to update the following placeholders with your specific values:
- your-key-pair: Your AWS EC2 key pair name
- your-admin-ip: Your IP address for restricted admin access
- yourpassword: Your desired RDS database password

# Initialize and Apply Terraform
```sh
terraform init
```
```sh
terraform apply
```
# 3. Docker Configuration
- Build and run the Docker containers for WordPress and Nginx.

# 4. Nginx Configuration
Create the necessary Nginx configuration files:
- nginx.conf: Main configuration file for Nginx

# 5. Log Rotation
Configure log rotation for Nginx by creating a logrotate.conf file.

# 6. Log Analysis Script
Create an analyze_logs.py script to analyze Nginx logs and generate a report.

# 7. Deployment Validation
 1. Ensure EC2 instances and RDS are running.
 2. Validate that Nginx is serving the WordPress site on port 8080.
 3. Check log rotation configuration.
 4. Run the log analysis script and review the report.

# Cleanup
To destroy the infrastructure created by Terraform, run:
```sh
terraform destroy
```
