resource "aws_s3_bucket" "s3_bucket" {
  bucket = "afe-tf-test"

  //lifecycle {
    //prevent_destroy = true
  //}
}