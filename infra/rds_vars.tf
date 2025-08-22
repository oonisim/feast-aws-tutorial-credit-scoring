variable "feast_registry_db_admin" {
  description = "Username for the Feast registry database"
  type        = string
  default     = "pgadmin"
}
variable "feast_registry_db_password" {
  description = "Password for the Feast registry database"
  type        = string
  sensitive   = true
}
variable "feast_registry_db_port" {
  description = "Port for the Feast registry database"
  type        = number
  default     = 54320
}
variable "rds_subnet_ids" {
  type = list(string)
  default = [
    "subnet-017837486d3ef7ff3",
    "subnet-04afd989d42d15f24",
    "subnet-028d464c150608a4b"
  ]
}