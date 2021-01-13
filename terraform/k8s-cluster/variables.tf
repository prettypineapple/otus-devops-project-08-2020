variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
}

variable kube_cluster_name {
  description = "Cluster name"
}

variable kube_node_pool_name {
  description = "Cluster name"
}

variable machine_type {
  description = "Machine_type"
}

variable node_count {
  description = "Nodes count"
}

variable node_disk_size_gb {
  description = "Node disk size in Gb"
}

variable "node_image_type" {
  description = "The image type to use for nodes."
  default     = "COS"
}

variable "network" {
  description = "The name or self_link of the Google Compute Engine network to which the cluster is connected"
  default     = "default"
}

variable "fw_name" {
  description = "The name of the firewall rule"
  default     = "allow-ssh"
}

//variable "fw_network" {
//  description = "The network this firewall rule applies to"
//  default     = "default"
//}

variable "fw_priority" {
  description = "The firewall rule priority"
  default     = "1000"
}

variable "fw_protocol" {
  description = "The name of the protocol to allow"
  default     = "tcp"
}

variable "fw_ports" {
  description = "A list of ports and/or port ranges to allow"
  default = ["22"]
}

variable "fw_source_ranges" {
  description = "A list of source CIDR ranges that this firewall applies to"
  default     = ["0.0.0.0/0"]
}

variable "fw_source_tags" {
  description = "A list of source tags for this firewall rule"
  default     = []
}

//variable "fw_target_tags" {
//  description = "A list of target tags for this firewall rule"
//  default     = []
//}

variable "master_version" {
  description = "Cluster version"
}


variable "k8s-network-tag" {
  description = "k8s cluster network tag"
}
