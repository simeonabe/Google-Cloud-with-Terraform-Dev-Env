# Configure the Google Cloud provider
provider "google" {
  project = "terraform-shd-gcloud"
  region  = "us-east1"
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
}
