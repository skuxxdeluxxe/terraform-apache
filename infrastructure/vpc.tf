# VPC
resource "aws_vpc" "terra_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "WebServerVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terra_vpc.id
}

# Create Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.terra_vpc.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Public-Subnet-${count.index + 1}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "Private-Subnet-${count.index + 1}"
  }
}

# Route table: attach Internet Gateway 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

# Public Route Table association with Public Subnets
resource "aws_route_table_association" "public-association" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# Create EIPS for Nat Gateways
resource "aws_eip" "nat_eip" {
  count = length(var.public_subnets_cidr)
  vpc   = true
}

# Create Nat Gateways and associate them to the public subnets
resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.public_subnets_cidr)
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
}

# Create Private Route Tables and Route them to the Nat Gateways
resource "aws_route_table" "private_rt" {
  count  = length(var.private_subnets_cidr)
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nat_gw.*.id, count.index)
  }
  tags = {
    Name = "PrivateRouteTable-${count.index + 1}"
  }
}

# Private Route Table association with Private Subnets
resource "aws_route_table_association" "private-association" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
}