#!/bin/bash
####################################################################################
#        Name: GEL.020.Create.AADDS.NSG.rule.sh                                    #
# Description: NSG rule to allow access to Azure Active Directory Domain Services  #
#              Required to allow access to the LDAPS interface                     #
#              This is based off GEL.0911.Optional.GELENABLE.IAC.sh                #
# -------------------------------------------------------------------------------- #
# Mike Goddard,        Initial release,                                   MAY-2022 #
####################################################################################
#set -x

WORK_DIR=$HOME/project/vars
ADDS_NSG="aadds-nsg"
ADDS_RG="GEL_AZADDS"
ADDS_SUB="5483d6c1-65f0-400d-9910-a7a448614167"
#AzureRegion=$(echo ${myAzureRegion}|tr -d "'")
RG=$(cat ${WORK_DIR}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
node_rg=$(cat ${WORK_DIR}/variables.txt | grep node-res-group | awk -F'::' '{print $2}')
AKS_NAME=$(cat ${WORK_DIR}/variables.txt | grep cluster-name | awk -F'::' '{print $2}')

PublicIPName=$(az network lb show -g ${node_rg} -n kubernetes --query "frontendIpConfigurations[].publicIpAddress.id" -o tsv |grep -v kubernetes|awk -F'/' '{print $NF}')
PublicIPAdd=$(az network public-ip show -g ${node_rg} -n ${PublicIPName} --query "ipAddress" -o tsv)
ADDS_Priority=$(az network nsg rule list --nsg-name ${ADDS_NSG} --resource-group ${ADDS_RG} --subscription ${ADDS_SUB} -o tsv --query "[].priority"|tail -1)
ADDS_Priority=$((ADDS_Priority+1))
myResult=$(az network nsg rule create --name ${RG}_to_ADDS --nsg-name ${ADDS_NSG} --resource-group ${ADDS_RG} --subscription ${ADDS_SUB} --priority ${ADDS_Priority} \
    --access Allow --destination-address-prefixes "VirtualNetwork" --destination-port-ranges 636 --direction Inbound --protocol '*' \
    --source-address-prefixes ${PublicIPAdd} --source-port-ranges '*')
    retVal=$?
if [ $retVal -ne 0 ]; then
    # Deal with multiple rules being added at the same time so the priority has clashed with another rule
    sleep 5
    ADDS_Priority=$(az network nsg rule list --nsg-name ${ADDS_NSG} --resource-group ${ADDS_RG} --subscription ${ADDS_SUB} -o tsv --query "[].priority"|tail -1)
    ADDS_Priority=$((ADDS_Priority+1))
    myResult=$(az network nsg rule create --name ${RG}_to_ADDS --nsg-name ${ADDS_NSG} --resource-group ${ADDS_RG} --subscription ${ADDS_SUB} --priority ${ADDS_Priority} \
    --access Allow --destination-address-prefixes "VirtualNetwork" --destination-port-ranges 636 --direction Inbound --protocol '*' \
    --source-address-prefixes ${PublicIPAdd} --source-port-ranges '*')
fi

