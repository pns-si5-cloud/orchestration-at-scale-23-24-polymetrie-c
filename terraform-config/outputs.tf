output "namespace" {
  value = kubernetes_namespace.student_ns.metadata[0].name
}
