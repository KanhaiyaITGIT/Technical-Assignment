############################
# VPC
############################
resource "aws_vpc" "MY_Network" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

############################
# Internet Gateway
############################
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.MY_Network.id

  tags = {
    Name = "${var.project_name}-IGW"
  }
}

############################
# Public Subnets (2)
############################
resource "aws_subnet" "Public" {
  count             = 2
  vpc_id            = aws_vpc.MY_Network.id
  cidr_block        = element(["10.0.0.0/22", "10.0.4.0/22"], count.index)
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
  }
}

############################
# Private Subnets (2)
############################
resource "aws_subnet" "Private" {
  count             = 2
  vpc_id            = aws_vpc.MY_Network.id
  cidr_block        = element(["10.0.8.0/20", "10.0.16.0/20"], count.index)
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-private-${count.index + 1}"
  }
}

############################
# Database Subnet
############################
resource "aws_subnet" "database" {
  vpc_id            = aws_vpc.MY_Network.id
  cidr_block        = "10.0.32.0/24"
  availability_zone = var.azs[0]

  tags = {
    Name = "${var.project_name}-database"
  }
}

############################
# Cache Subnet
############################
resource "aws_subnet" "cache" {
  vpc_id            = aws_vpc.MY_Network.id
  cidr_block        = "10.0.33.0/24"
  availability_zone = var.azs[1]

  tags = {
    Name = "${var.project_name}-cache"
  }
}

############################
# Elastic IP for NAT
############################
resource "aws_eip" "elastic_IP" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

############################
# NAT Gateway
############################
resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.elastic_IP.id
  subnet_id     = aws_subnet.Public[0].id

  tags = {
    Name = "${var.project_name}-NAT-GW"
  }
}

############################
# Public Route Table
############################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.MY_Network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.Public[count.index].id
  route_table_id = aws_route_table.public.id
}

############################
# Private Route Table
############################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.MY_Network.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = {
    private1 = aws_subnet.Private[0].id
    private2 = aws_subnet.Private[1].id
    database = aws_subnet.database.id
    cache    = aws_subnet.cache.id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}
