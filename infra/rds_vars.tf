variable "feast_registry_db_name" {
  type = string
  description = "Name of the FEAST registry database name on the RDS instance"
  default = "feast"
}
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
}
