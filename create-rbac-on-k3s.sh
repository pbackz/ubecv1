#!/bin/bash
#https://stackoverflow.com/questions/67210000/rbac-role-based-access-control-on-k3s

openssl genrsa -out pbackz.key 2048
openssl req -new -key pbackz.key -out pbackz.csr -subj "/CN=pbackz/O=pbackz_grp"

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: pbackz
spec:
  groups:
  - system:authenticated
  request: $(cat pbackz.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

kubectl get csr

kubectl certificate approve pbackz

kubectl get csr pbackz -o jsonpath='{.status.certificate}'  | base64 -d > pbackz.crt

cat <<EOF | kubectl apply -f - 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pbackz-role
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
EOF

cat <<EOF | kubectl apply -f - 
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pbackz-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pbackz-role
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: pbackz
EOF

kubectl config set-credentials pbackz --client-key=pbackz.key --client-certificate=pbackz.crt --embed-certs=true

kubectl config set-context pbackz --cluster=default --user=pbackz

kubectl config use-context pbackz

kubectl config current-context

kubectl run web --image=nginx