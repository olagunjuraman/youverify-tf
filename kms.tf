resource "aws_kms_key" "eks_encryption_key" {
  description             = "KMS key for EKS cluster encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-eks-encryption-key"
   Compliance  = "GDPR_PCI-DSS"
  }
}