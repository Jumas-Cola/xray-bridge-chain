#!/bin/bash
set -e
cd "$(dirname "$0")"
ansible-playbook -i inventory/hosts.yml upstream.yml --ask-pass
ansible-playbook -i inventory/hosts.yml bridge.yml --ask-pass
