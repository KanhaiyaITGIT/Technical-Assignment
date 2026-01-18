output "vpc_id" {
  value = aws_vpc.MY_Network.id
}

output "public_subnet_ids" {
  value = aws_subnet.Public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.Private[*].id
}

output "database_subnet_id" {
  value = aws_subnet.database.id
}

output "cache_subnet_id" {
  value = aws_subnet.cache.id
}

output "security_group_id" {
  value = aws_security_group.main_sg.id
}
