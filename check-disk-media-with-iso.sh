#!/bin/bash
# Purpose: check integrity of a USB Disk created from iso (using dd)

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 /path/to/isofile.iso /dev/usbdevice"
  exit 1
fi

# the hash application to use, can be other like sha1sum, sha256sum, sha512sum, cksum
HASHAPP='sha256sum'

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
bytes_of_iso=$(wc --bytes ${ISOFILE} | cut -d' ' -f1)

hash_of_usb="$(dd if=${USBDEVICE} | head --bytes ${bytes_of_iso} | ${HASHAPP} | cut -d' ' -f1)"
echo "info: ${HASHAPP} of ${USBDEVICE} - ${hash_of_usb}"

if [[ ${hash_of_iso} == ${hash_of_usb} ]]; then
  echo "✅ OK: ISO(${hash_of_iso}) == USB(${hash_of_usb})"
else
  echo "❌ FAIL: ISO(${hash_of_iso}) != USB(${hash_of_usb})"
  false
fi
