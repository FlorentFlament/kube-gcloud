# Kubernetes deployment on Google cloud

Terraform files to:
* deploy a Kubernetes cluster
* allocate a public IP (for k8s ingresses)
* setup a DNS zone (for k8s ingresses)
* uploads a wildcard TLS certificate (for k8s ingresses)
* creates a tiller service user to be used by helm

Required variables:
* gcloud_project
* gcloud_region
* gcloud_zone
* cluster_name
* cluster_nodes_count
* cluster_dns_zone

Required secrets:
* gcloud_credentials
* cluster_ingress_cert
* cluster_ingress_cert_key

Generating self-signed SSL certificates:
```
$ openssl req -x509 -newkey rsa:2048 -keyout secrets/kube-web.key -out secrets/kube-web.crt -days 365 -subj '/CN=<WILDCARD_DOMAIN>' -nodes
```
