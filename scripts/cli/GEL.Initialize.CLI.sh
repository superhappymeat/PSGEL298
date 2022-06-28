#!/bin/bash
# This script will initialize the SAS Viya CLI to create the profile for the Viya namespace.
# At this piont there is little or no error checking.

# Setup default profile options
WORK_DIR=$HOME/project/vars
RG=$(cat ${WORK_DIR}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
aks_alias=${RG}.$(cat ~/azureregion.txt).cloudapp.azure.com  # Used for the Test deployment
gelenable_alias=${RG}.gelenable.sas.com

# Parmameters: GEL.Initilize.CLI.sh <namespace> -o <output format>
# $1 = Viya namespace
# $3 = Output format
NS=$1
outformat=$3

if [ -z ${outformat} ]; then 
  # If NULL set default output to text
  outformat="text";
fi

# Test for the namespace
if [ -z ${NS} ]; then
  printf "\nNo namespace provided\n\n"
  exit;
else
  ns_true=$(kubectl get ns | grep ${NS});
fi

if [[ -z ${ns_true} ]]; then
  # No namespace found
  printf "\nNo namespace found\n\n"
  exit;
else
  # Pull the Viya CA Certificate
  sudo rm /tmp/${NS}_ca_certificate.pem
  kubectl -n ${NS} get secret sas-viya-ca-certificate-secret -o go-template='{{(index .data "ca.crt")}}' | base64 -d > /tmp/${NS}_ca_certificate.pem

  export SSL_CERT_FILE=/tmp/${NS}_ca_certificate.pem

  if [ ${NS} = "test" ]; then
    INGRESS_URL=https://${aks_alias};
  else
    INGRESS_URL=https://${NS}.${gelenable_alias};
  fi

  printf "\n\nThe Viya endpoint URL is: ${INGRESS_URL}\n"
  # create the profile
  /opt/sas/viya/home/bin/sas-viya --profile ${NS} profile set-endpoint "${INGRESS_URL}"
  /opt/sas/viya/home/bin/sas-viya --profile ${NS} profile toggle-color off
  #/opt/sas/viya/home/bin/sas-viya --profile Default profile set-output fulljson
  /opt/sas/viya/home/bin/sas-viya --profile ${NS} profile set-output ${outformat};
fi


