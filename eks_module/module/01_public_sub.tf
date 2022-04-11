
resource "aws_vpc" "eks_vpc" {
	cidr_block 				= var.vpc_cidr
	enable_dns_hostnames 	= true
	enable_dns_support 		= true

	tags = {
		"Name" 				= "${var.cluster_name}_VPC"
	}
}

resource "aws_subnet" "public" {
	count					= length(var.public_subnet.subnet_list)

	availability_zone 		= var.public_subnet.subnet_list[count.index].availability_zone
	cidr_block 				= var.public_subnet.subnet_list[count.index].subnet_cidr
	vpc_id 					= aws_vpc.eks_vpc.id
	map_public_ip_on_launch = true

	tags = {
		"Name" 				= "${var.public_subnet.subnet_name}_${var.public_subnet.subnet_list[count.index].short_az}"
	}
}

resource "aws_route_table" "public" {
	vpc_id 			= aws_vpc.eks_vpc.id

	route {
		cidr_block 	= "0.0.0.0/0"
		gateway_id 	= aws_internet_gateway.eks_igw.id
	}
	tags = {
		"Name" 		= "${var.cluster_name}_Public"
	}
}

resource "aws_route_table_association" "public" {
	count 			= length(var.public_subnet.subnet_list)

	route_table_id	= aws_route_table.public.id
	subnet_id 		= aws_subnet.public[count.index].id
}

resource "aws_internet_gateway" "eks_igw" {
 vpc_id = aws_vpc.eks_vpc.id

 tags = {
	  Name 			= "${var.cluster_name}_igw"
	}
}

