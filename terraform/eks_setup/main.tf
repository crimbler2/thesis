module "aws_resources" {
  source = "./aws_resources"
  kubernetes_version = var.kubernetes_version
  stage = var.stage
  region = var.region
}

module "kubernetes_resources" {
  source = "./argocd"

  root_repo_path = var.root_repo_path
  root_repo_url  = var.root_repo_url
  service_account_arn = module.aws_resources.service_account_arn

  depends_on = [module.aws_resources]
}