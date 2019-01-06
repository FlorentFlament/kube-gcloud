variable cluster_name { type = "string" }
variable cluster_nodes_count { type = "string" }
variable cluster_dns_zone { type = "string" }
variable cluster_ingress_cert { type = "string" }
variable cluster_ingress_cert_key { type = "string" }

#
# Kubernetes cluster in its fresh network
#
resource "google_compute_network" "kube_net" {
  name = "${var.cluster_name}-net"
}
resource "google_container_cluster" "kube" {
  name = "${var.cluster_name}"
  network = "${google_compute_network.kube_net.self_link}"
  initial_node_count = "${var.cluster_nodes_count}"
}

#
# Allocating a public IP for apps running in the cluster.
# Adding a wildcard DNS entry.
#
data "google_dns_managed_zone" "kube_dns_zone" {
  name = "${var.cluster_dns_zone}"
}
resource "google_compute_global_address" "kube_ip" {
  name = "${var.cluster_name}-public-ip"
}
resource "google_dns_record_set" "dns" {
  name         = "*.${data.google_dns_managed_zone.kube_dns_zone.dns_name}"
  managed_zone = "${data.google_dns_managed_zone.kube_dns_zone.name}"
  type         = "A"
  ttl          = 60
  rrdatas      = ["${google_compute_global_address.kube_ip.address}"]
}

#
# Uploading the ingress SSL certificate to Kuberbetes secrets store.
#
resource "kubernetes_secret" "ingress_cert" {
  metadata {
    name = "wildcard-ingress-cert"
  }
  data {
    tls.crt = "${file("${var.cluster_ingress_cert}")}"
    tls.key = "${file("${var.cluster_ingress_cert_key}")}"
  }
  type = "kubernetes.io/tls"
}

#
# Helm setup needs a tiller user
#
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}
resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "${kubernetes_service_account.tiller.metadata.0.name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller.metadata.0.name}"
    namespace = "kube-system"
  }
}
