# Configure the Google Cloud provider
provider "google" {
  project = "terraform-shd-gcloud"
  region  = "us-east1"
}

# Create a Google Compute Firewall
resource "google_compute_firewall" "instance" {
  name    = "terraform-shd-instance"
  network = "default"

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["${var.server_port}"]
  }
}

# Create a Google Compute instance
resource "google_compute_instance" "shd" {
  name          = "shd"
  machine_type  = "f1-micro"
  zone          = "us-east1-b"
  
  boot_disk {
    initialize_params {
      image = "ubuntu-1604-lts"
    }
  }
  
  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
  
  tags = ["terraform-shd"]
  
  metadata_startup_script = "echo 'Hello, World' > index.html ; nohup busybox httpd -f -p ${var.server_port} &"
}
