resource "aws_eks_cluster" "main" {
  name = "${var.env}-eks"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.eks-cluster.arn
  version  = "1.30"

  vpc_config {
    subnet_ids = var.subnet_ids
  } 
}

