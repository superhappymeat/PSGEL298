![Global Enablement & Learning](https://gelgitlab.race.sas.com/GEL/utilities/writing-content-in-markdown/-/raw/master/img/gel_banner_logo_tech-partners.jpg)

# Fast track with the cheatcodes

- [Fast track with the cheatcodes](#fast-track-with-the-cheatcodes)
  - [(Re)generate the cheatcodes](#regenerate-the-cheatcodes)
  - [Run the cheatcodes (examples)](#run-the-cheatcodes-examples)
    - [Example 1: Automating the "Manual" deployment path](#example-1-automating-the-manual-deployment-path)
    - [Example 2: Automating the "DepOp" deployment path](#example-2-automating-the-depop-deployment-path)
    - [Example 3: Running the "Fully Automated" deployment path](#example-3-running-the-fully-automated-deployment-path)
  - [Remember to clean-up](#remember-to-clean-up)
    - [Run Track-A Cleanup](#run-track-a-cleanup)
    - [Run Track-B Cleanup](#run-track-b-cleanup)

The 'cheatcodes' have been developed for this workshop and are **NOT** part of the SAS Viya software, nor are they an official tool supported by SAS. They provide an automated path through the lab exercises.

*It should be noted that it has not been possible to automate all the build steps. For example, the login to the Azure command line or creating the wildcard DNS name, to name a couple manual steps*.

## (Re)generate the cheatcodes

* Run the command below to generate the cheat codes

    ```sh
    cd ~/PSGEL298-sas-viya-4-deployment-on-azure-kubernetes-service/
    git pull
    #git reset --hard origin/master
    # optionnaly you can switch to a diffent version branch
    # ex:
    # git checkout "release/stable-2021.2.5"
    # git checkout "gelenable/stable-2021.2.4"
    /opt/gellow_code/scripts/cheatcodes/create.cheatcodes.sh /home/cloud-user/PSGEL298-sas-viya-4-deployment-on-azure-kubernetes-service/
    ```

    Now you can directly call the cheatcodes for each step.

* If you don't have your Azure credentials, yet :
  * The script will stop at the "az login" interactive step and wait for you to login in Azure with the authorization code and your credentials.

## Run the cheatcodes (examples)

*Important: it is recommended to send the output into a log file, so, in case of failure, you can investigate more easily*.

### Example 1: Automating the "Manual" deployment path

* To build the AKS cluster, perform the pre-requisites and deploy Viya 4 using the "manual" way.

    ```sh
    bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/00*/00_100_Creating_an_AKS_Cluster.sh 2>&1 \
    | tee -a ~/00_100_Creating_an_AKS_Cluster.log
    bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/00*/00_110_Performing_the_prerequisites.sh 2>&1 \
    | tee -a ~/00_110_Performing_Prereqs_in_AKS.log
    bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/01-Manual/01_200_Deploying_Viya_4_on_AKS.sh 2>&1 \
    | tee -a ~/01_200_Deploying_Viya_4_on_AKS.log
    ```

    Important: it is recommended to send the output into a log file, so, in case of failure, you can investiguate more easily.

  * Optionally you can run this command to also deploy the monitoring and logging tools in the AKS cluster. This runs on the second namespace configuration.

    ```sh
    # Run the second namespace deployment
    bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/01-Manual/01_210_Deploy_a_second_namespace_in_AKS.sh 2>&1 \
    | tee -a ~/01_210_Deploy_a_second_namespace_in_AKS.log

    # Install the Monitoring and logging
    bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/01-Manual/01_230_Install_monitoring_and_logging.sh 2>&1 \
    | tee -a ~/01_230_Install_monitoring_and_logging.log
    ```

### Example 2: Automating the "DepOp" deployment path

1. Build the AKS cluster and perform the Viya pre-requisites.

    ```sh
    bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/00*/00_100_Creating_an_AKS_Cluster.sh 2>&1 \
    | tee -a ~/01_100_Creating_an_AKS_Cluster.log
    bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/00*/00_110_Performing_the_prerequisites.sh 2>&1 \
    | tee -a ~/01_110_Performing_Prereqs_in_AKS.log
    ```

1. Deploy the Deployment Operator into the cluster and create a GitLab instance.

    This will run the DepOp exercise pre-requisites and take you to the point of using the deployment operator to deploy SAS Viya.

    ```sh
    bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/02-DepOp/02_300_Deployment_Operator_environment_set-up.sh 2>&1 \
    | tee -a ~/02_300_Deployment_Operator_environment_set-up.log
    ```

    You can now proceed to exercise [02_310 Using the DO with a Git Repository](../Track-A-Standard/02-DepOp/02_310_Using_the_DO_with_a_Git_Repository.md).

---

* The following is for workshop testing.

    ```sh
    # 02_310_Using_the_DO_with_a_Git_Repository
    bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/02-DepOp/02_310_Using_the_DO_with_a_Git_Repository.sh 2>&1 \
    | tee -a ~/02_310_Using_the_DO_with_a_Git_Repository.log
    ```

    _You will be prompted to set the Discovery project to be Public. Run the following to get the GitLab URL and password for the root user: `cat ~/gitlab-details.txt`_

    ```sh
    # Run exercise 02_330_Using_the_Orchestration_Tool
    bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/02-DepOp/02_330_Using_the_Orchestration_Tool.sh 2>&1 \
    | tee -a ~/02_330_Using_the_Orchestration_Tool.log
    ```

---

### Example 3: Running the "Fully Automated" deployment path

* To build the AKS cluster, perform the pre-requisites and deploy Viya 4 using the viya4-iac-azure and viya4-deployment docker containers (as described in the "Fully Automated" Hands-on):

    ```sh
    bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-B-Automated/03_500_Full_Automation_of_AKS_Deployment.sh 2>&1 \
    | tee -a ~/03_500_Full_Automation_of_AKS_Deployment.log
    ```

## Remember to clean-up

### Run Track-A Cleanup

* Run the following script to delete the cluster and related resources created by the **Track-A** exercises.

    ```sh
    code_dir=$HOME"/PSGEL298-sas-viya-4-deployment-on-azure-kubernetes-service/scripts"
    bash ${code_dir}/utils/GEL.400.Delete.Environment.sh
    ```

### Run Track-B Cleanup

* Run the following script to delete the cluster and related resources created by the **Track-B** exercises.

    ```sh
    code_dir=$HOME"/PSGEL298-sas-viya-4-deployment-on-azure-kubernetes-service/scripts"
    bash ${code_dir}/utils/GEL.500.Delete.Environment.sh
    ```
