# OUTPUTS SECTION
#public IP of the controller
output "controller_ip" {
  value = aws_instance.controller.public_ip
}
# key pair output 
output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}
#outpus 
#output of the public Ip 
output "amazon_worker_ips" {
  value = aws_instance.amazon_linux_workers[*].public_ip
}
#output of the pivate Ip 
output "ubuntu_worker_ips" {
  value = aws_instance.ubuntu_workers[*].public_ip
}
#private IPS

output "amazon_worker_private_ips" {
  value = aws_instance.amazon_linux_workers[*].private_ip
}
#output of the pivate Ip 
output "ubuntu_worker_private_ips" {
  value = aws_instance.ubuntu_workers[*].private_ip
}

