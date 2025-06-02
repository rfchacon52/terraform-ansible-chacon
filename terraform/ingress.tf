# -----------------------------------------------------------------------------
# Kubernetes Ingress Resource (Defining the spec rule)
# This Ingress resource is what the AWS Load Balancer Controller watches for.
# Based on its annotations and spec rules, it provisions an AWS Application Load Balancer (ALB).
# -----------------------------------------------------------------------------
resource "kubernetes_ingress_v1" "my_application_ingress" {
  metadata {
    name      = "my-application-ingress"
    namespace = "default" # The namespace where your backend service is
    annotations = {
      # REQUIRED: This annotation tells the AWS Load Balancer Controller to handle this Ingress
      "kubernetes.io/ingress.class" = "alb"

      # REQUIRED: Scheme for the ALB (internet-facing or internal)
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"

      # REQUIRED: Target type for the ALB (ip or instance). 'ip' is generally preferred for EKS.
      "alb.ingress.kubernetes.io/target-type" = "ip"

      # OPTIONAL: Specify listener ports. This example sets up HTTP on port 80.
      # For HTTPS, you would add a 443 listener and a certificate-arn annotation.
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}]"

      # OPTIONAL: Specify subnets for the ALB. ALB will automatically pick if not specified,
      # but explicit definition is recommended for control, especially for internet-facing ALBs.
      # Use public subnets for internet-facing ALBs.
      "alb.ingress.kubernetes.io/subnets" = "subnet-020fcee93927ce647,subnet-006a859dc2c83544d"

      # OPTIONAL: Enable WAF integration
      # "alb.ingress.kubernetes.io/wafv2-acl-arn" = "arn:aws:wafv2:region:account-id:webacl/WebACLName/WebACLId"

      # OPTIONAL: Enable HTTPS with ACM certificate and HTTP to HTTPS redirect
      # "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      # "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:region:account-id:certificate/your-cert-id"
      # "alb.ingress.kubernetes.io/ssl-policy" = "ELBSecurityPolicy-TLS-1-2-2017-01"
      # "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"

      # OPTIONAL: Health check path for target groups
       "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
       "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "30"
    }
  }

  spec {
    # Define rules for routing incoming traffic to your backend services.
    # Each 'rule' block defines a routing condition.
    rule {
      host = "my-app.example.com" # Replace with the actual domain you want to use
      http {
        path {
          path     = "/app"           # Matches the root path
          path_type = "Prefix"     # Matches paths that begin with the specified path
          backend {
            service {
              name = kubernetes_service_v1.sample_nginx_service.metadata[0].name # Name of your Kubernetes Service
              port {
                number = 80       # Port of your Kubernetes Service
              }
            }
          }
        }
      }
    }

    # You can add more 'rule' blocks for different hosts or paths:
    # rule {
    #   host = "api.example.com"
    #   http {
    #     path {
    #       path = "/v1/*"
    #       path_type = "Prefix"
    #       backend {
    #         service {
    #           name = "my-api-service"
    #           port {
    #             number = 8080
    #           }
    #         }
    #       }
    #     }
    #   }
    # }

    # Optional: TLS configuration for HTTPS.
    # Note: If you use the `alb.ingress.kubernetes.io/certificate-arn` annotation,
    # this `tls` block is primarily for Kubernetes internal validation/reference,
    # as the ALB handles the SSL termination.
    # tls {
    #   hosts        = ["my-app.example.com"]
    #   secret_name  = "my-app-tls-secret" # Kubernetes Secret containing TLS cert and key
    # }
  }

}