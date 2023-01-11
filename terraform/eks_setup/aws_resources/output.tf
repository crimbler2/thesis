output "cluster_endpoint" {
  value = aws_eks_cluster.thesis.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.thesis.name
}

output "cluster_ca" {
  value = aws_eks_cluster.thesis.certificate_authority[0].data
}

output "service_account_arn" {
  value = aws_iam_role.thesis-sa.arn
}