# Prototype: uses an EXISTING GCP project, not a newly created project.
resource "google_compute_network" "this" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "this" {
  name          = "${var.name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
}
resource "google_compute_firewall" "ssh" {
  name          = "${var.name}-ssh"
  network       = google_compute_network.this.name
  source_ranges = [var.ssh_cidr]
  target_tags   = ["${var.name}-ssh"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
# GCP creates its default internet route automatically; access_config adds public IP.
resource "google_compute_instance" "this" {
  name         = "${var.name}-vm"
  zone         = var.zone
  machine_type = var.machine_type
  tags         = ["${var.name}-ssh"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 20
      type  = "pd-standard"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.this.id
    access_config {}
  }
  metadata = {
    "ssh-keys"               = "${var.admin_username}:${trimspace(var.ssh_public_key)}"
    "block-project-ssh-keys" = "true"
    "enable-oslogin"         = "FALSE"
  }
  # No service_account block: no application API identity is requested by this lab.
  depends_on = [google_compute_firewall.ssh]
}
