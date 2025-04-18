eval $(crc oc-env)
echo "logging as developer"
oc login -u developer -p developer https://api.crc.testing:6443 > /dev/null
echo "creating project ospoc"
oc new-project ospoc > /dev/null
echo "logging as kubeadmin"
oc login -u kubeadmin -p kubeadmin https://api.crc.testing:6443 > /dev/null
#FIXME
cd /home/tomek/workspace/wildfly-operator
echo "installing operator"
make install >> /dev/null
make deploy >> /dev/null
echo "granting wildfly-operator role to developer"
oc adm policy add-role-to-user wildfly-operator developer --role-namespace=ospoc -n ospoc
echo "logging as developer"
oc login -u developer -p developer https://api.crc.testing:6443 > /dev/null
echo "logging to docker repository"
oc registry login > /dev/null 2>&1
OPENSHIFT_IMAGE_REGISTRY=$(oc registry info 2>/dev/null)
docker login -u openshift -p "$(oc whoami -t)"  "$OPENSHIFT_IMAGE_REGISTRY" > /dev/null 2>&1


