# Provider and Project Configuration
provider "google" {
  project = var.project_id
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Instances
resource "google_compute_instance" "instance_grafana" {
  name         = "instance-grafana"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "https://www.googleapis.com/compute/beta/projects/debian-cloud/global/images/debian-12-bookworm-v20241009"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  metadata = {
    startup-script = "apt update\napt install -y git\ngit clone https://github.com/masterpi227/mittelstand.git\ncd mittelstand/iot-basics\nbash docker.sh\nbash grafana.sh"
  }

  tags = ["grafana"]
}

resource "google_compute_instance" "instance_influxdb" {
  name         = "instance-influxdb"
  machine_type = "n1-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "https://www.googleapis.com/compute/beta/projects/debian-cloud/global/images/debian-12-bookworm-v20241009"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  metadata = {
    startup-script = "apt update\napt install -y git\ngit clone https://github.com/masterpi227/mittelstand.git\ncd mittelstand/iot-basics\nbash docker.sh\nbash influxdb.sh"
  }

  tags = ["influxdb"]
}

resource "google_compute_instance" "instance_mosquitto" {
  name         = "instance-mosquitto"
  machine_type = "g1-small"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "https://www.googleapis.com/compute/beta/projects/debian-cloud/global/images/debian-12-bookworm-v20241009"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  metadata = {
    startup-script = "apt update\napt install -y git\ngit clone https://github.com/masterpi227/mittelstand.git\ncd mittelstand/iot-basics\nbash docker.sh\nbash mosquitto_noauth.sh"
  }

  tags = ["mosquitto"]
}

resource "google_compute_instance" "instance_node_red" {
  name         = "instance-node-red"
  machine_type = "n1-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "https://www.googleapis.com/compute/beta/projects/debian-cloud/global/images/debian-12-bookworm-v20241009"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  metadata = {
    startup-script = "sudo apt update\nsudo apt install -y docker.io\nsudo apt install -y git\ngit clone https://github.com/masterpi227/mittelstand.git\ncd mittelstand/iot-basics\nsudo bash docker.sh\nsudo bash node-red.sh"
  }

  tags = ["node-red"]
}

resource "google_compute_instance" "instance_simulator" {
  name         = "instance-simulator"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "https://www.googleapis.com/compute/beta/projects/debian-cloud/global/images/debian-12-bookworm-v20241009"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  tags = ["http-server", "https-server"]
}

# Firewalls
resource "google_compute_firewall" "allow_influxdb" {
  allow {
    ports    = ["8086"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  name          = "allow-influxdb"
  network       = "default"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["influxdb"]
}

resource "google_compute_firewall" "allow_mosquitto" {
  allow {
    ports    = ["1883"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  name          = "allow-mosquitto"
  network       = "default"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mosquitto"]
}

resource "google_compute_firewall" "allow_port_5000_flask_app" {
  allow {
    ports    = ["5000"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  name          = "allow-port-5000-flask-app"
  network       = "default"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["node-red"]
}

resource "google_compute_firewall" "default_allow_grafana" {
  allow {
    ports    = ["3000"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  name          = "default-allow-grafana"
  network       = "default"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["grafana"]
}

resource "google_compute_firewall" "default_allow_http" {
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  name          = "default-allow-http"
  network       = "default"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "default_allow_https" {
  allow {
    ports    = ["443"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  name          = "default-allow-https"
  network       = "default"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

resource "google_compute_firewall" "default_allow_icmp" {
  allow {
    protocol = "icmp"
  }
  description   = "Allow ICMP from anywhere"
  direction     = "INGRESS"
  name          = "default-allow-icmp"
  network       = "default"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "default_allow_internal" {
  allow {
    ports    = ["0-65535"]
    protocol = "tcp"
  }
  allow {
    ports    = ["0-65535"]
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  description   = "Allow internal traffic on the default network"
  direction     = "INGRESS"
  name          = "default-allow-internal"
  network       = "default"
  project       = var.project_id
  source_ranges = ["10.128.0.0/9"]
}

resource "google_compute_firewall" "default_allow_node_red" {
  allow {
    ports    = ["1880"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  name          = "default-allow-node-red"
  network       = "default"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["node-red"]
}

resource "google_compute_firewall" "default_allow_rdp" {
  allow {
    ports    = ["3389"]
    protocol = "tcp"
  }
  description   = "Allow RDP from anywhere"
  direction     = "INGRESS"
  name          = "default-allow-rdp"
  network       = "default"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "default_allow_ssh" {
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  description   = "Allow SSH from anywhere"
  direction     = "INGRESS"
  name          = "default-allow-ssh"
  network       = "default"
  project       = var.project_id
  source_ranges = ["0.0.0.0/0"]
}