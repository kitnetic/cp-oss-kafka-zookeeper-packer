#!/bin/bash

echo "waiting 180 seconds for cloud-init to update /etc/apt/sources.list"
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting ...; sleep 1; done'

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo rm /boot/grub/menu.lst

sleep 3

sudo -E apt-get upgrade -y

sleep 3

sudo -E apt-get install -y software-properties-common git python-dev htop ntp jq apt-transport-https

# Disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py || python2 get-pip.py

if [[ -f /sys/hypervisor/uuid && `head -c 3 /sys/hypervisor/uuid` == "ec2" ]]; then
  # install AWS-specific plugins only if running on AWS
  # see http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/identify_ec2_instances.html
  echo "Found old EC2 - Installing AWS CLI"
  pip install boto awscli || pip2 install boto awscli
elif [[ -f /sys/devices/virtual/dmi/id/product_uuid && `sudo head -c 3 /sys/devices/virtual/dmi/id/product_uuid` == "EC2" ]]; then
  # install AWS-specific plugins only if running on AWS
  # see http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/identify_ec2_instances.html
  echo "Found new EC2 - Installing AWS CLI"
  pip install boto awscli || pip2 install boto awscli
elif (sudo dmidecode -s system-product-name | grep -q "Google Compute Engine"); then
  # install Google Compute specific plugins only if running on GCP
  echo "Found GCP - Installing ..... ??"
else
  echo "No Cloud Provider Found - Not Installing anything"
fi



