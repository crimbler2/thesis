resource aws_vpc "thesis" {
  cidr_block           = "10.19.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.stage}-thesis-vpc"
  }
}

resource aws_subnet "thesis-private-1a" {
  vpc_id            = aws_vpc.thesis.id
  cidr_block        = "10.19.0.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name                                          = "${var.stage}-thesis-private-1a"
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource aws_subnet "thesis-private-1b" {
  vpc_id            = aws_vpc.thesis.id
  cidr_block        = "10.19.1.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name                                          = "${var.stage}-thesis-private-1b"
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "thesis-public" {
  vpc_id                  = aws_vpc.thesis.id
  cidr_block              = "10.19.2.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                        = "${var.stage}-thesis-public"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_internet_gateway" "thesis" {
  vpc_id = aws_vpc.thesis.id

  tags = {
    Name = "${var.stage}-thesis"
  }
}


resource "aws_eip" "thesis" {
  vpc = true

  tags = {
    Name = "${var.stage}-thesis-nat"
  }
}

resource "aws_nat_gateway" "thesis" {
  allocation_id = aws_eip.thesis.id
  subnet_id     = aws_subnet.thesis-public.id

  tags = {
    Name = "${var.stage}-thesis"
  }

  depends_on = [aws_internet_gateway.thesis]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.thesis.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.thesis.id

  }

  tags = {
    Name = "${var.stage}-thesis-private"
  }
}

resource "aws_route_table_association" "thesis-private-1a" {
  subnet_id      = aws_subnet.thesis-private-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "thesis-public-1b" {
  subnet_id      = aws_subnet.thesis-private-1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.thesis.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.thesis.id
  }


  tags = {
    Name = "${var.stage}-thesis-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.thesis-public.id
  route_table_id = aws_route_table.public.id
}