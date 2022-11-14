# Create a pubblicsubnet.id variable
output "subnet_id1" {
  value = aws_subnet.publicsubnet.id
}

# Create a privatesubnet.id variable
output "subnet_id2" {
  value = aws_subnet.privatesubnet.id
}
