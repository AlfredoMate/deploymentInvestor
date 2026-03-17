variable "dockerhub_backend" {
  type    = string
  default = "alfredomate/investor"
}

variable "dockerhub_frontend" {
  type    = string
  default = "alfredomate/investor-frontend"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "investor_db"
}
