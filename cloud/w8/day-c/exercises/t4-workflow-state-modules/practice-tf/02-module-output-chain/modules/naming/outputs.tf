/*
TODO:
- Return the values that the root module should consume next.
*/

output "example_name" {
  description = "Example name returned by the naming module."
  value       = local.name_prefix
}
