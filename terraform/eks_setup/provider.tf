terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = {

    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster_auth" "thesis" {
  name = local.cluster_name
}


provider "kubernetes" {
  host                   = aws_eks_cluster.thesis.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.thesis.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.thesis.token
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.thesis.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.thesis.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.thesis.token
  }
}