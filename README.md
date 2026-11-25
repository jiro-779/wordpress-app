
# AWS WordPress Infrastructure — Application

![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF)
![WordPress](https://img.shields.io/badge/WordPress-CMS-21759B)

## Project Overview

An automated WordPress deployment on AWS using Terraform and GitHub Actions.

The application infrastructure is managed separately from the networking platform and integrates with it through Terraform remote state.

## Architecture

- Application Load Balancer (ALB)
- EC2 Launch Template
- Auto Scaling Group (ASG)
- Amazon RDS MySQL
- Amazon EFS shared storage
- AWS Secrets Manager
- IAM Roles and Security Groups
- AWS KMS encryption

## Key Features

- Automated WordPress installation using EC2 User Data
- Private EC2 instances
- Load balancing and health checks
- Automatic instance scaling capabilities
- Shared WordPress content through Amazon EFS
- Database credentials managed by AWS Secrets Manager
- Encrypted EC2 storage
- Separate DEV and PROD environment configurations

## Technologies

| Technology | Purpose |
|---|---|
| AWS | Cloud infrastructure |
| Terraform | Infrastructure as Code |
| GitHub Actions | CI/CD automation |
| Amazon EC2 | Application hosting |
| Amazon RDS | MySQL database |
| Amazon EFS | Shared file storage |
| AWS Secrets Manager | Credentials management |
| Apache & PHP | Web application runtime |

## CI/CD Pipeline

GitHub Actions automates the infrastructure lifecycle:

1. Terraform Init
2. Terraform Format Check
3. Terraform Validate
4. Terraform Plan
5. Terraform Apply
6. Terraform Destroy

Authentication is implemented using GitHub OIDC and AWS IAM roles without long-lived AWS access keys.

## Deployment Order

1. Deploy the platform infrastructure.
2. Deploy the application infrastructure.
3. Access WordPress using the ALB DNS endpoint.
4. Destroy application resources.
5. Destroy platform resources.

## Deployment Results

The DEV environment was successfully deployed and tested in the AWS eu-north-1 region.

- Successful Terraform deployment
- Running EC2 instance
- Available RDS MySQL database
- Healthy ALB target
- Working WordPress website and administration dashboard

Infrastructure resources were destroyed after testing to avoid unnecessary AWS costs.

## Related Repository

[AWS WordPress Platform Infrastructure](https://github.com/jiro-779/wordpress-platform)

## Author

**Jirayr Hovsepyan**

Junior DevOps / Cloud Engineer

[GitHub Profile](https://github.com/jiro-779)
