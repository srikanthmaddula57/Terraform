# Terraform Provisioning S3

provider "aws" {
region = "ap-southeast-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "srikanth-143786"
  acl    = "private"

  tags = {
    Name         = "my bucket"
    Environment  = "Dev"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "sample.test"
  source = "/root/terraform_practice/s3/sample.test"
}

resource "aws_s3_bucket_object" "object2" {
  for_each = fileset(path.module, "**/*.txt")
  bucket   = aws_s3_bucket.bucket.bucket
  key      = each.value
  source   = "${path.module}/${each.value}"
}
output  "fileset-results" {
  value   =  fileset(path.module, "**/*.txt")
}

resource "aws_s3_bucket_object" "object1" {
  for_each = fileset(path.module, "*.html")
  bucket   = aws_s3_bucket.bucket.bucket
  key      = each.value
  source   = "${path.module}/${each.value}"
}
output  "fileset-results1" {
  value   =  fileset(path.module, "*.html")
}


