![Global Enablement & Learning](https://gelgitlab.race.sas.com/GEL/utilities/writing-content-in-markdown/-/raw/master/img/gel_banner_logo_tech-partners.jpg)

# Clean up the resources in the Cloud

* [README First!](#readme-first)
* [General information](#general-information)
  * [Deleting the AKS Cluster with Terraform](#deleting-the-aks-cluster-with-terraform)
  * [Deleting the AKS cluster from the Azure portal](#deleting-the-aks-cluster-from-the-azure-portal)
* [Complete Hands-on Navigation Index](#complete-hands-on-navigation-index)

## README First!

To delete the cluster and related resources see [Destroy everything](./03_500_Full_Automation_of_AKS_Deployment.md#destroy-everything).

***You need to use the provided script to fully clean-up after the lab exercises***.

## General information

### Deleting the AKS Cluster with Terraform

While it is possible to use Terraform to clean-up the resources that Terraform created, this will leave objects that were created outside of Terraform. Therefore, to fully clean-up and environment additional actions need to be performed.

The following describes how to use Terraform to delete the AKS cluster.

* The command below uses Terraform to destroy the AKS cluster.

    ```sh
    docker container run -it --rm \
        --env-file $HOME/jumphost/workspace/.tf_creds_iac \
        -v $HOME/jumphost/workspace/.azure/:/root/.azure/ \
        -v $HOME/jumphost/workspace:/workspace \
        viya4-iac-azure \
        destroy \
        -var-file /workspace/gel02-vars.tfvars \
        -state /workspace/gel02-vars.tfstate \
        -lock=false \
        -input=false
    ```

* You can also do it with the azure CLI (more efficient)

    ```sh
    #STUDENT=$(cat ~/jumphost/workspace/.student.txt)
    JMP_HOST=$(hostname)
    docker container  run  --rm \
        -v $HOME/jumphost/workspace/.azure/:/root/.azure/ \
        -v $HOME/jumphost/workspace/.kubeconfig_aks:/root/.kube/config \
        --entrypoint az \
        viya4-iac-azure \
        group delete --name pg298-${JMP_HOST}-rg --yes
    ```

### Deleting the AKS cluster from the Azure portal

While it is possible to delete resources using the Azure Portal, for the workshop environment this is NOT possible. The 'gatedemoxxx' users only have READ access to the resources, therefore, it is not possible to use the Portal to delete the resources.

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
* [Track A-Standard/01-Manual / 01 240 Stop shrink and Start-scale in AKS](/Track-A-Standard/01-Manual/01_240_Stop-shrink_and_Start-scale_in_AKS.md)
* [Track A-Standard/02-DepOp / 02 300 Deployment Operator environment set up](/Track-A-Standard/02-DepOp/02_300_Deployment_Operator_environment_set-up.md)
* [Track A-Standard/02-DepOp / 02 310 Using the DO with a Git Repository](/Track-A-Standard/02-DepOp/02_310_Using_the_DO_with_a_Git_Repository.md)
* [Track A-Standard/02-DepOp / 02 330 Using the Orchestration Tool](/Track-A-Standard/02-DepOp/02_330_Using_the_Orchestration_Tool.md)
* [Track B-Automated / 03 500 Full Automation of AKS Deployment](/Track-B-Automated/03_500_Full_Automation_of_AKS_Deployment.md)
* [Track B-Automated / 03 590 Cleanup](/Track-B-Automated/03_590_Cleanup.md)**<-- you are here**
<!-- endnav -->
