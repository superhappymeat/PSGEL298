#!/bin/bash
####################################################################################
#        Name: GEL.010.Define.Environment.sh                                       #
# Description: Ensure azure variables are set for the workshop                     #
#              This is based off GEL.0910.Optional.GELENABLE.Workshop.SP.Logon.sh  #
# -------------------------------------------------------------------------------- #
# Mike Goddard,        Initial release,                                   APR-2022 #
####################################################################################
#set -x

FUNCTION_FILE=/opt/gellow_code/scripts/common/common_functions.shinc
source <( cat ${FUNCTION_FILE}  )

function logon-sp () {
    if  isFirstHost   ;     then

        WORK_DIR=$HOME/project
        GELENABLE_WORKSHOP_CODE=PSGEL298

        logit "Obtain credentials"
        mkdir -p ${WORK_DIR}/vars/GELENABLE_CREDS
        curl -sk https://gelweb.race.sas.com/scripts/gelenable/security/${GELENABLE_WORKSHOP_CODE}_sp_cert.pem > ${WORK_DIR}/vars/GELENABLE_CREDS/SP_cert.pem
        curl -sk https://gelweb.race.sas.com/scripts/gelenable/security/${GELENABLE_WORKSHOP_CODE}_sp_cert.pfx > ${WORK_DIR}/vars/GELENABLE_CREDS/SP_cert.pfx
        mySP_Id=$(curl -sk https://gelweb.race.sas.com/scripts/gelenable/security/${GELENABLE_WORKSHOP_CODE}_sp_id.txt)
        myTentant_Id=$(curl -sk https://gelweb.race.sas.com/scripts/gelenable/security/tenantID.txt)
        if [[ -z ${mySP_Id} ]] ; then
            logit "ERROR: Failed to obtain Workshop Service Principal ID"
            exit 99
        fi
        if [[ -z ${myTentant_Id} ]] ; then
            logit "ERROR: Failed to obtain GELENABLE Tenant ID"
            exit 99
        fi
        if ! [[ -f ${WORK_DIR}/vars/GELENABLE_CREDS/SP_cert.pem ]] ; then
            logit "ERROR: Failed to obtain Workshop Service Principal Certificate"
            exit 99
        fi

        logit "Authenticate using Azure CLI"
        myResult=$(az login --service-principal -u ${mySP_Id} -p ${WORK_DIR}/vars/GELENABLE_CREDS/SP_cert.pem -t ${myTentant_Id})
        if [[ -z ${myResult} ]] ; then
            logit "ERROR: Something went wrong authenitcating the Workshop Service Principal"
            exit 99
        fi

        # Fetch Workshop Subscription ID
        SubscriptionID=$(echo ${myResult}|jq -r --arg test1 "${GELENABLE_WORKSHOP_CODE}" '.[] | select(.name | contains($test1)) | .id')
        logit "Workshop Subscription ID: ${SubscriptionID}"

        # Set the Azure subscription
        az account list
        az account set -s "${SubscriptionID}"

        # Fetch Persistent Subscription ID for DNS Updates
        PersistentSub=$(echo ${myResult}|jq -r --arg test1 "GEL Persistent Resources" '.[] | select(.name | contains($test1)) | .id')

        # Setup Environment Variables to authenticate with Workshop Service Principal
        TFCREDFILE=${WORK_DIR}/vars/.aztf_creds
        printf "%s\n" \
        "ARM_CLIENT_ID=${mySP_Id}" \
        "ARM_CLIENT_CERTIFICATE_PATH=${WORK_DIR}/vars/GELENABLE_CREDS/SP_cert.pfx" \
        "ARM_CLIENT_CERTIFICATE_PASSWORD=lnxsas" \
        "ARM_SUBSCRIPTION_ID=${SubscriptionID}" \
        "TF_VAR_subscription_id=${SubscriptionID}" \
        "ARM_TENANT_ID=${myTentant_Id}" \
        "TF_VAR_tenant_id=${myTentant_Id}" \
        "GEL_PERSISTENT_SUB=${PersistentSub}" \
        | tee ${TFCREDFILE}
        # Set Terraform variables to file
        #TFCREDFILE=~/.aztf_creds
        #echo "TF_VAR_subscription_id=${SubscriptionID}" > ${TFCREDFILE}
        #echo "TF_VAR_tenant_id=${myTentant_Id}" >> ${TFCREDFILE}

    fi
}

case "$1" in
    'enable')
    ;;
    'start')
        logit "Authenticate GELENABLE Workshop Service Principal. "
        logit 'If you want it, execute:
        export GELENABLE_WORKSHOP_CODE=PSGEL###
        export GELENABLE_SIZE=small
        sudo -E bash $(find ${CODE_DIR}/scripts/loop/viya4/ -iname *optional*GELENABLE*SP.Logon* -type f) logon-sp'
    ;;
    'stop')

    ;;
    'clean')

    ;;
    'logon-sp')
        logon-sp

    ;;
    'validate')

    ;;
    'list')

    ;;

    *)
        printf "\nThe parameter '$1' does not do anything in the script '`basename "$0"`' \n"
        exit 0
    ;;
esac
