terraform {
  backend "s3" {
    bucket = "igp-terraform-remote-backend-s3"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"
  }
}