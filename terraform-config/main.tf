provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "student_ns" {
  metadata {
    name = "student-backend"
  }
}

resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend-deployment"
    namespace = kubernetes_namespace.student_ns.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          image = "sylcantor/k8s-app:v1.2"
          name  = "backend"

          port {
            container_port = 8080
          }

          env {
            name  = "DATABASE_URL"
            value = "postgresql://postgres:xYOa2gvS8N@db:5432/postgres"
          }

          env {
            name  = "REDIS_HOST"
            value = "redis-master"
          }

          env {
            name  = "REDIS_PORT"
            value = "6379"
          }

          env {
            name  = "REDIS_PASSWORD"
            value = "t8mJPkJxOe"
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "backend" {
  metadata {
    name = "backend-service"
    namespace = kubernetes_namespace.student_ns.metadata[0].name
  }

  spec {
    selector = {
      app = "backend"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "db" {
  metadata {
    name = "db"
    namespace = kubernetes_namespace.student_ns.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "db"
      }
    }

    template {
      metadata {
        labels = {
          app = "db"
        }
      }

      spec {
        container {
          image = "postgres:13"
          name  = "db"
          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "xYOa2gvS8N"
          }

          env {
            name  = "POSTGRES_DB"
            value = "postgres"
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "db" {
  metadata {
    name = "db"
    namespace = kubernetes_namespace.student_ns.metadata[0].name
  }

  spec {
    selector = {
      app = "db"
    }

    port {
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "redis" {
  metadata {
    name = "redis"
    namespace = kubernetes_namespace.student_ns.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          image = "redis:latest"
          name  = "redis"
          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"
    namespace = kubernetes_namespace.student_ns.metadata[0].name
  }

  spec {
    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.student_ns.metadata[0].name
  }
  data = {
    "prometheus.yml" = file(var.prometheus_config_path)
  }
}



resource "kubernetes_deployment" "prometheus" {
  metadata {
    name = "prometheus"
    namespace = kubernetes_namespace.student_ns.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }

      spec {
        container {
          image = "prom/prometheus"
          name  = "prometheus"
          port {
            container_port = 9090
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/prometheus"
          }
        }

        volume {
          name = "config-volume"

          config_map {
            name = kubernetes_config_map.prometheus_config.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "prometheus" {
  metadata {
    name = "prometheus"
    namespace = kubernetes_namespace.student_ns.metadata[0].name
  }

  spec {
    selector = {
      app = "prometheus"
    }

    port {
      port        = 9090
      target_port = 9090
    }

    type = "ClusterIP"
  }
}
