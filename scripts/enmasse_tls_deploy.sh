#!/bin/sh

echo DEPLOYING ECLIPSE HONO AND ENMASSE ON OPENSHIFT

# creating new project
oc new-project hono --description="Open source IoT connectivity" --display-name="Eclipse Hono"

echo Deploying EnMasse ...
oc create sa enmasse-service-account -n $(oc project -q)
oc policy add-role-to-user view system:serviceaccount:$(oc project -q):default
oc policy add-role-to-user edit system:serviceaccount:$(oc project -q):enmasse-service-account

oc secret new qdrouterd-certs ../certs/server-cert.pem ../certs/server-key.pem
oc secret add serviceaccount/default secrets/qdrouterd-certs --for=mount
oc secret new mqtt-certs ../certs/server-cert.pem ../certs/server-key.pem
oc secret add serviceaccount/default secrets/mqtt-certs --for=mount

oc process -f https://github.com/EnMasseProject/enmasse/releases/download/0.8.0/sasldb-tls-enmasse-template.yaml | oc create -f -
echo ... done

echo ECLIPSE HONO AND ENMASSE DEPLOYED ON OPENSHIFT

# NOTE : to execute for deploying telemetry and event addresses
# curl -X PUT -H "content-type: application/json" --data-binary @addresses.json http://$(oc get service -o jsonpath='{.spec.clusterIP}' address-controller):8080/v3/address