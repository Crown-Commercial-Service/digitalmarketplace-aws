resource "aws_subnet" "private" {
  for_each = var.vpc_private_subnets_cidr_blocks

  availability_zone = "${var.aws_region}${each.key}"
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.project_name}-${var.environment_name}-private-${each.key}"
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
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_subnets.id
}
