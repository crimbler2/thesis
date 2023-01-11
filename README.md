This monorepository holds different configuration files all related to Kubernetes, ArgoCD, Terraform and Crossplane.
It can be used to compare Crossplane and Terraform.

This is the directory structure:
```
.
└── infrastructure
    ├── clusters
    │   └── claims
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
The Terraform directory contains an EKS Setup in Terraform. 

The root directory contains 2 ArgoCD ApplicationSets further configured by kustomize.
One ApplicationSet applies the resources of the `clustertools` folder, the other will create the applications based on the
config files in the `tenants` folder. They again point to this same repo and the folder `remote_repos`.

Under `clustertools/crossplane/xrs/eks_setup_xr` a Crossplane Composite Resource is defined and composed.
This XR describes the same resources as the Terraform Setup.
The folder `cluster_setup_claims` defines Claims for the just mentioned Composite Resource.

On a high level, the folders point to each other via ArgoCD Applications like so:
```
(terraform|crossplane) -> root -> clustertools
(terraform|crossplane) -> root -> tenants -> remote_repos
```
