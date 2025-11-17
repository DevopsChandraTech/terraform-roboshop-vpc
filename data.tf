data "aws_vpc" "main" {
    default = true
} 

data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.main.id  # Replace with your VPC ID or reference a variable/module output

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}