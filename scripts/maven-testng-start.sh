#!/bin/sh

apt-get install -y zip

echo "================================= MAVEN TESTNG BEGIN ========================================="

echo "****************************** RUN PARAMS ******************************"
echo UPSTREAM_PIPELINE_ID: $([ $UPSTREAM_PIPELINE_ID ] && echo $UPSTREAM_PIPELINE_ID || echo null)
echo UPSTREAM_BRANCH: $([ $UPSTREAM_BRANCH ] && echo $UPSTREAM_BRANCH || echo null)
echo RUN_GROUPS: $([ "$RUN_GROUPS" = "" ] && echo All || echo $RUN_GROUPS)
echo LOCALE: $ENV_LOCALE
echo URL: $ENV_URL
echo ENV_OVERRIDE_HOST: $ENV_OVERRIDE_HOST
[ "$ENV_OVERRIDE_HOST" = "true" ] && echo ENV_IP: $ENV_IP
echo RUN_THREAD_COUNT: $RUN_THREAD_COUNT
echo RUN_DEVICE: $RUN_DEVICE
echo "************************************************************************"

mvnLocalRepoOpts="package -Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository"
mvnEnvOpts="$MVN_ADDITIONAL_PARAMS -Dremote=true -Dlocale=$ENV_LOCALE -DenvUrl=$ENV_URL"

mvn clean test site $mvnLocalRepoOpts $mvnEnvOpts -Dgroups=$RUN_GROUPS -DtestSuite=$RUN_SUITE

zipFilePath="./target/public-$ENV_LOCALE.zip"

echo "Zip target folder"
zip -o -r -qq "$zipFilePath" ./target/site/allure-maven-plugin/*
echo "Zip target folder complete"

echo "Upload report to cache-server..."
export FS_FILE_PATH=$zipFilePath
export FS_UPLOAD_PATH="public-$ENV_LOCALE.zip"
sh ./scripts/cache-pull.sh
echo "Backup uploaded"

echo "================================= MAVEN TESTNG END ========================================="
