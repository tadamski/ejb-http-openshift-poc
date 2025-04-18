mvn clean package
eval "$(crc oc-env)"
PROJECT_DIR=$(pwd)
echo "project dir to $PROJECT_DIR"
oc login -u developer -p developer https://api.crc.testing:6443 > /dev/null
echo "creating project ospoc"
oc new-project ospoc > /dev/null
oc registry login > /dev/null
OPENSHIFT_IMAGE_REGISTRY="$(oc registry info)"
docker login -u openshift -p "$(oc whoami -t)" "$OPENSHIFT_IMAGE_REGISTRY" > /dev/null
cd "$PROJECT_DIR"/client || exit
echo "buduje klienta"
docker build -t client:latest .
docker tag client:latest "$OPENSHIFT_IMAGE_REGISTRY"/ospoc/client:latest
docker push "$OPENSHIFT_IMAGE_REGISTRY"/ospoc/client:latest
echo "buduje service"
cd "$PROJECT_DIR"/service || exit
docker build -t service:latest .
docker tag  service:latest "$OPENSHIFT_IMAGE_REGISTRY"/ospoc/service:latest
docker push "$OPENSHIFT_IMAGE_REGISTRY"/ospoc/service:latest