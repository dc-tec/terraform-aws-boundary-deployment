resource "aws_vpc" "main" {
  count = var.create_vpc == true ? 1 : 0

  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({ "Name" = "${var.name}-vpc" }, var.tags)
}

resource "aws_internet_gateway" "main" {
  count = var.create_vpc == true ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge({ "Name" = "${var.name}-igw" }, var.tags)
}

resource "aws_eip" "main" {
  count = var.create_vpc == true ? length(aws_subnet.public) : 0

  domain = "vpc"

  tags = merge({ "Name" = "${var.name}-eip" }, var.tags)

  depends_on = [aws_internet_gateway.main[0]]
}

resource "aws_nat_gateway" "main" {
  count = var.create_vpc == true ? length(aws_subnet.public) : 0

  allocation_id = aws_eip.main[count.index].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge({ "Name" = "${var.name}-nat" }, var.tags)

  depends_on = [aws_internet_gateway.main[0], aws_eip.main[0]]
}

resource "aws_route_table" "public" {
  count = var.create_vpc == true ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge({ "Name" = "${var.name}-rt-public" }, var.tags)
}

resource "aws_route_table" "private" {
  count = var.create_vpc == true ? length(aws_subnet.private) : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge({ "Name" = "${var.name}-rt-private" }, var.tags)
}

resource "aws_route" "public" {
  count = var.create_vpc == true ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id
}

resource "aws_route" "private" {
  count = var.create_vpc == true ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}

resource "aws_subnet" "public" {
  count = var.create_vpc == true ? var.public_subnet_count : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge({ "Name" = "${var.name}-sn-public-${count.index}" }, var.tags)
}

resource "aws_subnet" "private" {
  count = var.create_vpc == true ? var.private_subnet_count : 0

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge({ "Name" = "${var.name}-sn-private-${count.index}" }, var.tags)
}

resource "aws_route_table_association" "public" {
  count = var.create_vpc == true ? var.public_subnet_count : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = var.create_vpc == true ? var.private_subnet_count : 0

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private[0].id
}
