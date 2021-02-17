# KafkaServer

This ansible Playbook provides resources for installing, configuring and managing [Apache Kafka](https://kafka.apache.org/). Installs Apache Kafka from a _`.tgz`_ source and installs the appropriate configuration for your platform's init system. It also installs _`OpenJDK1.8`_ since it is a Kafka requirement.

It uses the Solace Kafka Connector in order to stablish communication. More information about this Kafka connector can be found [here](https://github.com/SolaceProducts/pubsubplus-connector-kafka-source).

Lastly, This specific repo configures everything that is needed to connect to [FAA SWIM TFMS](https://www.faa.gov/air_traffic/technology/swim/) service, but other sources could be configured easily you can use the _`connect-solace-source.properties.j2`_ configuration template.

## Project Structure

```ssh
.
├── LICENSE
├── README.md
├── ansible.cfg
├── apache_kafka.yml
├── hosts
└── roles
    └── install
        ├── defaults
        │   └── main.yml
        ├── handlers
        │   └── main.yml
        ├── tasks
        │   └── main.yml
        └── templates
            ├── bashrc.j2
            ├── connect-solace-source.properties.j2
            ├── connect-standalone.properties.j2
            ├── kafka.service.j2
            ├── solace_source.properties.j2
            └── zookeeper.service.j2
```

## Requirements

### Platform Support

- RHEL 7.x
- CentOS 7.x

### Versions

- ansible 2.9.17

### Authentication

It uses key based authentication and it assumes you already have a key and you can configure the path using the _ansible_ssh_private_key_file_ variable in _`hosts`_ file.
You can create one using this command:

```ssh
ssh-keygen -t rsa -b 4096 -m PEM -C vm@mydomain.com -f ~/.ssh/vm_ssh
```

## Role Variables

This variables and their default values are located in `roles/install/defaults/main.yml`

```ssh
kafka_version: 2.3.0
kafka_scala_version: 2.12
kafka_user: kafkaAdmin
kafka_group: kafkaAdmin
kafka_root_dir: /opt
kafka_dir: '{{ kafka_root_dir }}/kafka'
solace_version: 2.0.2
```

## Secrets

For development purposes _`roles/install/defaults/main.yml`_ also has a secrets sections that you can update in order to connect to FAA SWIM TFMS service. It is recommended to store these secrets somewhere else like [Hashicorp Vault](https://www.vaultproject.io/) or [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/).

```ssh
SWIMEndpoint:
SWIMEndpointPort:
SWIMUserNaMe:
Password:
SWIMVPN:
SWIMQueue:
```

## Usage

Terraform uses the [local-exec provisioner](https://www.terraform.io/docs/language/resources/provisioners/local-exec.html) in order to execute this ansible playbook, but If you want to use separately, you can use these commands.

```ssh
ansible-playbook --syntax-check apache_kafka.yml
ansible-playbook apache_kafka.yml
```

## HOSTS file

The _`hosts`_ file is the inventory file where you need to provide the IPs of the servers that need to be configured. You can also configure the SSH Key to use, username and SSH port.

## Authors

Marcelo Zambrana
