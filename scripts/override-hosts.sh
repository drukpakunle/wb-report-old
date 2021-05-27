#!/bin/bash

## скрипт для переопределения хоста тестируемого энвайромента

if [[ $ENV_OVERRIDE_HOST == "true" ]]; then
  apt-get install -y iputils-ping

  echo "================================= OVERRIDE HOSTS BEGIN ========================================="

  hostsFilePath='/etc/hosts'

  cmd=$(
    cat <<EOF
      echo $ENV_IP \
      www.test-site.ru \
      www.test-site.by \
      >>$hostsFilePath
EOF
  )

  echo "executing command: $cmd ...."
  sh -c -e "$cmd"
  echo "executing complete"

  echo "Hosts overriding testing..."
  ping "www.test-site.ru" -c 1
  ping "www.test-site.by" -c 1

  echo "hosts file data:"
  cat "$hostsFilePath"
  echo "Hosts overriding testing complete"

  echo "================================= OVERRIDE HOSTS END ==========================================="
else
  echo "Run without hosts overriding"
fi
