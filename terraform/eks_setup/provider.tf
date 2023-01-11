provider "aws" {
  region = var.region
}

data "aws_eks_cluster_auth" "thesis" {
  name = module.aws_resources.cluster_name
}

provider "kubernetes" {
  host                   = module.aws_resources.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_resources.cluster_ca)
  token                  = data.aws_eks_cluster_auth.thesis.token
}

provider "helm" {
  kubernetes {
    host                   = module.aws_resources.cluster_endpoint
    cluster_ca_certificate = base64decode(module.aws_resources.cluster_ca)
    token                  = data.aws_eks_cluster_auth.thesis.token
  }
}