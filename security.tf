
resource "aws_security_group" "eks_cluster_sg" {
  name        = "youverify-eks-cluster-sg"
  description = "Security group for Youverify EKS cluster"
  vpc_id      = aws_vpc.youverify_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "youverify-eks-cluster-sg"
  }
}

resource "aws_security_group_rule" "eks_cluster_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.youverify_vpc.cidr_block]
  security_group_id = aws_security_group.eks_cluster_sg.id
}






resource "aws_security_group" "eks_nodes_sg" {
  name        = "youverify-eks-nodes-sg"
  description = "Security group for Youverify EKS worker nodes"
  vpc_id      = aws_vpc.youverify_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }


  ingress {
    from_port                = 1025
    to_port                  = 65535
    protocol                 = "tcp"
    security_groups          = [aws_security_group.eks_cluster_sg.id]
  }

  tags = {
    Name = "youverify-eks-nodes-sg"
  }
}


# Network ACLs
resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.youverify_vpc.id
  subnet_ids = aws_subnet.youverify_public_subnet[*].id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "youverify-public-nacl"
  }
}




resource "aws_network_acl_rule" "private_return_traffic" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}


resource "aws_network_acl" "private_nacl" {
  vpc_id     = aws_vpc.youverify_vpc.id
  subnet_ids = aws_subnet.youverify_private_subnet[*].id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.youverify_vpc.cidr_block
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "youverify-private-nacl"
  }
}

resource "aws_security_group_rule" "allow_eks_to_ecr" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "Allow EKS nodes to pull images from ECR"
}
