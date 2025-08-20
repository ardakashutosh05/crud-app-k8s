# 🛠️ CRUD App with Jenkins, Docker, MySQL, and SonarCloud

A simple CRUD (Create, Read, Update, Delete) Node.js application with MySQL database hosted on AWS RDS. Jenkins is used for CI/CD pipeline and SonarCloud for static code analysis.

---

## 📋 Project Setup Guide

### 1. 🚀 Launch an EC2 Instance (Ubuntu)

- Create an EC2 instance using **Ubuntu (Free Tier)**
- Open ports in the **security group**:
  - `22` (SSH)
  - `8080` (Jenkins)
  - `3000` (Node.js app)
- Connect via SSH:
  ```bash
  ssh -i <your-key>.pem ubuntu@<EC2_PUBLIC_IP>
  ```
---

### 2. ⚙️ Run EC2 Setup Script

- Run the script to install:
    - System updates
    - Docker
    - Jenkins

  ```bash
  chmod +x scripts/docker-jenkins-install.sh
  ./scripts/docker-jenkins-install.sh
  ```
---

### 3. 🗄️ AWS RDS (MySQL)

- Go to RDS → Create database
- Select:
    - Engine: MySQL
    - DB identifier: testdb-1
    - Username: root
    - Password: *********
    - Public access: Yes (for testing)
- After creation, note the endpoint:
  ```bash
  testdb-1.cp24ccc4chcf.ap-southeast-1.rds.amazonaws.com
  ```

---

### 4. 📦 Clone the Repository

  ```bash
  git clone https://github.com/ashubambal/crud-app.git
  cd crud-app
  ```

---

### 5. 🔐 Access Jenkins

- Visit: http://<EC2_PUBLIC_IP>:8080
- Get the Jenkins unlock key:

  ```bash
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  ```
---

### 6. ➕ Install Jenkins Plugins

- Install the following plugins:
    - Docker Pipeline
    - SonarQube Scanner
    - Pipeline Stage View

---

### 7. 🔍 Setup SonarCloud

- Go to SonarCloud
- Click: "Analyze a new project"
- Link your GitHub repository
- Organization name: Jenkins
- Click: "Create organization"
- Create a Sonar Token (keep it safe)
    - Step two create sonar token -> Click on My-account -> Security -> Ganrate token

---

### 8. 🔑 Add Credentials in Jenkins

- Go to:
- Manage Jenkins → Credentials → System → Global credentials → Add Credentials
- Add the following:
```
| ID            | Type                | Use                       |
| ------------- | ------------------- | ------------------------- |
| `sonar-token` | Secret text         | SonarCloud authentication |
| `docker-cred` | Username + Password | DockerHub login           |
```  
---

### 9. ⚙️ Configure SonarQube in Jenkins

- Go to:
- Manage Jenkins → Global Tool Configuration
- SonarQube Scanner installations:
    - Name: sonar-scanner
    - Version: select appropriate version -> save
- Go to:
- Manage Jenkins → System   
- SonarQube servers:
    - Name: SonarCloud
    - Select Environment Variable check box
    - URL: https://sonarcloud.io
    - Credentials: sonar-token -> save

---

### 10. 🚀 Create Jenkins Pipeline

- Create a new item (ci-jenkins) -> pipeline -> click on check box (GitHub hook trigger for GITScm polling)
- Pipeline (Pipeline script from SCM) -> Use GitHub as source -> save
- Add webhook support -> Go to Github Repo settings -> Webhooks -> http://<EC2-IP>:8080/github-webhook/ -> Content type * (appliation/json) -> save

---
## 11.🧩 Jenkins Pipeline (4 Stages)

Our Jenkinsfile will contain 4 stages:
- Build – Install dependencies & run tests
- SonarCloud Analysis – Static code analysis
- Docker Build & Push – Build & push Docker image to DockerHub
- Deploy to Kubernetes – Apply Kubernetes manifests

---
## 12.⚙️ Kubernetes Setup (via Script)
🚢CI/CD with Kubernetes (EKS)
So far, our Jenkins pipeline deployed the app directly on EC2. Now, we’ll extend the pipeline to deploy on Kubernetes (EKS) with automatic image pull from Docker Hub.

- We already have a script for Kubernetes setup:
cd script/
```
chmod 777 setup-k8s.sh
./setup-k8s.sh
```
---

## 13. ☁️ AWS CLI Configuration
  - aws configure
  - AWS Access Key ID → <your-access-key>
  - AWS Secret Access Key → <your-secret-key>
  - Default region → us-east-1 (N. Virginia)
  - Output format → json

---

