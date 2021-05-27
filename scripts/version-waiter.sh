#!/bin/bash

## этот скрипт не только получает версию приложения, но и ждет раскатки после билда,
## нужно, если тесты запускаются по триггеру, например, мержа в релизную ветку, при этом приложение
## не успевает раскататься. Мы его терпеливо ждем.

echo "Installation of libraries..."
apt-get install -y jq
echo "Installation of libraries complete"

export ENV_URL=$ENV_URL

echo "================================= VERSION WAITER BEGIN ========================================="

if [ $UPSTREAM_PIPELINE_ID ] && [[ $UPSTREAM_BRANCH == *"release-"* ]]; then
  versionExpected=$(echo $UPSTREAM_BRANCH | sed 's/release-//')
  echo "Waiting major version: $versionExpected ..."

  timeOutInSeconds=30
  waitMaximumTimeInSeconds=600
  waitTimeInSeconds=0
  versionActual=$(sh ./scripts/version-get-major.sh)

  while [ "$versionExpected" != "$versionActual" ] && (($waitMaximumTimeInSeconds > $waitTimeInSeconds)); do
    echo "Current full version $(sh ./scripts/version-getter.sh)"
    echo "waitTimeInSeconds: $waitTimeInSeconds"
    echo "Sleep $timeOutInSeconds seconds..."
    sleep $timeOutInSeconds
    ((waitTimeInSeconds += timeOutInSeconds))
    versionActual=$(sh ./scripts/version-get-major.sh)
  done

  if [ "$versionExpected" == "$versionActual" ]; then
    echo "Version: $versionExpected appeared"
  else
    echo "Version: $versionExpected NOT appeared after $waitMaximumTimeInSeconds seconds"
  fi
else
  echo "Version waiting skipped"
fi

echo "================================= VERSION WAITER END ==========================================="
