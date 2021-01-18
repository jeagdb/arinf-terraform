output "master_db" {
  value = aws_instance.db_master.public_ip
}

output "slave_db" {
  value = aws_instance.db_slave.public_ip
}