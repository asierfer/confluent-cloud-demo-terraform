resource "aws_s3_bucket" "s3_bucket" {
  bucket = "your-bucket-tf"

  //lifecycle {
    //prevent_destroy = true
  //}
}
