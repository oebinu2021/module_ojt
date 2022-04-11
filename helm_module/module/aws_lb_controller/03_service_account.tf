

resource "kubernetes_service_account" "first" {
  metadata {
    name      = "${var.sa_name}"
    namespace = "${var.namespace}"
    labels    = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "${var.chart_name}"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.cluster.name}"
    }
  }
}
