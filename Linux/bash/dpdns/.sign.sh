#!/bin/bash
if [ -z "$1" ] ; then
  echo "Usage: $0 {file}"
  exit 0
fi

md5sum "${1}" > "${1}".md5
