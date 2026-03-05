variable "dockerhub_frontend" {
  default = "alfredomate/investor-frontned:latest"
}

variable "dockerhub_backed" {
  default = "alfredomate/investor"
}

variable "TF_VAR_db_username" {
    type = String
  
}

variable "TF_VAR_db_password" {
    type = String
  
}


