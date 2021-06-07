# Cheat Sheet

kubectl run mypod --image=nginx --dry-run -o yaml
kubectl run mypod --image=nginx --namespace=default --env=HELLO=VALUE --dry-run -o yaml


# Docker - Running containers in Docker

- Run a container interactively

```bash
docker run -it -p 8080:80 -e ENV_VAR=value -e ENV_VAR_SECRET=value alpine sh   

docker run -it -p 8080:80 nginx
```

- Run a container non-interactively

```bash
docker run -d -p 8080:80 -e ENV_VAR=value -e ENV_VAR_SECRET=value alpine sh -c "sleep 1000" 

docker run --name container --user 1000 -d -p 8080:80 -e ENV_VAR=value -e ENV_VAR_SECRET=value alpine sh -c "sleep 1000" 
```

- Open a shell into a running container
docker exec -it container sh


# Exercise - Build a docker image

## DockerHub

### Windows

```powershell
$registry_uri="dockerhubregistry/myrepo"
docker build --tag $registry_uri . 
docker run --rm –it $registry_uri sh
docker login -u dockerhubregistry
docker push $REPO
```

### MacOS

```bash
registry_uri="dockerhubregistry/myrepo"
docker build --tag $registry_uri .
docker run --rm –it $registry_uri sh
docker login -u dockerhubregistry
docker push $registry_uri
```

## Azure ACR 

### Windows

```powershell
$registry="akstraining123"
$registry_uri="akstraining123.azurecr.io"
$accounts=az account list
if ($accounts.length -eq 0){
  az login --tenant gunnebo.com
}
az acr login --name $registry
docker build -t $registry_uri/my/repo:0.13 --tag $registry_uri/my/repo:latest .
docker push $registry_uri/my/repo:0.13
docker push $registry_uri/my/repo:latest
```

### MacOS

```bash
registry="akstraining123"
registry_uri="akstraining123.azurecr.io"
accounts=$(az account list)
if $accounts; then
  az login --tenant gunnebo.com
fi
az acr login --name $registry
docker build -t $registry_uri/my/repo:0.13 --tag $registry_uri/my/repo:latest .
docker push $registry_uri/my/repo:0.13
docker push $registry_uri/my/repo:latest
```

# Exercise - Run a container in Kubernetes (imperative)

kubectl run mypod --rm -it --port 80 --env="ENV_VAR_SECRET=value" --image=nginx 

```
--rm remove container once PID 1 it had exit'ed
--port 80 expose port 80 outside of the container
-it Run interactively
```

kubectl port-forward mypod 8080:80

- Now go to http://127.0.0.1:8080/



# Resources Types in Kubernetes

Pod -> Deployment/Job/DaemonSet/Statefulset -> ReplicaSets 



# Exercise - Run a container in Kubernetes (declarative)

## Create a basic pod

kubectl apply -f pod.yaml

## Create a Deployment

kubectl apply -f Deployment.yaml

## Create a Deployment with RollingUpdate capability

kubectl apply -f DeploymentRollingUpdate.yaml

## Gain access to the pod with a service

kubectl apply -f PodService.yaml

## RollingUpdates - Kubectl

- Apply an immediate change to the deployment to upgrade it

kubectl set image deployment.v1.apps/mydep alpine:3.9.3

- Check status of the upgrade

kubectl rollout status deployment.v1.apps/mydep

- Check the history of rollouts

kubectl rollout history deployment.v1.apps/mydep --revision=2

- Rollback

kubectl rollout undo deployment.v1.apps/mydep


## Exercise - Helm RollingUpdates

- Create the chart

cd charts
helm create mynewchart
rm -fr mynewchart/templates/tests  

- Install the chart 

helm upgrade mypod ./mynewchart --install --namespace default

- Run the port-forward command displayed in the prompt

## Follow-up email

```bash
#Perfrom and record the RollingUpgrade of a Kubernetes deployment to docker image version nginx:1.161 where the deployment name is ‘nginx-deployment’ and the container name is ‘nginx’

kubectl --record deployment.apps/nginx-deployment set image deployment.v1.apps/nginx-deployment nginx=nginx:1.16.1
--record You can specify the --record flag to write the command executed in the resource annotation kubernetes.io/change-cause. The recorded change is useful for future introspection. For example, to see the commands executed in each Deployment revision. See here for more information

#Generate a yaml file for a deployment 

kubectl create deployment mydeployment --image=nginx --dry-run -o yaml

#MacOS/Linux - Output a list of Kubernetes Resource “Kind:” vs “apiVersion:” for use at the top of all Kubernetes yaml files
for kind in `kubectl api-resources | tail +2 | awk '{ print $1 }'`; do kubectl explain $kind; done | grep -e "KIND:" -e "VERSION:"

```


# Session 2 - AKS Core

az ad sp create-for-rbac --skip-assignment --name myAKSClusterServicePrincipal

