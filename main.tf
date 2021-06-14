provider "google" {
  version = "~> 3.67.0"
  project = var.project_id
  region  = var.project_region
  credentials = file("credentials.json")

resource "google_container_cluster" "primary" {
  name = "${var.project_name}"
  zone = "${var.gcp_zone}"
  initial_node_count = 3

    node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.project_name} --zone ${google_container_cluster.primary.zone}"
    }
}

resource "kubernetes_namespace" "gke-demo" {
  metadata {
    name = "gke-demo"
  }
}

resource "kubernetes_deployment" "app-deploy-demo" {
  metadata {
    name      = "app-deploy-demo"
    namespace = kubernetes_namespace.gke-demo.id
    labels = {
      app = "app-deploy-demo"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "app-deploy-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "app-deploy-demo"
        }
      }

      spec {
        container {
          image = "gcr.io/decent-habitat-315907/tomcat"
          name  = "app-deploy-demo"
        }
      }
    }
  }
}

resource "kubernetes_service" "app-deploy-service" {
  metadata {
    name      = "app-deploy-service"
    namespace = kubernetes_namespace.gke-demo.id
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.app-deploy-demo.metadata.0.labels.app}"
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}
