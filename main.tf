provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.data_center
}
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_datastore" "datastore" {
  name          = var.workload_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.compute_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = "10.2.32.4"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "sddc-cgw-network-1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network12" {
  name          = var.Subnet12_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network13" {
  name          = var.Subnet13_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

/*=================================================================
Get Template data
==================================================================*/

data "vsphere_virtual_machine" "photo" {
  name          = "PhotoApp"
  datacenter_id = data.vsphere_datacenter.dc.id
}

/*=================================================================
Clone PhotoApp
==================================================================*/
resource "vsphere_virtual_machine" "terraform-photo" {
  name             = "terraform-photo"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = "Workloads"

  num_cpus = 2
  memory   = 1024
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = data.vsphere_network.network13.id
  }
  disk {
    label = "disk0"
    size  = 20
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.photo.id
    customize {
      linux_options {
        host_name = "PhotoApp"
        domain    = "vmc.local"
      }
      network_interface {
        ipv4_address = cidrhost(var.subnet13, 200) #fixed IP address .200
        ipv4_netmask = 24
      }
      ipv4_gateway = cidrhost(var.subnet13, 1)
    }
  }
}
