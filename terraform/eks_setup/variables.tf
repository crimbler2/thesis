variable "region" {
  type        = string
  description = "Region of the setup"

  validation {
    condition     = contains(["eu-central-1", "eu-west-1"], var.region)
    error_message = "Allowed regions are \"eu-central-1\" and \"eu-west-1\""
  }
}

variable "stage" {
  type        = string
  description = "Stage of the Cluster Setup. Will be prefixed to the resource name. Generally one of \"dev\",\"int\" or \"prod\""
}

variable "kubernetes_version" {
  type        = string
  description = "Version of the Kubernetes Cluster"
  validation {
    condition     = contains(["1.21", "1.22", "1.23", "1.24"], var.kubernetes_version)
    error_message = "Allowed kubernetes versions are \"1.21\", \"1.22\", \"1.23\" or \"1.24\""
  }
}

variable "root_repo_url" {
  type        = string
  description = "Repository of the root kubernetes resources. Will be read by argoCD and deployed."
}

variable "root_repo_path" {
  type        = string
  description = "Path of the root kubernetes resources inside the root repo"
}