## 14. 🔑 IAM Role for EC2 → EKS Access

  - Go to IAM → Roles → Create Role
  - Trusted Entity: AWS Service
  - Use Case: EC2
  - Attach Policies:
    - AmazonEKSClusterPolicy
    - AmazonEKSWorkerNodePolicy
    - AmazonEC2ContainerRegistryFullAccess
    - AmazonEKS_CNI_Policy
    - Name: EC2-EKS-Access-Role
  - Attach Role to EC2 (Jenkins Instance):
  - EC2 → Instances → Select Instance → Actions → Security → Modify IAM Role

---

## 15. ☸️ Create EKS Cluster
```bash
eksctl create cluster \
  - name cluster2 \
  - region ap-southeast-1 \
  - node-type t2.medium \
  - zones ap-southeast-1a,ap-southeast-1b
```

---

## 16. 🔑 Update kubeconfig
```bash
aws eks --region ap-southeast-1 update-kubeconfig --name cluster2
```
---

## 17. 📝 Create Kubernetes YAML Files

📌 k8s/app.yaml
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: crud-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: crud-app
  template:
    metadata:
      labels:
        app: crud-app
    spec:
      containers:
        - name: crud-app
          image: ardakashutosh05/crud-123:latest
          ports:
            - containerPort: 3000
```

📌 k8s/svc.yaml
```bash
apiVersion: v1
kind: Service
metadata:
  name: crud-service
spec:
  type: LoadBalancer
  selector:
    app: crud-app
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
```

📌 Apply configs:
```bash
kubectl apply -f k8s/app.yaml
kubectl apply -f k8s/svc.yaml
kubectl get pods
kubectl get svc
```

---

## 18. 🤖 Jenkinsfile with Kubernetes Deployment

Extend your Jenkinsfile with Kubernetes deployment stage:
```bash
stage('Deploy to Kubernetes') {
    steps {
        sh """
          kubectl apply -f k8s/app.yaml
          kubectl apply -f k8s/svc.yaml
        """
    }
}
```
✅ Now, every time you push code → Jenkins builds → SonarCloud analysis → Docker image push → Kubernetes auto-deploys! 🚀

----

## 19. 📊 Install & Access Grafana + Prometheus
    
🔹 Install Helm & Prometheus Stack
```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm -y

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring
kubectl get pods -n monitoring
```

🔹 Access Grafana
```bash
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
```

👉 Open browser: http://localhost:3000

Get Grafana admin password:

```bash
kubectl get secret kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}
```
---
## 20. 🔹 Expose Grafana & Prometheus via LoadBalancer

Instead of using port-forward, you can expose them directly:

```bash
kubectl patch svc kube-prometheus-stack-prometheus -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'
kubectl patch svc kube-prometheus-stack-grafana -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -n monitoring
```

👉 Check the EXTERNAL-IP column and open in browser:

```Prometheus → http://<EXTERNAL-IP>:9090```

```Grafana → http://<EXTERNAL-IP>:80```

---

## 21. 🔍 Monitor Kubernetes Pods & Workloads in Grafana

Now that Grafana is running with Prometheus as the data source, you can monitor real-time cluster metrics.

🔹 Access Grafana Dashboard

 - Open Grafana → Dashboards → Kubernetes / Compute Resources / Cluster

 You will see:

  - CPU Utilization

  - Memory Utilization

  - Pods & Workloads per Namespace

  - CPU/Memory Requests & Limits
---

🔹 Monitor Pods by Namespace

 Grafana automatically groups metrics by namespace.
    
 For example:

- default → User applications

- kube-system → Kubernetes system pods

- monitoring → Prometheus & Grafana pods

- Your custom namespace (e.g., flipkart) → Application workloads
---
## Example Dashboard View

<img width="1896" height="965" alt="Screenshot 2025-08-19 165526" src="https://github.com/user-attachments/assets/48a605e0-67ea-4ee2-a815-bd6a836a3da0" />


(Screenshot shows CPU, memory, and pods utilization across namespaces.)

---

## 📁 Project Structure

  ```bash
crud-app/
├── app.js                  # Express app
├── Dockerfile              # Docker container config
├── Jenkinsfile             # Jenkins pipeline
├── package.json
├── public/                 # Static frontend
├── scripts/
│   └── docker-jenkins-install.sh
└── .env                    # (not committed, local secrets)
  ```
---

## ✅ Technologies Used

- Node.js + Express
- MySQL (AWS RDS)
- Docker
- Jenkins
- SonarCloud
- GitHub

---

## Website UI and Operation

<p align="center">
  <img src="assets/recording.gif" alt="Demo" width="700">
</p>
