#!/bin/bash
####################################################################################
#        Name: GEL.520.SP.Login.sh                                                 #
# Description: This script is required so that the viya4-iac container can cache   #
#              the Azure credentials. This is needed for the connection to the     #
#              NFS Server to create the folder structures for the Viya deployment. #
# -------------------------------------------------------------------------------- #
# Mike Goddard,        Initial release,                                   MAY-2022 #
####################################################################################
#set -x

# The WORKSPACE is the volume mount within the Docker container
Workspace="/workspace"

# Credentials to be stored in $HOME/deploy-using-docker/workspace/azure

GELENABLE_WORKSHOP_CODE=PSGEL298
mySP_Id=$(curl -sk https://gelweb.race.sas.com/scripts/gelenable/security/${GELENABLE_WORKSHOP_CODE}_sp_id.txt)
myTentant_Id=$(curl -sk https://gelweb.race.sas.com/scripts/gelenable/security/tenantID.txt)

#myResult=$(az login --service-principal -u ${mySP_Id} -p ${Workspace}/vars/GELENABLE_CREDS/SP_cert.pem -t ${myTentant_Id})
az login --service-principal -u ${mySP_Id} -p ${Workspace}/vars/GELENABLE_CREDS/SP_cert.pem -t ${myTentant_Id}

#if [[ -z "${myResult}" ]] ; then
#    echo "ERROR: Something went wrong authenitcating using the Workshop Service Principal"
#    exit 99
#fi