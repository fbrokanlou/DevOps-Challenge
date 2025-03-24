#!/bin/bash

# get this arguments {{ ca_cert_generation_revision }} {{ ca_key_generation_revision }} {{ kafka_namespace }}"
ca_cert_generation_revision="${ca_cert_generation_revision}"
ca_key_generation_revision="${ca_key_generation_revision}"
kafka_namespace="${kafka_namespace}"
kafka_cluster_name="${kafka_cluster_name}"


## Step 1) Generate required CA certificates and keys

openssl genrsa 4096 > cluster-ca.key
openssl genrsa 4096 > clients-ca.key

openssl req -new -x509 -nodes -days 3650 -key cluster-ca.key -out cluster-ca.crt \
  -subj "/C=DE/ST=Berlin/L=Berlin/O=DevOps Challenge/CN=Kafka Cluster CA"


openssl req -new -x509 -nodes -days 3650 -key clients-ca.key -out clients-ca.crt \
  -subj "/C=DE/ST=Berlin/L=Berlin/O=DevOps Challenge/CN=Kafka Clients CA"

openssl rand -base64 16 > cluster-pass.p12
openssl rand -base64 16 > clients-pass.p12

openssl pkcs12 -export -in cluster-ca.crt -nokeys -out cluster-ca.p12 -password pass:$(cat cluster-pass.p12) -caname cluster-ca.crt
openssl pkcs12 -export -in clients-ca.crt -nokeys -out clients-ca.p12 -password pass:$(cat clients-pass.p12) -caname clients-ca.crt


## Step2) Save the generated certificates and keys in the Kubernetes cluster as secrets

### Step 2.1) Configure the Cluster CA secret
kubectl create secret generic "${kafka_cluster_name}"-cluster-ca-cert \
  --from-file=ca.crt=cluster-ca.crt \
  --from-file=ca.p12=cluster-ca.p12 \
  --from-literal=ca.password=$(cat cluster-pass.p12) \
  -n "${kafka_namespace}"

kubectl create secret generic "${kafka_cluster_name}"-cluster-ca \
  --from-file=ca.key=cluster-ca.key \
  -n "${kafka_namespace}"

kubectl label secret "${kafka_cluster_name}"-cluster-ca-cert strimzi.io/kind=Kafka strimzi.io/cluster="${kafka_cluster_name}" -n "${kafka_namespace}"
kubectl label secret "${kafka_cluster_name}"-cluster-ca strimzi.io/kind=Kafka strimzi.io/cluster="${kafka_cluster_name}" -n "${kafka_namespace}"
kubectl annotate secret "${kafka_cluster_name}"-cluster-ca-cert strimzi.io/ca-cert-generation="${ca_cert_generation_revision}" -n "${kafka_namespace}"
kubectl annotate secret "${kafka_cluster_name}"-cluster-ca strimzi.io/ca-key-generation="${ca_key_generation_revision}" -n "${kafka_namespace}"


### Step 2.1) Configure the Clients CA secret
kubectl create secret generic "${kafka_cluster_name}"-clients-ca-cert \
  --from-file=ca.crt=clients-ca.crt \
  --from-file=ca.p12=clients-ca.p12 \
  --from-literal=ca.password=$(cat clients-pass.p12) \
  -n "${kafka_namespace}"

kubectl create secret generic "${kafka_cluster_name}"-clients-ca \
  --from-file=ca.key=clients-ca.key \
  -n "${kafka_namespace}"

kubectl label secret "${kafka_cluster_name}"-clients-ca-cert strimzi.io/kind=Kafka strimzi.io/cluster="${kafka_cluster_name}" -n "${kafka_namespace}"
kubectl label secret "${kafka_cluster_name}"-clients-ca strimzi.io/kind=Kafka strimzi.io/cluster="${kafka_cluster_name}" -n "${kafka_namespace}"
kubectl annotate secret "${kafka_cluster_name}"-clients-ca-cert strimzi.io/ca-cert-generation="${ca_cert_generation_revision}" -n "${kafka_namespace}"
kubectl annotate secret "${kafka_cluster_name}"-clients-ca strimzi.io/ca-key-generation="${ca_key_generation_revision}" -n "${kafka_namespace}"

