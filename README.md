This repo holds the configuration for installing tools (crossplane and external-secrets) and example services to a
Cluster via ArgoCD.
If the `root` folder (or one of its overlays) is applied to a cluster, ArgoCD will apply 2 ApplicationSets.
One directly applies the resources of the `clustertools` folder, the other will create the applications based on the
config files in the `tenants` folder. They again point to this same repo and the folder `remote_repos`.
The folders point to each other via ArgoCD Applications like so:

```
root -> clustertools
root -> tenants -> remote_repos
```
