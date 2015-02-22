#!/bin/bash
#
# Author: Fazle Arefin
# Purpose: Copies your public key to servers for passwordless auth
#

# TODO: change this path to the file containing your password
# the password can be in plain-text or base64 encoded; don't add any blank line
# if the password is base64 encoded, change the value of $Base64_Enc
export Pwd_File='/home/fazle/.passwd/fazle'

# TODO: base64 encoding; 0 is off, 1 is on
export Base64_Enc=0

# TODO: number of hosts to copy your key in parallel
Parallel_Copy=10

Hosts=$@

# some basic checks
if [[ "$1" == "" ]]; then
    echo "No host(s) provided" 1>&2
    exit 44
elif [[ 0 -ne $(hash sshpass &> /dev/null)$? ]]; then
    echo "Install sshpass first" 1>&2
    exit 55
elif ! [[ -f $Pwd_File ]]; then
    echo "Password file missing" 1>&2
    exit 66
fi

copy_ssh_id() {
    host=$(echo -n $1)    # strip the newline character from $1

    if [[ $Base64_Enc -eq 1 ]]; then
        sshpass -p "$(base64 -d $Pwd_File)" ssh-copy-id -o ConnectTimeout=5 $host &> /dev/null
    else
        sshpass -p "$(cat $Pwd_File)" ssh-copy-id -o ConnectTimeout=5 $host &> /dev/null
    fi

    if [[ $? -eq 0 ]]; then
        echo "✔ Copied ssh public key to $host" 1>&2
    else
        echo "✘ Could not copy ssh public key to $host" 1>&2
    fi
}

export -f copy_ssh_id

echo ${Hosts[*]} | xargs -d' ' -n1 -P${Parallel_Copy} bash -c 'copy_ssh_id "$@"' _

