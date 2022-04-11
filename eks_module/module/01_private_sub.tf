
resource "aws_eip" "private" {
//  count = var.single_nat_gateway ? 1 : length(var.private_subnet.subnet_list)

  vpc = true

	tags = {
		"Name" = "${var.cluster_name}_NAT"
	}

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_nat_gateway" "eks_nat" {
//	count = var.single_nat_gateway ? 1 : length(var.private_subnet.subnet_list)
//	connectivity_type = "private"
  	allocation_id = aws_eip.private.id
	subnet_id     = aws_subnet.public[0].id

	tags = {
		"Name" = "${var.cluster_name}_NAT"
	}

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_subnet" "private" {
	count	=	length(var.private_subnet.subnet_list)

	availability_zone 	= var.private_subnet.subnet_list[count.index].availability_zone
	cidr_block 			= var.private_subnet.subnet_list[count.index].subnet_cidr
	vpc_id = aws_vpc.eks_vpc.id

	tags = {
		"Name" = "${var.private_subnet.subnet_name}_${var.private_subnet.subnet_list[count.index].short_az}"
	}
}


resource "aws_route_table" "private" {
// 	count = length(var.private_subnet.subnet_list)
	vpc_id = aws_vpc.eks_vpc.id

	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.eks_nat.id
	}
	tags = {
		"Name" = "${var.cluster_name}_Private"
	}	
}


resource "aws_route_table_association" "private" {
	count = length(var.private_subnet.subnet_list)

	route_table_id = aws_route_table.private.id
	subnet_id = aws_subnet.private[count.index].id
}

