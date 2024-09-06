resource "aws_vpc" "youverify_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "youverify-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "youverify_public_subnet" {
  count             = 3
  vpc_id            = aws_vpc.youverify_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                        = "youverify-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb"    = "1"
    "kubernetes.io/cluster/youverify-cluster" = "shared"
  }
}

# Private Subnets
resource "aws_subnet" "youverify_private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.youverify_vpc.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                              = "youverify-private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/youverify-cluster" = "shared"
  }
}

resource "aws_internet_gateway" "youverify_igw" {
  vpc_id = aws_vpc.youverify_vpc.id

  tags = {
    Name = "youverify-igw"
  }
}

resource "aws_eip" "youverify_nat_eip" {
  count  = 3
}

resource "aws_nat_gateway" "youverify_nat_gateway" {
  count         = 3
  allocation_id = aws_eip.youverify_nat_eip[count.index].id
  subnet_id     = aws_subnet.youverify_public_subnet[count.index].id

  tags = {
    Name = "youverify-nat-gateway-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.youverify_igw]
}

resource "aws_route_table" "youverify_public_rt" {
  vpc_id = aws_vpc.youverify_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.youverify_igw.id
  }

  tags = {
    Name = "youverify-public-rt"
  }
}

resource "aws_route_table" "youverify_private_rt" {
  count  = 3
  vpc_id = aws_vpc.youverify_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.youverify_nat_gateway[count.index].id
  }

  tags = {
    Name = "youverify-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "youverify_public_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.youverify_public_subnet[count.index].id
  route_table_id = aws_route_table.youverify_public_rt.id
}

resource "aws_route_table_association" "youverify_private_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.youverify_private_subnet[count.index].id
  route_table_id = aws_route_table.youverify_private_rt[count.index].id
}



resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.youverify_vpc.id

  tags = {
    Name        = "${var.project_name}-vpc-flow-logs"
    Compliance  = "GDPR_PCI-DSS"
  }
}



resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name = "/aws/vpc-flow-log/${var.project_name}"
  retention_in_days = 90

  tags = {
    Name        = "${var.project_name}-vpc-flow-logs"
    Compliance  = "GDPR_PCI-DSS"
  }
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "${var.project_name}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-vpc-flow-log-role"
    Compliance  = "GDPR_PCI-DSS"
  }
}
