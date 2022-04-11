

################ NodeGroup #######################

resource "aws_eks_node_group" "node_group" {
  count = length(var.node_list)

  node_role_arn   = aws_iam_role.node_iam.arn
  subnet_ids      = aws_subnet.public[*].id
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-${var.node_list[count.index].name}"

  scaling_config {
    desired_size = var.node_list[count.index].desired_size
    min_size     = var.node_list[count.index].min_size
    max_size     = var.node_list[count.index].max_size
  }

 	launch_template {
    id      = aws_launch_template.node[count.index].id
    version = "1"
	} 


  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
    aws_launch_template.node,
  ]
}


################# Launch Template ####################



data "aws_ami" "node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"]
}

locals {
  eks_node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
}



resource "aws_launch_template" "node" {
    count = length(var.node_list)

    name = "${var.cluster_name}-${var.node_list[count.index].name}"
    disable_api_termination = true
  
  lifecycle {
    create_before_destroy = true
  }

    image_id        = data.aws_ami.node.id
    instance_type   = var.node_list[count.index].instance_type
    vpc_security_group_ids = [aws_security_group.node.id]
    user_data = base64encode(local.eks_node_userdata)
    
    tag_specifications {
      resource_type = "instance"

      tags = {
        "Name" = "${var.cluster_name}-${var.node_list[count.index].name}"
      }
    }
}

###################### NodeGroup_IAM #########################


locals {
	node_role_name = format("%s-node-group", var.cluster_name)
}

resource "aws_iam_role" "node_iam" {
  name = local.node_role_name

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_iam.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_iam.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_iam.name
}



######################## NodeGroup_Security_Group #########################



resource "aws_security_group" "node" {
  name        = "${var.cluster_name}_node_sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.cluster_name}_node_sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-cluster" {
  description              = "Allow node Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.eks.id
  to_port                  = 65535
  type                     = "ingress"
}

