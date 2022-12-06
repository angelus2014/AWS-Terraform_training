# Create a vpc_id variable to use in other modules
output "vpc_id" {
  value = aws_vpc.main.id
}
