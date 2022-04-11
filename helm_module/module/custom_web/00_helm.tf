

resource "helm_release" "custom_helm" {

  repository = var.repo_path
  name       = var.chart_name
  chart      = var.chart_name

}

