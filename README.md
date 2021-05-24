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