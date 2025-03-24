## Intro

This project is designed to streamline the deployment and management of a Kafka-based messaging system using Kubernetes and Ansible. This README provides a step-by-step guide for setting up the Kafka operator, configuring a Kafka cluster, and managing Kafka topics within the Kubernetes cluster. Additionally, it outlines improvements to Dockerfiles to enhance security, efficiency, and maintainability. Finally, it explains best practices for setting up monitoring and alerting.

## Infrastructure as Code (IaC) Best Practices

This project follows Infrastructure as Code (IaC) principles to ensure consistency, scalability, and maintainability. Below are the best practices adopted:

1. **Version Control with Git**:
    - All Kubernetes manifests, Ansible playbooks, and variable definitions will be stored in a Git repository.
    - This ensures traceability, collaboration, and rollback capabilities for all infrastructure changes.

2. **Modular Configuration**:
    - Variables are defined in separate YAML files (`vars` directory) to allow modular and reusable configurations.
    - This approach simplifies customization for different environments and deployments.

3. **Declarative Kubernetes Resources**:
    - Kubernetes resources are defined declaratively, ensuring that the desired state of the cluster is maintained.
    - The use of Kubernetes operator (here, Kafka Operator) automates complex tasks like managing Kafka clusters and topics.

4. **Automation with Ansible**:
    - Ansible playbooks are used to automate the deployment and configuration of Kubernetes resources.
    - This reduces manual intervention and ensures repeatability across environments.

5. **Environment Isolation**:
    - Python virtual environments are used to isolate dependencies, preventing conflicts between projects.
    - Kubernetes namespaces are leveraged to isolate resources within the cluster.

6. **Idempotency**:
    - Ansible playbooks and Kubernetes manifests are designed to be idempotent, ensuring that repeated executions do not cause unintended changes.

7. **Documentation and Comments**:
    - All IaC files include comments and documentation to explain their purpose and usage.
    - This improves maintainability and helps new contributors understand the project structure.

 

## Prerequisites:

To get started with this project, ensure you have the following tools and dependencies installed:

1. **Python Virtual Environment**:
    - Create a virtual environment to isolate dependencies:
      ```bash
      python3 -m venv .venv
      source .venv/bin/activate
      ```

2. **Required Python Packages**:
    - Install the necessary Python libraries:
      ```bash
      pip install kubernetes ansible-core
      ```
    - These libraries are essential for interacting with Kubernetes clusters and running Ansible playbooks.

3. **Additional Tools**:
    - Ensure you have Docker installed for building and managing container images.
    - Install `kubectl` for managing Kubernetes clusters.
    - Install `k3s` or any other Kubernetes distribution if you are setting up a local cluster.

4. **Kubernetes Access**:
    - Ensure you have set the path to the config file via the `KUBECONFIG` variable .

By completing the above steps, you will have the necessary environment set up to proceed with the deployment and management tasks outlined in this project. This includes configuring the Kafka operator, setting up the Kafka cluster, and managing Kafka topics effectively.

## Configuration Data and Variables

The `vars` directory contains several YAML files that define configuration data and variables used throughout the Ansible playbooks. Each file serves a specific purpose and helps in customizing the deployment process. Below is a description of each file:

> **Note:** Ensure to review the variable files for the resoans behind each configuration. This will help to customize the deployment to meet the requirements and avoid potential issues during execution.

1. **`kafka_main_vars.yaml`**:
    - Contains shared and common variables used across multiple playbooks.
    - Example:
      ```yaml
      kakfa_namespace: "kafka"
      ```

2. **`kafka_operator_vars.yaml`**:
    - Contains variables required for deploying the Kafka Operator, such as namespace, image details, and resource limits.
    - Example:
      ```yaml
      strimzi_helm_chart: strimzi-kafka-operator
      strimzi_helm_chart_version: 0.45.0
      ```

3. **`kafka_cluster_vars.yaml`**:
    - Defines the configuration for the Kafka Cluster, including broker count, Zookeeper settings, and storage configurations.
    - Example:
      ```yaml
        kafka_version: "3.9.0"
        kafka_broker_replicas: 3
      ```

4. **`kafka_topic_vars.yaml`**:
    - Specifies the settings for Kafka topics, such as topic names, partitions, and replication factors.
    - Example:
      ```yaml
      kafka_topic_partitions: 6
      ```

