#!/bin/bash
set -e

#Get the key
wget -qO - https://packages.confluent.io/deb/${CONFLUENT_VERSION}/archive.key | sudo apt-key add -


sudo add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/${CONFLUENT_VERSION} stable main"

sudo apt-get update

sudo apt-get install confluent-kafka-2.12

mv -f  zookeeper.properties /etc/kafka/zookeeper.properties
