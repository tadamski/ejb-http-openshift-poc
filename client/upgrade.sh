mvn clean package
export IMAGE=client:latest
export OPENSHIFT_NS=$(oc project -q)
oc registry login
export OPENSHIFT_IMAGE_REGISTRY=$(oc registry info)
docker login -u openshift -p $(oc whoami -t)  $OPENSHIFT_IMAGE_REGISTRY
docker build -t client:latest .
docker tag $IMAGE $OPENSHIFT_IMAGE_REGISTRY/$OPENSHIFT_NS/$IMAGE
docker push $OPENSHIFT_IMAGE_REGISTRY/$OPENSHIFT_NS/$IMAGE
helm upgrade client -f helm.yaml wildfly/wildfly
