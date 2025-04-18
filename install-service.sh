SERVICE_NAME=$1
export SERVICE_NAME
N=$2
echo "installing service $SERVICE_NAME with $N nodes"
cd "$(pwd)"/service  || exit
< operator-template.yaml yq '.metadata.name = strenv(SERVICE_NAME)' | yq ".spec.replicas = $N" > operator.yaml
kubectl create -f operator.yaml
#rm operator.yaml
echo "waiting for $1 pod 1"
#FIXME without sleep the wait commands sometimes doesn't see the pod and fails
sleep 10
for i in $(seq 0 $(("$N"-1)))
do
   oc wait --for=condition=Ready=true pod "$SERVICE_NAME-$i" --timeout=300s
   echo "adding user to $1-$i"
   oc exec -i "$1-$i" -- bash -c "/opt/wildfly/bin/add-user.sh -a pies pies" > /dev/null
done
echo "installing proxy for service $SERVICE_NAME"
helm install "$SERVICE_NAME" -f proxy.yaml haproxytech/haproxy > /dev/null
cd "$(pwd)"  || exit
