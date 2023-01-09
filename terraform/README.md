# Terraform
## eks_setup
This directory contains a terraform module `eks_setup` which provisions an EKS_Cluster,
the necessary networking, the necessary IAM Roles and Policies and installs ArgoCD into the cluster
including a bootstrapping ArgoCD-Application which points to a repository configurable by a variable.
## workspaces
The second folder `workspaces` uses this module in two exemplary environments: `int` and `prod`