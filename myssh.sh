#!/bin/bash
#
# Purpose: Tries to ssh to a server using key-based auth, and if fails, copies the key to the server and tries to ssh again
# Author: Fazle Arefin
#
# Depends on: ./ssh-copy-id-auto-multi.sh

THIS_SCRIPT=$0
SSH_HOST=$1

[ $# -eq 1 ] || exit 100

ssh -o PubkeyAuthentication=yes -o PasswordAuthentication=no -o ChallengeResponseAuthentication=no -o KbdInteractiveAuthentication=no $SSH_HOST

if [ $? -ne 0 ]; then
  ./ssh-copy-id-auto-multi.sh $SSH_HOST && $THIS_SCRIPT $SSH_HOST
fi
