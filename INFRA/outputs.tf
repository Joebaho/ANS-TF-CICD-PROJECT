# OUTPUTS SECTION
#public IP of the controller
output "controller_ip" {
  value = aws_instance.controller.public_ip
}
#public IPS of workers nodes
output "worker_ips" {
  value = concat(
    aws_instance.ubuntu_workers[*].public_ip,
    aws_instance.amazon_linux_workers[*].public_ip
  )
}
#Private IPs of Workers node
output "worker_Private_ips" {
  value = concat(
    aws_instance.ubuntu_workers[*].private_ip,
    aws_instance.amazon_linux_workers[*].private_ip
  )
}

