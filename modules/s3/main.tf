resource "aws_s3_bucket" "datalake_bucket" {
  bucket = var.bucket_name

  tags = {
    Layer     = "${var.layer}"
    Project   = "DersonLake"
    Managedby = "Terraform"
    Author    = "AndersonSantana"
  }

}

resource "aws_s3_bucket_ownership_controls" "owernership_controls" {
  bucket = aws_s3_bucket.datalake_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.owernership_controls]

  bucket = aws_s3_bucket.datalake_bucket.id
  acl    = "private"
}
