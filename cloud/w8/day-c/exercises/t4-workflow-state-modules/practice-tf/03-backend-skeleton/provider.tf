/*
TODO:
- Put provider configuration here.
- Backend configuration belongs inside terraform { backend "s3" { ... } } in main.tf or a dedicated terraform block.
*/

provider "aws" {
  region = "us-east-1"
}
