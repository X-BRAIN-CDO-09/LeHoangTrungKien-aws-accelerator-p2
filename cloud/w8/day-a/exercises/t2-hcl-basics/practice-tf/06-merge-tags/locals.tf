locals {
  standard_tags = merge(
    var.default_tags,
    {
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
      ManagedBy   = "Terraform"
    }
  )

  cost_tags = merge(
    local.standard_tags,
    {
      CostCenter = "CloudDevops"
    }
  )
}
