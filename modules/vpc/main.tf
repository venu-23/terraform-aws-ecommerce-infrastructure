# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name        = "ecommerce-${var.environment}-vpc"
    Environment = var.environment
    Project     = "ecommerce"
  }
}

# -------------------------
# Internet Gateway
# -------------------------


resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    name        = "ecommerce-${var.environment}-IGW"
    Environment = var.environment
    Project     = "ecommerce"
  }
}

# -------------------------
# Public Subnets
# -------------------------

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "ecommerce-${var.environment}-public_subnet-${count.index + 1}"
    Environment = var.environment
    Project     = "ecommerce"
    Tier        = "public"
  }
}


# -------------------------
# Private Subnets
# -------------------------

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "ecommerce-${var.environment}-private_subnet-${count.index + 1}"
    Environment = var.environment
    Project     = "ecommerce"
    Tier        = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id

  }

  tags = {
    Name        = "ecommerce-${var.environment}-public-rt"
    Environment = var.environment
    Project     = "ecommerce"
  }
}

# -------------------------
# Public Route Table Association
# -------------------------

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Elastic IP for NAT Gateway
# -------------------------


resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "ecommerce-${var.environment}-nat-eip"
    Environment = var.environment
    Project     = "ecommerce"
  }
}

# -------------------------
# NAT Gateway placed in Public subnet1
# -------------------------

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name        = "ecommerce-${var.environment}-nat-gw"
    Environment = var.environment
    Project     = "ecommerce"
  }

  depends_on = [
    aws_internet_gateway.this
  ]

}

# -------------------------
# Private Route Table
# -------------------------


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block  = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name        = "ecommerce-${var.environment}-private-rt"
    Environment = var.environment
    Project     = "ecommerce"
  }

}

# -------------------------
# Private RT and Subnet connection
# -------------------------

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


