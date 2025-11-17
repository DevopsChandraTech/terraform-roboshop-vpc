variable "cidr_block" {
    type = string
}

variable "project_name" {
    type = string
}

variable "environment" {
    type = string
}

variable "common_tags" {
    type = map
    default = {
        Project = "roboshop"
        Terraform =true
    }
}

variable "vpc_tags" {
    type = map
}

variable "public_cidr" {
    type = list
}

variable "private_cidr" {
    type = list
}

variable "database_cidr" {
    type = list
}

variable "igw_tags" {
    type = map
    default = {}
}

variable "public_tags" {
    type = map
    default = {}
}

variable "private_tags" {
    type = map
    default = {}
}

variable "database_tags" {
    type = map
    default = {}
}

variable "private_route_table_tags" {
    type = map
    default = {}
}   

variable "public_route_table_tags" {
    type = map
    default = {}
}  

variable "nat_gatway_tags" {
    type = map
    default = {}
}

variable "database_route_table_tags" {
    type = map
    default = {}
}

variable "is_required_peering" {
    type = bool
    default = true
}


