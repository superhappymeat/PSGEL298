#!/bin/bash
# Script to wait for the user to confirm that the Git project is public
printf "\n\n"
printf "      \e[1;33m**********************************************************\n"
printf "      \e[1;33m**********************************************************\n"
printf "      \e[1;33m**  IMPORTANT!                                          **\n"
printf "      \e[1;33m**  The Discovery project needs to be Public.           **\n"
printf "      \e[1;33m**                                                      **\n"
printf "      \e[1;33m**  Change the visibility of the project now.           **\n"
printf "      \e[1;33m**********************************************************\n"
printf "      \e[1;33m**********************************************************\e[0m\n\n"

printf "\nSee here for instructions: \nhttps://gelgitlab.race.sas.com/GEL/workshops/PSGEL298-sas-viya-4-deployment-on-azure-kubernetes-service/-/blob/main/Track-A-Standard/02-DepOp/02_310_Using_the_DO_with_a_Git_Repository.md#step-5-apply-the-cr-to-deploy-the-discovery-environment
\n"

printf "\n   Type 'Y' or 'yes' when the Discovery project has been set to 'Public'\n"
printf "     Or 'N' if you are not able to do it.\n\n"

while true
do
  read -r -p "Ready to proceed? [Y/N]:" input

  case $input in
    [yY][eE][sS]|[yY])
  echo "Yes"
  break
  ;;
    [nN][oO]|[nN])
  echo "No"
  break
  exit 1
  ;;
  *)
  echo "Invalid input..."
  ;;
 esac
done