

######### HELM ###########

variable "cluster_name" {
  type      = string
  default   = ""
}

variable "chart_name" {
  type      = string
  default      = ""
}

variable "repo_path" {
  type        = string
  default     = null
}

variable "sa_create" {
  type      = bool
  default   = false
}

variable "sa_name" {
  type      = string
  default   = ""
}

variable "namespace" {
  type      = string
  default   = ""
}


######## POLICY ###########

variable "policy_name" {
  type      = string
  default   = ""
}


######### ROLE ############

variable "role_name" {
  type      = string
  default   = ""
}




