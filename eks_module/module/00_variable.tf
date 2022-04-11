
variable "region" {
	default = ""  
	description = "aws region"
}

variable "cluster_name" {
	default = ""
	type = string
	description = "eks cluster name"
}

variable "vpc_cidr" {
    default = ""
    type    = string
    description = "EKS_Cluster_CIDR"
}

variable "public_subnet" {
	default	= {}  
	description = "Public Subnet List"
}

variable "private_subnet" {
	default	= {}  
	description = "Private Subnet List"
}

variable "node_list" {
  type = list(object({
    name            = string
    instance_type   = string
    instance_volume = string
    desired_size    = number
    min_size        = number
    max_size        = number
    description     = string
  }))

  default     = []
  description = "definition to create node groups"
}