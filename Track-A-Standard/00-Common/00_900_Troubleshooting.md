![Global Enablement & Learning](https://gelgitlab.race.sas.com/GEL/utilities/writing-content-in-markdown/-/raw/master/img/gel_banner_logo_tech-partners.jpg)

# Troubleshooting the AKS Build

* [Terraform authentication issues](#terraform-authentication-issues)
* [Azure API quota (too many request for the subscription)](#azure-api-quota-too-many-request-for-the-subscription)
* [Troubleshooting API Requests Quota](#troubleshooting-api-requests-quota)

## Terraform authentication issues

* If, during the Terraform apply command execution, you see an error message like :

    ```log
    Error: Unable to list provider registration status, it is possible that this is due to invalid credentials or the service principal does not have permissionto use the Resource Manager API, Azure error: resources.ProvidersClient#List: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. Status=403 Code="AuthorizationFailed" Message="The client 'ad3b1992-e72b-4960-b1b0-bf92ad73d51a' with object id 'ad3b1992-e72b-4960-b1b0-bf92ad73d51a' does not have authorization to perform action 'Microsoft.Resources/subscriptions/providers/read' over scope '/subscriptions/c973059c-87f4-4d89-8724-a0da5fe4ad5c' or the scope is invalid. If access was recently granted, please refresh your credentials."
    ```

* Then, there are two possible explanations:
  * The az CLI is not set to use the sas-gelsandbox subscription - go back to this [section](#set-the-azure-cli-defaults)
  * There is an issue with the Azure credentials generated to be used with Terraform - check the content of the ~/.aztf_creds file.

## Azure API quota (too many request for the subscription)

* If, during the Terraform apply command execution, you see an error message like :

    ```log
    Error: waiting for creation of Managed Kubernetes Cluster "psgel298-{Student_ID}-aks" (Resource Group "psgel298-{Student_ID}-rg"): Code="CreateVMSSAgentPoolFailed" Message="VMSSAgentPoolReconciler retry failed: autorest/azure: Service returned an error. Status=429 Code=\"OperationNotAllowed\" Message=\"The server rejected the request because too many requests have been received for this subscription.\" Details=[{\"code\":\"TooManyRequests\",\"message\":\"{\\\"operationGroup\\\":\\\"HighCostGetVMScaleSet30Min\\\",\\\"startTime\\\":\\\"2021-01-28T03:48:16.7336912+00:00\\\",\\\"endTime\\\":\\\"2021-01-28T03:50:00+00:00\\\",\\\"allowedRequestCount\\\":1643,\\\"measuredRequestCount\\\":1883}\",\"target\":\"HighCostGetVMScaleSet30Min\"}] InnerError={\"internalErrorCode\":\"TooManyRequestsReceived\"}"
    ```

* It is not your fault, it simply means that the Azure Resource Manager APIs quota has been exceeded. Refer to the [Troubleshooting API requests quota](#troubleshooting-api-requests-quota) section for more information. You will have to try another time, but later.

## Troubleshooting API Requests Quota

* During the workshop you might hit this error, when you run the Terraform apply command to create the AKS cluster:

    ```log
    Error: waiting for creation of Managed Kubernetes Cluster "psgel298-{Student_ID}-aks" (Resource Group "psgel298-{Student_ID}-rg"): Code="CreateVMSSAgentPoolFailed" Message="VMSSAgentPoolReconciler retry failed: autorest/azure: Service returned an error. Status=429 Code=\"OperationNotAllowed\" Message=\"The server rejected the request because too many requests have been received for this subscription.\" Details=[{\"code\":\"TooManyRequests\",\"message\":\"{\\\"operationGroup\\\":\\\"HighCostGetVMScaleSet30Min\\\",\\\"startTime\\\":\\\"2021-01-28T03:48:16.7336912+00:00\\\",\\\"endTime\\\":\\\"2021-01-28T03:50:00+00:00\\\",\\\"allowedRequestCount\\\":1643,\\\"measuredRequestCount\\\":1883}\",\"target\":\"HighCostGetVMScaleSet30Min\"}] InnerError={\"internalErrorCode\":\"TooManyRequestsReceived\"}"
    ```

* This problem is documented [there](https://docs.microsoft.com/en-us/azure/aks/troubleshooting#im-receiving-429---too-many-requests-errors)

  **When a kubernetes cluster on Azure (AKS or no) does a frequent scale up/down or uses the cluster autoscaler (CA), those operations can result in a large number of HTTP calls that in turn exceed the assigned subscription quota leading to failure**

* Let's see how we can check the remaining calls for example for this specific operation that happens when we create the AKS cluster.

    ```sh
    # Get the resource group and cluster names
    RG=$(cat ~/variables.txt | grep resource-group | awk -F'::' '{print $2}')
    AKS_NAME=$(cat ~/variables.txt | grep cluster-name | awk -F'::' '{print $2}')
    # list VMSS state
    # Get the rquest parameters values
    ResourceGroup="MC_${RG}_${AKS_NAME}_$(cat ~/azureregion.txt)"
    # Paramaters check
    echo Subscription $TF_VAR_subscription_id
    echo ResourceGroup $ResourceGroup
    # Get the number of remaining API requests
    declare response=$(az account get-access-token)
    declare token=$(echo $response | jq ".accessToken" -r)
    # get the first node pool VMSS
    vmss=$(az vmss list --resource-group ${ResourceGroup} -o tsv --query [0].name)
    echo VM SCALE SET: $vmss
    curl -s -I -X GET -H "Authorization: Bearer $token" "https://management.azure.com/subscriptions/"${TF_VAR_subscription_id}"/resourceGroups/"${ResourceGroup}"/providers/Microsoft.Compute/virtualMachineScaleSets/${vmss}/virtualMachines?api-version=2020-12-01" | grep "remaining-resource" | awk -F "[:;,]" '{{print $1 "=> 3mn-limit:" $3 " 30mn-limit:" $5}}'
    ```

* In case you see the error

    ```sh
    # Get the resource group and cluster names
    RG=$(cat ~/variables.txt | grep resource-group | awk -F'::' '{print $2}')
    AKS_NAME=$(cat ~/variables.txt | grep cluster-name | awk -F'::' '{print $2}')
    ResourceGroup="MC_${RG}_${AKS_NAME}_$(cat ~/azureregion.txt)"
    # Paramaters check
    echo Subscription $TF_VAR_subscription_id
    echo ResourceGroup $ResourceGroup
    # Get the number of remaining API requests
    declare response=$(az account get-access-token)
    declare token=$(echo $response | jq ".accessToken" -r)
    vmss=$(az vmss list --resource-group ${ResourceGroup} -o tsv --query [0].name)
    echo VM SCALE SET: $vmss
    curl -s -I -X GET -H "Authorization: Bearer $token" "https://management.azure.com/subscriptions/"${TF_VAR_subscription_id}"/resourceGroups/"${ResourceGroup}"/providers/Microsoft.Compute/virtualMachineScaleSets/${vmss}/virtualMachines?api-version=2020-12-01"
    ```

    The response should include a `Retry-After` value, which specifies the number of seconds you should wait (or sleep) before sending the next request.

    ## Return to instructions

    Click here to return to [00_100 Creating an AKS Cluster](../00-Common/00_100_Creating_an_AKS_Cluster.md#in-case-it-did-not-work-for-you) lab exercise.
