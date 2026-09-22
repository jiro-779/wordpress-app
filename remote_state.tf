data "terraform_remote_state" "platform" {
  backend = "s3"

  config = {
    bucket = "jiro-779-wordpress-terraform-state"
    key    = "platform/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}