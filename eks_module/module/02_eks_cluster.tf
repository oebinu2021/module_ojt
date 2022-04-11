

################ Cluster ###################

resource "aws_eks_cluster" "eks" {
//	count = length(var.cluster_name)
    
	name = var.cluster_name
	role_arn = aws_iam_role.eks.arn

	vpc_config {
		security_group_ids = [aws_security_group.eks.id]
		subnet_ids = aws_subnet.public[*].id
		endpoint_public_access = true
		endpoint_private_access = true
	}

	depends_on = [
		aws_iam_role_policy_attachment.eks-cluster-EKSClusterPolicy,
		aws_iam_role_policy_attachment.eks-cluster-EKSServicePolicy,
	]
}


############## Cluster_IAM ####################

locals {
	cluster_role_name = "${var.cluster_name}-role"
}

resource "aws_iam_role" "eks" {
	name = local.cluster_role_name

	assume_role_policy = <<POLICY
{
"Version": "2012-10-17",
"Statement": [
	{
	"Action": "sts:AssumeRole",
	"Principal": {
		"Service": "eks.amazonaws.com"
	},
	"Effect": "Allow",
	"Sid": ""
	}
]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-EKSClusterPolicy"{
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
	role = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-EKSServicePolicy" {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
	role = aws_iam_role.eks.name
}


############### Clusgter_Security_Group #################

resource "aws_security_group" "eks" {
	name = "${var.cluster_name}_cluster_sg"
	description = "Cluster communication with worker nodes"
	vpc_id = aws_vpc.eks_vpc.id

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "${var.cluster_name}_cluster_sg"
	}
}

resource "aws_security_group_rule" "eks_cluster_ingress_node_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 443
  type                     = "ingress"
}



