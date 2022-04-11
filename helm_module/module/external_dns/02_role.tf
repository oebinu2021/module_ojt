
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

############# OIDC ###############

data "tls_certificate" "cluster" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

/*
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [ data.tls_certificate.cluster.certificates.0.sha1_fingerprint ]
  url             = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer

}*/

data "aws_iam_policy_document" "cluster" {
#  count = var.create_role ? 1 : 0

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
#      identifiers = [ aws_iam_openid_connect_provider.cluster.arn ]
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.sa_name}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "cluster" {
#  count = var.create_role ? 1 : 0

  name    = var.role_name
  path    = "/"
  max_session_duration = 3600
  assume_role_policy   = join("", data.aws_iam_policy_document.cluster.*.json)

}

resource "aws_iam_role_policy_attachment" "cluster" {
#  count = var.create_role ? 1 : 0

  role       = join("", aws_iam_role.cluster.*.name)
  policy_arn = aws_iam_policy.cluster.arn
}



