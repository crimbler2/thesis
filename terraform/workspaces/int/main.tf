module "ClusterSetup" {
  source             = "../../terraform_my_eks"
  kubernetes_version = "1.24"
  region             = "eu-central-1"
  stage              = "dev"
  root_repo_path     = "root/overlays/dev"
  root_repo_url      = "https://github.com/crimbler2/argocd-infrastructure-repo.git"
}