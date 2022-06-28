![Global Enablement & Learning](https://gelgitlab.race.sas.com/GEL/utilities/writing-content-in-markdown/-/raw/master/img/gel_banner_logo_tech-partners.jpg)

# SAS Viya 4 - Deployment on Azure Kubernetes Service

**PSGEL298: SAS Viya 4 - Deployment on Azure Kubernetes Service**

```yaml
Cadence: Stable
Version: 2021.2.6
```

---

- [SAS Viya 4 - Deployment on Azure Kubernetes Service](#sas-viya-4---deployment-on-azure-kubernetes-service)
  - [One deployment, but 3 deployment options](#one-deployment-but-3-deployment-options)
  - [Deployment learning path](#deployment-learning-path)
  - [Structure and content](#structure-and-content)
  - [Clean up - why ?](#clean-up---why-)
  - [Next steps](#next-steps)
  - [Complete Hands-on Navigation Index](#complete-hands-on-navigation-index)

Welcome to the SAS Viya 4 - Deployment on Azure Kubernetes Service (AKS) workshop. This README provides an overview of the workshop structure and the exercises that can be undertaken.

## One deployment, but 3 deployment options

* There are several options to build and prepare the underlying Kubernetes cluster for a SAS Viya deployment.

* Once the infrastructure and Kubernetes cluster have been provisioned for SAS Viya, there are 3 options to deploy SAS Viya into the Kubernetes cluster:

  * Performing a **manual deployment**
  * Using the **deployment operator** (SAS preferred method), and 
  * **Automated deployment with ansible** ([viya4-deployment](https://github.com/sassoftware/viya4-deployment) GitHub project).

* Each deployment method comes with it's unique possibilities and requirements for deploying and maintaining the resultant environment.

To help clarify the deployment methods and paths to a successful SAS Viya deployment, we have organized the "Cloud Provider" lab hands-on a specific way that is described below.

## Deployment learning path

**The goal of this hands-on organization is to help you better understand and test the various deployment paths.**

![learningpath](/img/workshop_structure.png)

## Structure and content

To support the three deployment paths, and the two learning tracks (learning paths), the Git project is organised with the following structure.

```log
├── README (Get an overview of the Hands-on organization)
├── 00_001_Access_environments.md
├── 00_999_Fast_track_with_cheatcodes.md (instructions on how to generate the cheatcodes)
|
├── Track-A-Standard
|      ├── 00-Common
│      |      ├── 00_100_Creating_an_AKS_Cluster.md (required for both Standard options Manual and DepOp)
│      |      ├── 00_110_Performing_the_prerequisites.md (required for both Standard options Manual and DepOp)
|      |      └── 00_400_Cleanup.md (required clean-up of costly cloud assets used in both Standard Deployment methods)
|      |
│      ├── 01-Manual (perform these set of instructions to follow the Standard / Manual Deployment method)
│      │      ├── 01_200_Deploying_Viya_4_on_AKS.md
│      │      ├── 01_210_Deploy_a_second_namespace_in_AKS.md
│      │      ├── 01_220_CAS_Customizations.md
│      │      ├── 01_230_Install_monitoring_and_logging.md
│      │      └── 01_240_Stop-shrink_and_Start-scale_in_AKS.md
|      |
│      └── 02-DepOp (perform these set of instructions to follow the Standard / Deployment Operator method)
│             ├── 02_300_Deployment_Operator_environment_set-up.md
│             ├── 02_310_Using_the_DO_with_a_Git_Repository.md
│             └── 02_330_Using_the_Orchestration_Tool.md
|
└── Track-B-Automated (perform these set of instructions to follow the Fully-Automated Deployment Method)
       ├── 03_500_Full_Automation_of_AKS_Deployment.md
       └── 03_590_Cleanup.md
```

While the content will evolve to integrate additional hands-on in the future, the structure should remain the same.

**Learning path: Track-A-Standard**

* In the "00-Common" folder, we have 2 common hands-on exercises (01_100 and 01_110):
  * To create the AKS cluster with the viya4-iac-azure GitHub tool (terraform method)
  * To install install the pre-requisites manually
  * **these 2 hands-on are mandatory if you want to do the "manual" and "deployment operator" hands-on that are in their respective subfolders.**
  * There is also the **clean-up** instructions (01_400_Cleanup.md), where we provide a script to clean-up the environment and destroy the cluster.

* In the "01-Manual" folder,
  * We show how to use the manual method of deployment (get the assets, kustomize build, kubectl apply)
  * We also have additional Hands-on (CAS Customization, install Monitoring and Logging, stop and start, etc...)

* In the "02-DepOp" folder,
  * We prepare the environment for a deployment with the Deployment Operator (DepOp).
  * We show how to install Viya with the Deployment Operator (either from a Gitlab repository or an inline configuration).

**Learning path: Track-B-Automated**
* In the "Track-B-Automated" folder,
  * We use the viya-iac-azure GitHub tool (docker method) to create the AKS cluster.
  * We then use the viya-iac-deployment GitHub tool (docker method) to install the pre-requisite and deploy Viya 4.
  * We provide the steps to clean-up the environment and destroy the cluster.

If you want to automate these steps, you can use the instruction in the hands-on [**00_999 Fast track with cheatcodes**](./Access_and_Setup/00_999_Fast_track_with_cheatcodes.md).

## Clean up - why ?

**Running SAS Viya in the Cloud is not free!**

* When you create an AKS cluster and deploy Viya on it, a lot of infrastructure resources needs to be created in the Cloud on your behalf (Virtual Network, VMs, Disks,  Load-balancers, etc...)

* Although we try to reduce them as much as possible (smaller instances, autoscaling with minimum node count set to 0), it still generate significant costs, we roughly estimate them at 50 US dollars when you let your cluster run for the 8 hours.

* This is the reason why we provide you ways to clean-up the environment and destroy your cluster once you have completed your training activity

* But just to make sure, there is a scheduled job that deletes any AKS cluster associated Resource group after 8 hours.

---

## Next steps

* Make sure you have everything to [access your lab environment](Access_and_Setup/00_001_Access_Environments.md)
* Then Select the desired learning path:

  * [Standard - create the AKS cluster](Track-A-Standard/00-Common/00_100_Creating_an_AKS_Cluster.md)

  OR

  * [Fully Automated](Track-B-Automated/03_500_Full_Automation_of_AKS_Deployment.md)

---

## Complete Hands-on Navigation Index

<!-- startnav -->
* [Access and Setup / 00 001 Access Environments](/Access_and_Setup/00_001_Access_Environments.md)
* [README](/README.md)**<-- you are here**
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
* [Track B-Automated / 03 590 Cleanup](/Track-B-Automated/03_590_Cleanup.md)
<!-- endnav -->
