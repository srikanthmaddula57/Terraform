provider "aws" {
access_key = "AKIA3EHJ4SWBU3N4KMHD"
secret_key = "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"
region = "ap-southeast-1"
}

resource "aws_instance" "web" {
ami = "ami-0c0d01aec729d094d" 
instance_type = "t2.micro"
key_name = "${aws_key_pair.keypair.key_name}"
vpc_security_group_ids = [aws_security_group.allow_ports.ids]

tags = {
   Name = "srikanth_terraform"
}
}

resource "aws_key_pair" "keypair" {
  key_name = "terraform"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTxcEVCzfuEXkrfaMIukUQZjO7A094fW8zvlVVC5KmTMwsrJ3R9akclneL3iNVEjkk1xx1bG6fRPa0sfv13H3swW/3LLyskwtbkRNs1LQTdb6FiSi/lIwGslmbGuZ4Tn+At3o+u+AltSK/85z/+sBkFrzb7ITy8EBWbH643yc/AHJW1Ie22pDhUl/s0MglZwOnMo7hUBmHVLvFrqM3KsL9Q2Q7inWJ/bISGvT5qXf344AW/zkON9bNwGMToGO+wM1tHrEgVCWa4ED0gDj5yL9Nkgn2YCVs+kkzAxNj3gkCmAk7yj709Y6cpaQlC6/SkSuyewCdlDJNO/D+M9368JP9 root@ip-172-31-45-202"
}

resource "aws_eip" "myeip" {
  vpc = true
  instance = "{aws_instance.web.id}"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name= "Default VPC"
  }
}

resource "aws_security_group" "allow_ports" {
  name = "allow_ports"
  description = "Allow inbound traffic"
  vpc_id =  "${allow_default_vpc.default.id}"
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


