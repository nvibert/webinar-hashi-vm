variable "data_center" { default = "SDDC-Datacenter" }
variable "cluster" { default = "Cluster-1" }
variable "workload_datastore" { default = "WorkloadDatastore" }
variable "compute_pool" { default = "Compute-ResourcePool" }

variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}


variable "Subnet12_name"      { default = "segment12"}
variable "Subnet13_name"      { default = "segment13" }
variable "subnet12"           { default = "12.12.12.0/24"}
variable "subnet13"           { default = "13.13.13.0/24"}

variable "demo_count"         { default = 3 }