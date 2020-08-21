provider "aws" {
access_key = "AKIA3EHJ4SWBU3N4KMHD"
secret_key = "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"
region = "ap-southeast-1"
}

resource "aws_instance" "web" {
ami = "ami-0c0d01aec729d094d" 
instance_type = "t2.micro"
key_name = "${aws_key_pair.keypair.key_name}"
vpc_security_group_ids = [aws_security_group.allow_ports.id]

tags = {
   Name = "srikanth_terraform"
}
}

resource "aws_key_pair" "keypair" {
  key_name = "terraform"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDa26FKyzZd0uExWF/XKO/9gsa4pNH6yIAtrJTU6bt3pXjWo0W4AbQjTxHe3GnKtAgxhpIX6jPmu+TbykEs53w4dfMaDqbtwKxNj7IwfkSU1AgEgP1vSDh3q9yOhp6JaEqY7qqrOEaTHHZvWsHstiZG8UKg4Ba7/91i9Pib2OQ2nQrKyKp4r9H1cjXEijYNFI3gtgqG9HOSDu0xWsCPNEJ05mKJ8VxXNFeJyxmjBdqjS/xS83bmocrMq+SE+6OQuKgFZ1hb3svnfVZv1rEFxITO/1tQOJqh4UuBgXXBn5n+RlRUtoUvZDM+YHpnDjoEr8HnzrIG5X4Xw2ksmluSqkpL root@ip-172-31-45-202"
}


resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "allow_ports" {
  name = "allow_ports"
  description = "Allow inbound traffic"
  vpc_id =  "${aws_default_vpc.default.id}"

  ingress {
    description = "http from vpc" 
    from_port = 80
    to_port = 80
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "tomcot port from vpc"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from vpc"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
   Name = "allow_ports"
  }
}


