resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.vpc_private_subnet_cidr_block

  tags = {
    "Name" = "${var.project_name}-${var.environment_name}-private"
  }
}

resource "aws_route_table" "private_subnets" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public.id
  }

  tags = {
    "Name" : "${var.project_name}-${var.environment_name}-private"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_subnets.id
}
