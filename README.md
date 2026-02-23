# Kubernetes 3-Tier Application Deployment
## 📌 Project Overview

This project contains a complete **Kubernetes deployment of a 3-tier web application**:

* Presentation Layer: NGINX Ingress for external access
* Application Layer: Flask Python web application
* Data Layer: MongoDB database with persistent storage

The application **allows users to view and interact with a web interface** that displays dynamic content, with the ability to change the background color via configuration.

This project is designed as a **portfolio‑grade DevOps project**, aligned with **real industry practices** and expectations for **DevOps Junior / Associate roles**.

---

## 🧱 Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                      Kubernetes Cluster                      │
│                                                              │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐   │
│  │   Ingress   │────▶│    Flask    │────▶│   MongoDB   │   │
│  │   (nginx)   │     │     App     │     │  StatefulSet│   │
│  └─────────────┘     └─────────────┘     └─────────────┘   │
│         │                   │                    │          │
│         │                   │                    │          │
│  ┌──────▼──────┐    ┌───────▼──────┐    ┌───────▼──────┐   │
│  │ Application │    │   ConfigMap  │    │   Persistent │   │
│  │   Service   │    │   & Secrets  │    │    Volume    │   │
│  └─────────────┘    └──────────────┘    └──────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```
![Architecture UI](./Architecture1_python-katas.png)

---

## 🧰 Tools & Technologies Used

* **Docker** - For container building
* **Minikube** - Local Kubernetes cluster
* **kubectl** - Kubernetes CLI
* **hadolint** - Dockerfile linter (optional)
* **jq** - JSON processor (for tests)

---

## 📂 Project Structure

```bash
.
├── README.md                 # This documentation
├── manifest.yml              # Complete Kubernetes manifest
├── application/              # Flask application source
├── requirments.txt           # Python dependencies
│   ├── Dockerfile            # Docker image definition
│   ├── app.py                # Main Flask application
│   ├── requirements.txt      # Python dependencies
│   ├── forms.py              # Form definitions
│   └── templates/            # HTML templates
│       ├── start.html        # Home page template
│       └── form_test.html    # Test DB page template
└── docker-compose.yaml       # Local development setup (optional)
```

---

## 🚀 Deployment Steps
### 1. Start Minikube and Enable Ingress

```bash
# Start Minikube
minikube start --driver=docker

# Enable NGINX Ingress
minikube addons enable ingress

# Verify Ingress controller is running
kubectl get pods -n ingress-nginx
```

### 2. Create Your Namespace and Context (Isolation)

```bash
# Run the preparation script with your full name
./utils/local_minikube_preparation.sh "Diego Lopez"

# Switch to your context
kubectl config use-context minikube-dlopez
```

### 3. Build and Load Docker Image

```bash 
# Build the Flask application image
cd application
docker build -t dlopez_application:latest .

# Load image into Minikube (for imagePullPolicy: IfNotPresent)
minikube image load dlopez_application:latest

# Return to main directory
cd ..
```

### 4. Deploy the Application 

```bash
# Apply the Kubernetes manifest
kubectl apply -f manifest.yml

# Watch pods come up
kubectl get pods -n dlopez -w
```

### 5. Access the Application 

```bash
# Get Minikube IP
minikube ip

# Add to /etc/hosts (Linux/Mac)
echo "$(minikube ip) dlopez.application.com" | sudo tee -a /etc/hosts

# Open in browser
open http://dlopez.application.com
```

---

## 📊 Application Endpoints

|   Endpoint    |    Description         |        Expected Output          |
| ------------- |:----------------------:|:-------------------------------:|    
| /             | Home page              | Main page with teal background  |
| /color        | Color API              | JSON with current color setting |    
| /test_db      | Database test form     | Form to write data to MongoDB   | 
| /db_message   | Home page              | JSON of all stored messages     |
| /issue        | Color API              | JSON showing issue fix status   |    
| /healthz      | Database test form     | "OK" (for kubernetes)           | 
| /healthx      | Readiness probe        | "OK" (for kubernetes)           |

---

## 🔧 Configuration
### ConfigMap (Non-sensitive Configuration)

```yaml
data:
  MONGO_HOST: "mongo"        # MongoDB service name
  MONGO_PORT: "27017"        # MongoDB port
  BG_COLOR: "teal"            # Default background color
  FAIL_FLAG: "false"          # Issue page status
