function kubectltopnodes(){
    kubectl get nodes --no-headers | awk '{print $1}' | xargs -I {} sh -c 'echo {}; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo'
}

function ksleep(){
  # Beware this relies on the container being in position 0 and will overwrite any existing command. 
    kubectl patch deploy $1 --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/command", "value":"[\"/bin/sh\",\"-c\",\"sleep infinity\""}]'
}