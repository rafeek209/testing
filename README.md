	1-start your minikube with 2 nodes 


crazy@CrazyPortable:~$ minikube start --nodes 2
crazy@CrazyPortable:~$ kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
minikube       Ready    control-plane   35s   v1.30.0
minikube-m02   Ready    <none>          10s   v1.30.0
-------------------------------------------------------------------
	2- create 3 namespaces 
     - FE  
     - mongo-db 
     - mongo-express


razy@CrazyPortable:~$ kubectl create namespace fe
namespace/fe created
razy@CrazyPortable:~$ kubectl create namespace mongo-db
namespace/mongo-db created
razy@CrazyPortable:~$ kubectl create namespace mongo-express
namespace/mongo-express created
-------------------------------------------------------------------
	3- Deployments&services: 
    	A-  simple web frontend application in the FE-namespace namespace with 2 riplca  - and Use an emptyDir Volume to store the web content and mount it to /usr/share/nginx/html in the POD - Create a NodePort Service named frontend-service to expose the Nginx application externally on port 80.


crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f frontend_deploy.yaml
deployment.apps/frontend created

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f frontend_nodeport.yaml 
service/frontend-nodeport created
-------------------------------------------------------------------
  	b - Deploy a MongoDB database in the mongo-db namespace.
     Use a Deployment named mongodb-deployment with:
     1 replica.
     The image: mongo:latest
     Create a Secret named mongodb-secret in the mongo-db namespace to store the MongoDB root username (MONGO_INITDB_ROOT_USERNAME) and password (MONGO_INITDB_ROOT_PASSWORD).
     Root username: admin
     Root password: admin123
     Use a Persistent Volume and Persistent Volume Claim (PVC) named mongodb-pvc to store MongoDB data at /data/db.
     Create a ClusterIP Service named mongodb-service to expose the MongoDB database internally within the cluster on port 27017.
     
     
crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongodb_secret.yaml 
secret/mongodb-secret created

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongodb_deployment.yaml 
deployment.apps/mongodb-deployment created

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongodb_clusterip.yaml 
service/mongodb-clusterip created

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f pv.yaml 
persistentvolume/mongodb-pv created

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f pvc.yaml 
persistentvolumeclaim/mongodb-pvc created

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongodb_deployment.yaml
deployment.apps/mongodb-deployment configured

-------------------------------------------------------------------
	c- Deploy Mongo Express in the mongo-express namespace.
     Use a Deployment named mongo-express-deployment with:
     1 replica.
     The image: mongo-express:latest.
     Create a ConfigMap named mongo-express-config in the mongo-express namespace to store environment variables for the Mongo Express application.
     Hint (you should accces the MongoDB by mongo-express deployment)
     Create a NodePort Service named mongo-express-service to expose the Mongo Express interface externally on port 8081.
     
     
crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongoexpress_map.yaml 
configmap/mongoexpress-config created

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongoexpress_deploy.yaml 
deployment.apps/mongoexpress-deployment created

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongoexpress_nodeport.yaml 
service/mongoexpress-nodeport created
-------------------------------------------------------------------
	4- Use Taints and Tolerations:
	a- Taint one of the Minikube nodes with key=db:NoSchedule.


crazy@CrazyPortable:~$ kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
minikube       Ready    control-plane   70m   v1.30.0
minikube-m02   Ready    <none>          70m   v1.30.0

crazy@CrazyPortable:~$ kubectl taint nodes minikube-m02 key1=value1:NoSchedule
node/minikube-m02 tainted
-------------------------------------------------------------------
	b- Apply a Toleration in the mongodb-deployment to allow the MongoDB pod to be scheduled on the tainted node 


crazy@CrazyPortable:~$ kubectl delete deployment mongodb-deployment -n mongo-db
deployment.apps "mongodb-deployment" deleted

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongodb_deployment.yaml
deployment.apps/mongodb-deployment created
-------------------------------------------------------------------
	c- make sure that the DB pod will scheduled in this node by applying node affinty with the taint and toleration.


crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl label nodes minikube-m02 key2=value2
node/minikube-m02 labeled

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongodb_deployment.yaml
deployment.apps/mongodb-deployment configured
-------------------------------------------------------------------
