CHART_REPO := http://jenkins-x-chartmuseum:8080
DIR := "env"
TEST_DIR := "test-manual"
NAMESPACE := "kube-system-ingress"
PACKAGE_NAME := "eks-alb-nginx-ingress"
PACKAGE_VERSION := "0.0.1"
OS := $(shell uname)

build: clean
	rm -rf requirements.lock
	helm version
	helm init
	# helm repo add releases ${CHART_REPO}
	helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
	helm repo add stable 	http://storage.googleapis.com/kubernetes-charts
	helm dependency build ${DIR}
	helm lint ${DIR}

install: 
	helm upgrade ${NAMESPACE} ${DIR} --install --namespace ${NAMESPACE} --debug

delete:
	helm delete --purge ${NAMESPACE} 

debug:
	helm install --name=${NAMESPACE} --namespace=${NAMESPACE} ${DIR} --debug --dry-run 

package:
	rm -rf ${PACKAGE_NAME} && mkdir -p ${PACKAGE_NAME}
	cp -r ${DIR}/* eks-alb-nginx-ingress/
	sed -i -e "s/name:.*/name: $(PACKAGE_NAME)/" eks-alb-nginx-ingress/Chart.yaml
	sed -i -e "s/version:.*/version: $(PACKAGE_VERSION)/" eks-alb-nginx-ingress/Chart.yaml
	helm package eks-alb-nginx-ingress
	helm repo index .
	rm -rf ${PACKAGE_NAME}


test:
	kubectl delete -f ${TEST_DIR} 
	kubectl apply -f ${TEST_DIR} 
	
print: 
	kubectl get po,ing,svc -n kube-system-ingress 
	kubectl get po,ing,svc -n default 

clean:


