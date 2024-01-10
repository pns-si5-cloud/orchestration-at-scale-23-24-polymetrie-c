variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "student-backend"
}

variable "prometheus_config_path" {
  description = "Path to the Prometheus configuration file"
  type        = string
  default     = "./prometheus-configmap.yaml" 
}
