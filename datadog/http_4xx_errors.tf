resource "datadog_monitor" "alb_error_rate" {
  name = "Http_4xx_errors"
  type = "metric alert"

  # Query: Calculates the percentage of 5xx errors relative to total requests
  # Logic: (5xx / Total) * 100
  # Filter: Uses var.env (default "dev")
  query = "sum(last_5m):(sum:aws.applicationelb.http_code_target_4xx_count{env:${var.env}} by {loadbalancer}.as_count() / sum:aws.applicationelb.request_count{env:${var.env}} by {loadbalancer}.as_count()) * 100 > 10"

  message = <<EOT
    {{#is_alert}}
    High 4xx Error Rate Detected on {{loadbalancer.name}}
    Current Value: {{value}}%
    
    This monitor triggers when the 5xx error rate exceeds 10% in the last 5 minutes.
    Check the ALB target groups and backend health immediately.
    {{/is_alert}} 
    
  EOT

  tags = ["env:${var.env}", "service:alb", "terraform:managed", "region:us-east-2"]

  # Thresholds: Critical at 5%, Warning at 3%
  monitor_thresholds {
    critical =10 
    warning  = 5
  }

  notify_no_data    = false
  renotify_interval = 60
  
  # Wait for full 5 minutes of data before calculating to avoid false positives
  require_full_window = true 

  notify_audit = false
  timeout_h    = 0
  include_tags = true
}
