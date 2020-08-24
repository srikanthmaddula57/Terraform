# Terraform ELB Provisioning

provider "aws" {
region = "ap-southeast-1"
}

resource "aws_instance" "web" {
ami = "ami-0c0d01aec729d094d"
instance_type = "t2.micro"
count  = 2
key_name = "${aws_key_pair.keypair.key_name}"
vpc_security_group_ids = [aws_security_group.allow_ports.id]
user_data= <<-EOF
#!/bin/bash
yum install httpd -y
echo "Hey I am $(hostname -f)" > /var/www/html/index.html
service httpd start
chkconfig httpd on
EOF

tags = {
   Name = "srikanth_terraform${count.index}"
}
}

resource "aws_key_pair" "keypair" {
  key_name = "terraform1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmFB4tWkub6zvSVd/uKWV6aYOdUv+PFgvouRLWM4lV6W/HqvnWnY05BsCbwonmt6IXEgCB/0Yg4S/goVbx49TBsyM2Y73iJTPaEV8qiIIBBrWQEJ+VtSBiCYgkWbEdS44Meuihh4hg53b38peM3JetCt6yOh2BGlg1pOq3NCFT2RUxixdq/zSoVRnXV5N3Bloe8ZaBJVBHFv2bya39lNCckcmgBbIUC4ODimLqnssnz37omdRTs8x/8OstQQWVngMKaYnGCL8cghUSj5MVyFvrcsyaok+baFbqhHFw3ldmKr5iLUKQA67PEHSGefbkcUoFWtS3b2QCASiad1BeH+9X root@ip-172-31-32-69"
}


resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "allow_ports" {
  name = "alb"
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
data "aws_subnet_ids" "subnet" {
  vpc_id    =  "${aws_default_vpc.default.id}"
}

resource "aws_lb_target_group" "my-target-group" {
  health_check {
    interval             = 10
    path                 = "/"
    protocol             = "HTTP"
    timeout              = 5
    healthy_threshold    = 5
    unhealthy_threshold  = 2
  }
  name              = "my-test-tg"
  port              = 80
  protocol          = "HTTP"
  target_type       = "instance"
  vpc_id            = "${aws_default_vpc.default.id}"
}

resource "aws_lb"  "my-aws-alb" {
  name        =   "srikanth-test-alb"
  internal    =  false
  security_groups = [
    "${aws_security_group.allow_ports.id}",
  ]
  subnets  = data.aws_subnet_ids.subnet.ids

  tags  = {
    Name   =  "srikanth-test-alb"
  }
  ip_address_type      = "ipv4"
  load_balancer_type   = "application"
}

resource "aws_lb_listener"  "srikanth-test-alb-listner"  {
 load_balancer_arn         =  aws_lb.my-aws-alb.arn
      port                 = 80
      protocol             = "HTTP"
      default_action  {
        target_group_arn   = "${aws_lb_target_group.my-target-group.arn}"
        type               = "forward"
      }
}

resource "aws_alb_target_group_attachment"  "ec2_attach"  {
  count           = length(aws_instance.web)
  target_group_arn     = aws_lb_target_group.my-target-group.arn
  target_id            = aws_instance.web[count.index].id
}
