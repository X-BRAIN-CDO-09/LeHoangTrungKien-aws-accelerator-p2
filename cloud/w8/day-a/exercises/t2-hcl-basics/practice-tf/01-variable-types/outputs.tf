output "project_name"{
    description = "Generated name for project"
    value = var.project_name
}

output "environment"{
    description = "target environment"
    value = var.environment
}

output "replica_count"{
    value = var.replica_count
}

output "enable_monitoring"{
    value = var.enable_monitoring
}

output "services"{
    value = var.services
}