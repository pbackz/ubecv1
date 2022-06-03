#!/bin/bash
#https://stackoverflow.com/questions/67210000/rbac-role-based-access-control-on-k3s

openssl genrsa -out toto.key 2048
openssl req -new -key toto.key -out toto.csr -subj "/CN=toto/O=toto_grp"

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: toto
spec:
  groups:
  - system:authenticated
  request: $(cat toto.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

kubectl get csr

kubectl certificate approve toto

kubectl get csr toto -o jsonpath='{.status.certificate}'  | base64 -d > toto.crt

cat <<EOF | kubectl apply -f - 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: toto-role
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - secrets
  - services
  verbs:
  - get
  - list
  - watch
  - update
EOF

cat <<EOF | kubectl apply -f - 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: toto-role-2
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - secrets
  - services
  - deployments
  - configmaps
  verbs:
  - get
  - list
  - create
  - delete
  - update
EOF

cat <<EOF | kubectl apply -f - 
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: toto-binding-2
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: toto-role-2
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: toto
EOF

kubectl config set-credentials toto --client-key=toto.key --client-certificate=toto.crt --embed-certs=true

kubectl config set-context toto --cluster=default --user=toto

kubectl config use-context toto

kubectl config current-context

kubectl run web --image=nginx