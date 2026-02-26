#!/bin/bash
#
# Create namespace, role in the cluster and
# prepare a config context for interacting with the cluster
#
# Arguments:
#  full name used for cluster resource names (e.g., 'Anton Butsko')


if [[ $# -eq 0 ]]; then
  echo -e "ERROR! You must enter your full name, for example:\n${0} \"Anton Butsko\""
  exit 1
fi

readonly FULL_NAME=$1
readonly FIRST_NAME_LETTER="${FULL_NAME:0:1}"
readonly LAST_NAME="${FULL_NAME##* }"
readonly USERNAME="$(echo "${FIRST_NAME_LETTER}${LAST_NAME}" | tr '[:upper:]' '[:lower:]')"

readonly OLD_KUBE_CONTEXT=$(kubectl config current-context)
kubectl config use-context minikube

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${USERNAME}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${USERNAME}
  namespace: ${USERNAME}
secrets:
- name: ${USERNAME}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ${USERNAME}
  name: ${USERNAME}
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: ${USERNAME}
  name: ${USERNAME}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ${USERNAME}
subjects:
- kind: ServiceAccount
  name: ${USERNAME}
  namespace: ${USERNAME}
EOF

# hotfix for version 1.24
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${USERNAME}
  namespace: ${USERNAME}
  annotations:
    kubernetes.io/service-account.name: ${USERNAME}
type: kubernetes.io/service-account-token
EOF
readonly SECRET_NAME=$(kubectl --namespace "${USERNAME}" get serviceaccount "${USERNAME}" --output jsonpath='{.secrets[0].name}')
readonly ENCRYPTED_TOKEN=$(kubectl --namespace "${USERNAME}" get secrets "${SECRET_NAME}" --output jsonpath='{.data.token}')
readonly DECRYPTED_TOKEN=$(echo "${ENCRYPTED_TOKEN}" | base64 --decode)

kubectl config set-credentials "minikube-${USERNAME}" --token="${DECRYPTED_TOKEN}"
kubectl config set-context "minikube-${USERNAME}" --namespace="${USERNAME}" --user="minikube-${USERNAME}" --cluster=minikube

kubectl config use-context "${OLD_KUBE_CONTEXT}"
