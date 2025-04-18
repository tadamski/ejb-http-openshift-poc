export SERVICE_NAME=$1
echo "service name to $SERVICE_NAME"
mvn clean package > /dev/null
export IMAGE=service:latest
export OPENSHIFT_NS=$(oc project -q)
oc registry login > /dev/null
export OPENSHIFT_IMAGE_REGISTRY=$(oc registry info)
docker login -u openshift -p $(oc whoami -t)  $OPENSHIFT_IMAGE_REGISTRY > /dev/null
docker build -t ${IMAGE} . > /dev/null
docker tag  $IMAGE $OPENSHIFT_IMAGE_REGISTRY/$OPENSHIFT_NS/$IMAGE > /dev/null
docker push  $OPENSHIFT_IMAGE_REGISTRY/$OPENSHIFT_NS/$IMAGE > /dev/null
cat operator-template.yaml | yq '.metadata.name = strenv(SERVICE_NAME)' > operator.yaml
kubectl create -f operator.yaml
rm operator.yaml
