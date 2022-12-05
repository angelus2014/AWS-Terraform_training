# Create a vpc_id variable to use in other modules
output "vpc_id" {
  value = aws_vpc.this.id
}

# Create the public subnet id
output "public_subnet_id" {
  value = aws_subnet.public[*].id
}

# Create the private subnet id
output "private_subnet_id" {
  value = aws_subnet.private[*].id
}
