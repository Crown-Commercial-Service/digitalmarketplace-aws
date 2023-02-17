resource "aws_subnet" "public" {
  for_each = var.vpc_public_subnets_cidr_blocks

  availability_zone = "${var.aws_region}${each.key}"
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" : "${var.project_name}-${var.environment_name}-public-${each.key}"
  }
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  vpc = true

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_nat_gateway" "public" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "${var.project_name}-${var.environment_name} public NAT ${each.key}"
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

