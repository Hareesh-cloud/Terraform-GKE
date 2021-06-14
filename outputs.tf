output "ap-deploy-demo_url" {
  value = "${kubernetes_service.app-deploy-service.load_balancer_ingress.0.ip}:${kubernetes_service.app-deploy-service.spec.0.port.0.port}"
}
