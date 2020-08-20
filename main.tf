provider "aws" {
access_key = "AKIA3EHJ4SWBU3N4KMHD"
secret_key = "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"
region = "ap-southeast-1"
}

resource "aws_instance" "web" {
ami = "ami-0c0d01aec729d094d" 
instance_type = "t2.micro"

tags = {
   Name = "srikanth_terraform"
}
}
