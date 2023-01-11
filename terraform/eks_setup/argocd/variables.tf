variable "service_account_arn" {
  type = string
  description = "Arn of the Service Account of the argocd namespace"
}

variable "root_repo_url" {
  type        = string
  description = "Repository of the root kubernetes resources. Will be read by argoCD and deployed."
}

variable "root_repo_path" {
  type        = string
  description = "Path of the root kubernetes resources inside the root repo"
}