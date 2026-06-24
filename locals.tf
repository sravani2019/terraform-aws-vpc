locals {
    common_tags = {
        project = var.project
        Environment = var.environment
        Terraform = true
        Name = local.common_name
    }
    
    common_name = "${var.project}-${var.environment}"
    az_names = slice(data.aws_availability_zones.azs.names, 0, 2)
}