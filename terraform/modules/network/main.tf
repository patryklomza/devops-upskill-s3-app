resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.owner_tag}-vpc-tf"
  }
}

resource "aws_subnet" "public" {
  for_each          = var.public_subnet
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = {
    Name = "${var.owner_tag}-public-subnet"
  }
}
resource "aws_subnet" "s3_app" {
  for_each          = var.s3_subnet
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = {
    Name = "${var.owner_tag}-s3-app-subnet"
  }
}
resource "aws_subnet" "rds_app" {
  for_each          = var.rds_subnet
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = {
    Name = "${var.owner_tag}-s3-rds-subnet"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.owner_tag}-gw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.owner_tag}-public-rt"
  }
}

resource "aws_route" "public-rt" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public-subnet-association" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table" "app-rt" {
  vpc_id = aws_vpc.main.id
  for_each = toset(var.azs)

  tags = {
    Name = "${var.owner_tag}-${each.key}-app-rt"
  }
}

resource "aws_route" "app-rt" {
  for_each =  aws_route_table.app-rt
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[each.key].id
  depends_on             = [aws_nat_gateway.nat]
}

resource "aws_route_table_association" "s3-app-subnet-association" {
  for_each       = aws_subnet.s3_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.app-rt[each.key].id
}

resource "aws_route_table_association" "rds-app-subnet-association" {
  for_each       = aws_subnet.rds_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.app-rt[each.key].id
}

resource "aws_eip" "nat-eip" {
  for_each = aws_subnet.public
  vpc      = true

  tags = {
    Name = "${var.owner_tag}-${each.value.availability_zone}"
  }

}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_eip.nat-eip
  allocation_id = aws_eip.nat-eip[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${var.owner_tag}-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}