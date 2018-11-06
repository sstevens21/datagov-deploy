#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

target=$1
shift

# TODO make this configurable?
image=ubuntu1404-ansible

# try to cleanup any existing containers
docker rm --force $target &> /dev/null || true

# Start the container based on $image
docker run -d --name $target $image sh -c "while true; do sleep 10000; done" > /dev/null

# Create a fake inventory for docker connection
inventory=$(mktemp)
cat <<EOF > $inventory
# Autogenerated inventory for building docker images for testing
$target ansible_connection=docker ansible_user=root
EOF

# Ansible it up
cd ../ansible
ansible-playbook -c docker -u root -i $inventory "$@"

# Save the container
docker commit --message "$target playbook" --author "data.gov"