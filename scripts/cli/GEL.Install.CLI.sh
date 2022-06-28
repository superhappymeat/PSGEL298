#!/bin/bash
# This script will install the SAS Viya CLI
# Note: The CLI package itself has already been downloaded from the SAS Support site
# The CLI addins will be installed from the production external repository

# Remove the existing CLI
cd ~
sudo rm -rf /opt/sas/viya/home
rm -rf  ~/.sas/viya-plugins/

# Create the required directory
sudo mkdir -p /opt/sas/viya/home/bin

# Download & Extract CLI
printf "\nDownloading and Extracting the SAS Viya CLI\n"
sudo wget -O /opt/sas/viya/home/sas-viya-cli-1.19.1-linux-amd64.tgz --quiet https://gelgitlab.race.sas.com/GEL/workshops/PSGEL263-sas-viya-4.0.1-advanced-topics-in-authentication/-/raw/main/scripts/sas-viya-cli-1.19.1-linux-amd64.tgz
sudo tar -zxf /opt/sas/viya/home/sas-viya-cli-1.19.1-linux-amd64.tgz -C /opt/sas/viya/home/bin/

# Install Plugins
printf "\nInstall Plugins\n"
#myPlugins=`/opt/sas/viya/home/bin/sas-viya plugins list-repo-plugins |awk 'NR>3 {print $1}'|head -n -1|sed 's/\*//g'`
#for myPlugin in ${myPlugins}; do
#  /opt/sas/viya/home/bin/sas-viya plugins install -repo SAS ${myPlugin}
#done
/opt/sas/viya/home/bin/sas-viya plugins install -repo SAS all

# Fetch pyviyatools
rm -rf ~/admin/pyviyatools
mkdir -p ~/admin/pyviyatools
git -C ~/admin/ clone https://github.com/sassoftware/pyviyatools.git

printf "Installation complete\n"
