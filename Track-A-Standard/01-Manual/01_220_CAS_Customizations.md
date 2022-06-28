![Global Enablement & Learning](https://gelgitlab.race.sas.com/GEL/utilities/writing-content-in-markdown/-/raw/master/img/gel_banner_logo_tech-partners.jpg)

- [Introduction](#introduction)
- [Customization 1: Access CAS from Python via HTTP](#customization-1-access-cas-from-python-via-http)
  - [Understanding CAS access from RACE](#understanding-cas-access-from-race)
  - [Connect to CAS from Python](#connect-to-cas-from-python)
- [Customization 2 : Force CAS Worker to run on different nodes](#customization-2--force-cas-worker-to-run-on-different-nodes)
  - [Increase the CAS Pods CPU request](#increase-the-cas-pods-cpu-request)
  - [Validate](#validate)
- [Next Steps](#next-steps)
- [Table of Contents for the Manual Deployment Method exercises](#table-of-contents-for-the-manual-deployment-method-exercises)
- [Complete Hands-on Navigation Index](#complete-hands-on-navigation-index)

## Introduction

This exercise builds on the last exercise for the 'prod' environment ([01_210 Deploy a second namespace](./01_210_Deploy_a_second_namespace_in_AKS.md)). Please ensure that you have completed that exercise first.

***Note***: _the 'PROD' environment needs to be running in order to get the Viya CA certificate._

## Customization 1: Access CAS from Python via HTTP

### Understanding CAS access from RACE

There are two methods that can be used to connect to CAS resources from Python.  Both use the Python swat package but each uses a different protocol. One method is to use the binary protocol. This is preferred method as it is more flexible and more efficient.  The alternative is to use the HTTP protocol via the REST interface. Although it is less efficient it is easier to use in that you an access CAS via the ingress and requires minimal configuration. See [documentation](https://sassoftware.github.io/python-swat/binary-vs-rest.html) for details.

Since our jump machine runs in RACE EXNET, it currently has limited access to ports in Azure.  Accessing CAS via the binary protocol requires that an additional port be opened between RACE and Azure.  As a result in this section we will simply connect to CAS via the ingress (HTTP).

Steps for accessing CAS via the binary protocol can be found here. [Customization 4 : Expose port 5570 for CAS external access](#customization-4-expose-port-5570-for-cas-external-access)  Please note that this hands-on will not work until the port between RACE and Azure is opened.

### Connect to CAS from Python

1. First let's install swat in the our collection.

    ```bash
    sudo pip install swat
    ```

1. Get the CA certificate for the 'prod' deployment.

    ```bash
    kubectl -n prod get secret sas-viya-ca-certificate-secret -o go-template='{{(index .data "ca.crt")}}' | base64 -d > /tmp/my_ca_certificate.pem
    ```

1. Make sure the CA certificate is has been obtained

    ```sh
    cat /tmp/my_ca_certificate.pem
    ```

1. Run the following script to generate the code for the Python session.

    The script will generate the statements that are specific to your environment. You will use this once you have the Python session.

    ```sh
    code_dir=$HOME"/PSGEL298-sas-viya-4-deployment-on-azure-kubernetes-service/scripts"
    bash ${code_dir}/utils/GEL.220.Python.Session.sh
    ```

1. Connect to CAS from Python

    ```sh
    python
    ```

    You should see something like :

        ```log
        Python 3.5.2 (default, Jul 17 2020, 14:04:10)
        [GCC 5.4.0 20160609] on linux
        Type "help", "copyright", "credits" or "license" for more information.
        >>>
        ```

1. Now cut and paste the code output from the previous step into the Python session.

    Now should see:

    ![](../../img/gelenable-python-to-cas.png)


1. Type the following to exit the Python shell.

    ```sh
    quit()
    ```

## Customization 2 : Force CAS Worker to run on different nodes

_Note : With recent versions, if you use the initial kustomization.yaml file (with the cas auto-resourcing), the CAS operator determines the amount of CPU required for your deployment based upon available CPU on the Kubernetes nodes where CAS is running._
_If you prefer to set your own CPU resources, perform the following steps._

CAS (aka the Cloud Analytics Services) is the SAS Viya High-Performance Analytics Engine and, as such, can take advantage of the whole processing power of a physical machine (in terms of CPU, memory and storage). As CAS can also be distributed across multiple nodes, if there is a lot of data to process in a short period of time, it would a a good idea to ensure that only ONE CAS worker is located on each physical node.
It would avoid any conflict between CAS workers on the same machine and let CAS fully benefit from the machines resources.

In Kubernetes there are different ways to force a pod to be alone on a node, for example using Pod anti-affinity or play on the resource requests.

In this example, we will change the worker CPU request to ensure that only one CAS worker can fit on a node of the CAS nodepool.

After the deployment, you might have noticed that all the CAS pods (the CAS controller and the CAS workers) are running on a single Kubernetes node.

CAS (aka the Cloud Analytics Services) is the SAS Viya High-Performance Analytics Engine and, as such, can take advantage of the whole processing power of a physical machine (in terms of CPU, memory and storage). As CAS can also be distributed across multiple nodes, if there is a lot of data to process in a short period of time, it would a a good idea to ensure that only ONE CAS worker is located on each physical node.
It would avoid any conflict between CAS workers on the same machine and let CAS fully benefit from the machines resources.

In Kubernetes there are different ways to force a pod to be alone on a node, for example using Pod anti-affinity or play on the resource requests.

In this example, we will change the worker CPU request to ensure that only one CAS worker can fit on a node of the CAS nodepool (we have 4 CPU nodes, so we request a minimum of 3 CPU for each CAS node).

See [Official documentation](http://pubshelpcenter.unx.sas.com:8080/preview/?docsetId=rnddplyreadmes&docsetTarget=sas-cas-operator_examples_cas_configure_cas-manage-cpu-and-memory_yaml.htm&docsetVersion=friday&locale=en) or just follow the steps below to  do it.

### Increase the CAS Pods CPU request

* Create the "PatchTransformer" manifest to request 3 CPUs for the CAS containers

    ```sh
    mkdir -p ~/project/deploy/prod/site-config/patches/
    cat > ~/project/deploy/prod/site-config/patches/3cpu-per-casnode.yaml << EOF
    ---
    apiVersion: builtin
    kind: PatchTransformer
    metadata:
      name: cas-manage-cpu-and-memory
    patch: |-
      - op: replace
        path: /spec/controllerTemplate/spec/containers/0/resources/requests/cpu
        value:
          3
    target:
      group: viya.sas.com
      kind: CASDeployment
      name: .*
      version: v1alpha1
    EOF
    ```

* In the transformers section of the kustomization.yml add the line ```site-config/patches/3cpu-per-casnode.yaml```

    ```log
    [...]
    transformers:
    [... previous transformers items ...]
    - site-config/patches/3cpu-per-casnode.yaml
    [...]
    ```

* Alternatively, you can run these commands to update your kustomization.yaml file using the yq tool.

    ```sh
    printf "
    - command: update
      path: transformers[+]
      value:
        site-config/patches/3cpu-per-casnode.yaml   ## patch to change CAS Disk Cache from empty dir to ephem stotage in azure
    " | yq -I 4 w -i -s - ~/project/deploy/prod/kustomization.yaml

* Rebuild the manifests

    ```sh
    cd ~/project/deploy/prod
    kustomize build -o site.yaml
    ```

* Delete the CAS Deployment operator and re-apply the manifest

    ```sh
    kubectl -n prod delete CASDeployment default
    cd ~/project/deploy/prod
    kubectl -n prod apply -f site.yaml
    ```

### Validate

* First you will notice that the CAS controller and workers status change from "Running" to "Pending" or "PodInitializing" state.

* You can follow the status in Lens, or use the following command.

    ```sh
    watch 'kubectl get pods -n prod -o wide | grep sas-cas-server'
    ```

    For example,
    
    ![cas pods](../../img/cas-pods.png)

* After a little while, you should see new nodes being provisionned.

* Using the command line:

    ```sh
    kubectl get nodes | grep cas
    ```

    You should see that there are now new nodes. For example.

    ```log
    aks-cas-18185891-vmss000001         Ready    agent   42h    v1.21.9
    aks-cas-18185891-vmss000008         Ready    agent   134m   v1.21.9
    aks-cas-18185891-vmss000009         Ready    agent   134m   v1.21.9
    aks-cas-18185891-vmss00000a         Ready    agent   134m   v1.21.9
    aks-cas-18185891-vmss00000b         Ready    agent   133m   v1.21.9
    ```

<!-- REMOVED Should be in a separate md exercise - NEEDS to be redeveloped for gelenable
## Customization 3 : Use Azure Fast Ephemeral storage for CAS Disk Cache

To get the best I/O performances as possible on our CAS workers, we want to use NVMe Flash Drives on LSv2 Azure instances for CAS Disk Cache (Ephemeral storage).

[Doc Reference](http://pubshelpcenter.unx.sas.com:8080/test/?cdcId=itopscdc&cdcVersion=v_006&docsetId=dplyml0phy0dkr&docsetTarget=n08u2yg8tdkb4jn18u8zsi6yfv3d.htm&locale=en#p0wtwirnp4uayln19psyon1rkkr9)

### Redeploy with LSv2 Azure instances for the CAS nodes

* Destroy the AKS cluster

  ```sh
  cd ~/project/aks/azure-aks-4-viya-master
  # temp
  #terraform destroy -input=false -var-file=./gel-vars.tfvars
  terraform destroy -input=false -var-file=./gel-vars.tfvars
  ```

  ```Don't forget to confirm the deletion.```

* Change the TF vars to use LSV2 instance for the CAS node pools

  ```sh
  ansible localhost -m lineinfile -a "path='~/project/aks/azure-aks-4-viya-master/gel-vars.tfvars' regexp='^cas_nodepool_vm_type' line='cas_nodepool_vm_type      = \"Standard_L16s_v2\"'" --diff
  ```

* Rebuild the plan

  ```sh
  cd ~/project/aks/azure-aks-4-viya-master
  #terraform plan -input=false \
  terraform plan -input=false \
      -var-file=./gel-vars.tfvars \
      -out ./my-aks.plan
  ```

* Re-apply the plan

  ```sh
  TFPLAN=my-aks.plan
  # by default, we go with the multi node pools AKS cluster but you can choose the minimal one to test
  cd ~/project/aks/azure-aks-4-viya-master
  #time terraform apply "./${TFPLAN}"
  #temp for TF 0.13.1
  time terraform apply "./${TFPLAN}"
  ```

* Update the kubctl config

  ```sh
  # generate the config file with a recognizable name
  cd ~/project/aks/azure-aks-4-viya-master
  mkdir -p ~/.kube
  #terraform output kube_config > ~/.kube/${STUDENT}-aks-kubeconfig.conf
  #temp for TF 0.13.1
  terraform output kube_config > ~/.kube/${STUDENT}-aks-kubeconfig.conf
  SOURCEFOLDER=~/.kube/${STUDENT}-aks-kubeconfig.conf
  ansible localhost -m file -a "src=$SOURCEFOLDER dest=~/.kube/config state=link" --diff
  ```

* Disable API authorization range

  ```sh
  az aks update -n ${STUDENT}viya4aks-aks -g ${STUDENT}viya4aks-rg --api-server-authorized-ip-ranges ""
  ```

* Generate the cheatcodes

  ```sh
  cd ~/payload/workshop/PSGEL298-sas-viya-4-deployment-on-azure-kubernetes-service/
  bash ~/payload/cheatcodes/create.cheatcodes.sh .
  ```

* Redeploy Viya with the cheatcodes

  ```sh
  bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/00*/00_110_Performing_the_prerequisites.sh 2>&1 \
  | tee -a ~/01_110_Performing_Prereqs_in_AKS.log
  bash -x ~/PSGEL298-sas-viya-4-deployment*/Track-A-Standard/01-Manual/01_200_Deploying_Viya_4_on_AKS.sh 2>&1 \
  | tee -a ~/01_200_Deploying_Viya_4_on_AKS.log
  ```

### Mount and Stripe NVMe Drives (ephemeral storage)

* Create the script locally

  ```sh
  cat << 'EOF' > ~/project/deploy/test/mountephemstorage.sh
  #!/bin/bash -e
  # source : https://gitlab.sas.com/xeno/viya-in-azure-reference-architecture/-/blob/master/artifacts/StripeMountEphemeralDisks.sh
  # Create a RAID 0 stack with the NVMe disks, mount it in /sastmp, create CDC folders
  # to run only when using Lsv2 instance types that comes with multiple NVMe flash drives
  # Support nvm-type ephemerals on LSv2 instance types

  # create sastmp directory/mountpoint
  if [ ! -d /sastmp/ ]; then
      mkdir /sastmp
  fi

  # find the nvm drive devices
  drives=""
  drive_count=0
  nvm_drives=$(lsblk  -d -n --output NAME | grep nvm || :)
  for device_name in $nvm_drives; do

    device_path="/dev/$device_name"

    if [ -b "$device_path" ]; then
      echo "Detected ephemeral disk: $device_path"
      drives="$drives $device_path"
      drive_count=$((drive_count + 1 ))
    else
      echo "Ephemeral disk $device_path is not present. skipping"
    fi

  done

  if [ "$drive_count" = 0 ]; then

    echo "No ephemeral disks detected."

  else

    # format (raid) ephemeral drives if needed
    if  [ "$(blkid /dev/md0 | grep xfs)" = "" ]; then

      #yum -y -d0 install mdadm

      # find the drive devices
      drives=""
      drive_count=0
      nvm_drives=$(lsblk  -d -n --output NAME | grep nvm)
      for device_name in $nvm_drives; do

        device_path="/dev/$device_name"

        if [ -b "$device_path" ]; then
          echo "Detected ephemeral disk: $device_path"
          drives="$drives $device_path"
          drive_count=$((drive_count + 1 ))
        else
          echo "Ephemeral disk $device_path is not present. skipping"
        fi

      done

      # overwrite first few blocks in case there is a filesystem, otherwise mdadm will prompt for input
      for drive in $drives; do
        dd if=/dev/zero of="$drive" bs=4096 count=1024
      done

      # create RAID and filesystem
      READAHEAD=16384
      partprobe
      mdadm --create --verbose /dev/md0 --level=0 -c256 --force --raid-devices=$drive_count $drives
      echo DEVICE "$drives" | tee /etc/mdadm.conf
      mdadm --detail --scan | tee -a /etc/mdadm.conf
      blockdev --setra $READAHEAD /dev/md0

      mkfs -t xfs /dev/md0

    fi

    # in case it was mounted already...
    umount /sastmp || true
    # for some instances, /mnt is the default instance store, already mounted. so we unmount it:
    umount /mnt || true

    mount -t xfs -o noatime /dev/md0 /sastmp

  fi

  if [ ! -d /sastmp/saswork/ ]; then
      mkdir /sastmp/saswork
  fi
  chmod 777 /sastmp/saswork
  if [ ! -d /sastmp/cascache/ ]; then
      mkdir /sastmp/cascache
  fi
  chmod 777 /sastmp/cascache
  EOF
  ```

* get the VM Scale Set name

    ```sh
    CAS_VMSET=$(az vmss list --resource-group MC_${STUDENT}VIYA4AKS-RG_${STUDENT}VIYA4AKS-AKS_$(cat ~/azureregion.txt) --query [].name --output tsv | grep cas)
    ```

* run the script on all the VMSS instances of the VM Scale Set

    ```sh
    az vmss list-instances -n ${CAS_VMSET} -g MC_${STUDENT}VIYA4AKS-RG_${STUDENT}VIYA4AKS-AKS_$(cat ~/azureregion.txt) --query "[].id" --output tsv | \
    az vmss run-command invoke --scripts @"~/project/deploy/test/mountephemstorage.sh" \
        --command-id RunShellScript --ids @-
    ```

* You can then use Lens to connect to your CAS node and check

* Check with "df -h" and "ls /sastmp" commands.

    ```log
    /dev/md0                                                                                                   3.5T  3.6G  3.5T   1% /sastmp
    ```

### Kustomizations for the new CAS DISK CACHE location

When not specified in the kustomize.yaml file CAS_DISK_CACHE defaults to /cas/cache directory.
The backing volume for /cas/cache is by default an **emptyDir** volume.

* Create the "PatchTransformer" manifest to use NVMe drives on the CAS nodes

    ```sh
    cat > ~/project/deploy/test/site-config/patches/mycascache.yaml << EOF
    ---
    apiVersion: builtin
    kind: PatchTransformer
    metadata:
      name: cas-add-host-mount
    patch: |-
        - op: add
          path: /spec/controllerTemplate/spec/volumes/-
          value:
            name: mycascache
            hostPath:
              path: /sastmp/cascache
              type: Directory
        - op: add
          path: /spec/controllerTemplate/spec/containers/0/volumeMounts/-
          value:
            name: mycascache
            mountPath: /mycascache
    target:
      group: viya.sas.com
      kind: CASDeployment
      name: .*
      version: v1alpha1
    EOF
    ```
-->

<!-- This was already hidden
    alternative by changing default cas-default-cache-volume, not working yet - see https://rndjira.sas.com/browse/DOCMNTATION-351

    * create the "PatchTransformer" manifest to use NVMe drives on the CAS nodes

    ```sh
    cat > ~/project/deploy/test/site-config/patches/cas-disk-cache.yaml << EOF
    ---
    apiVersion: builtin
    kind: PatchTransformer
    metadata:
      name: cas-volumes
    patch: |-
      - op: replace
        path: /spec/controllerTemplate/spec/volumes
        value:
        - name: cas-default-cache-volume
          hostPath:
            path: /sastmp/cascache
            type: Directory
    target:
      group: viya.sas.com
      kind: CASDeployment
      name: .*
      version: v1alpha1
    EOF
    ```
-->

<!-- REMOVED Should be in a separate md exercise
* Set the CASENV_CAS_DISK_CACHE environment variable. One way to set the environment variable is to create a patch file similar to the $deploy/sas-bases/examples/cas/configure/cas-add-environment-variables.yaml example

    ```sh
    cat > ~/project/deploy/test/site-config/patches/changeCDClocation.yaml << EOF
    # This block of code is for adding environment variables for the CAS server.
    ---
    apiVersion: builtin
    kind: PatchTransformer
    metadata:
      name: cas-add-environment-variables
    patch: |-
        - op: add
          path: /spec/controllerTemplate/spec/containers/0/env/-
          value:
            name: CASENV_CAS_DISK_CACHE
            value: "/mycascache"
    target:
      group: viya.sas.com
      kind: CASDeployment
      name: .*
      version: v1alpha1
    EOF
    ```

* In the transformers section of the kustomization.yml add the lines ```- site-config/patches/mycascache.yaml``` and ```- site-config/patches/changeCDClocation.yaml```

    ```log
    [...]
    transformers:
    [... previous transformers items ...]
    - site-config/patches/mycascache.yaml
    - site-config/patches/changeCDClocation.yaml
    [...]
    ```

* Alternatively, you can run these commands to update your kustomization.yaml file using the yq tool.

* execute this code for the new volume

    ```sh
    printf "
    - command: update
      path: transformers[+]
      value:
        site-config/patches/mycascache.yaml   ## patch to change CAS Disk Cache from empty dir to ephem stotage in azure
    " | yq -I 4 w -i -s - ~/project/deploy/test/kustomization.yaml
    ```

* Execute this code for the new location of CDC

    ```sh
    printf "
    - command: update
      path: transformers[+]
      value:
        site-config/patches/changeCDClocation.yaml   ## patch to change CAS Disk Cache from empty dir to ephem stotage in azure
    " | yq -I 4 w -i -s - ~/project/deploy/test/kustomization.yaml
    ```

* Rebuild the manifests

    ```sh
    cd ~/project/deploy/test
    kustomize build -o site.yaml
    ```

* Delete the CAS Deployment operator and re-apply the manifest

    ```sh
    kubectl -n test delete CASDeployment default
    cd ~/project/deploy/test
    kubectl -n test apply -f site.yaml
    ```

### Test it

* To really ensure that the CAS Disk Cache is now using the directory on which our NVMe drives are mounted, connect to a CAS node and run the command below :

    ```sh
    lsof +L1 | grep -e "cascache"
    ```

* Here is an example of what you should see:

    ![CAS disk cache](../../img/cdc.png)

## Customization 4 : Expose port 5570 for CAS external access

Please note that this hands-on will not work until port 5570 is opened between RACE and Azure.
![under construction](../../img/construction.png)

### Create a new CAS service to expose CAS ports

* First we prepare a manifest to create a new service to expose the CAS Controller

    ```sh
    cat > ~/project/deploy/test/CASlb.yaml << EOF
    ---
    apiVersion: v1
    kind: Service
    metadata:
        labels:
            app.kubernetes.io/instance: default
        name: sas-cas-server-default-lb
    spec:
        ports:
        - name: cas-cal
          port: 5570
          protocol: TCP
          targetPort: 5570
        - name: cas-gc
          port: 5571
          protocol: TCP
          targetPort: 5571
        selector:
            casoperator.sas.com/node-type: controller
            casoperator.sas.com/server: default
        type: "LoadBalancer"
        loadBalancerSourceRanges:
          - 149.173.0.0/16 #Cary
          - 109.232.56.224/27 #Marlow
          - 71.135.5.0/16 # Rob s VPN
    ---
    EOF
    ```

* Now, let's apply the manifest

    ```sh
    kubectl -n test apply -f  ~/project/deploy/test/CASlb.yaml
    kubectl -n test get svc | grep Load
    ```

* Check in the Azure Portal

Back to the Azure portal, you can notice that a new Public IP has been created

![new Public IP](../../img/newPublicIP.png)

You can also notice the creation of two new rules in the load-balancer configuration:

![new rules](../../img/newrules.png)

### Create a DNS alias name for the CAS service

Let's use the Azure CLI to associate the DNS to the newly created Public IP address.

* First we need to get the LB Public IP id (as defined in the Azure Cloud).

  ```sh
  STUDENT=$(cat ~/student.txt)
  # get the LB Public IP id (as defined in the Azure Cloud)
  CASPublicIPId=$(az resource list --query "[?type=='Microsoft.Network/publicIPAddresses' && tags.service == 'test/sas-cas-server-default-lb'].id" --output tsv)
  echo $CASPublicIPId
  ```

  _Notes : The provisioning of the new public IP, triggered by the previous step (service creation) can take a bit of time_

  * _The CASPublicIPId variable can only be obtained once the new public IP has been created in Azure. Until then, the CASPublicId is empty._

  * _Make sure the $CASPublicIPId variable has a value before proceeding with the next steps._

  * _It might also take some time for Azure to get this object Id. So if you still don't get a value for `CASPublicIPId` after a while, open the Azure portal and associate manually your DNS name, instead of runnin the az CLI command below._

* If the `CASPublicIPId` variable is not empty, we use the Public IP Id to create and associate a DNS alias:

  ```sh
  #use the Id to associate a DNS alias
  az network public-ip update -g MC_${STUDENT}viya4aks-rg_${STUDENT}viya4aks-aks_$(cat ~/azureregion.txt) \
  --ids $CASPublicIPId --dns-name ${STUDENT}cas
  ```

### Configuration of Server Certificate Attributes

* As TLS is required for the CAS communications we need to add our alias in the certificate SAN DNS entries (so the client can connect with the CA Certificates).

* The file sas-bases/examples/security/customer-provided-merge-sas-certframe-configmap.yaml can be used to add additional SAN DNS entries to the certificates generated by cert-manager.

    ```yaml
    ---
    apiVersion: builtin
    kind: ConfigMapGenerator
    metadata:
      name: sas-certframe-user-config
    behavior: merge
    literals:
    - SAS_CERTIFICATE_DURATION={{ CERTIFICATE_DURATION_IN_HOURS }}
    - SAS_CERTIFICATE_ADDITIONAL_SAN_DNS={{ ADDITIONAL_SAN_DNS_ENTRIES }}
    - SAS_CERTIFICATE_ADDITIONAL_SAN_IP={{ ADDITIONAL_SAN_IP_ENTRIES }}
    ```

* Let's create our own ConfigMapGenerator (we only need to change the ADDITIONAL_SAN_DNS_ENTRIES value)

    ```sh
    cat > ~/project/deploy/test/site-config/security/customer-provided-merge-sas-certframe-configmap.yaml << EOF
    ---
    apiVersion: builtin
    kind: ConfigMapGenerator
    metadata:
      name: sas-certframe-user-config
    behavior: merge
    literals:
    - SAS_CERTIFICATE_ADDITIONAL_SAN_DNS=${STUDENT}cas.eastus.cloudapp.azure.com
    EOF
    ```

* Add the path to the file to the generators block of your `kustomization.yaml` file. Here is an example:

    ```yaml
    generators:
    - site-config/security/customer-provided-merge-sas-certframe-configmap.yaml # merges customer provided configuration settings into the sas-certframe-user-config configmap
    ```

* We can automate the change with yq

    ```sh
    printf "
    - command: update
      path: generators[+]
      value:
        site-config/security/customer-provided-merge-sas-certframe-configmap.yaml # merges customer provided configuration settings into the sas-certframe-user-config configmap
    " | yq -I 4 w -i -s - ~/project/deploy/test/kustomization.yaml
    ```

So, with this we have added our external DNS alias to the SAN DNS entries.
On a running system you’ll need to restart pods for the sas-certframe init container to trigger and request the new certificate.

### Configure CAS authentication to Cloudnative

* Set the CASCLOUDNATIVE environment variable.

    One way to set the environment variable is to create a patch file

    ```sh
    mkdir -p ~/project/deploy/test/site-config/patches
    cat > ~/project/deploy/test/site-config/patches/setCASCLOUDNATIVE.yaml << EOF
    # This block of code is for adding environment variables for the CAS server.
    ---
    apiVersion: builtin
    kind: PatchTransformer
    metadata:
      name: cas-add-environment-variable-cloudnative
    patch: |-
        - op: add
          path: /spec/controllerTemplate/spec/containers/0/env/-
          value:
            name: CASCLOUDNATIVE
            value: "1"
    target:
      group: viya.sas.com
      kind: CASDeployment
      name: .*
      version: v1alpha1
    EOF
    ```

* In the transformers section of the kustomization.yml add the line - site-config/cas-server-default_nfs_mount.yaml

    ```log
    [...]
    transformers:
    [... previous transformers items ...]
    - site-config/patches/setCASCLOUDNATIVE.yaml
    [...]
    ```

* Alternatively, you can run these commands to update your kustomization.yaml file using the yq tool.
* Execute this code to add the CASCLOUDNATIVE settings

    ```sh
    printf "
    - command: update
      path: transformers[+]
      value:
        site-config/patches/setCASCLOUDNATIVE.yaml   ## patch to set CASCLOUDNATIVE
    " | yq -I 4 w -i -s - ~/project/deploy/test/kustomization.yaml
    ```

### Rebuild the manifest and update the environment

* Rebuild the manifests

    ```sh
    cd ~/project/deploy/test
    kustomize build -o site.yaml
    ```

* For the CAS configuration changes to take place and the sas-certframe init container to trigger and request the new certificate, delete the CAS Deployment operator and re-apply the manifest

    ```sh
    # delete the CAS Deployment CAS Deployment operator CRD
    kubectl -n test delete CASDeployment default
    cd ~/project/deploy/test
    kubectl -n test apply -f site.yaml
    ```

### Make sure the environment is ready for python connection test

```Read the notes below before proceeeding with the next steps```

* The ```kubectl apply``` command will recreate the "CASDeployment" CRD and force the CAS Controller and workers to restart.
* But many other pods will also restart to pick up the updated Server certificate.
* Wait for pods to come back, especially "SASLogon" which is required for our swat connection test (and can takes a while to maybe re-pull the image and start).
* Make sure the Viya services are ready before proceeding with the next steps.

### Connect to CAS from Python

* First let's install swat in the our collection

    ```sh
    sudo pip install swat
    ```

* Get the CA certificate

    ```sh
    kubectl -n test get secret sas-viya-ca-certificate-secret -o go-template='{{(index .data "ca.crt")}}' | base64 -d > /tmp/my_ca_certificate.pem
    ```

* Make sure the CA certificate is has been obtained

    ```sh
    cat /tmp/my_ca_certificate.pem
    ```

* Connect to CAS from Python

    ```sh
    python
    ```

* You should see something like :

    ```log
    Python 3.5.2 (default, Jul 17 2020, 14:04:10)
    [GCC 5.4.0 20160609] on linux
    Type "help", "copyright", "credits" or "license" for more information.
    >>>
    ```

* Type the following in the Python session

    ```sh
    import swat
    import os
    os.environ['TKESSL_OPENSSL_LIB'] = '/lib/x86_64-linux-gnu/libssl.so.1.1'
    os.environ['CAS_CLIENT_SSL_CA_LIST'] = '/tmp/my_ca_certificate.pem'
    student=os.environ['STUDENT']
    conn = swat.CAS(student+"cas.eastus.cloudapp.azure.com", "5570", "sastest1", "lnxsas")
    conn.serverstatus()
    ```

* Now should see :

    ```log
    >>> conn.serverstatus()
    NOTE: Grid node action status report: 4 nodes, 9 total actions executed.
    CASResults([('About', {'CAS': 'Cloud Analytic Services', 'Version': '4.00', 'VersionLong': 'V.04.00M0P10072020', 'Viya Release': '20201125.1606315308620', 'Viya Version': 'LTS 2020.1', 'Copyright': 'Copyright © 2014-2020 SAS Institute Inc. All Rights Reserved.', 'ServerTime': '2020-12-15T11:55:46Z', 'System': {'Hostname': 'controller.sas-cas-server-default.test.svc.cluster.local', 'OS Name': 'Linux', 'OS Family': 'LIN X64', 'OS Release': '5.4.0-1032-azure', 'OS Version': '#33~18.04.1-Ubuntu SMP Tue Nov 17 11:40:52 UTC 2020', 'Model Number': 'x86_64', 'Linux Distribution': 'Red Hat Enterprise Linux release 8.2 (Ootpa)'}, 'license': {'site': 'FULL ORDER FOR VIYA 4 GEL/WORKSHOPS', 'siteNum': 70273294, 'expires': '31Aug2021:00:00:00', 'gracePeriod': 45, 'warningPeriod': 46}, 'CASHostAccountRequired': 'OPTIONAL'}), ('server', Server Status

    nodes  actions
    0      4        9), ('nodestatus', Node Status

                                                    name        role  uptime  running  stalled
    0  worker-2.sas-cas-server-default.test.svc.clust...      worker  25.479        0        0
    1  worker-1.sas-cas-server-default.test.svc.clust...      worker  25.479        0        0
    2  worker-0.sas-cas-server-default.test.svc.clust...      worker  25.479        0        0
    3  controller.sas-cas-server-default.test.svc.clu...  controller  25.553        0        0)])
    ```

* Type the following to exit the Python shell

    ```sh
    quit()
    ```
-->

---

## Next Steps

Now that you have made the CAS customizations,  deployed Viya, let's instll monitoring and logging functionality.

Click [here](./01_230_Install_monitoring_and_logging.md) to move onto the next exercise: ***01_230_Install_monitoring_and_logging.md***

## Table of Contents for the Manual Deployment Method exercises

<!--Navigation for this set of labs-->
* [00-Common / 00 100 Creating an AKS Cluster](../00-Common/00_100_Creating_an_AKS_Cluster.md)
* [00-Common / 00 110 Performing the prerequisites](../00-Common/00_110_Performing_the_prerequisites.md)
* [01-Manual / 01 200 Deploying Viya 4 on AKS](./01_200_Deploying_Viya_4_on_AKS.md)
* [01-Manual / 01 210 Deploy a second namespace in AKS](./01_210_Deploy_a_second_namespace_in_AKS.md)
* [01-Manual / 01 220 CAS Customizations](./01_220_CAS_Customizations.md) **<-- You are here**
* [01-Manual / 01 230 Install monitoring and logging](./01_230_Install_monitoring_and_logging.md)
* [01-Manual / 01 240 Stop shrink and Start-scale in AKS](./01_240_Stop-shrink_and_Start-scale_in_AKS.md)
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
* [Track A-Standard/01-Manual / 01 220 CAS Customizations](/Track-A-Standard/01-Manual/01_220_CAS_Customizations.md)**<-- you are here**
* [Track A-Standard/01-Manual / 01 230 Install monitoring and logging](/Track-A-Standard/01-Manual/01_230_Install_monitoring_and_logging.md)
* [Track A-Standard/01-Manual / 01 240 Stop shrink and Start-scale in AKS](/Track-A-Standard/01-Manual/01_240_Stop-shrink_and_Start-scale_in_AKS.md)
* [Track A-Standard/02-DepOp / 02 300 Deployment Operator environment set up](/Track-A-Standard/02-DepOp/02_300_Deployment_Operator_environment_set-up.md)
* [Track A-Standard/02-DepOp / 02 310 Using the DO with a Git Repository](/Track-A-Standard/02-DepOp/02_310_Using_the_DO_with_a_Git_Repository.md)
* [Track A-Standard/02-DepOp / 02 330 Using the Orchestration Tool](/Track-A-Standard/02-DepOp/02_330_Using_the_Orchestration_Tool.md)
* [Track B-Automated / 03 500 Full Automation of AKS Deployment](/Track-B-Automated/03_500_Full_Automation_of_AKS_Deployment.md)
* [Track B-Automated / 03 590 Cleanup](/Track-B-Automated/03_590_Cleanup.md)
<!-- endnav -->
