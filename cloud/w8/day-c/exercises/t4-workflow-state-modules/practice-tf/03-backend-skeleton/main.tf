/*
TODO:
- Add the terraform backend block here.
- Add any bootstrap resources only if the exercise asks for them.
*/

terraform {
  backend "s3" {
    # bucket       = "your-state-bucket"
    # key          = "path/to/terraform.tfstate"
    # region       = "us-east-1"
    # encrypt      = true
    # use_lockfile = true
  }
}
