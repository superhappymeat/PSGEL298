#!/bin/bash
####################################################################################
#        Name: WhatsMyDetails.sh                                                   #
# Description: Get the student details                                             #
#              Given the auto-generated names this is needed to get the details    #
# -------------------------------------------------------------------------------- #
# Mike Goddard,        Initial release,                                   May-2022 #
####################################################################################
#set -x

# Set the colour codes
Color_Off='\033[0m'       # Text Reset
Green='\033[0;32m'        # Green
BGreen='\033[1;32m'       # Bold Green
IGreen='\033[0;92m'       # High Intensity Green
BIGreen='\033[1;92m'      # Bold High Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
IBlue='\033[0;94m'        # High Intensity Blue
BIBlue='\033[1;94m'       # Bold High Intensity Blue
ICyan='\033[0;96m'        # Cyan

# Set the working dir
WORK_DIR=$HOME/project/vars
workspace=$HOME/deploy-using-docker/workspace

track=$1
option=$2

function get-prefix-a () {
    printf "\n"
    printf "________________________________________________________________________________________________\n\n"
    printf "This is your resource prefix: ${BIGreen}"$(cat ~/MY_PREFIX.txt)"${Color_Off}\n\n"
    printf "You can use this to filter resources in the Azure Portal\n"
    printf "Make sure you are in subscription: '${IBlue}PSGEL298 SAS Viya 4: Deployment on Azure Kubernetes Service${Color_Off}'\n"
    printf "________________________________________________________________________________________________\n\n"
}

function get-prefix-b () {
    printf "\n"
    printf "________________________________________________________________________________________________\n\n"
    printf "This is your resource prefix: ${BIGreen}"$(cat ~/MY_PREFIX.txt)"-b${Color_Off}\n\n"
    printf "You can use this to filter resources in the Azure Portal\n"
    printf "Make sure you are in subscription: '${IBlue}PSGEL298 SAS Viya 4: Deployment on Azure Kubernetes Service${Color_Off}'\n"
    printf "________________________________________________________________________________________________\n\n"
}

