# Create namespace for Argo CD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Deploy Argo CD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"  # Specify your desired version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Basic configuration values
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"  # Remove in production
  }

  # Configure RBAC settings
  set {
    name  = "server.config.rbac\\.default\\.policy"
    value = "role:readonly"
  }

  depends_on = [kubernetes_namespace.argocd]
}

# Output the Argo CD server URL
output "argocd_server_url" {
  value = "https://${data.kubernetes_service.argocd_server.status.0.load_balancer.0.ingress.0.ip}"
  depends_on = [helm_release.argocd]
}

# Data source to get the Argo CD server service details
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  depends_on = [helm_release.argocd]
}