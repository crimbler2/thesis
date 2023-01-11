resource "kubernetes_namespace" "argo_cd" {
  metadata {
    name   = "argocd-system"
    labels = {
      "created_by" = "terraform"
    }
  }
}

resource "helm_release" "argo_cd" {
  chart      = "argo-cd"
  name       = "argocd"
  namespace  = "argocd-system"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "5.6.2"

  values = [
    file("${path.module}/config/argocd-config.yaml")
  ]
  set {
    name  = "server.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.service_account_arn
  }
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.service_account_arn
  }

  depends_on = [kubernetes_namespace.argo_cd]
}

resource "kubernetes_secret_v1" "argo_repo" {
  metadata {
    name      = "github-repo"
    namespace = "argocd-system"
    labels    = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    "type" = "git"
    "url"  = "https://github.com/crimbler2/argocd-infrastructure-repo"
  }

  depends_on = [helm_release.argo_cd]
}

resource "helm_release" "root_application" {
  chart      = "argocd-apps"
  name       = "argocd-root-application"
  namespace  = "argocd-system"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "0.0.6"

  values = [
    file("${path.module}/config/argocd-root-application.yaml")
  ]
  set {
    name  = "applications[0].source.repoURL"
    value = var.root_repo_url
  }
  set {
    name  = "applications[0].source.path"
    value = var.root_repo_path
  }

  depends_on = [helm_release.argo_cd]
}