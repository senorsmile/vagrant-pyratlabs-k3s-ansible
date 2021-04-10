#!/usr/bin/env bash

set -euo pipefail

export ANSIBLE_CALLBACK_WHITELIST='timer,profile_tasks'
export ANSIBLE_STDOUT_CALLBACK='yaml'

opts=(
  ansible-playbook 
  --diff 
  -i ./inventory/ 
  --forks 10  
  site.yml 
  $@
)

time pipenv run ${opts[@]}
