resource "null_resource" "kube-config" {
    depends_on = [aws_eks_node_group.main]
    provisioner "local-exec" {
        command =<<EOF
aws eks update-kubeconfig --name ${var.env}-eks
kubectl apply -f /opt/vault-token.yaml
EOF    
    }
}

resource "helm_release" "external-secrets" {
  depends_on = [null_resource.kube-config]  
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "rexternal-secrets"
  namespace  = "kube-system"
  wait       = true
}

resource "null_resource" "external-secrets-store" {
    depends_on  = [null_resource.external-secrets]
    provisioner "local-exec" {
        command =<<EOF
kubectl apply -f - <<EOK
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://vault-internal.adevops.click:8200"
      path: "project-${var.env}"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"
          key: "token"
          namespace: kube-system
EOK
EOF    
    }
}