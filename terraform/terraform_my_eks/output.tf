output "endpoint" {
  value = aws_eks_cluster.thesis.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.thesis.certificate_authority[0].data
}

output "nat-gw-ip" {
  value = aws_eip.thesis.address
}