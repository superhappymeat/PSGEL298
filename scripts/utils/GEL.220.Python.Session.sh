#!/bin/bash
####################################################################################
#        Name: GEL.220.Python.Session.sh                                           #
# Description: Generate the code for the Python exercise (session)                 #
# -------------------------------------------------------------------------------- #
# Mike Goddard,        Initial release,                                   MAY-2022 #
####################################################################################
#set -x

# Set the colour codes
Color_Off='\033[0m'       # Text Reset
Green='\033[0;32m'        # Green
BGreen='\033[1;32m'       # Bold Green
BIGreen='\033[1;92m'      # Bold High Green
Yellow='\033[0;33m'       # Yellow

# Set variables
WORK_DIR=$HOME/project/vars
RG=$(cat ${WORK_DIR}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
aks_alias=${RG}.$(cat ~/azureregion.txt).cloudapp.azure.com
gelenable_alias=${RG}.gelenable.sas.com

printf "\n\n${BIGreen}Copy the following code into the Python session\n"
printf "_______________________________________________________________________________________________${Color_Off}\n\n"
printf "import swat\n"
printf "import os\n"
printf "os.environ['TKESSL_OPENSSL_LIB'] = '/lib/x86_64-linux-gnu/libssl.so.1.1'\n"
printf "os.environ['CAS_CLIENT_SSL_CA_LIST'] = '/tmp/my_ca_certificate.pem'\n"
printf "casingress=\"https://prod.${gelenable_alias}:443/cas-shared-default-http\"\n"
printf "conn = swat.CAS(casingress, username=\"gatedemo001\", password=\"Metadata0\")\n"
printf "conn.serverstatus()\n"
printf "${BIGreen}_______________________________________________________________________________________________${Color_Off}\n\n"