```

### Secret (Sensitive Data)

```yaml
data:
  MONGO_INITDB_ROOT_USERNAME: cm9vdA==  # "root" (base64 encoded)
  MONGO_INITDB_ROOT_PASSWORD: ZXhhbXBsZQ==  # "example" (base64 encoded)
```

---

## 🔍 Key Features Explained
### Init Container
The application pod includes an init container that waits for MongoDB to be available:

```yaml
initContainers:
- name: wait-for-mongo
  command: ['sh', '-c', "until nslookup mongo; do echo waiting for mongo; sleep 2; done"]
```

### Health probes
* Liveness probe (/healthz): Restarts container if application hangs
* Readiness probe (/healthx): Stops sending traffic if application isn't ready

### Persistent Storage
MongoDB uses persistent storage to survive pod restarts:

```yaml
volumeClaimTemplates:
- metadata:
    name: mongo-data
  spec:
    accessModes: ["ReadWriteOnce"]
    resources:
      requests:
        storage: 1Gi
```

---

## 🧪 Testing
### Local Testing with Docker Compose

```bash
# Start both services
docker-compose up -d

# Test the application
curl http://localhost:5000

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Kubernetes Testing
 
 ```bash
# Check all resources
kubectl get all,configmap,secret,ingress,pvc -n dlopez

# Check application logs
kubectl logs -n dlopez -l app=application

# Test database connectivity
curl http://dlopez.application.com/db_message

# Test issue page
curl http://dlopez.application.com/issue

# Change background color (via ConfigMap)
kubectl patch configmap application -n dlopez -p '{"data":{"BG_COLOR":"blue"}}'
kubectl rollout restart deployment application -n dlopez
 ```

---

## 📈 Resource Allocation
### Application Pod

|   Resource    |      Request    |   Limit    |
| ------------- |:---------------:|:----------:|   
|    CPU        |   0.2 cores     | 0.5 cores  |
|    Memory     |   64Mi          |   128Mi    |    

### MongoDB Pod

|   Resource    |      Request    |   Limit    |
| ------------- |:---------------:|:----------:|   
|    CPU        |   0.2 cores     | 0.5 cores  |
|    Memory     |     128Mi       |   256Mi    |  
|    Storage    |      1Gi        |     -      |

---

## 🐛 Troubleshooting
### Common Issues and Solutions

|        Issue          |                                Solution                                     |
| --------------------- |:---------------------------------------------------------------------------:|
|  ErrImageNeverPull	   |  Load image into Minikube: minikube image load dlopez_application:latest    |
|  MongoDB OOMKilled	   |                 Increase memory limits in StatefulSet                       |
|  Pod not ready	      |              Check logs: kubectl logs -n dlopez <pod-name>                  |
| Authentication failed |	                  Verify secret values are correct                         |                
|  Ingress not working	|        Ensure ingress addon is enabled: minikube addons enable ingress      |

### Useful Debugging Commands

```bash
# Check pod status
kubectl get pods -n dlopez

# View detailed pod info
kubectl describe pod -n dlopez -l app=application

# Follow logs
kubectl logs -n dlopez -l app=application -f

# Execute commands in pod
kubectl exec -n dlopez -it deployment/application -- /bin/sh

# Check events
kubectl get events -n dlopez --sort-by='.lastTimestamp'
```

---

## 🔐 Security Considerations

* Secrets are base64 encoded (not encrypted - for production, use external secrets manager)
* RBAC limits access to namespace-scoped resources
* Resource limits prevent DoS attacks
* Network policies (can be added) restrict pod-to-pod communication

---

## 📝 Notes for Production
For production deployment, consider:
1. Use external secrets manager (HashiCorp Vault, AWS Secrets Manager)
2. Enable encryption at rest for etcd
3. Implement network policies for pod isolation
4. Add horizontal pod autoscaling based on load
5. Use CI/CD pipeline for automated deployments
6. Implement monitoring (Prometheus + Grafana)
7. Add logging aggregation (ELK stack or Loki)

---

## 📚 Additional Resources

* [Kubernetes Documentation](https://kubernetes.io/docs/) 
* [Flask Documentation](https://flask.palletsprojects.com/)
* [MongoDB Kubernetes Operator](https://www.mongodb.com/kubernetes)
* [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)

---

## 👨‍💻 Author

**Diego López Arango** - DevOps Engineer 

⭐ Don't forget to star this repo if you found it helpful!
