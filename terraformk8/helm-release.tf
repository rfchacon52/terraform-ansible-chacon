resource "helm_release" "ingress-nginx" {
  name             = var.release_name
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = var.create_namespace
  chart            = var.chart_name
  repository       = var.chart_repository_url
  dependency_update = true
  reuse_values      = true
  force_update      = true
  atomic              = var.atomic

  values = [
    templatefile("./nginx-ingress-values.yam", {
      NAME_OVERRIDE   = var.release_name
    }
  )]

}
