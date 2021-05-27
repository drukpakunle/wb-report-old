#!/bin/bash

echo "Installation of libraries for generating a report..."
apt-get install -y zip unzip jq rsync allure
echo "Installation of libraries for generating a report complete"

echo "================================= BUILD REPORT BEGIN ========================================="

rm -rf .public
mkdir -p .public/$ENV_LOCALE/$CI_PIPELINE_ID
cp -r target/site/allure-maven-plugin/* .public/$ENV_LOCALE/$CI_PIPELINE_ID

echo "Reports params are collecting..."
dateTime=$(env TZ="Europe/Moscow" date +"%d.%m %A %H:%M MSK")

export ENV_URL=$ENV_URL
appVersion=$(sh ./scripts/version-getter.sh)

params=$(
  cat <<EOF
[{
  "locale": "$ENV_LOCALE",
  "pipelineId" : "$CI_PIPELINE_ID",
  "dateTime": "$dateTime",
  "upstreamPipelineId": $([ $UPSTREAM_PIPELINE_ID ] && echo \"$UPSTREAM_PIPELINE_ID\" || echo \"null\"),
  "appVersion": "$appVersion",
  "envUrl": "$ENV_URL",
  "envOverrideHost" : "$ENV_OVERRIDE_HOST",
  "envOverrideIP" : $([ $ENV_OVERRIDE_HOST = true ] && echo \"$ENV_IP\" || echo \"null\"),
  "runGroups": $([ $RUN_GROUPS = "" ] && echo \"All\" || echo \"$RUN_GROUPS\"),
  "runThreadCount": "$RUN_THREAD_COUNT",
  "device": "$RUN_DEVICE"
}]
EOF
)

jq -n "$params" >.public/$ENV_LOCALE/$CI_PIPELINE_ID/params.json
echo "Reports params collected and added to params.json: "
jq '.' <<<$params

publicZipFilePath="./public-$ENV_LOCALE.zip"

echo "Zip public folder to $publicZipFilePath"
zip -o -r -qq "$publicZipFilePath" .public
echo "Zip public folder complete"

echo "Upload reports cache..."

export FS_FILE_PATH=$publicZipFilePath
export FS_UPLOAD_PATH='public-'$ENV_LOCALE'.zip'
sh ./scripts/cache-push.sh

echo "Reports cache uploaded"
echo "Allure Report Link: " http://mobile.git.wildberries.ru/site-tests/$ENV_LOCALE/$CI_PIPELINE_ID

echo "=================================== BUILD REPORT END ==========================================="
