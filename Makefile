CHART_REPO := http://jenkins-x-chartmuseum:8080
DIR := "env"
TEST_DIR := "test-manual"
NAMESPACE := "kube-system-ingress"
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

test:
	kubectl delete -f ${TEST_DIR} 
	kubectl apply -f ${TEST_DIR} 
	
print: 
	kubectl get po,ing,svc -n kube-system-ingress 
	kubectl get po,ing,svc -n default 

clean:


