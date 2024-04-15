# Loadbalancing with OpenShift service

## Requirements
* Docker installed
* Code Ready Containers installed
* OpenShift Client installed
* Helm installed
* https://github.com/wildfly/wildfly-operator cloned
* ``` helm repo add wildfly https://docs.wildfly.org/wildfly-charts/ ```
* ``` helm repo update ```
* if ``` oc project -q ``` results in error invoke ``` oc new-project ospoc ```

## Installation
``` crc start ```

Look at the console log and find _kubeadmin_ password cause we need to install wildfly-operator:
```
oc login -u kubeadmin
cd $YOUR_WILDFLY_OPERATOR_DIR
make install
make deploy
```
Now we have to add permissions to _developer_ user to use the operator:

```
crc start
```
Login again as a _kubeadmin_, go to _User Management_ in left down corner and add role binding between _developer_ user and _wildfly-operator_ role.

After operator is installed log out from console and change _oc_ user to developer:
```
oc login -u developer -p developer
```
Now we are ready to deploy applications. Got to this PoC root directory and do:
```
mvn clean install
cd client
./install.sh
cd ../server
./install.sh
```

Later when you make some changes to the the code you can use _upgrade.sh_ scripts in client and server directory.

## Observing erronous load balancing behavior with standard OpenShift service

```
crc console
```

Login to the console as a _developer_ user.

Click on _client_ application, then _Resources_ and find the route address, it should be _https://client-ospoc.apps-crc.testing_.

Go to https://client-ospoc.apps-crc.testing/console this will trigger the invocation of stateful bean from client to the server.

In _Topology_ click _server_ app and localize the pod on (_server0_ or _server1_) to which the first invocation was rooted, by analyzing the console output (_Logs_).

Kill that pod from _Actions_ menu in right top corner.

Go to https://client-ospoc.apps-crc.testing/console again.

















