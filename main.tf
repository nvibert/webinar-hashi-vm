provider "vsphere" {
  vsphere_user                 = var.vsphere_user
  vsphere_password             = var.vsphere_password
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
  name          = "10.10.10.68"
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
Deploy Blue VMs
==================================================================*/

resource "vsphere_virtual_machine" "Blue" {
  lifecycle {
    ignore_changes = [storage_policy_id, disk.0.storage_policy_id]
  }
  count = var.demo_count
  name   = "Blue-VM-${count.index + 1}"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id
  datacenter_id     = data.vsphere_datacenter.dc.id
  host_system_id    = data.vsphere_host.host.id
  folder            = "Workloads"
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout = 0

  ovf_deploy {
    remote_ovf_url = "https://vmworld2020.s3-us-west-2.amazonaws.com/photon13.ova"
    disk_provisioning = "thin"
    ovf_network_map = {
      "sddc-cgw-network-1" = data.vsphere_network.network12.id
    }
  }
  tags = [
    vsphere_tag.tag.id        # vSphere Colored VM
  ]
}

/*=================================================================
Deploy Red VMs
==================================================================*/

resource "vsphere_virtual_machine" "Red" {
  lifecycle {
    ignore_changes = [storage_policy_id, disk.0.storage_policy_id]
  }
  count = var.demo_count
  name   = "Red-VM-${count.index + 1}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id = data.vsphere_datastore.datastore.id
  datacenter_id = data.vsphere_datacenter.dc.id
  host_system_id = data.vsphere_host.host.id
  folder           = "Workloads"
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout = 0

  ovf_deploy {
    remote_ovf_url = "https://vmworld2020.s3-us-west-2.amazonaws.com/photon13.ova"
    disk_provisioning = "thin"
    ovf_network_map = {
      "sddc-cgw-network-1" = data.vsphere_network.network12.id
    }
  }
  tags = [
    vsphere_tag.tag.id        # vSphere Colored VM
  ]
}


/*=================================================================
Define vSphere tags
==================================================================*/
resource "vsphere_tag_category" "category" {
  name        = "ColoredVMs"
  cardinality = "SINGLE"
  description = "Managed by Terraform"

  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "tag" {
  name        = "vSphere_tag"
  category_id = vsphere_tag_category.category.id
  description = "Managed by Terraform"
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
    thin_provisioned = false
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
