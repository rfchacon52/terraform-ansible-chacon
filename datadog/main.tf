resource "datadog_monitor" "alb_error_rate" {
  name = "Http_5xx_errors"
  type = "metric alert"

  # The query implements your formula: (5xx_count / total_requests) * 100
  # It evaluates over the last 5 minutes (last_5m)
  query = "sum(last_5m):(sum:aws.applicationelb.http_code_target_5xx_count{env:production} by {loadbalancer}.as_count() / sum:aws.applicationelb.request_count{env:production} by {loadbalancer}.as_count()) * 100 > 5"

  message = <<EOT
    {{#is_alert}}
    High Error Rate Detected on {{loadbalancer.name}}
    Current Value: {{value}}%
    
    This monitor triggers when the 5xx error rate exceeds the threshold.
    Check the ALB target groups and backend health.
    {{/is_alert}} 
    
  EOT

  tags = ["env:production", "service:alb", "terraform:managed"]

  # Thresholds: Critical at 5%
  monitor_thresholds {
    critical = 5
  }

  # Options
  notify_no_data    = false
  renotify_interval = 60
  
  # "require_full_window" ensures the monitor waits for 5 mins of data 
  # before evaluating, preventing partial data alerts.
  require_full_window = true 
  
  # How Datadog handles the alert state
  notify_audit = false
  timeout_h    = 0
  include_tags = true
}