## Exercise - Running Terraform using Docker

- Populate the below file with the provided `appId` and `password` 

`session2/terraform/terraform.tfvars`

### [OPTIONAL] Build and push the docker image 


- MacOS

```bash
registry_uri="akstraining123.azurecr.io"
accounts=$(az account list)
if $accounts; then
 az login --tenant gunnebo.com
fi
az acr login --name $registry_uri
docker build -t $registry_uri/terraform:0.14.6 --tag $registry_uri/terraform:latest .
docker push $registry_uri/terraform:0.14.6
docker push $registry_uri/terraform:latest
```

- Windows

```powershell
$registry="akstraining123"
$registry_uri="akstraining123.azurecr.io"
$accounts=az account list
if ($accounts.length -eq 0){
  az login --tenant gunnebo.com
}
az acr login --name $registry_uri
docker build -t $registry_uri/terraform:0.14.6 --tag $registry_uri/terraform:latest .
docker push $registry_uri/terraform:0.14.6
docker push $registry_uri/terraform:latest
```


### Running Terraform using Docker (Mac)


```bash
cd session2/terraform ; 



# Login to ACR
registry_uri="akstraining123.azurecr.io"
accounts=$(az account list)
if $accounts; then
 az login --tenant gunnebo.com
fi
az acr login --name $registry_uri


# Run the new 
docker rmi akstraining123.azurecr.io/terraform:0.14.6
docker run --rm -it -v ~/.azure:/root/.azure -v `pwd`:/project akstraining123.azurecr.io/terraform:0.14.6 bash

cd /project


# Ensure Azure Account is set
az account set --subscription 64e455b9-c577-484c-8710-35cb4a94a2c7

# Initialise the Terraform backend state
terraform init


# Deploy resources using Terraform
terraform apply
```

### Running Terraform using Docker (Win)

```powershell
cd session2/terraform ; 

$pwd=Get-Location
# Run the new 
docker rmi akstraining123.azurecr.io/terraform:0.14.6
docker run --rm -it -v ~/.azure:/root/.azure -v ${pwd}:/project akstraining123.azurecr.io/terraform:0.14.6 bash

cd /project


# Ensure Azure Account is set
az account set --subscription 64e455b9-c577-484c-8710-35cb4a94a2c7


# Initialise the Terraform backend state
terraform init


# Deploy resources using Terraform
terraform apply
```


## Exercise - Terraform Practical implementation

- Update the AKS tags to include your name eg. "georgec" : "true",

Edit: 

`session2/terraform/aks-cluster.tf`

- Deploy the change (Mac)
```bash
cd session2/terraform ; 

# Run the new 
docker run --rm -it -v ~/.azure:/root/.azure -v `pwd`:/project akstraining123.azurecr.io/terraform:0.14.6 bash

cd /project

# Initialise the Terraform backend state
terraform init


# Deploy resources using Terraform
terraform apply
```

- Deploy the change (Win)

```powershell
cd session2/terraform ; 

# Run the new 
$pwd=Get-Location
docker run --rm -it -v ~/.azure:/root/.azure -v ${pwd}:/project akstraining123.azurecr.io/terraform:0.14.6 bash

cd /project

# Initialise the Terraform backend state
terraform init


# Deploy resources using Terraform
terraform apply
```


## Exercise - Interact with AKS


Either 

 - Retrieve the Kubernetes configuration to authenticate your local Kubectl

 or

 - Use Azure CLI to retrieve the configuration

1. Retrieve the Kubernetes configuration to authenticate your local Kubectl

```bash
terraform apply

# or just use the output function
terraform output

```

- Copy and paste it to ~/.kube/kubeconfig_aks-training

- Use the context

export KUBECONFIG=~/.kube/kubeconfig_aks-training

- Test connectivity

kubectl get pods

- Deploy a container

kubectl apply -f pod.yaml

2. Use Azure CLI to retrieve the configuration

- Retrieve kube config using Azure CLI

az aks get-credentials --resource-group aks-training --name smashing-tortoise-aks

- Test connectivity

kubectl get pods

- Deploy a container

kubectl apply -f pod.yaml


## Basic monitoring

- See .bash_profile

- Deploy Metrics server

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml
Kubectl top nodes
Kubectl top pod 


- Deploy K8s Dashboard

```bash

# Install the dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

# Run the local k8s proxy

kubectl proxy --port=8001 --address=0.0.0.0 --accept-hosts='.*'

# Browse to the service
http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login

kubectl -n kube-system describe secret deployment-controller-token-frsqj

# To login using the token (MacOS)
kubectl -n kube-system get secret deployment-controller-token-bq2q6 -o jsonpath='{.data.token}' | base64 --decode

# To login using the token (Windows)
kubectl -n kube-system get secret deployment-controller-token-bq2q6 -o jsonpath='{.data.token}'
```