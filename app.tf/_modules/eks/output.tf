
output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}
output "cluster-endpoint" {
  value = aws_eks_cluster.eks.endpoint
}
output "cluster-name" {
  value = aws_eks_cluster.eks.name
}