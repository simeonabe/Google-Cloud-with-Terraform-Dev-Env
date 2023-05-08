# Configure the Google Cloud provider
provider "google" {
  project = "terraform-shd-gcloud"
  region  = "us-east1"
}

# Create a Google Compute Address
resource "google_compute_address" "shd" {
    name = "shd-address"
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

#---------------------------------------------------------------------

# Create a Google Compute Forwarding Rule
resource "google_compute_forwarding_rule" "shd" {
  name       = "shd-forwarding-rule"
  target     = "${google_compute_target_pool.shd.self_link}"
  port_range = "80"
  ip_address = "${google_compute_address.shd.address}"
}

resource "google_compute_target_pool" "shd" {
  name          = "shd-target-pool"
  health_checks = ["${google_compute_http_health_check.shd.name}"]
}

# Create a Google Compute Http Health Check
resource "google_compute_http_health_check" "shd" {
  name                 = "shd-health-check"
  request_path         = "/"
  check_interval_sec   = 30
  timeout_sec          = 3
  healthy_threshold    = 2
  unhealthy_threshold  = 2
  port                 = "${var.server_port}"
}

#---------------------------------------------------------------------

# Create a Google Compute instance Group Manager
resource "google_compute_instance_group_manager" "shd" {
  name = "shd-group-manager"
  zone = "us-east1-b"

  instance_template  = "${google_compute_instance_template.shd.self_link}"
  target_pools       = ["${google_compute_target_pool.shd.self_link}"]
  base_instance_name = "shd"
}

# Create a Google Compute Autoscaler
resource "google_compute_autoscaler" "shd" {
  name   = "shd-autoscaler"
  zone   = "us-east1-b"
  target = "${google_compute_instance_group_manager.shd.self_link}"

  autoscaling_policy = {
    max_replicas    = 8
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization = {
      target = 0.5
    }
  }
}

# Create a Google Compute instance Template
resource "google_compute_instance_template" "shd" {
  machine_type  = "f1-micro"
  
  disk {
    source_image = "ubuntu-1604-lts"
  }
  
  network_interface {
    network = "default"
  }
  
  metadata_startup_script = "echo 'Hello, World' > index.html ; nohup busybox httpd -f -p ${var.server_port} &"
}

#---------------------------------------------------------------------
/*
# Create a Google Compute Backend Service
resource "google_compute_backend_service" "shd" {
  name        = "shd-backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group_manager.shd.instance_group}"
  }

  health_checks = ["${google_compute_http_health_check.shd.self_link}"]
}
*/
#---------------------------------------------------------------------
