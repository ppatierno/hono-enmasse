# creating the directories for Eclipse Hono
bash create_host_dirs.sh

# creating Hono Server persistent volume (admin needed)
oc login -u system:admin
oc create -f ../application/target/fabric8/hono-app-pv.yml

# starting to deploy Eclipse Hono (developer user)
oc login -u developer
oc create -f ../application/target/fabric8/hono-app-pvc.yml

echo Deploying Hono Server ...
oc create -f ../application/target/fabric8/hono-app-svc.yml
oc create -f ../application/target/fabric8/hono-app-deployment.yml
oc create -f ../application/target/fabric8/hono-app-route.yml
echo ... done

echo Deploying HTTP REST adapter ...
oc create -f ../adapters/rest-vertx/target/fabric8/hono-adapter-rest-vertx-svc.yml
oc create -f ../adapters/rest-vertx/target/fabric8/hono-adapter-rest-vertx-deployment.yml
oc create -f ../adapters/rest-vertx/target/fabric8/hono-adapter-rest-vertx-route.yml
oc create -f ../adapters/rest-vertx/target/fabric8/hono-adapter-rest-vertx-insecure-route.yml
echo ... done

echo Deploying MQTT adapter ...
oc create -f ../adapters/mqtt-vertx/target/fabric8/hono-adapter-mqtt-vertx-svc.yml
oc create -f ../adapters/mqtt-vertx/target/fabric8/hono-adapter-mqtt-vertx-deployment.yml
oc create -f ../adapters/mqtt-vertx/target/fabric8/hono-adapter-mqtt-vertx-route.yml
echo ... done