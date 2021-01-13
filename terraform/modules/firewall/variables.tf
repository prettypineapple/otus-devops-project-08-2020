variable "fw_name" {
  description = "The name of the firewall rule"
}

variable "fw_network" {
  description = "The network this firewall rule applies to"
}

variable "fw_priority" {
  description = "The firewall rule priority"
}

variable "fw_protocol" {
  description = "The name of the protocol to allow"
}

variable "fw_ports" {
  description = "A list of ports and/or port ranges to allow"
}

variable "fw_source_ranges" {
  description = "A list of source CIDR ranges that this firewall applies to"
}

variable "fw_source_tags" {
  description = "A list of source tags for this firewall rule"
}

variable "fw_target_tags" {
  description = "A list of target tags for this firewall rule"
}
