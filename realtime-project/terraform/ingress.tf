# ------------------------------------------------------------------
# 2. Ingress-Nginx Controller Deployment (via Helm)
# ------------------------------------------------------------------
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true
  version    = "4.10.0" # Use a stable version

  # The NGINX Ingress Controller creates a Service of type LoadBalancer 
  # which provisions an AWS Network Load Balancer (NLB) by default.
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws\\.load-balancer-type"
    value = "nlb"
  }
  set {
    name  = "controller.replicaCount"
    value = 2
  }
}

# ------------------------------------------------------------------
# 3. Sample Application Deployment and Service
# ------------------------------------------------------------------
resource "kubernetes_deployment_v1" "app_a" {
  metadata { name = "app-a-deployment" }
  spec {
    replicas = "2"
    selector { match_labels = { app = "app-a" } }
    template {
      metadata { labels = { app = "app-a" } }
      spec { container { name = "app-a"; image = "nginx:latest" } }
    }
  }
}

resource "kubernetes_service_v1" "app_a_service" {
  metadata { name = "app-a-service" }
  spec {
    selector = { app = kubernetes_deployment_v1.app_a.metadata[0].labels.app }
    port { port = 80; target_port = 80 }
    type = "ClusterIP"
  }
}

# ------------------------------------------------------------------
# 4. Ingress Resource (Routing Rules)
# ------------------------------------------------------------------
resource "kubernetes_ingress_v1" "multi_service_ingress" {
  metadata {
    name = "multi-service-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/app-a"
          path_type = "Prefix"
          backend { service { name = kubernetes_service_v1.app_a_service.metadata[0].name; port { number = 80 } } }
        }
        # Add additional services here with different paths or hosts
      }
    }
  }
}