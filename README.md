# A Python Application to Monirtor the Website URL's - Containerized application and deploying on AWS ECS Fargate
## Scenario 1 - Terraform, AWS
In this scenario Terraform deploys highly available ECS Fargate Cluster with spreading to 03 AZ's.

## Assumptions:

1) **AWS credentials with admin previlges are configured in your local laptop to provision the resources using terraform**
2) **Updated the `terraform.tfvars` file for project inputs like VPC ID and Subnet Details**

Please refer the IAC deployment configuration in `main.tf` file
By using this terraform stack the below resources will be provisioned to accomodate this architecture design:

## Deployment instructions:
1) **Run the `sh terraform-deploy.sh` file for infrastructure and App deployment on the AWS environment.**