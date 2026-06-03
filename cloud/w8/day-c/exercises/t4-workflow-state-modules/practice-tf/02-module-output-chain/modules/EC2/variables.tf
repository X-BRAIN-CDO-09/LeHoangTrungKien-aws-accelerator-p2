/*
TODO:
- Declare the EC2 module inputs here.
- Typical inputs: ami_id, instance_type, subnet_id, security_group_ids.
*/

variable "project_name" {
  description = "Project name used for EC2 naming."
  type        = string
}
