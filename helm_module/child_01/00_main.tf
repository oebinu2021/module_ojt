

module "first_helm" {
    source = "../module/aws_lb_controller"   

    cluster_name    = var.cluster_name
    repo_path       = "../repo"
    namespace       = "kube-system"
    chart_name      = "aws-load-balancer-controller"
    sa_name         = "aws-load-balancer-controller-sa"
    role_name       = "aws-load-balancer-controller-role"
    policy_name     = "aws-load-balancer-controller-policy"
}

module "second_helm" {
    source = "../module/external_dns"   

    cluster_name    = var.cluster_name
    repo_path       = "../repo"
    namespace       = "kube-system"
    chart_name      = "external-dns"
    sa_name         = "external-dns-sa"
    role_name       = "external-dns-role"
    policy_name     = "external-dns-policy"
}

module "custom_helm" {
    source = "../module/custom_web"   

    cluster_name    = var.cluster_name
    repo_path       = "../repo"
    chart_name      = "custom-web"
}
