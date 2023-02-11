resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.vpc_public_subnet_cidr_block

  tags = {
    "Name" : "${var.project_name}-${var.environment_name}-public"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_nat_gateway" "public" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${var.project_name}-${var.environment_name} public NAT"
  }

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-igw"
  }
}

resource "aws_default_route_table" "poc" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

