echo "installing client"
cd "$(pwd)"/client  || exit
helm install client -f helm.yaml wildfly/wildfly > /dev/null
cd "$(pwd)" || exit