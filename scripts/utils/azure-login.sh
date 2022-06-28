#!/bin/bash
####################################################################################
#        Name: azure-login.sh                                                      #
# Description: This is based off GEL.0910.Optional.GELENABLE.Workshop.SP.Logon.sh  #
#              If the Azure session end, run this script to login to Azure         #
# -------------------------------------------------------------------------------- #
# Mike Goddard,        Initial release,                                   MAY-2022 #
####################################################################################
#set -x

WORK_DIR=$HOME/project
GELENABLE_WORKSHOP_CODE=PSGEL298
mySP_Id=$(curl -sk https://gelweb.race.sas.com/scripts/gelenable/security/${GELENABLE_WORKSHOP_CODE}_sp_id.txt)
myTentant_Id=$(curl -sk https://gelweb.race.sas.com/scripts/gelenable/security/tenantID.txt)

myResult=$(az login --service-principal -u ${mySP_Id} -p ${WORK_DIR}/vars/GELENABLE_CREDS/SP_cert.pem -t ${myTentant_Id})
if [[ -z ${myResult} ]] ; then
    logit "ERROR: Something went wrong authenitcating the Workshop Service Principal"
    exit 99
fi
