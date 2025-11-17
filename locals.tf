locals {
    common_name_suffix = "${var.project_name}-${var.environment}" #roboshop-dev-branch
    common_tags = {
        Terraform = true
        Project = "roboshop"
    }
    az_names = slicd(data.aws_availability_zones.available.names,0,2)
}

