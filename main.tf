#VPC
resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

tags = merge(
    local.common_tags,
    var.vpc_tags,
    {
        Name = local.common_name_suffix
    }
  )
}

#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    var.igw_tags,
    {
        Name = "${local.common_name_suffix}-igw"
    }
  )
} 

#PUBLIC-SUBNETS
resource "aws_subnet" "public" {
  count = length(var.public_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_cidr[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    var.public_tags,
    {
        Name = "${local.common_name_suffix}-public-${local.az_names[count.index]}" #roboshop-dev-public-us-east-1
    }
)
}

#PRIVATE-SUBNETS
resource "aws_subnet" "private" {
  count = length(var.private_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidr[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    local.common_tags,
    var.private_tags,
    {
        Name = "${local.common_name_suffix}-private-${local.az_names[count.index]}" #roboshop-dev-private-us-east-1a
    }
  )
}

#DATEBASE-SUBNETS
resource "aws_subnet" "database" {
  count = length(var.database_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_cidr[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    local.common_tags,
    var.database_tags,
    {
        Name = "${local.common_name_suffix}-database-${local.az_names[count.index]}" #roboshop-dev-database-us-east-1a
    }
  )
}

#PUBLIC-ROUTE-TABLE
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    var.public_route_table_tags,
    {
        Name = "${local.common_name_suffix}-public-route-table" #roboshop-dev-private-us-east-1a
    }
  )
}

#PRIVATE-ROUTE-TABLE
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    var.private_route_table_tags,
    {
        Name = "${local.common_name_suffix}-private-route-table" #roboshop-dev-private-us-east-1a
    }
  )
}

#DATABASE-ROUTE-TABLE
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    var.database_route_table_tags,
    {
        Name = "${local.common_name_suffix}-database-route-table" #roboshop-dev-private-us-east-1a
    }
  )
}

#ELASTIC-IP
resource "aws_eip" "nat" {
  domain   = "vpc"
  tags = {
    Name = "${local.common_name_suffix}-eip"
  }
}

#NAT-GATEWAY
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

tags = merge(
  local.common_tags,
  var.nat_gatway_tags,
    {
      Name = "${local.common_name_suffix}-nat-gateway" #roboshop-dev-private-us-east-1a
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

#PRIVATE EGRESS ROUTE TO NAT
resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

#DATABASE EGRESS ROUTE TO NAT
resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_cidr)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}