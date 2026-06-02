variable "project_name" {
    description = "Project name"
    type = string
    default = "KienXbrain"
}

variable "environment" {
    description = "target environment"
    type = string
    default = "dev"
}

variable "replica_count"{
    description = "number of copy"
    type = number
    default = 2
} 

variable "enable_monitoring"{
    type = bool
    default = true
} 

variable "services"{
    type = list(string)
    default = ["web", "api-gateway"]
} 

variable "tags"{
    type = map(string)
    default = {
      Environment     = "Test"
      Service         = "Example"
      HashiCorp-Learn = "aws-default-tags"
  }
} 
