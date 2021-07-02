#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/gcp

update_examples_git_ref

init_gcloud

init_kubeconfig
init_bootstrap

write_users

bin/prep-inception.sh

bastion_zone="$(cd inception && terraform output bastion_zone | jq -r)"
bastion_name="$(cd inception && terraform output bastion_name | jq -r)"

gcloud compute ssh --zone ${bastion_zone} ${bastion_name} --ssh-key-file ${CI_ROOT}/login.ssh \
k --command "ls ${CI_ROOT_DIR} || mkdir ${CI_ROOT_DIR}"

export REMOTE_FOLDER="${CI_ROOT_DIR}/repo"
export BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-i ${CI_ROOT}/login.ssh"
bin/prep-bastion.sh

popd

rsync -avr -e "ssh -l ${BASTION_USER} -o StrictHostKeyChecking=no ${ADDITIONAL_SSH_OPTS}" pipeline-tasks ${bastion_ip}:${REMOTE_FOLDER}/pipeline-tasks
