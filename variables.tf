variable "data_center" { default = "SDDC-Datacenter" }
variable "cluster" { default = "Cluster-1" }
variable "workload_datastore" { default = "WorkloadDatastore" }
variable "compute_pool" { default = "Compute-ResourcePool" }

variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}


variable "Subnet12_name"      {}
variable "Subnet13_name"      {}
variable "subnet12"           {}
variable "subnet13"           {}

variable "demo_count"         { default = 3 }

