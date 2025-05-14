variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}
# variable declaration for the vpc aws region
variable "aws_region" {
  type = string
}
#public ip access
variable "public_cidr" {
  type        = string
  description = "public Cidr block access from anywhere"
}
# variable declarations for port
variable "port_number" {
  type        = list(number)
  description = "list of port number for security group ingress and egress rules"
}
# variable declaration for index count
variable "number" {
  type = string
}
