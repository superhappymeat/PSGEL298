![Global Enablement & Learning](https://gelgitlab.race.sas.com/GEL/utilities/writing-content-in-markdown/-/raw/master/img/gel_banner_logo_tech-partners.jpg)

# Registry migration to the new GELENABLE Tenant

## PULL images from the existing GEL Registry

1. Login to the Azure "sas-gelsandbox" subscription.

    ```sh
    az login --use-device-code
    ```

1. Login to the "Old" GEL Registry (gelregistry.azurecr.io)

    ```sh
    az acr login -n gelregistry.azurecr.io
    ```

1. Pull the images

    ```sh
    docker pull gelregistry.azurecr.io/bitnami/minideb:buster
    docker pull gelregistry.azurecr.io/bitnami/postgres-exporter:0.8.0-debian-10-r99
    docker pull gelregistry.azurecr.io/bitnami/postgresql:11.9.0
    docker pull gelregistry.azurecr.io/bitnami/redis:6.0.9-debian-10-r0
    docker pull gelregistry.azurecr.io/bitnami/redis-exporter:1.12.1-debian-10-r1
    docker pull gelregistry.azurecr.io/bitnami/redis-exporter:1.12.1-debian-10-r11
    docker pull gelregistry.azurecr.io/bitnami/redis-sentinel:6.0.8-debian-10-r55
    docker pull gelregistry.azurecr.io/busybox:latest
    docker pull gelregistry.azurecr.io/gelldap/mailhog:latest
    docker pull gelregistry.azurecr.io/gelldap/mailhog:v1.0.1
    docker pull gelregistry.azurecr.io/gelldap/openldap:1.4.0
    docker pull gelregistry.azurecr.io/gitlab/gitlab-runner:alpine-v13.9.0
    docker pull gelregistry.azurecr.io/jettech/kube-webhook-certgen:v1.5.0
    docker pull gelregistry.azurecr.io/minio/mc:RELEASE.2018-07-13T00-53-22Z
    docker pull gelregistry.azurecr.io/minio/minio:RELEASE.2017-12-28T01-21-00Z
    docker pull gelregistry.azurecr.io/prom/prometheus:v2.15.2
    docker pull gelregistry.azurecr.io/psgel305/autoauction1_0:latest
    docker pull gelregistry.azurecr.io/psgel305/autoauction3_0:latest
    docker pull gelregistry.azurecr.io/psgel305/autoauctiondec1_0:latest
    docker pull gelregistry.azurecr.io/psgel305/autoauctionnorthernstate1_0:latest
    docker pull gelregistry.azurecr.io/psgel305/qs_reg1:latest
    docker pull gelregistry.azurecr.io/psgel305/qs_reg_pmmlmodel:latest
    docker pull gelregistry.azurecr.io/psgel305/qs_tree1:latest
    ```

1. TAG the images for the 'gelcontainerregistry.azurecr.io' ACR.

    ```sh
    # Tag for 'gelcontainerregistry.azurecr.io'
    docker tag gelregistry.azurecr.io/bitnami/minideb:buster \
    gelcontainerregistry.azurecr.io/bitnami/minideb:buster

    docker tag gelregistry.azurecr.io/bitnami/postgres-exporter:0.8.0-debian-10-r99 \
    gelcontainerregistry.azurecr.io/bitnami/postgres-exporter:0.8.0-debian-10-r99

    docker tag gelregistry.azurecr.io/bitnami/postgresql:11.9.0 \
    gelcontainerregistry.azurecr.io/bitnami/postgresql:11.9.0

    docker tag gelregistry.azurecr.io/bitnami/redis:6.0.9-debian-10-r0 \
    gelcontainerregistry.azurecr.io/bitnami/redis:6.0.9-debian-10-r0

    docker tag gelregistry.azurecr.io/bitnami/redis-exporter:1.12.1-debian-10-r1 \
    gelcontainerregistry.azurecr.io/bitnami/redis-exporter:1.12.1-debian-10-r1

    docker tag gelregistry.azurecr.io/bitnami/redis-exporter:1.12.1-debian-10-r11 \
    gelcontainerregistry.azurecr.io/bitnami/redis-exporter:1.12.1-debian-10-r11

    docker tag gelregistry.azurecr.io/bitnami/redis-sentinel:6.0.8-debian-10-r55 \
    gelcontainerregistry.azurecr.io/bitnami/redis-sentinel:6.0.8-debian-10-r55

    docker tag gelregistry.azurecr.io/busybox:latest \
    gelcontainerregistry.azurecr.io/busybox:latest

    docker tag gelregistry.azurecr.io/gelldap/mailhog:latest \
    gelcontainerregistry.azurecr.io/gelldap/mailhog:latest

    docker tag gelregistry.azurecr.io/gelldap/mailhog:v1.0.1 \
    gelcontainerregistry.azurecr.io/gelldap/mailhog:v1.0.1

    docker tag gelregistry.azurecr.io/gelldap/openldap:1.4.0 \
    gelcontainerregistry.azurecr.io/gelldap/openldap:1.4.0

    docker tag gelregistry.azurecr.io/gitlab/gitlab-runner:alpine-v13.9.0 \
    gelcontainerregistry.azurecr.io/gitlab/gitlab-runner:alpine-v13.9.0

    docker tag gelregistry.azurecr.io/jettech/kube-webhook-certgen:v1.5.0 \
    gelcontainerregistry.azurecr.io/jettech/kube-webhook-certgen:v1.5.0

    docker tag gelregistry.azurecr.io/minio/mc:RELEASE.2018-07-13T00-53-22Z \
    gelcontainerregistry.azurecr.io/minio/mc:RELEASE.2018-07-13T00-53-22Z

    docker tag gelregistry.azurecr.io/minio/minio:RELEASE.2017-12-28T01-21-00Z \
    gelcontainerregistry.azurecr.io/minio/minio:RELEASE.2017-12-28T01-21-00Z

    docker tag gelregistry.azurecr.io/prom/prometheus:v2.15.2 \
    gelcontainerregistry.azurecr.io/prom/prometheus:v2.15.2

    # Images for PSGEL305
    docker tag gelregistry.azurecr.io/psgel305/autoauction1_0:latest \
    gelcontainerregistry.azurecr.io/psgel305/autoauction1_0:latest

    docker tag gelregistry.azurecr.io/psgel305/autoauction3_0:latest \
    gelcontainerregistry.azurecr.io/psgel305/autoauction3_0:latest

    docker tag gelregistry.azurecr.io/psgel305/autoauctiondec1_0:latest \
    gelcontainerregistry.azurecr.io/psgel305/autoauctiondec1_0:latest

    docker tag gelregistry.azurecr.io/psgel305/autoauctionnorthernstate1_0:latest \
    gelcontainerregistry.azurecr.io/psgel305/autoauctionnorthernstate1_0:latest

    docker tag gelregistry.azurecr.io/psgel305/qs_reg1:latest \
    gelcontainerregistry.azurecr.io/psgel305/qs_reg1:latest

    docker tag gelregistry.azurecr.io/psgel305/qs_reg_pmmlmodel:latest \
    gelcontainerregistry.azurecr.io/psgel305/qs_reg_pmmlmodel:latest

    docker tag gelregistry.azurecr.io/psgel305/qs_tree1:latest \
    gelcontainerregistry.azurecr.io/psgel305/qs_tree1:latest
    ```

1. Login to the GELENABLE subscription.

1. Login to the 'gelcontainerregistry' ACR.

    ```sh
    az acr login -n gelcontainerregistry.azurecr.io
    ```

1. PUSH the images to the 'gelcontainerregistry' ACR.

    ```sh
    docker push gelcontainerregistry.azurecr.io/bitnami/minideb:buster
    docker push gelcontainerregistry.azurecr.io/bitnami/postgres-exporter:0.8.0-debian-10-r99
    docker push gelcontainerregistry.azurecr.io/bitnami/postgresql:11.9.0
    docker push gelcontainerregistry.azurecr.io/bitnami/redis:6.0.9-debian-10-r0
    docker push gelcontainerregistry.azurecr.io/bitnami/redis-exporter:1.12.1-debian-10-r1
    docker push gelcontainerregistry.azurecr.io/bitnami/redis-exporter:1.12.1-debian-10-r11
    docker push gelcontainerregistry.azurecr.io/bitnami/redis-sentinel:6.0.8-debian-10-r55
    docker push gelcontainerregistry.azurecr.io/busybox:latest
    docker push gelcontainerregistry.azurecr.io/gelldap/mailhog:latest
    docker push gelcontainerregistry.azurecr.io/gelldap/mailhog:v1.0.1
    docker push gelcontainerregistry.azurecr.io/gelldap/openldap:1.4.0
    docker push gelcontainerregistry.azurecr.io/gitlab/gitlab-runner:alpine-v13.9.0
    docker push gelcontainerregistry.azurecr.io/jettech/kube-webhook-certgen:v1.5.0
    docker push gelcontainerregistry.azurecr.io/minio/mc:RELEASE.2018-07-13T00-53-22Z
    docker push gelcontainerregistry.azurecr.io/minio/minio:RELEASE.2017-12-28T01-21-00Z
    docker push gelcontainerregistry.azurecr.io/prom/prometheus:v2.15.2
    docker push gelcontainerregistry.azurecr.io/psgel305/autoauction1_0:latest
    docker push gelcontainerregistry.azurecr.io/psgel305/autoauction3_0:latest
    docker push gelcontainerregistry.azurecr.io/psgel305/autoauctiondec1_0:latest
    docker push gelcontainerregistry.azurecr.io/psgel305/autoauctionnorthernstate1_0:latest
    docker push gelcontainerregistry.azurecr.io/psgel305/qs_reg1:latest
    docker push gelcontainerregistry.azurecr.io/psgel305/qs_reg_pmmlmodel:latest
    docker push gelcontainerregistry.azurecr.io/psgel305/qs_tree1:latest
    ```

