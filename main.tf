terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "acme-demo-organization"
  region  = "europe-west10"
}

resource "google_compute_network" "vpc_network" {
  project                 = "acme-demo-organization"
  name                    = "example-vpc-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnetwork" {
  project       = "acme-demo-organization"
  name          = "example-subnetwork"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west10"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "ssh" {
  project      = "acme-demo-organization"
  name         = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "flask" {
  project      = "acme-demo-organization"
  name         = "flask-app-firewall"
  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
  direction    = "INGRESS"
  network      = google_compute_network.vpc_network.id
  source_ranges = ["0.0.0.0/0"]
}