terraform {
  # Версия terraform
  required_version = "0.13.5"
}

provider "google" {
  # Версия провайдера
  version = "2.15"
  # ID проекта
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "gitlab" {
  name = "gitlab"
  machine_type = "n1-standard-1"
  zone = var.instance_zone
  tags = ["gitlab", "http-server", "https-server"]
  boot_disk {
    initialize_params {
        image = var.disk_image
        }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.gitlab_ip.address
    }
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_address" "gitlab_ip" {
  name = "gitlab-ip"
}
