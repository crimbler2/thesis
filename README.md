# This Repo

This monorepository is part of my Bachelor's Thesis.
It holds different configuration files all related to Kubernetes, ArgoCD, Terraform and Crossplane.
Its primary use is to compare Crossplane and Terraform by implementing the same EKS Setup with each of them.
The Setups then point to the directories in this Repository via ArgoCD Applications.

This repo can also serve as an example for using Crossplane, Terraform and ArgoCD.

This is the directory structure:
```
.
└── infrastructure
    ├── clustertools
    │   ├── crossplane
    │   │   └── xrs
    │   │       ├── eks_setup_xr
    │   │       └── vpc_xr
    │   └── external-secrets
    ├── remote_repos
    │   ├── remote_repo_team_1
    │   │   ├── base
    │   │   └── overlays
    │   │       ├── dev
    │   │       └── prod
    │   └── remote_repo_team_2
    │       ├── base
    │       └── overlays
    │           ├── dev
    │           └── prod
    ├── root
    │   ├── base
    │   └── overlays
    │       ├── dev
    │       └── prod
    ├── tenants
    └── terraform
              ├── terraform_my_eks
              │   └── argocd_config
              └── workspaces
                  ├── int
                  └── prod
```
The Terraform directory contains the EKS Setup in Terraform. 

The root directory contains 2 ArgoCD ApplicationSets further configured by kustomize.
One ApplicationSet applies the resources of the `clustertools` folder, the other will create the applications based on the
config files in the `tenants` folder. They again point to this same repo and the folder `remote_repos`.

Under `clustertools/crossplane/xrs/eks_setup_xr` a Crossplane Composite Resource is defined and composed.
This XR describes the same resources as the Terraform Setup.

On a high level, the folders point to each other via ArgoCD Applications like so:
```
(terraform|crossplane) -> root -> clustertools
(terraform|crossplane) -> root -> tenants -> remote_repos
```
