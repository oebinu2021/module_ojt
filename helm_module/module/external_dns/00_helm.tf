

resource "helm_release" "external-dns" {

  repository = var.repo_path
  name       = var.chart_name
  chart      = var.chart_name
  namespace  = var.namespace

  set {
    name     = "clusterName"
    value    = var.cluster_name
  }
  set {
    name     = "serviceAccount.create"
    value    = var.sa_create
  }
  set {
    name     = "serviceAccount.name"
    value    = var.sa_name
  }
}

