#!/bin/bash

PROJECT_DIR=$(pwd)/..

prepare_crc_env() {
  eval "$(crc oc-env)"
}

create_testsuite_namespace() {
  echo "logging as developer"
  oc login -u developer -p developer https://api.crc.testing:6443 > /dev/null
  echo "creating project ospoc"
  oc new-project ospoc > /dev/null
}

install_wildfly_operator() {
  echo "logging as kubeadmin"
  oc login -u kubeadmin -p kubeadmin https://api.crc.testing:6443 > /dev/null
  if [[ -z "$OPERATOR_DIR" ]]; then
      echo "Must provide the directory of wildfly-operator in OPERATOR_DIR variable" 1>&2
      exit 1
  fi
  cd "$OPERATOR_DIR" || exit
  echo "installing operator"
  make install >> /dev/null
  make deploy >> /dev/null
  echo "granting wildfly-operator role to developer"
  oc adm policy add-role-to-user wildfly-operator developer --role-namespace=ospoc -n ospoc
  echo "logging as developer"
  oc login -u developer -p developer https://api.crc.testing:6443 > /dev/null
  cd "$PROJECT_DIR" || exit
}

login_to_crc_docker_repository() {
  echo "logging to crc docker repository"
  oc registry login > /dev/null 2>&1
  OPENSHIFT_IMAGE_REGISTRY=$(oc registry info 2>/dev/null)
  docker login -u openshift -p "$(oc whoami -t)"  "$OPENSHIFT_IMAGE_REGISTRY" > /dev/null 2>&1
}

build_docker_image() {
  cd "$PROJECT_DIR"/"$1" || exit
  echo "building $1 image"
  docker build -t "$1":latest .
  docker tag "$1":latest "$OPENSHIFT_IMAGE_REGISTRY"/ospoc/"$1":latest
  docker push "$OPENSHIFT_IMAGE_REGISTRY"/ospoc/"$1":latest
  cd "$PROJECT_DIR" || exit
}

generate_images() {
  mvn clean package
  login_to_crc_docker_repository
  build_docker_image client
  build_docker_image service
}

before_testsuite() {
  prepare_crc_env
  create_testsuite_namespace
  install_wildfly_operator
  generate_images
}

clear_recent_test() {
  for release in $(helm ls --short)
  do
    helm delete "$release"
  done

  for server in $(oc get wildflyservers.wildfly.org -o name)
  do
    kubectl delete "$server"
  done
}

before_test() {
  prepare_crc_env
  clear_recent_test
  login_to_crc_docker_repository
}

after_testsuite() {
  oc delete project ospoc
}

install_client() {
  echo "installing client"
  cd "$PROJECT_DIR"/client  || exit
  helm install client -f helm.yaml wildfly/wildfly > /dev/null
  cd "$PROJECT_DIR" || exit
}

install_service() {
  export service_name=$1
  nodes_count=$2
  echo "installing service $service_name with $nodes_count nodes"
  cd "$PROJECT_DIR"/service  || exit
  < operator-template.yaml yq '.metadata.name = strenv(service_name)' | yq ".spec.replicas = $nodes_count" > operator.yaml
  kubectl create -f operator.yaml
  echo "waiting for $1 pod 1"
  #FIXME without sleep the wait commands sometimes doesn't see the pod and fails
  sleep 10
  for i in $(seq 0 $(("$nodes_count"-1)))
  do
     oc wait --for=condition=Ready=true pod "$service_name-$i" --timeout=300s
     echo "adding user to $service_name-$i"
     oc exec -i "$service_name-$i" -- bash -c "/opt/wildfly/bin/add-user.sh -a tomek tomek" > /dev/null
  done
  echo "installing proxy for service $service_name"
  helm install "$service_name" -f proxy.yaml haproxytech/haproxy > /dev/null
  cd "$(pwd)"  || exit
  #FIXME this time we are waiting for the proxy
  sleep 1
}

execute_test(){
  response=$(curl --insecure --silent --write-out "\n%{http_code}" https://client-ospoc.apps-crc.testing/client)
  http_code=$(tail -n1 <<< "$response")
  content=$(sed '$ d' <<< "$response")

  if [[ "$http_code" -ne 200 ]] ; then
    echo "Test FAILURE"
    echo "Reason: $content"
  else
    echo "Test SUCCESS"
  fi
}

