![Global Enablement & Learning](https://gelgitlab.race.sas.com/GEL/utilities/writing-content-in-markdown/-/raw/master/img/gel_banner_logo_tech-partners.jpg)

# Stop-shrink and Start-scale in AKS

- [Stop-shrink and Start-scale in AKS](#stop-shrink-and-start-scale-in-aks)
  - [Introduction](#introduction)
  - [Configure Azure autoscaling to 0 nodes](#configure-azure-autoscaling-to-0-nodes)
    - [Stop and then restart the environment](#stop-and-then-restart-the-environment)
      - [Commands to scale down to 0 the Viya environment (STOP)](#commands-to-scale-down-to-0-the-viya-environment-stop)
      - [Commands to scale up the Viya environment (RESTART)](#commands-to-scale-up-the-viya-environment-restart)
  - [Next Steps](#next-steps)
  - [Table of Contents for the Manual Deployment Method exercises](#table-of-contents-for-the-manual-deployment-method-exercises)
  - [Complete Hands-on Navigation Index](#complete-hands-on-navigation-index)

## Introduction

***This exercise uses the "PROD" deployment. Please ensure that you still have the PROD deployment.***

In this exercise you will:

* Update the "Test" configuration, as this is the base for the PROD deployment.
* You will then build and apply the PROD environment.

## Configure Azure autoscaling to 0 nodes

* To reduce the costs we would like to set the min_count for our SAS Viya Nodepools to 0. So when you stop the Viya environment, the nodes should disappear after a a little while, saving significant costs.

* The easiest way would have been to set it in the Terraform variables. However a bug is preventing the min_count/node_count to be set to zero in TF: <https://github.com/terraform-providers/terraform-provider-azurerm/pull/8300>.

* In addition portal does not allow you to it. So we use the az CLI to do it.

    ```bash
    WORK_DIR=$HOME/project/vars
    RG=$(cat ${WORK_DIR}/variables.txt | grep resource-group | awk -F'::' '{print $2}')
    AKS_NAME=$(cat ${WORK_DIR}/variables.txt | grep cluster-name | awk -F'::' '{print $2}')

    az aks nodepool update --update-cluster-autoscaler \
    --min-count 0 --max-count 3 -g ${RG} \
    -n stateless --cluster-name ${AKS_NAME}

    az aks nodepool update --update-cluster-autoscaler \
    --min-count 0 --max-count 3 -g ${RG} \
    -n stateful --cluster-name ${AKS_NAME}

    az aks nodepool update --update-cluster-autoscaler \
    --min-count 0 --max-count 1 -g ${RG} \
    -n compute --cluster-name ${AKS_NAME}

    az aks nodepool update --update-cluster-autoscaler \
    --min-count 0 --max-count 8 -g ${RG} \
    -n cas --cluster-name ${AKS_NAME}

    az aks nodepool update --update-cluster-autoscaler \
    --min-count 0 --max-count 1 -g ${RG} \
    -n connect --cluster-name ${AKS_NAME}
    ```

_Note: depending on the initial node pool configuration, some of the command above might fail and show an error when the autoscaler is not enabled for the node pool (when min-count=max-count). You can safely ignore the errors, it just means that these node pools will not scale down to 0 when we stop the Viya services._

### Stop and then restart the environment

Follow the documented instructions to [stop your environment](https://go.documentation.sas.com/?cdcId=itopscdc&cdcVersion=v_001LTS&docsetId=itopssrv&docsetTarget=n0pwhguy22yhe0n1d7pgi63mf6pb.htm&locale=en#p1nz12w805sz14n1rd6m593qnefy).

Once it's fully stopped, use the other instructions to [restart it](https://go.documentation.sas.com/?cdcId=itopscdc&cdcVersion=v_001LTS&docsetId=itopssrv&docsetTarget=n0pwhguy22yhe0n1d7pgi63mf6pb.htm&locale=en#p0szdr59qn1uwkn13ktqmzqjwpyh).

Because we are nice, instead of letting you struggle with the documentation, we prepared the commands for you below in our Lab environment. However be aware that the currently documentated process to do it is manual,cumbersome and error prone.

#### Commands to scale down to 0 the Viya environment (STOP)

1. Add a new transformer for the scale down to 0 of some of the resources (phase 0).

    Using this command you will update the 'kustomization.yaml' for the Test configuration.

    ```bash
    # Add a new transformer
    printf "
    - command: update
      path: transformers[+]
      value:
        sas-bases/overlays/scaling/zero-scale/phase-0-transformer.yaml
    " | $HOME/bin/yq -I 4 w -i -s - ~/project/deploy/test/kustomization.yaml
    ```

1. Rebuild the 'PROD' manifest.

    ```bash
    cd ~/project/deploy/prod
    kustomize build -o site.yaml
    ```

1. Apply the updated site.yaml file to your deployment.

    ```bash
    kubectl apply -f site.yaml
    ```

1. Wait for CAS operator-managed pods to get deleted.

    ```sh
    kubectl -n prod wait --for=delete -l casoperator.sas.com/server=default pods
    ```

1. Add an other new transformer for the scale down to 0 of the rest of the resources (phase 1).

    Again, to the Test kustomization.yaml.

    ```bash
    # Add a new transformer
    printf "
    - command: update
      path: transformers[+]
      value:
        sas-bases/overlays/scaling/zero-scale/phase-1-transformer.yaml
    " | $HOME/bin/yq -I 4 w -i -s - ~/project/deploy/test/kustomization.yaml
    ```

1. Rebuild the manifest.

    ```bash
    cd ~/project/deploy/prod
    kustomize build -o site.yaml
    ```

1. Apply the updated site.yaml file to your deployment.

    ```bash
    kubectl apply -f site.yaml
    ```

#### Commands to scale up the Viya environment (RESTART)

1. Remove the 2 lines, rebuild and reapply.

    ```bash
    cd ~/project/deploy/test
    $HOME/bin/yq d -i kustomization.yaml 'transformers(.==sas-bases/overlays/scaling/zero-scale/phase-0-transformer.yaml)'
    $HOME/bin/yq d -i kustomization.yaml 'transformers(.==sas-bases/overlays/scaling/zero-scale/phase-1-transformer.yaml)'
    ```

1. Rebuild the manifest.

    ```bash
    cd ~/project/deploy/prod
    kustomize build -o site.yaml
    ```

1. Apply the updated site.yaml file to your deployment.

    ```sh
    kubectl apply -f site.yaml
    ```

    _Note: if you run this hands-on exercise with the cheatcodes, it will just stop (scale down to 0) the Viya environment but NOT restart it, so you can also witness the AKS autoscaler behavior. To restart it, just reapply the site.yaml manifest_.

<!-- OLD WAY
* Stop all the "running" pods for good, you would have to run:

    ```sh
    kubectl -n test scale deployments --all --replicas=0
    kubectl -n test scale statefulsets --all --replicas=0
    kubectl -n test delete casdeployment --all
    kubectl -n test delete jobs --all
    ```

* Note that if we want to restart at this point you can run :

    ```sh
    cd ~/project/deploy/test
    kubectl -n test apply -f site.yaml
    ```

  But because we've done a scale to zero, and because the number of replicas is not part of the manifest, we also have to do a scale to 1 !

    ```sh
    kubectl -n test scale deployments --all --replicas=1
    kubectl -n test scale statefulsets --all --replicas=1
    ```
-->

---

## Next Steps

You have completed the Manual Deployment method instructions. Don't forget to Clean up the cloud assets to save $ when you are done.

Click [here](../00-Common/00_400_Cleanup.md) to move onto the next exercise: ***00_400_Cleanup.md***

## Table of Contents for the Manual Deployment Method exercises
<!--Navigation for this set of labs-->
* [00-Common / 00 100 Creating an AKS Cluster](../00-Common/00_100_Creating_an_AKS_Cluster.md)
* [00-Common / 00 110 Performing the prerequisites](../00-Common/00_110_Performing_the_prerequisites.md)
* [01-Manual / 01 200 Deploying Viya 4 on AKS](./01_200_Deploying_Viya_4_on_AKS.md)
* [01-Manual / 01 210 Deploy a second namespace in AKS](./01_210_Deploy_a_second_namespace_in_AKS.md)
* [01-Manual / 01 220 CAS Customizations](./01_220_CAS_Customizations.md)
* [01-Manual / 01 230 Install monitoring and logging](./01_230_Install_monitoring_and_logging.md)
* [01-Manual / 01 240 Stop shrink and Start-scale in AKS](./01_240_Stop-shrink_and_Start-scale_in_AKS.md) **<-- You are here**
* [00-Common / 00 400 Cleanup](../00-Common/00_400_Cleanup.md)

---

## Complete Hands-on Navigation Index
<!-- startnav -->
* [Access and Setup / 00 001 Access Environments](/Access_and_Setup/00_001_Access_Environments.md)
* [README](/README.md)
* [Track A-Standard/00-Common / 00 100 Creating an AKS Cluster](/Track-A-Standard/00-Common/00_100_Creating_an_AKS_Cluster.md)
* [Track A-Standard/00-Common / 00 110 Performing the prerequisites](/Track-A-Standard/00-Common/00_110_Performing_the_prerequisites.md)
* [Track A-Standard/00-Common / 00 400 Cleanup](/Track-A-Standard/00-Common/00_400_Cleanup.md)
* [Track A-Standard/00-Common / 00 490 Cleanup Information](/Track-A-Standard/00-Common/00_490_Cleanup_Information.md)
* [Track A-Standard/01-Manual / 01 200 Deploying Viya 4 on AKS](/Track-A-Standard/01-Manual/01_200_Deploying_Viya_4_on_AKS.md)
* [Track A-Standard/01-Manual / 01 210 Deploy a second namespace in AKS](/Track-A-Standard/01-Manual/01_210_Deploy_a_second_namespace_in_AKS.md)
* [Track A-Standard/01-Manual / 01 220 CAS Customizations](/Track-A-Standard/01-Manual/01_220_CAS_Customizations.md)
* [Track A-Standard/01-Manual / 01 230 Install monitoring and logging](/Track-A-Standard/01-Manual/01_230_Install_monitoring_and_logging.md)
* [Track A-Standard/01-Manual / 01 240 Stop shrink and Start-scale in AKS](/Track-A-Standard/01-Manual/01_240_Stop-shrink_and_Start-scale_in_AKS.md)**<-- you are here**
* [Track A-Standard/02-DepOp / 02 300 Deployment Operator environment set up](/Track-A-Standard/02-DepOp/02_300_Deployment_Operator_environment_set-up.md)
* [Track A-Standard/02-DepOp / 02 310 Using the DO with a Git Repository](/Track-A-Standard/02-DepOp/02_310_Using_the_DO_with_a_Git_Repository.md)
* [Track A-Standard/02-DepOp / 02 330 Using the Orchestration Tool](/Track-A-Standard/02-DepOp/02_330_Using_the_Orchestration_Tool.md)
* [Track B-Automated / 03 500 Full Automation of AKS Deployment](/Track-B-Automated/03_500_Full_Automation_of_AKS_Deployment.md)
* [Track B-Automated / 03 590 Cleanup](/Track-B-Automated/03_590_Cleanup.md)
<!-- endnav -->
