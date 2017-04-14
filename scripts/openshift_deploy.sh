#!/bin/sh

echo DEPLOYING ECLIPSE HONO AND ENMASSE ON OPENSHIFT

# creating new project
oc new-project hono --description="Open source IoT connectivity" --display-name="Eclipse Hono"

echo Deploying EnMasse ...
oc create sa enmasse-service-account -n $(oc project -q)
oc policy add-role-to-user view system:serviceaccount:$(oc project -q):default
oc policy add-role-to-user edit system:serviceaccount:$(oc project -q):enmasse-service-account

oc process -f https://raw.githubusercontent.com/EnMasseProject/enmasse/master/generated/sasldb-enmasse-template.yaml | oc create -f -
echo ... done

# creating the directory for Hono Server persistent volume
if [ ! -d /tmp/hono ]; then
    mkdir /tmp/hono
    chmod 777 /tmp/hono
else
    echo /tmp/hono already exists !
fi

# creating Hono Server persistent volume (admin needed)
oc login -u system:admin
oc create -f ../application/target/fabric8/hono-app-pv.yml

# starting to deploy Eclipse Hono (developer user)
oc login -u developer
oc create -f ../application/target/fabric8/hono-app-pvc.yml

echo Deploying Hono Server ...
oc create -f ../application/target/fabric8/hono-app-svc.yml
oc create -f ../application/target/fabric8/hono-app-deployment.yml
echo ... done

echo Deploying HTTP REST adapter ...
oc create -f ../adapters/rest-vertx/target/fabric8/hono-adapter-rest-vertx-svc.yml
oc create -f ../adapters/rest-vertx/target/fabric8/hono-adapter-rest-vertx-deployment.yml
echo ... done

echo Deploying MQTT adapter ...
oc create -f ../adapters/mqtt-vertx/target/fabric8/hono-adapter-mqtt-vertx-svc.yml
oc create -f ../adapters/mqtt-vertx/target/fabric8/hono-adapter-mqtt-vertx-deployment.yml
echo ... done

echo ECLIPSE HONO AND ENMASSE DEPLOYED ON OPENSHIFT

# NOTE : to execute for deploying telemetry and event addresses
# curl -X PUT -H "content-type: application/json" --data-binary @addresses.json http://$(oc get service -o jsonpath='{.spec.clusterIP}' address-controller):8080/v3/address