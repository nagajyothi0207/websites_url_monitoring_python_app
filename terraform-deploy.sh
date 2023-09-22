#!/bin/bash

NOW=`date +%s`
rm -rf .common.tf
echo "#Terraform inputs" >common.tfvars
AWS_DEFAULT_REGION=`aws configure list | grep region | awk '{print $2}'`
REGION=\"${AWS_DEFAULT_REGION}\"
echo "aws_region = " $REGION" " >>common.tfvars
YOUR_PUBLIC_IP_ADDRESS=$(curl -s ifconfig.me)
public_ip_restriction=\"${YOUR_PUBLIC_IP_ADDRESS}/32\"
echo "alb_inbound_allowed_public_ip = " $public_ip_restriction" " >>common.tfvars
# Main variables to modify for your account
AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
NAME=$1
APP_NAME=\"${NAME}\"
[[ -z "$NAME" ]] && { echo "must pass a App anme param" ; exit 1; }
echo "application_name             = " $APP_NAME" " >>common.tfvars 
VERSION='latest'
echo "this script helps to bootstrap the project deployment resources on Default VPC"
terraform init -upgrade
terraform fmt
terraform validate
terraform plan -var-file="terraform.tfvars" -var-file="common.tfvars" -out myplan
terraform apply myplan
echo ""
echo "Terraform deployment has been completed. Proceeding to deploy the Docker application on ECS"
echo ""
# Docker Application Build and deploy process starts from here
echo "Docker Application Build and deploy process starts from here"
# Authenticate against our Docker registry
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
export REPOSITORY_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME
# Build and push the image - CI Stage
echo Build started on `date`
echo Building the Docker image...
docker build -t $NAME:$VERSION ./docker
echo Pushing the Docker image to ECR...
docker tag $NAME:$VERSION $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$NAME:$VERSION
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$NAME:$VERSION
echo Build completed on `date`
# CD stage
echo Deploying new task definition $NAME:$VERSION to ECS cluster...
echo ECS_CLUSTER_NAME - $NAME, ECS_SERVICE_NAME - $NAME
aws ecs update-service --cluster $NAME --service $NAME --force-new-deployment 2>&1 | tee ./ecs_service_update_logs.txt
sleep 10
echo ECS service $NAME updated
terraform output
echo ""
echo "Click the Above URL to test the application status"
echo "Your ECS Containerized Application Setup has been Successfully deployed"
exit 0

