/*
terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    region  = <your_region>
    profile = "default"
    key     = "terraformstatefile"
    bucket  = <your_bucket_name>
  }
}
*/