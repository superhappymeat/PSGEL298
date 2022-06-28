#!/bin/bash
####################################################################################
#        Name: GEL.500.Delete.Environment.sh                                       #
# Description: This script is to clean-up the AKS cluster and resources            #
#              This is based off GEL.0911.Optional.GELENABLE.IAC.sh                #
# -------------------------------------------------------------------------------- #
# Mike Goddard,        Initial release,                                   MAY-2022 #
####################################################################################
#set -x

# Set the colour codes
Color_Off='\033[0m'       # Text Reset
Yellow='\033[1;33m'       # Yellow

# Get the resource names
WORK_DIR=$HOME/deploy-using-docker/workspace
RG=$(cat ${WORK_DIR}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
node_rg=$(cat ${WORK_DIR}/variables.txt | grep node-res-group | awk -F'::' '{print $2}')
myCluster=$(cat ${WORK_DIR}/variables.txt | grep cluster-name | awk -F'::' '{print $2}')
#gelACR="/subscriptions/5483d6c1-65f0-400d-9910-a7a448614167/resourceGroups/GEL_ContainerRegistry/providers/Microsoft.ContainerRegistry/registries/gelcontainerregistry"
#ADDS_NSG="aadds-nsg"
#ADDS_RG="GEL_AZADDS"
#ADDS_SUB="5483d6c1-65f0-400d-9910-a7a448614167"
GEL_PERSISTENT_SUB=$(cat ${WORK_DIR}/vars/.aztf_creds | grep GEL_PERSISTENT_SUB | awk -F'=' '{print $2}')

printf "\n\n${Yellow}You are about to delete your AKS cluster and related resources!${Color_Off}\n\n"

read -n 1 -p "  Delete AKS resources (Y/N): " input

if [ "$input" = "Y" ]; then
  # Detach GEL Azure Container Registry - ensures RBAC is cleaned up easily - takes 2mins to run
  #printf "\n\nDetaching the  GEL Azure Container Registry - this takes around 2mins to run\n"
  #az aks update -g ${RG} -n ${myCluster} --detach-acr ${gelACR}

  # Remove AADDS NSG rule
  #printf "\nRemoving the AADDS NSG rule\n"
  #az network nsg rule delete --name ${RG}_to_ADDS --nsg-name ${ADDS_NSG} --resource-group ${ADDS_RG} --subscription ${ADDS_SUB}

  # az group delete --resource-group MyResourceGroup
  printf "\n\nDeleteing Resource Group: ${RG}\n"
  az group delete --resource-group ${RG} --yes
  printf "\nDeleteing Resource Group: ${node_rg}\n"
  az group delete --resource-group ${node_rg} --yes

  # Delete DNS entries from the GEL DNS
  printf "\n\nDeleteing the entries in the GEL DNS\n"
  az network dns record-set a delete -g gel_dns -z gelenable.sas.com -n ${RG} --subscription ${GEL_PERSISTENT_SUB} --yes
  az network dns record-set a delete -g gel_dns -z gelenable.sas.com -n *.${RG} --subscription ${GEL_PERSISTENT_SUB} --yes

  printf "\n\nDelete operation completed.\n\n"
fi