These variable files allow for a modular and flexible approach to managing configurations, making it easier to adapt the deployment to different environments or requirements. Ensure that the values in these files are updated to match your specific setup before running the playbooks.


## Install Kafka Operator

To install the Kafka Operator, an Ansible playbook named `kafka_operator_setup.yaml` has been created to automate the deployment process. Follow the steps below to execute the playbook and set up the Kafka Operator:

1. **Run the Ansible Playbook**:
    - Execute the playbook to deploy the Kafka Operator:
      ```bash
      ansible-playbook kafka_operator_setup.yaml
      ```
    - This playbook will handle the creation of necessary Kubernetes resources, such as namespaces, roles, role bindings, and the Kafka Operator deployment.

2. **Verify the Installation**:
    - After running the playbook, confirm that the Kafka Operator is successfully deployed:
      ```bash
      kubectl get pods -n <namespace>
      ```
    - Replace `<namespace>` with the namespace where the Kafka Operator was deployed. You should see the Kafka Operator pod running.


## Setup Kafka Cluster

To set up the Kafka Cluster, an Ansible playbook named `kafka_cluster_setup.yaml` has been created to automate the deployment process. Follow the steps below to execute the playbook and configure the Kafka Cluster:

1. **Run the Ansible Playbook**:
    - Execute the playbook to deploy the Kafka Cluster:
      ```bash
      ansible-playbook kafka_cluster_setup.yaml
      ```
    - This playbook will handle the creation of necessary Kubernetes resources, such as Kafka brokers, Zookeeper instances, and related configurations.

2. **Verify the Deployment**:
    - After running the playbook, confirm that the Kafka Cluster is successfully deployed:
      ```bash
      kubectl get pods -n <namespace>
      ```
    - Replace `<namespace>` with the namespace where the Kafka Cluster was deployed. You should see the Kafka broker and Zookeeper pods running.

By completing these steps, you will have a fully functional Kafka Cluster ready for managing topics and processing messages.

## Setup Kafka Topic

To set up Kafka topics, an Ansible playbook named `kafka_topic_setup.yaml` has been created to automate the process. Follow the steps below to execute the playbook and configure Kafka topics:

1. **Run the Ansible Playbook**:
    - Execute the playbook to create Kafka topics:
      ```bash
      ansible-playbook kafka_topic_setup.yaml
      ```
    - This playbook will handle the creation of Kafka topics with the specified configurations, such as replication factor, partitions, and topic name.

2. **Verify the Topic Creation**:
    - After running the playbook, confirm that the Kafka topics are successfully created:
      ```bash
      kubectl describe kafkatopic <topic_name> -n <kafka_namespace>
      ```
    - Replace `<topic_name>` with the name of a Kafka topic, `<kafka_namespace>` with the namespace where the Kafka Cluster is deployed. You should see the details of topic, including all configuration options.

By completing these steps, you will have the necessary Kafka topics configured and ready for use in your messaging system.

## Test Kafka cluster:
Send and receive messages ([Source](https://strimzi.io/quickstarts/))

With the cluster running, run a simple producer to send messages to the Kafka topic `posts`:

```sh
kubectl run kafka-producer -ti --image=quay.io/strimzi/kafka:0.45.0-kafka-3.9.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server kafka-kafka-bootstrap.kafka.svc:9092 --topic posts
```
Once everything is set up correctly, you’ll see a prompt where you can type in your messages:

`If you don't see a command prompt, try pressing enter.`

then type some message, e.g.
`>Hello DevOps Challenge!`

And to receive them in a different terminal, run:
```sh
kubectl run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.45.0-kafka-3.9.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server kafka-kafka-bootstrap.kafka.svc:9092 --topic posts --from-beginning
```

If everything works as expected, you’ll be able to see the message you produced in the previous step:


## Dockerfiles and Kubernetes deployments
### Improvements to Dockerfiles

1) Set the Working Directory to ensures a cleaner workspace inside the container.
2) Used `requirements.txt` file, it makes dependency management more transparent and reusable.
3) Installed Dependencies in One Layer toReduces the number of layers in the image.
4) Useed `--no-cache-dir` in pip install: Reduces image size by preventing pip from caching packages.
5) Useed a Non-Root User ti enhance security by avoiding running the app as root.
6) Optional recommedned improvments (not applied here)
    - Reduce Image Size by using `python:3.8-alpine` instead of `python:3.8-slim` if possible.
    - Use a Multi-Stage Build:This isn't strictly necessary for this simple Python app, but overall it helps keep the image minimal.
