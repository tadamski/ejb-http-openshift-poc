mvn clean package
export IMAGE=server:latest
export OPENSHIFT_NS=$(oc project -q)
oc registry login
export OPENSHIFT_IMAGE_REGISTRY=$(oc registry info)
docker login -u openshift -p $(oc whoami -t)  $OPENSHIFT_IMAGE_REGISTRY
docker build -t server:latest .
docker tag  $IMAGE $OPENSHIFT_IMAGE_REGISTRY/$OPENSHIFT_NS/$IMAGE
docker push  $OPENSHIFT_IMAGE_REGISTRY/$OPENSHIFT_NS/$IMAGE
kubectl delete wildflyserver server
kubectl create -f operator.yaml
