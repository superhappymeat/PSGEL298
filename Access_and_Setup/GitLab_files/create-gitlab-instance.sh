#!/bin/bash
# Script to deploy GitLab and configure the DNS name for the students GitLab instance.
echo "Remove any existing gitlab namespace"
kubectl delete namespace gitlab
kubectl create namespace gitlab

GIT_URL={{ GIT_HOST }}
printf "\n\nStarting the GitLab install for: ${GIT_URL}\n"
sleep 2
kubectl -n gitlab apply -f ~/project/operator-driven/working/gitlab-install.yaml

# Write out the GitLab URL
#printf "\nYour GitLab URL is: ${GIT_URL} \n\n"
printf "\nWaiting for GitLab to be Ready (this can take 6 to 7 minutes)...\n"

# Monitor the status of the webservice appliction (gitlab-webservice-default).
# This method isn't dependent on the wildcard DNS being setup.
# There are two instances, so wait for both to be ready.
while [[ $(kubectl get pods -l app=webservice -n gitlab -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True" ]]; do
  printf "..."
  sleep 5
  printf "..."
  sleep 5
done

printf "\n\nGitLab status is: READY\n"
printf "Extra wait for the system to stablize.\n"
sleep 10

# Get the Public IP for GitLab
printf "\nGet the Public IP for the GitLab instance\n"
GIT_LBIP=$(kubectl get service -n gitlab | grep LoadBalancer | awk '{print $4}')

az network public-ip list --subscription {{ SUBSCRIPTION }} --out table | grep ${GIT_LBIP} | awk '{print $1}' | tee ~/.Git_publicIP_name.txt

printf "\nCreate the DNS alias\n"
PublicIPName=$(cat ~/.Git_publicIP_name.txt)

az network public-ip update --resource-group {{ MC_RG }} --name $PublicIPName --dns-name gitlab-{{ JMP_HOST }}

printf "\nYour GitLab URL is: http://${GIT_URL} \n\n"

printf "\nGetting the password for the GitLab root user\n"
gitlab_root_pw=$(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode )
#echo $gitlab_root_pw

printf "\n* GitLab URL: http://${GIT_URL}/  (User=root Password=${gitlab_root_pw})\n\n" | tee -a ~/urls.md

printf "\nRun the following command to get the GitLab URL and password: \e[1;32mcat ~/urls.md | grep gitlab\e[0m\n"

printf "\nSet-up complete!\n\n"

