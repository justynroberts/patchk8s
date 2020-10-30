#!/bin/sh
#set -x
if [ $# -eq 0 ]
  then
    echo "No arguments supplied. The utility works as follows - patchk8s.sh [namespace to patch].This will patch all pods with the downward API"
    exit
fi

NAMESPACE=$1

PATCH=$(cat << !EOF!
{
    "spec": {
        "template": {
            "spec": {
                "containers": [ {
                    "env": [ {
                        "name": "INSTANA_AGENT_HOST",
                        "valueFrom": {
                            "fieldRef": {
                                "apiVersion": "v1",
                                "fieldPath": "status.hostIP"
                            }
                        }
                    } ],
                    "name": "%NAME%"
                } ]
            }
        }
    }
}
!EOF!)

DEPLOYMENTS=$(kubectl get deployment -n $NAMESPACE --no-headers=true | awk '{print $1}' -)

for D in $DEPLOYMENTS
do
    echo "Patching  Deployment :-  $D"
    P=$(echo "$PATCH" | sed "s/%NAME%/$D/")
    kubectl patch deployment $D -n "$NAMESPACE" -p "$P"
done
