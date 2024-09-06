resource "aws_eks_cluster" "youverify_cluster" {
  name     = "youverify-cluster"
  role_arn = aws_iam_role.youverify_eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat(
      aws_subnet.youverify_public_subnet[*].id,
      /*aws_subnet.youverify_private_subnet[*].id*/
    )
    /* security_group_ids = [aws_security_group.eks_cluster_sg.id] */
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks_encryption_key.arn
    }
  }

  depends_on = [aws_iam_role_policy_attachment.youverify_eks_cluster_policy]
}

resource "aws_eks_node_group" "youverify_node_group" {
  cluster_name    = aws_eks_cluster.youverify_cluster.name
  node_group_name = "youverify-node-group"
  node_role_arn   = aws_iam_role.youverify_eks_node_role.arn
  subnet_ids      = aws_subnet.youverify_public_subnet[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.youverify_eks_worker_node_policy,
    aws_iam_role_policy_attachment.youverify_eks_cni_policy,
    aws_iam_role_policy_attachment.youverify_eks_ec2_policy
  ]
}

/*
# Data source for available AZs
data "aws_availability_zones" "available" {
  state = "available"
}
*/
