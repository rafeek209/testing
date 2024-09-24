
### 1. Start Minikube with 2 Nodes

```bash
crazy@CrazyPortable:~$ minikube start --nodes 2
crazy@CrazyPortable:~$ kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
minikube       Ready    control-plane   35s   v1.30.0
minikube-m02   Ready    <none>          10s   v1.30.0
```

---

### 2. Create Namespaces

Create the following namespaces:

- **FE**
- **mongo-db**
- **mongo-express**

```bash
crazy@CrazyPortable:~$ kubectl create namespace fe
namespace/fe created

crazy@CrazyPortable:~$ kubectl create namespace mongo-db
namespace/mongo-db created

crazy@CrazyPortable:~$ kubectl create namespace mongo-express
namespace/mongo-express created
```

---

### 3. Deployments & Services

#### A. Web Frontend Application

Deploy a simple web frontend application in the `FE` namespace with 2 replicas. Use an `emptyDir` Volume to store the web content and mount it to `/usr/share/nginx/html` in the pod. Create a NodePort Service named `frontend-service` to expose the Nginx application externally on port 80.

```bash
crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f frontend_deploy.yaml
deployment.apps/frontend created

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f frontend_nodeport.yaml 
service/frontend-nodeport created
```

#### B. MongoDB Deployment

Deploy a MongoDB database in the `mongo-db` namespace with the following:

- **Deployment**: `mongodb-deployment` with 1 replica, using the image `mongo:latest`.
- **Secret**: Create a Secret named `mongodb-secret` to store the MongoDB root username (`MONGO_INITDB_ROOT_USERNAME`) and password (`MONGO_INITDB_ROOT_PASSWORD`).
  - Root username: `admin`
  - Root password: `admin123`
- **Persistent Volume and Persistent Volume Claim**: Named `mongodb-pvc` to store MongoDB data at `/data/db`.
- **ClusterIP Service**: Named `mongodb-service` to expose the MongoDB database internally on port 27017.

```bash
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
```

#### C. Mongo Express Deployment

Deploy Mongo Express in the `mongo-express` namespace with the following:

- **Deployment**: Named `mongo-express-deployment` with 1 replica, using the image `mongo-express:latest`.
- **ConfigMap**: Create a ConfigMap named `mongo-express-config` to store environment variables for Mongo Express.
- **NodePort Service**: Named `mongo-express-service` to expose the Mongo Express interface externally on port 8081.

```bash
crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongoexpress_map.yaml 
configmap/mongoexpress-config created

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongoexpress_deploy.yaml 
deployment.apps/mongoexpress-deployment created

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongoexpress_nodeport.yaml 
service/mongoexpress-nodeport created
```

---

### 4. Use Taints and Tolerations

#### A. Taint a Minikube Node

Taint one of the Minikube nodes with `key=db:NoSchedule`.

```bash
crazy@CrazyPortable:~$ kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
minikube       Ready    control-plane   70m   v1.30.0
minikube-m02   Ready    <none>          70m   v1.30.0

crazy@CrazyPortable:~$ kubectl taint nodes minikube-m02 db=NoSchedule
node/minikube-m02 tainted
```

#### B. Apply Toleration in MongoDB Deployment

Apply a toleration in the `mongodb-deployment` to allow the MongoDB pod to be scheduled on the tainted node.

```bash
crazy@CrazyPortable:~$ kubectl delete deployment mongodb-deployment -n mongo-db
deployment.apps "mongodb-deployment" deleted

crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl apply -f mongodb_deployment.yaml
deployment.apps/mongodb-deployment created
```

#### C. Apply Node Affinity

Ensure that the DB pod will be scheduled on the tainted node by applying node affinity with the taint and toleration.

```bash
crazy@CrazyPortable:~/Dpartition/prac/k8s/TASK7_K8s_YAML$ kubectl label nodes minikube-m02 key2=value2
node/minikube-m02 labeled
```

---

