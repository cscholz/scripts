#!/bin/bash
Version=20180710.01
# update2ram
# Scripts mounts (open)SUSE and Fedora update folder to ram to reduce
# disk write operations on usb sticks
# Style-Guide: https://google.github.io/styleguide/shell.xml#Case_statement

function mount_cache() {
  #######################################
  # Raise version number of dnsbl
  # Arguments:
  # Returns:
  #   None
  #######################################


  local package_folder=/var/cache/zypp/
  #package_folder=/var/cache/dnf/

  find $package_folder -maxdepth 1 -type d -name packages -print0 | while IFS= read -r -d $'\0' line; do
      echo "$line mounted to ram"
      mount -t tmpfs none "$line"
  done
}

function umount_cache() {
  #######################################
  # Raise version number of dnsbl
  # Arguments:
  # Returns:
  #   None
  #######################################

  
  local package_folder=/var/cache/zypp/
  #package_folder=/var/cache/dnf/
  
  find $package_folder -maxdepth 1 -type d -name packages -print0 | while IFS= read -r -d $'\0' line; do
      echo "$line unmounted from ram"
      umount "$line"
  done
}


check_self_update() {
  #######################################
  # Check for a new version of myself
  # Arguments:
  #   $1 $0 (script name)
  # Returns:
  #   None
  #######################################

  self=$(basename ${0})

  # The base location from where to retrieve new versions of this script
  local update_base=https://raw.githubusercontent.com/cscholz/scripts/master/Linux/bash/update2ram/

  local myself_web_version
  myself_web_version=$(curl -s -r 0-50 "${update_base}/${self}" | \
  head -2 | egrep -o "([0-9.]{1,4}+)" )
  myself_local_version=$(head -2 ${0}  | egrep -o "([0-9.]{1,4}+)")
  if [[ "${myself_web_version}"  > "${myself_local_version}" ]]; then
    echo -e "\033[40;1;33mNew version (v.${myself_local_version} -> v.${myself_web_version}) available.\033[0m"
          read -p "Update (y/N) " -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      run_self_update "${self}" "${update_base}"
    fi
  else
          echo "No update available (v.${myself_local_version})"
        fi
}

run_self_update() {
  #######################################
  # Download a new copy of myself and replace myself with it
  # Arguments:
  #   $1 $0 (script name)
  #   $2 update where the new version is stored
  # Returns:
  #   None
  #######################################

  self=${1}

  # The base location from where to retrieve new versions of this script
  update_base=${2}

  echo "> Performing self-update..."

  # Download new version
  echo -n "> Downloading latest version..."
  if ! wget --quiet --output-document="${0}.tmp" "${update_base}/${self}" ; then
    echo "Failed: Error while trying to wget new version!"
    echo "File requested: ${update_base}/${self}"
    exit 1
  fi
  echo "Done."

  # Download MD5 of update
  echo -n "> Downloading md5 sum..."
  if ! wget --quiet --output-document="${0}.md5" "${update_base}/${self}.md5" ; then
    echo "Failed: Error while trying to wget md5sum!"
    echo "File requested: ${update_base}/${self}.md5"
    exit 1
  fi
  echo "Done."

  # Checking MD5 sum
  echo -n "> Checking MD5 sum..."
  web_md5=$(cat ${0}.md5 | awk '{print $1}')
  local_md5=$(md5sum $(realpath ${0}.tmp) | awk '{print $1}')
  if [[ $web_md5 != "${local_md5}" ]]; then
    echo "Failed. Abort!"
    echo "${web_md5} / ${local_md5}"
    rm "${0}.md5"
    exit 0
  fi
  echo "Ok"
  rm "${0}.md5"

  # Copy over modes from old version
  OCTAL_MODE=$(stat -c '%a' $(realpath ${0}))
  if ! chmod ${OCTAL_MODE} "${0}.tmp" ; then
    echo "Failed: Error while trying to set mode on ${0}.tmp."
    exit 1
  fi

  # Spawn update script
  cat > updateScript.sh << EOF
#!/bin/bash
# Overwrite old file with new
if mv "${0}.tmp" "${0}"; then
  echo "Done. Update complete."
  rm \${0}
else
  echo "Failed. Please try again!"
  rm \${0}
fi
EOF

  echo -n "> Start update process..."
  exec /bin/bash updateScript.sh
}


main() {
   case "$1" in
   start)
           mount_cache
           ;;
   stop)
           umount_cache
           ;;
   restart)
           %1 stop
           %1 start
           ;;
   update)
          check_self_update
          ;;
   *)
          echo "Usage: $0 start|stop|restart|update"
          exit 1
          ;;
    esac
}

main "$@"
