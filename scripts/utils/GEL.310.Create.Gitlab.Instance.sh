#!/bin/bash
####################################################################################
#        Name: GEL.310.Create.Gitlab.Instance.sh                                   #
# Description: Script to deploy Gitlab in the Students cluster                     #
#              Updated to use the GELENABLE DNS                                    #
# -------------------------------------------------------------------------------- #
# Mike Goddard,        Initial release,                                   MAY-2022 #
####################################################################################
#set -x

# Get the required variables
WORK_DIR=$HOME/project/vars
RG=$(cat ${WORK_DIR}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
GIT_HOST=${RG}.gelenable.sas.com
#AKS_NAME=$(cat ${WORK_DIR}/variables.txt | grep cluster-name | awk -F'::' '{print $2}')
#SUBSCRIPTION=$(cat ${WORK_DIR}/.aztf_creds | grep ARM_SUBSCRIPTION_ID | awk -F'=' '{print $2}')
#MC_RG=$(cat ${WORK_DIR}/variables.txt | grep node-res-group | awk -F'::' '{print $2}')

printf "\n\nRemove any existing gitlab namespace\n"
kubectl delete namespace gitlab
kubectl create namespace gitlab

GIT_URL=gitlab.${GIT_HOST}
printf "\n\nInstalling the GitLab instance: ${GIT_URL}\n"
sleep 2
#kubectl -n gitlab apply -f ~/project/operator-driven/working/gitlab-install.yaml
#kubectl -n gitlab apply -f ~/project/operator-driven/working/gelenable-gitlab-install.yaml

printf "\n\nUpdating the Helm repo for the Gitlab install\n\n"
# Update Helm for the Gitlab install
## the Helm repo for gitlab:
helm repo add gitlab https://charts.gitlab.io/
## update its content
helm repo update

printf "\nStarting the GitLab install for: ${GIT_URL}\n\n"
sleep 2

helm upgrade --install gitlab gitlab/gitlab \
--timeout 600s \
--set global.hosts.domain=${GIT_HOST} \
--set global.hosts.https=false \
--set certmanager-issuer.email=me@example.com \
--set global.edition=ce \
--set nginx-ingress.enabled=false \
--set global.ingress.enabled=true \
--set global.ingress.class=nginx \
--set global.ingress.tls.enabled=false \
--namespace gitlab \
--version v4.10.2 \
--set postgresql.image.registry=gelcontainerregistry.azurecr.io \
--set postgresql.image.repository=bitnami/postgresql \
--set postgresql.image.tag=11.9.0 \
--set postgresql.metrics.image.registry=gelcontainerregistry.azurecr.io \
--set postgresql.metrics.image.repository=bitnami/postgres-exporter \
--set postgresql.metrics.image.tag=0.8.0-debian-10-r99 \
--set postgresql.volumePermissions.image.registry=gelcontainerregistry.azurecr.io \
--set postgresql.volumePermissions.image.repository=bitnami/minideb:buster \
--set global.minio.image=gelcontainerregistry.azurecr.io/minio/minio:RELEASE.2017-12-28T01-21-00Z \
--set global.minio.minioMc.image=gelcontainerregistry.azurecr.io/minio/minio:RELEASE.2017-12-28T01-21-00Z \
--set minio.image=gelcontainerregistry.azurecr.io/minio/minio \
--set minio.tag=RELEASE.2017-12-28T01-21-00Z \
--set minio.minioMc.image=gelcontainerregistry.azurecr.io/minio/minio \
--set minio.minioMc.tag=RELEASE.2017-12-28T01-21-00Z \
--set busybox.image.repository=gelcontainerregistry.azurecr.io/busybox:latest \
--set redis.image.registry=gelcontainerregistry.azurecr.io \
--set redis.image.repository=bitnami/redis \
--set redis.image.tag=6.0.9-debian-10-r0 \
--set redis.metrics.image.registry=gelcontainerregistry.azurecr.io \
--set redis.metrics.image.repository=bitnami/redis-exporter \
--set redis.metrics.image.tag=1.12.1-debian-10-r11 \
--set redis.sentinel.image.registry=gelcontainerregistry.azurecr.io \
--set redis.sentinel.image.repository=bitnami/redis-sentinel:6.0.8-debian-10-r55 \
--set redis.sysctlImage.registry=gelcontainerregistry.azurecr.io \
--set redis.sysctlIimage.repository=bitnami/minideb:buster \
--set redis.volumePermissions.image.registry=gelcontainerregistry.azurecr.io \
--set redis.volumePermissions.image.repository=bitnami/minideb:buster \
--set nginx-ingress.controller.admissionWebhooks.patch.image.repository=gelcontainerregistry.azurecr.io/jettech/kube-webhook-certgen:v1.5.0 \
--set prometheus.server.image.repository=gelcontainerregistry.azurecr.io/prom/prometheus \
--set prometheus.server.image.tag=v2.15.2


# Write out the GitLab URL
#printf "\nYour GitLab URL is: ${GIT_URL} \n\n"
printf "\nWaiting for GitLab to be Ready (this can take 3 to 4 minutes)...\n"

# Monitor the status of the webservice appliction (gitlab-webservice-default).
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

printf "\nYour GitLab URL is: http://${GIT_URL} \n"

printf "\nGetting the password for the GitLab root user\n\n"
gitlab_root_pw=$(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode )

# Write the GitLab information to a file
rm $HOME/gitlab-details.txt
echo "Your GitLab instance information" | tee -a ~/gitlab-details.txt
echo "  GitLab URL: http://${GIT_URL}/" | tee -a ~/gitlab-details.txt
echo "  Admin user: root" | tee -a ~/gitlab-details.txt
echo "  Password:   ${gitlab_root_pw}" | tee -a ~/gitlab-details.txt

printf "\nRun the following command to get the GitLab URL and password: \e[1;32mcat ~/gitlab-details.txt\e[0m\n"

printf "\nSet-up complete!\n\n"

