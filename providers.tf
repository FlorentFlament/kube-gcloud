variable gcloud_credentials { 
  type        = "string",
  description = "Path to the Google cloud credentials json file to use."
}
variable gcloud_project { type = "string" }
variable gcloud_region {type = "string" }
variable gcloud_zone {type = "string"}

provider "google" {
  version     = "~> 1.20"
  credentials = "${file("${var.gcloud_credentials}")}"
  project     = "${var.gcloud_project}"
  region      = "${var.gcloud_region}"
  zone        = "${var.gcloud_zone}"
}

provider "kubernetes" {
  version                = "~> 1.4"
  host                   = "https://${google_container_cluster.kube.endpoint}"
  username               = "${google_container_cluster.kube.master_auth.0.username}"
  password               = "${google_container_cluster.kube.master_auth.0.password}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.kube.master_auth.0.cluster_ca_certificate)}"
}
