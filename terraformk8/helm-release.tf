resource "helm_release" "nginx" {
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

  set {
    name  = "image.tag"
    value = "1.23.3-debian-11-r3"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${path.module}/helm-chart/nginx/values.yaml", {
      NAME_OVERRIDE   = var.release_name
    }
  )]

}
