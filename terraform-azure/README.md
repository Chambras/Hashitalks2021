# Terraforming Data Analytics Environments

It creates the following resources:

- A new Resource Group
- A RedHat VM
- A VNet
- A Storage Account with a container so it can be mounted in DataBricks.
- 4 subnets to host the Single Kafka VM, but in mind to create a cluster in the future.
- 2 subnets public and private dedicated to DataBricks Cluster.
- A Network Security Group with SSH, HTTP and RDP access.
- A Network Security Group dedicated to the DataBricks Cluster.
- A DataBricks Workspace with VNet injection.
- A DataBricks Cluster.
- A starter Notebook with initial python code to connect to Kafka.

## Project Structure

This project has the following files which make them easy to reuse, add or remove.

```ssh
.
├── README.md
├── main.tf
├── networking.tf
├── outputs.tf
├── security.tf
├── storage.tf
├── variables.tf
├── vm.tf
└── workspace.tf
```

Most common parameters are exposed as variables in _`variables.tf`_

## Pre-requisites

It is assumed that you have azure CLI and Terraform installed and configured.
More information on this topic [here](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure). I recommend using a Service Principal with a certificate.

### versions

This terraform script has been tested using the following versions:

- Terraform =>0.14.6
- Azure provider 2.47.0
- Databricks provider 0.3.0
- Azure CLI 2.19.1

## VM Authentication

It uses key based authentication and it assumes you already have a key. You can configure the path using the _sshKeyPath_ variable in _`variables.tf`_ You can create one using this command:

```ssh
ssh-keygen -t rsa -b 4096 -m PEM -C vm@mydomain.com -f ~/.ssh/vm_ssh
```

## Usage

Just run these commands to initialize terraform, get a plan and approve it to apply it.

```ssh
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
```

I also recommend using a remote state instead of a local one. You can change this configuration in _`main.tf`_
You can create a free Terraform Cloud account [here](https://app.terraform.io).

This terraform script uses the [local-exec provisioner](https://www.terraform.io/docs/language/resources/provisioners/local-exec.html) in order to execute ansible playbook located in _'ansible/KafkaServer/apache_kafka.yml'_ which does all the required post-provisioning configuration. You can go to that folder for all the details.

## Useful Apache Kafka commands

Create a topic

```ssh
# stdds
kafka-topics.sh --create --replication-factor 3 --partitions 1 --topic stdds --zookeeper localhost:9092

#tfms
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic tfms
```

List topics

```ssh
kafka-topics.sh --list --bootstrap-server localhost:9092
```

Delete topics

```ssh
# stdds
kafka-topics.sh --delete --topic stdds --bootstrap-server localhost:9092

# tfms
kafka-topics.sh --delete --topic tfms --bootstrap-server localhost:9092
```

Describe topics

```ssh
# stdds
kafka-topics.sh --describe --topic tfms --bootstrap-server localhost:9092

# tfms
kafka-topics.sh --describe --topic tfms --bootstrap-server localhost:9092
```

Start standalone connection

```ssh
# stdds
connect-standalone.sh /opt/kafka/config/connect-standalone.properties /opt/kafka/config/connect-solace-stdds-source.properties

# tfms
connect-standalone.sh /opt/kafka/config/connect-standalone.properties /opt/kafka/config/connect-solace-tfms-source.properties
```

Check incoming messages. This command will display all the messages from the beginning and might take some time if you have lots of messages.

```ssh
# stdds
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic stdds --from-beginning

# tfms
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic tfms --from-beginning
```

If you just want to check specific messages and not display all of them, you can use the `--max-messages` option.
The following comand will display the first message.

```ssh
# stdds
kafka-console-consumer.sh --from-beginning --max-messages 1 --topic stdds --bootstrap-server localhost:9092

# tfms
kafka-console-consumer.sh --from-beginning --max-messages 1 --topic tfms --bootstrap-server localhost:9092
```

if you want to see all available options, just run the `kafka-console-consumer.sh` without any options

```ssh
kafka-console-consumer.sh
```

## Clean resources

It will destroy everything that was created.

```ssh
terraform destroy --force
```

## Caution

Be aware that by running this script your account might get billed.

## Authors

- Marcelo Zambrana
