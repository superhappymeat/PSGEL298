![Global Enablement & Learning](https://gelgitlab.race.sas.com/GEL/utilities/writing-content-in-markdown/-/raw/master/img/gel_banner_logo_tech-partners.jpg)

# Delete the AKS Cluster and Related Resources

- [Delete the AKS Cluster and Related Resources](#delete-the-aks-cluster-and-related-resources)
  - [README First!](#readme-first)
  - [Using the GEL Clean-up script](#using-the-gel-clean-up-script)
  - [Additional Information](#additional-information)
  - [Next Steps](#next-steps)
  - [Complete Hands-on Navigation Index](#complete-hands-on-navigation-index)

## README First!

There are a number of ways to clean up your environment, and we encourage you to do so to minimise costs to SAS.

As there are a number of resource definitions that have been created for resources outside of your cluster, the recommended approach is to use the provided GEL clean-up script.

While it is possible to use Terraform to clean-up the resources that Terraform created, this will leave objects that were created outside of Terraform, that reside outside of your two resource groups.

## Using the GEL Clean-up script

As stated this is the recommended method to clean-up your environment.

* Run the following script to delete the cluster.

    ```sh
    code_dir=$HOME"/PSGEL298-sas-viya-4-deployment-on-azure-kubernetes-service/scripts"

    bash ${code_dir}/utils/GEL.400.Delete.Environment.sh
    ```

    You need to confirm the deletion.

## Additional Information

Additional information on deleting the environment is provided [here](./00_490_Cleanup_Information.md).

---

## Next Steps

You have finished the Hands-on instructions for the Standard Deployment Method you chose.

Click [here](../../Track-B-Automated/03_500_Full_Automation_of_AKS_Deployment.md) to move onto the Fully Automated Deployment exercise: ***03_500_Full_Automation_of_AKS_Deployment.md***

---

## Complete Hands-on Navigation Index
<!-- startnav -->
* [Access and Setup / 00 001 Access Environments](/Access_and_Setup/00_001_Access_Environments.md)
* [README](/README.md)
* [Track A-Standard/00-Common / 00 100 Creating an AKS Cluster](/Track-A-Standard/00-Common/00_100_Creating_an_AKS_Cluster.md)
* [Track A-Standard/00-Common / 00 110 Performing the prerequisites](/Track-A-Standard/00-Common/00_110_Performing_the_prerequisites.md)
* [Track A-Standard/00-Common / 00 400 Cleanup](/Track-A-Standard/00-Common/00_400_Cleanup.md)**<-- you are here**
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
* [Track B-Automated / 03 590 Cleanup](/Track-B-Automated/03_590_Cleanup.md)
<!-- endnav -->
