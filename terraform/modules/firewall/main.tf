//resource "google_compute_firewall" "default" {
//  name        = var.fw_name
//  description = "Allow ssh for EVERYONE MUAHAHAHHAHAHAH"
//  network     = var.fw_network
//  priority    = var.fw_priority
//
//  allow {
//    protocol = var.fw_protocol
//    ports    = var.fw_ports
//  }
//
//  source_ranges = var.fw_source_ranges
//  target_tags   = var.fw_target_tags
//  source_tags   = var.fw_source_tags
//}


// SSH to everyone

resource "google_compute_firewall" "firewall_ssh" {
  name = var.fw_name
  network = var.fw_network
  priority    = var.fw_priority
  allow {
    protocol = var.fw_protocol
    ports    = var.fw_ports
  }
  source_ranges = var.fw_source_ranges
}
