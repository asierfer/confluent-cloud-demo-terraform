resource "aws_s3_bucket" "s3_bucket" {
  //use your prefix name for the bucket name
  bucket = "your-name-tf-test"

  //lifecycle {
    //prevent_destroy = true
  //}
}
