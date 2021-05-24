function getTags() {
  repo=$1
  wget -q https://registry.hub.docker.com/v1/repositories/$repo/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'
}

function getEvents(){
  kubectl get events
}

function getnodes(){
  kubectl get node -o wide
}

