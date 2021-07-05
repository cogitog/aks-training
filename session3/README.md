


# Istio Demo – Install Istio and configure namespaces

## PreReqs

- Login to AKS 

unset KUBECONFIG
az login --tenant gunnebo.com
az aks get-credentials --resource-group aks-training --name smashing-tortoise-aks 


## Install Istioctl 

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.10.2 sh -
cd istio-*
export PATH=$PWD/bin:$PATH


## Install Istio
echo "Deleting namespace"
kubectl delete namespace istio-system
echo "Creating namespace"
kubectl create namespace istio-system
echo "Installing istio"
istioctl install --set profile=demo -y

## Enable mTLS for 'default' namespace
kubectl label namespace default istio-injection=enabled --overwrite

## Enable mTLS for 'secure' namespace
kubectl create namespace secure
kubectl label namespace secure istio-injection=enabled --overwrite
kubectl apply -f istio//example1/istio-mtls-secure.yaml

## Install the example application
kubectl apply -f istio/example1/productpage.yaml -l service=productpage # productpage Service
kubectl apply -f istio/example1/productpage.yaml -l account=productpage # productpage ServiceAccount
kubectl apply -f istio/example1/productpage.yaml -l app=productpage


## Expose the traffic via an IstioGateway and VirtualService
kubectl apply -f istio/example1/istio-gateway-virtualservice.yaml

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

curl -s "http://${GATEWAY_URL}/productpage" | grep -o "<title>.*</title>"


# Exercise 1 – Create productpage application

## Deploy your own productpage 

Example. georgec

```bash
sed 's/REPLACE_ME/georgec/g' istio/exercise1/productpage.yaml  > ./istio/exercise1/productpage-georgec.yaml
kubectl apply -f istio/exercise1/productpage-georgec.yaml 

# Connect to the service via port-forward
kubectl port-forward deploy/productpage-georgec 9080:9080 &
```

## Fix the networking issue!

Search for "BROKEN" in the selector

# Exercise 2 – Create  Istio Gateway and VirtualService

## Deploy the VirtualService and Gateway

```bash
sed 's/REPLACE_ME/georgec/g' ./istio/exercise2/istio-gateway-virtualservice.yaml  > ./istio/exercise2/istio-gateway-virtualservice-georgec.yaml
kubectl apply -f ./istio/exercise2/istio-gateway-virtualservice-georgec.yaml 


# Connect to the service via the LoadBalancer
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

curl -s "http://${GATEWAY_URL}/productpage" | grep -o "<title>.*</title>"
```


## Fix the networking issue!

Check the Browser console for errors, remove the specific route

Remove yaml to allow traffic on other required routes eg. /static

```yaml
 match:
    - uri:
        exact: /productpage
```

# Troubleshooting 

## CheatSheet

```bash
# List Kubernetes control plane events in timeStamp order
kubectl get events --sort-by=.metadata.creationTimestamp

# List logs for the latest version of a pod for a given deployment
kubectl logs -f deploy/productpage-georgec 

# Labelling resources is important to help group resources and therefore identify and manage them
kubectl get all -A -l app=productpage -o yaml 

# Recreate all resources with label ‘productpage’ in namespace ‘temp’
kubectl get all -A -l app=productpage -o yaml | sed ‘s/default/temp/g’ | xargs kubectl apply -f -

# Compares the current state of the cluster against the state that the cluster would be in if the manifest was applied.
kubectl diff -f ./my-manifest.yaml

# Connect directly to a Deployment to test it works 
kubectl port-forward deploy/productpage-georgec 9080:9080
curl http://localhost:9080/productpage

# Run a Busybox container to debug networking issues
kubectl run --rm -it --generator=deployment/apps.v1 --image=busybox:1.28 bash
> ping kubernetes.default
```


