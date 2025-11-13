data "aws_vpc" "default" {
    default = true
} 

data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id  # Replace with your VPC ID or reference a variable/module output

  filter {
    name   = "association.main"
    values = ["true"]
  }
}