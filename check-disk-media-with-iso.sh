#!/bin/bash
# Purpose: check integrity of a USB Disk created from iso (using dd)

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 /path/to/isofile.iso /dev/usbdevice"
  exit 1
fi

# the hash application to use, can be other like sha1sum, sha256sum, sha512sum, cksum
HASHAPP='md5sum'

# the ISO file
ISOFILE=$1

# change if your device is different
USBDEVICE=$2

# check to see if file exists
if ! [[ -e ${ISOFILE} ]]; then 
  echo "${ISOFILE} does not exist"
  exit 1
fi

hash_of_iso="$(${HASHAPP} ${ISOFILE} | cut -d' ' -f1)"
echo "info: ${HASHAPP} of ${ISOFILE} - ${hash_of_iso}"
bytes_of_iso=$(wc --bytes ${ISOFILE})

hash_of_usb=$(dd if=${USBDEVICE} | head --bytes ${bytes_of_iso} | ${HASHAPP} | cut -d' ' -f1)
echo "info: ${HASHAPP} of ${USBDEVICE} - ${hash_of_usb}"

if [[ ${hash_of_iso} == ${hash_of_usb} ]]; then
  echo "OK: ${HASHAPP} of ISO(${hash_of_iso}) matches ${HASHAPP} of USB(${hash_of_usb})"
  exit 0
else 
  echo "FAIL: ${HASHAPP} of ISO(${hash_of_iso}) does not match ${HASHAPP} of USB(${hash_of_usb})"
  exit 1
fi
