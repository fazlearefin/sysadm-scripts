#!/bin/bash
#
# Purpose: Write the passed in parameter as hostid to /etc/hostid
#          If no parameter is passed, write current hostid to /etc/hostid
# Author:  Fazle Arefin [fazlearefin at yahoo dot com]
#

if [[ -n "$1" ]]; then
  host_id=$1
  # chars must be 0-9, a-f, A-F and exactly 8 chars
  egrep -o '^[a-fA-F0-9]{8}$' <<< $host_id || exit 1
else
  host_id=$(hostid)
fi

a=${host_id:6:2}
b=${host_id:4:2}
c=${host_id:2:2}
d=${host_id:0:2}

echo -ne \\x$a\\x$b\\x$c\\x$d > /etc/hostid &&
  echo "Success" 1>&2

exit 0
