module "ClusterSetup" {
  source             = "../../eks_setup"
  kubernetes_version = "1.24"
  region             = "eu-central-1"
  stage              = "prod"
  root_repo_path     = "root/overlays/prod"
  root_repo_url      = "https://github.com/crimbler2/argocd-infrastructure-repo.git"
}