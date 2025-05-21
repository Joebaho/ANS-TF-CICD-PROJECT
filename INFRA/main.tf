
# ZONE OF DATA SOURCE

# # Declare the data source for AZ
# data "aws_availability_zones" "az" {
#   state = "available"
# }
# Declare the data source for the latest AMI Linux 
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
#Declare the data source for the latest AMI Ubuntu 
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # 
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
#Key pair creation 
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  public_key = tls_private_key.example.public_key_openssh
  lifecycle {
    create_before_destroy = true
    ignore_changes = [key_name]
  }
}
# resource "aws_key_pair" "deployer" {
#   key_name   = "ansible-ssh-key-${sha256(timestamp())}"
#   public_key = file("/home/ubuntu/.ssh/id_rsa.pub")
# }
# Create Amazon linux controller
resource "aws_iam_role" "iam_for_ec2" {
  name        = "Ec2RoleForSSM"
  description = "EC2 IAM role for SSM access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = ["ec2.amazonaws.com"]
        },
        Action = ["sts:AssumeRole"]
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
   ]
}
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "Ec2RoleForSSM"
  role = aws_iam_role.iam_for_ec2.name
}
resource "aws_instance" "controller" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.deployer.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = filebase64("${path.module}/user_data.sh")
  tags = {
     Name = "ansible-controller"
     Role = "controller"
  }
}
# Create Amazon linux server
resource "aws_instance" "amazon_linux_workers" {
  count                  = var.number
  instance_type          = var.instance_type
  ami                    = data.aws_ami.amazon_linux_2.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.deployer.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "amazon-worker-${count.index}"
    Role = "worker"
  }
}
#Create ubuntu server 
resource "aws_instance" "ubuntu_workers" {
  count                  = var.number
  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.deployer.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "ubuntu-worker-${count.index}"
    Role = "worker"
  }
}

resource "aws_security_group" "web_sg" {
  #vpc_id      = data.aws_vpc.default.id
  description = "security group for server"
  name        = "web_sg_${random_id.sg_suffix.hex}"

  ingress {
    from_port   = var.port_number[0] #80
    to_port     = var.port_number[0] #80
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr]
  }
  ingress {
    from_port   = var.port_number[1] #22
    to_port     = var.port_number[1] #22
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr]
  }
  egress {
    from_port   = var.port_number[2] #0
    to_port     = var.port_number[2] #0
    protocol    = "-1"
    cidr_blocks = [var.public_cidr]
  }
  tags = {
    "Name" = "web_sg"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "random_id" "sg_suffix" {
  byte_length = 4
}
# D