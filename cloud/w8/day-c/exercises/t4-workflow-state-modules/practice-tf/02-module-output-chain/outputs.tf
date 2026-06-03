/*
TODO:
- Export the final values that come from module outputs.
*/

output "example_chain" {
  description = "Example output that comes from a module output chain."
  value       = module.VPC.vpc_cidr
}
