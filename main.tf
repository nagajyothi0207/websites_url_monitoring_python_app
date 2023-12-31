# Module declaration from projects
module "ecs_monitoring_app" {
  source                        = "git::https://github.com/nagajyothi0207/terraform_modules_registry//AWSECSFargatePythonFlaskApp?ref=aws_ecs_python_app-v0.0.3"
  application_name              = var.application_name
  vpc_id                        = var.vpc_id
  subnets                       = var.subnets
  alb_inbound_allowed_public_ip = var.alb_inbound_allowed_public_ip
}

#--------- Outputs -------------#
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.ecs_monitoring_app.alb_dns_name
}

output "monitoring_status" {
  description = "The URL Monitoring Status Path"
  value       = module.ecs_monitoring_app.monitoring_status
}