# Create a pubblicsubnet.id variable
output "subnet_id" {
  value = aws_subnet.publicsubnet.id
}