function get-resourcegroup-a () {
    # Maybe get these from the vars file
    RG=$(cat ${WORK_DIR}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
    mc_rg=$(cat ${WORK_DIR}/variables.txt | grep node-res-group | awk -F'::' '{print $2}')
    printf "________________________________________________________________________________________________\n\n"
    printf "Your Resource Group names are.\n"
    printf "  Primary resource group name: ${BIGreen}"${RG}"${Color_Off}\n"
    printf "  Node resource group name:    ${BIGreen}"${mc_rg}"${Color_Off}\n"
    printf "________________________________________________________________________________________________\n\n"
}

function get-resourcegroup-b () {
    RG=$(cat ${workspace}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
    mc_rg=$(cat ${workspace}/variables.txt | grep node-res-group | awk -F'::' '{print $2}')
    printf "________________________________________________________________________________________________\n\n"
    printf "Your Resource Group names are.\n"
    printf "  Primary resource group name: ${BIGreen}"${RG}"${Color_Off}\n"
    printf "  Node resource group name:    ${BIGreen}"${mc_rg}"${Color_Off}\n"
    printf "________________________________________________________________________________________________\n\n"
}

function list-urls-a () {
    RG=$(cat ${WORK_DIR}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
    aks_alias=${RG}.$(cat ~/azureregion.txt).cloudapp.azure.com
    gelenable_alias=${RG}.gelenable.sas.com
    printf "________________________________________________________________________________________________\n\n"
    printf "The Manual deployment exercise URLs are\n"
    printf "  - TEST deployment:      ${BIGreen}"https://${aks_alias}/SASDrive"${Color_Off}\n"
    printf "  - PROD deployment:      ${BIGreen}https://prod.${gelenable_alias}/SASDrive${Color_Off}\n"
    printf "\nThe Deployment Operator exercise URLs are\n"
    printf "  - GitLab:               ${BIGreen}http://gitlab.${gelenable_alias}/${Color_Off}\n"
    printf "  - Discovery deployment: ${BIGreen}https://discovery.${gelenable_alias}/SASDrive${Color_Off}\n"
    printf "________________________________________________________________________________________________\n\n"
}

function list-urls-b () {
    RG=$(cat ${workspace}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
    gelenable_alias=${RG}.gelenable.sas.com
    printf "________________________________________________________________________________________________\n\n"
    printf "The Docker deployment exercise URLs are\n"
    printf "  - VIYA4NFS deployment:      ${BIGreen}https://viya4nfs.${gelenable_alias}/SASDrive${Color_Off}\n"
    printf "________________________________________________________________________________________________\n\n"
}

function monitoring-a () {
    RG=$(cat ${WORK_DIR}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
    gelenable_alias=${RG}.gelenable.sas.com
    printf "________________________________________________________________________________________________\n\n"
    printf "Viya 4 Monitoring and Logging component URLs\n\n"
    printf "The Monitoring URLs are:\n"
    printf "  - Grafana:        ${BIGreen}https://${gelenable_alias}/grafana/${Color_Off}\n"
    printf "  - Prometheus:     ${BIGreen}https://${gelenable_alias}/prometheus/${Color_Off}\n"
    printf "  - Alertmanager:   ${BIGreen}https://${gelenable_alias}/alertmanager/${Color_Off}\n\n"
    printf "The Logging URLs are:\n"
    printf "  - Kibana:         ${BIGreen}http://${gelenable_alias}/kibana/${Color_Off}\n"
    printf "________________________________________________________________________________________________\n\n"
}

function list-details-a () {
    cluster=$(cat ~/variables.txt | grep cluster-name | awk -F'::' '{print $2}')
    location=$(cat ~/variables.txt | grep location | awk -F'::' '{print $2}')
    RG=$(cat ~/variables.txt | grep resource-group | awk -F'::' '{print $2}')
    mc_rg=$(cat ~/variables.txt | grep node-res-group | awk -F'::' '{print $2}')
    pg_server=$(cat ~/variables.txt | grep postgres-server | awk -F'::' '{print $2}')
    printf "________________________________________________________________________________________________\n\n"
    printf "Your Azure resource details are.\n"
    printf "  The resources are in Azure Region: ${BIGreen}"${location}"${Color_Off}\n"
    printf "  AKS cluster name:                  ${BIGreen}"${cluster}"${Color_Off}\n"
    printf "  Primary resource group name:       ${BIGreen}"${RG}"${Color_Off}\n"
    printf "  Node resource group name:          ${BIGreen}"${mc_rg}"${Color_Off}\n"
    printf "  Postgres Server name:              ${BIGreen}"${pg_server}"${Color_Off}\n"
    printf "________________________________________________________________________________________________\n\n"
}

function list-details-b () {
    cluster=$(cat ${workspace}/variables.txt | grep cluster-name | awk -F'::' '{print $2}')
    location=$(cat ${workspace}/variables.txt | grep location | awk -F'::' '{print $2}')
    RG=$(cat ${workspace}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
    mc_rg=$(cat ${workspace}/variables.txt | grep node-res-group | awk -F'::' '{print $2}')
    printf "________________________________________________________________________________________________\n\n"
    printf "Your Azure resource details are.\n"
    printf "  The resources are in Azure Region: ${BIGreen}"${location}"${Color_Off}\n"
    printf "  AKS cluster name:                  ${BIGreen}"${cluster}"${Color_Off}\n"
    printf "  Primary resource group name:       ${BIGreen}"${RG}"${Color_Off}\n"
    printf "  Node resource group name:          ${BIGreen}"${mc_rg}"${Color_Off}\n"
    printf "________________________________________________________________________________________________\n\n"
}

function details-help () {
    printf "\n\n"
    printf "Usage:   WhatsMyDetails [track] [options]\n\n"
    printf "Track:\n"
    printf "  -a            Display variables for Track-A\n"
    printf "  -b            Display variables for Track-B\n\n"
    printf "Options:\n"
    printf "  list          Display the Teraform variables\n"
    printf "  prefix        Display the details of the resource prefix that was generated\n"
    printf "  monitoring    List the Monitoring and Logging URLs\n"
    printf "  rg            Display the Resource Group information\n"
    printf "  urls          List the Viya URLs for your deployments\n"
    printf "\n\n"
}

function Track-A () {
    case "${option}" in
        'prefix')
        get-prefix-a
        ;;

        'rg')
        get-resourcegroup-a
        ;;

        'urls')
        list-urls-a
        ;;

        'list')
        list-details-a
        ;;

        'monitoring')
        monitoring-a
        ;;

        *)
        printf "\nThe parameter '$2' does not do anything in the script '`basename "$0"`' \n\n"
        exit 0
        ;;
    esac
}

function Track-B () {
    case "${option}" in
        'prefix')
        get-prefix-b
        ;;

        'rg')
        get-resourcegroup-b
        ;;

        'urls')
        list-urls-b
        ;;

        'list')
        list-details-b
        ;;

        *)
        printf "\nThe parameter '$2' does not do anything in the script '`basename "$0"`' \n\n"
        exit 0
        ;;
    esac
}

case "${track}" in
    '-a')
      Track-A
    ;;

    '-b')
      Track-B
    ;;

    '--help')
      details-help
    ;;

    *)
      #printf "\nThe parameter '$1' does not do anything in the script '`basename "$0"`' \n\n"
      printf "\nInvalid input, see help.\n"
      details-help
      #exit 0
    ;;
esac
