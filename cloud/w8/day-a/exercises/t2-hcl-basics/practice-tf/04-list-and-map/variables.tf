variable "services" {
  description = "List of service names used to practice list expressions."
  type        = list(string)
  default     = ["api", "worker", "web"]
}

variable "service_ports" {
  description = "Map of service names to their listening ports."
  type        = map(number)
  default = {
    api    = 8080
    worker = 9090
    web    = 3000
  }
}

variable "default_tags" {
  description = "Default tags used to practice map values."
  type        = map(string)
  default = {
    Project     = "TerraformPractice"
    Environment = "dev"
    Owner       = "LeHoangTrungKien"
  }
}
