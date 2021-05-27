#!/bin/sh

## субскрипт version-waiter.sh. Получаем полную версию аппы

aboutUrl="$ENV_URL/_about?json=Y"
timeOutInSeconds=30
waitMaximumTimeInSeconds=600
waitTimeInSeconds=0

getResponseCodeCmd=$(
  cat <<EOF
  curl -o /dev/null -s -w "%{http_code}\n" "$aboutUrl" --cookie "mobile_client=1"
EOF
)

getVersionCmd=$(
  cat <<EOF
  curl -s "$aboutUrl" --cookie "mobile_client=1" | jq '.appVersion' | sed 's/\"\(.*\)\"/\1/'
EOF
)

while [ "$(sh -c -e "$getResponseCodeCmd")" != "200" ] && (($waitMaximumTimeInSeconds > $waitTimeInSeconds)); do
  sleep $timeOutInSeconds
  ((waitTimeInSeconds += timeOutInSeconds))
done

if [ "$(sh -c -e "$getResponseCodeCmd")" = "200" ]; then
  echo $(sh -c -e "$getVersionCmd")
else
  echo "version not available"
fi