7) Benefits of These Changes:
    - Better Caching: The dependency installation step (`COPY requirements.txt` and `pip install`) is cached separately from the application files, improving build efficiency.
    - Security: Running as a non-root user improves security.
    - Smaller Image Size: --no-cache-dir prevents unnecessary files from being stored.
    - Reusability: Using requirements.txt makes it easier to manage dependencies.


### Container Build and Deployment Instructions

This section provides instructions for building container images and deploying the applications (producer and consumer) to a Kubernetes cluster.

1. **Build the Container Images**:
    - Each application (producer and consumer) includes a `build.sh` script in its respective directory.
    - Run the `build.sh` script to build the container image for the application.
    - If using K3s, the script will also handle transferring the built image to the K3s cluster. For other Kubernetes distributions (e.g., Minikube), use the appropriate method to make the image available to the cluster.

2. **Deploy the Applications**:
    - First ensure that the Kubernetes cluster is properly configured and accessible before proceeding with the above steps (Check step 4 in preiriquisites above).
    - After building and transferring the images, use the provided Kubernetes deployment manifests to create the deployments.
    - Apply the deployment manifests using `kubectl apply -f <manifest-file>` to deploy the applications to the cluster.

 
## Kafka Cluster Monitoring and Alerting Setup
My recommended how-to for On-premise/Private-Cloud setups:

Example sources: https://github.com/strimzi/strimzi-kafka-operator/tree/0.45.0/examples/metrics

Solution for setting up monitoring and alerting for your Kafka cluster using **Prometheus**, **Alert Manager**, and **Grafana**:

**1. Enabling Kafka Metrics with Strimzi Kafka Operator**
The first step is to enable metrics for your Kafka cluster. Strimzi Kafka Operator makes it easier to deploy and manage Kafka clusters on Kubernetes and it provides a built-in mechanism for exposing Kafka metrics via JMX (Java Management Extensions). Kafka’s JMX metrics allows to track a variety of metrics related to broker health, performance, and throughput.

Exposing JMX metrics is the first and necessary step to monitor Kafka, as it gives us access to key metrics like message throughput, byte rates, consumer lag, and more. 

example https://github.com/strimzi/strimzi-kafka-operator/blob/0.45.0/examples/metrics/kafka-metrics.yaml#L64

**2. Configuring Prometheus to Scrape Kafka Metrics**
Prometheus will collect the metrics exposed by Kafka brokers via JMX.

Prometheus uses a pull-based model where it scrapes metrics from configured targets at regular intervals. By adding Kafka as a target in Prometheus’ scrape configuration, it will continuously gather data from Kafka. This is important for real-time monitoring, as it provides the visibility into Kafka’s performance metrics.

The static_configs section allows us to define which Kafka brokers Prometheus should scrape metrics from. 

**3. Setting Up Alerting with Alert Manager**

Alert Manager is integrated with Prometheus to handle alerts when certain conditions are met. It can send notifications through different channels like email, Slack, or other messaging systems.

If key metrics' values drop significantly, it could indicate that Kafka is underperforming or facing issues (e.g., consumer lag, broker failure). Setting thresholds on these metrics allows us to detect issues early.

Examples:
- Alertmanager config to send messges to Slack: https://github.com/strimzi/strimzi-kafka-operator/blob/0.45.0/examples/metrics/prometheus-alertmanager-config/alert-manager-config.yaml
- Alert rule examples: https://github.com/strimzi/strimzi-kafka-operator/blob/0.45.0/examples/metrics/prometheus-install/prometheus-rules.yaml


**4. Using Grafana for Visualization**
Configure visualizations for Kafka metrics

Grafana integrates seamlessly with Prometheus and offers pre-configured dashboards for Kafka.

Dashboard examples: https://github.com/strimzi/strimzi-kafka-operator/tree/0.45.0/examples/metrics/grafana-dashboards