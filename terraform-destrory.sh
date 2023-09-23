# To Destroy the Resources, run the below commands
#!/bin/bash

NAME=$1
VERSION='latest'
APP_NAME=\"${NAME}\"
[[ -z "$NAME" ]] && { echo "must pass a App anme param" ; exit 1; }
aws ecr batch-delete-image  --repository-name $NAME --image-ids imageTag=$VERSION
terraform plan -destroy -var-file="terraform.tfvars" -var-file="common.tfvars" -out myplan
terraform apply myplan
