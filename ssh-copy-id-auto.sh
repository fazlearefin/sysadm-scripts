#!/bin/bash
#
# Author: Fazle Arefin
# Purpose: Copies your public key to servers for passwordless auth
#

# TODO: change this path to the file containing your password
# the password can be in plain-text or base64 encoded; don't add any blank line
# if the password is base64 encoded, change the value of $BASE64_ENC
export PWDFILE='/home/fazle/.passwd/fazle'

# TODO: base64 encoding; 0 is off, 1 is on
export BASE64_ENC=0

# TODO: number of hosts to copy your key in parallel
PARALLEL_COPY=10

HOSTS=$@

# some basic checks
if [ "$1" == "" ]; then
    echo "No host(s) provided" 1>&2
    exit 44
elif [ 0 -ne $(which sshpass &> /dev/null)$? ]; then
    echo "Install sshpass first" 1>&2
    exit 55
elif ! [ -f $PWDFILE ]; then
    echo "Password file missing" 1>&2
    exit 66
fi

copy_ssh_id() {
    host=$(echo -n $1)    # strip the newline character from $1

    if [ $BASE64_ENC -eq 1 ]; then
        sshpass -p "$(base64 -d $PWDFILE)" ssh-copy-id -o ConnectTimeout=5 $host &> /dev/null
    else
        sshpass -p "$(cat $PWDFILE)" ssh-copy-id -o ConnectTimeout=5 $host &> /dev/null
    fi

    if [ $? -eq 0 ]; then
        echo "✔ Copied ssh public key to $host" 1>&2
    else
        echo "✘ Could not copy ssh public key to $host" 1>&2
    fi
}

export -f copy_ssh_id

echo ${HOSTS[*]} | xargs -d' ' -n1 -P${PARALLEL_COPY} bash -c 'copy_ssh_id "$@"' _

