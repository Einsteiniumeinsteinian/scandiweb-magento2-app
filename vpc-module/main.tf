resource "aws_vpc" "vpc" {
  cidr_block           = var.network.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name : "${var.tags.name}-vpc"
    environment : var.tags.environment
  }
}

# Subnets
# Private subnet
resource "aws_subnet" "private_subnet" {
  count                   = var.network.private_subnet == null ? 0 : length(var.network.private_subnet)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(var.network.Azs, count.index)
  cidr_block              = element(var.network.private_subnet, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tags.name}-private_subnet${count.index}"
    environment : var.tags.environment
  }
}

#Public subnet
resource "aws_subnet" "public_subnet" {
  count                   = var.network.public_subnet == null ? 0 : length(var.network.public_subnet)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(var.network.Azs, count.index)
  cidr_block              = element(var.network.public_subnet, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tags.name}_public_subnet${count.index}"
    environment : var.tags.environment
  }
}

# elastic Ip
resource "aws_eip" "eip" {
  count = var.network.private_subnet == null ? 0 : length(var.network.private_subnet)

  tags = {
    Name = "${var.tags.name}-eip${count.index}"
    environment : var.tags.environment
  }
}

# nat id
resource "aws_nat_gateway" "nat" {
  count             = aws_eip.eip == null ? 0 : length(var.network.private_subnet)
  subnet_id         = aws_subnet.public_subnet[count.index].id
  connectivity_type = "public"
  allocation_id     = aws_eip.eip[count.index].id
  depends_on = [
    aws_internet_gateway.igw,
    aws_eip.eip
  ]
  tags = {
    Name = "${var.tags.name}-nat${count.index}"
    environment : var.tags.environment
  }
}

#internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.tags.name}-igw"
    environment = var.tags.environment
  }
}

# Route table
# Public Route Table
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.tags.name}-public-rtb"
    environment : var.tags.environment
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public_rtba" {
  count          = length(var.network.public_subnet)
  route_table_id = aws_route_table.public_rtb.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

#Private Route table and Route Table Association
resource "aws_route_table" "private_rtb" {
  count  = length(var.network.private_subnet)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.tags.name}-private-rtb${count.index}"
    environment : var.tags.environment
  }
}

#Private Route Table Association
resource "aws_route_table_association" "private_rtba" {
  count          = var.network.private_subnet == null ? 0 : length(var.network.private_subnet)
  route_table_id = aws_route_table.private_rtb[count.index].id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

# Secuirty Group
resource "aws_security_group" "sg" {
  count       = length(var.security_groups)
  name        = var.security_groups[count.index].name
  description = var.security_groups[count.index].description
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.security_groups[count.index].ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.security_groups[count.index].egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }
  tags = {
    Name = "${var.tags.name}-${var.security_groups[count.index].name}"
    environment : var.tags.environment
  }

}
