prefix                               = "{{tfvars_prefix}}"
location                             = "{{tfvars_location}}"
ssh_public_key                       = "~/.ssh/id_rsa.pub"

## General config
kubernetes_version                   = "{{tfvars_k8s_version}}"

# no jump host machine
create_jump_public_ip                = false

# tags in azure
tags                                 = { {{tfvars_tags}} }

## Admin Access
# IP Ranges allowed to access all created cloud resources
#default_public_access_cidrs         = ["109.232.56.224/27", "149.173.0.0/16", "194.206.69.176/28"]
# we allow access from the RACE VMWARE and RACE Azure clients network
default_public_access_cidrs          = ["149.173.0.0/16", "52.226.102.80/31"]
cluster_endpoint_public_access_cidrs = ["149.173.0.0/16", "52.226.102.80/31"]

## Storage
# "standard" creates NFS server VM, "ha" creates Azure Netapp Files
# Storage for SAS Viya CAS/Compute
storage_type                         = "standard"
# required ONLY when storage_type is "standard" to create NFS Server VM
create_nfs_public_ip = true            # # we want to be able to access our NFS server VM form the outside.
nfs_vm_admin         = "nfsuser"
nfs_vm_machine_type  = "Standard_D8s_v4"
nfs_raid_disk_size   = 128
nfs_raid_disk_type   = "Standard_LRS"

# Default node pool
default_nodepool_vm_type             = "Standard_D4_v4"   # 4x16 no Temp storage
default_nodepool_min_nodes           = 1
default_nodepool_max_nodes           = 3
default_nodepool_max_pods            = 80
default_nodepool_availability_zones  = ["1"]

# Additional node pools
node_pools_availability_zone         = "1"
node_pools_proximity_placement       = false

# AKS Node Pools config
node_pools = {
  cas = {
    "machine_type" = "Standard_E4ds_v4"         # 4x32 w 150GiB SSD
    "os_disk_size" = 200
    "min_nodes" = 1
    "max_nodes" = 10
    "max_pods"  = 30                            # max_pods must be greater than 10
    "node_taints" = ["workload.sas.com/class=cas:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class" = "cas"
    }
  },
  compute = {
    #"machine_type" = "Standard_L8s_v2"         # 8x64 w 80GBSSD 1.9TB NVMe
    "machine_type" = "Standard_E8ds_v4"         # 8x64 w 300GiB SSD
    "os_disk_size" = 200
    "min_nodes" = 1
    "max_nodes" = 1
    "max_pods"  = 30
    "node_taints" = ["workload.sas.com/class=compute:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class"        = "compute"
      "launcher.sas.com/prepullImage" = "sas-programming-environment"
    }
  },
  connect = {
    #"machine_type" = "Standard_L8s_v2"         # 8x64 w 80GBSSD 1.9TB NVMe
    "machine_type" = "Standard_E8ds_v4"         # 8x64 w 300GiB SSD
    "os_disk_size" = 200
    "min_nodes" = 0
    "max_nodes" = 1
    "max_pods"  = 20
    "node_taints" = ["workload.sas.com/class=connect:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class"        = "connect"
      "launcher.sas.com/prepullImage" = "sas-programming-environment"
    }
  },
  stateless = {
    "machine_type" = "Standard_D8s_v4"            # 8x32 no local Temp storage
    "os_disk_size" = 200
    "min_nodes" = 1
    "max_nodes" = 6
    "max_pods"  = 80
    "node_taints" = ["workload.sas.com/class=stateless:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class" = "stateless"
    }
  },
  stateful = {
    "machine_type" = "Standard_D8s_v4"            # 8x32 no local Temp storage
    "os_disk_size" = 200
    "min_nodes" = 1
    "max_nodes" = 6
    "max_pods"  = 80
    "node_taints" = ["workload.sas.com/class=stateful:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class" = "stateful"
    }
  }
}

# Azure Postgres config
# Changed with 4.1.0
# Comment out this code block when using internal Crunchy Postgres and Azure Postgres is NOT needed
postgres_servers = {
  default = {
    sku_name                     = "GP_Gen5_8"
    administrator_login          = "pgadmin"
    administrator_password       = "LNX_sas_123"
    ssl_enforcement_enabled      = false
  }
}

# Azure Container Registry
# We will use external orders and pull images from SAS Hosted registries
create_container_registry           = false
container_registry_sku              = "Standard"
container_registry_admin_enabled    = "false"
container_registry_geo_replica_locs = null

# Azure Monitor
create_aks_azure_monitor = false
