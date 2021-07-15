# Name: data_remote_state.tf
# Owner: Saurav Mitra
# Description: This terraform config will retrieve the VPC module output values
# https://www.terraform.io/docs/language/state/remote-state-data.html

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "aws-infra-demo"

    workspaces = {
      name = "aws_infra_vpc"
    }
  }
}
