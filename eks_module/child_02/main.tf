

provider "aws" {
  region = "ap-northeast-2"
#  version = ">= 4.2.0"
}

module "second" {
  source = "../module"


################# Cluster_info #######################

  cluster_name = "second"
  vpc_cidr     = "20.0.0.0/16"

################  Public_Subnet  #####################

public_subnet = {
  subnet_name = "PUBLIC"    # ex) <subnet_name>_<short_az>
  subnet_list = [
    {
        availability_zone   =   "ap-northeast-2a"
        short_az            =   "apne-2a"
        subnet_cidr         =   "20.0.10.0/24"
    }, 
    {
        availability_zone   =   "ap-northeast-2c"
        short_az            =   "apne-2c"
        subnet_cidr         =   "20.0.100.0/24"
    }
  ]
}

################  Private_Subnet  ####################

private_subnet = {
  subnet_name = "PRIVATE"   # ex) <subnet_name>_<short_az>
  subnet_list = [
    {
        availability_zone   =   "ap-northeast-2a"
        short_az            =   "apne-2a"
        subnet_cidr         =   "20.0.20.0/24"
    }, 
    {
        availability_zone   =   "ap-northeast-2c"
        short_az            =   "apne-2c"
        subnet_cidr         =   "20.0.200.0/24"
    }
  ]
}

################## NodeGroup #####################

node_list = [
/*  {
    name            = "t2micro"
    instance_type   = "t2.micro"
    instance_volume = "30"
    desired_size    = 1
    min_size        = 1
    max_size        = 3
    description     = "eks node"
  },*/
  {
    name            = "t3medium"
    instance_type   = "t3.medium"
    instance_volume = "30"
    desired_size    = 2
    min_size        = 1
    max_size        = 4
    description     = "for operations"
  },
]

}