prefix                               = "{{tfvars_prefix}}"
location                             = "{{tfvars_location}}"

## public ssh key for VMs (access to the NFS Server VM with nfsuser account and the private key)
ssh_public_key                       = "/workspace/viya_deploy_idrsa.pub"

## General config
kubernetes_version                   = "{{tfvars_k8s_version}}"

# jump host machine (Reminder we can not SSH to outside from the RACE.EXNET machine)
create_jump_vm                       = false

# tags in azure
tags                                 = { {{tfvars_tags}} }

## Admin Access
# IP Ranges allowed to access all created cloud resources
#default_public_access_cidrs         = ["109.232.56.224/27", "149.173.0.0/16", "194.206.69.176/28"]
# we allow access from the RACE VMWARE and RACE Azure clients network
default_public_access_cidrs          = ["149.173.0.0/16", "52.226.102.80/31"]
cluster_endpoint_public_access_cidrs = ["149.173.0.0/16", "52.226.102.80/31"]

#vm_public_access_cidrs              = ["149.173.0.0/16"]

## Storage
# "standard" creates NFS server VM, "ha" creates Azure Netapp Files
storage_type                         = "standard"
# we want to be able to access our NFS server VM form the outside.
create_nfs_public_ip                 = true

default_nodepool_vm_type             = "Standard_D4_v4"   # 4x16 no Temp storage
default_nodepool_min_nodes           = 1

node_pools_proximity_placement       = false

default_nodepool_availability_zones  = ["1"]
node_pools_availability_zone         = "1"

# AKS Node Pools config
node_pools = {
  cas = {
    "machine_type" = "Standard_E4ds_v4"         # 4x32 w 150GiB SSD
    "os_disk_size" = 200
    "min_nodes" = 1
    "max_nodes" = 8
    "max_pods"  = 110
    "node_taints" = ["workload.sas.com/class=cas:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class" = "cas"
    }
  },
  compute = {
    #"machine_type" = "Standard_L8s_v2"        # # 8x64 w 80GBSSD 1.9TB NVMe @ 0.62
    "machine_type" = "Standard_E8ds_v4"         # 8x64 w 300GiB SSD
    "os_disk_size" = 200
    "min_nodes" = 1
    "max_nodes" = 1
    "max_pods"  = 110
    "node_taints" = ["workload.sas.com/class=compute:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class"        = "compute"
      "launcher.sas.com/prepullImage" = "sas-programming-environment"
    }
  },
  connect = {
    "machine_type" = "Standard_E8ds_v4"         # 8x64 w 300GiB SSD
    "os_disk_size" = 200
    "min_nodes" = 0
    "max_nodes" = 1
    "max_pods"  = 110
    "node_taints" = ["workload.sas.com/class=connect:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class"        = "connect"
      "launcher.sas.com/prepullImage" = "sas-programming-environment"
    }
  },
  stateless = {
    "machine_type" = "Standard_D8s_v4"            # 8x32 no local Temp storage
    "os_disk_size" = 200
    "min_nodes" = 0
    "max_nodes" = 3
    "max_pods"  = 110
    "node_taints" = ["workload.sas.com/class=stateless:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class" = "stateless"
    }
  },
  stateful = {
    "machine_type" = "Standard_D8s_v4"            # 8x32 no local Temp storage
    "os_disk_size" = 200
    "min_nodes" = 0
    "max_nodes" = 3
    "max_pods"  = 110
    "node_taints" = ["workload.sas.com/class=stateful:NoSchedule"]
    "node_labels" = {
      "workload.sas.com/class" = "stateful"
    }
  }
}

# Azure Postgres config
# Changed with 4.1.0
# Comment out this code block when using internal Crunchy Postgres and Azure Postgres is NOT needed
#postgres_servers = {
#  default = {
#    sku_name                     = "GP_Gen5_8"
#    administrator_login          = "pgadmin"
#    administrator_password       = "LNX_sas_123"
#    ssl_enforcement_enabled      = true
#  }
#}

# Azure Container Registry
# We will use external orders and pull images from SAS Hosted registries
create_container_registry           = false
