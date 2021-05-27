#!/bin/bash

echo "Installation of libraries..."
apt-get install -y zip unzip jq rsync allure
echo "Installation of libraries complete"

echo "================================= BUILD PAGES BEGIN ========================================="

rm -rf public
mkdir -p public

rm -rf ./target/.public
mkdir -p ./target/.public

echo "Pull reports cache from cache-server..."

export FS_FILE_NAME='public.zip'
sh ./scripts/cache-pull.sh
export FS_FILE_NAME='public-ru.zip'
sh ./scripts/cache-pull.sh
export FS_FILE_NAME='public-by.zip'
sh ./scripts/cache-pull.sh
export FS_FILE_NAME='public-am.zip'
sh ./scripts/cache-pull.sh
export FS_FILE_NAME='public-kg.zip'
sh ./scripts/cache-pull.sh
export FS_FILE_NAME='public-kz.zip'
sh ./scripts/cache-pull.sh

echo "Reports cache downloaded"

echo "Unzip reports cache..."
unzip -oo ./target/'*.zip'
echo "Unzip reports complete"

# переносим статику в пэйджес
rsync -r report/ public
rsync -r .public/* public

params=$(
  cat <<EOF
[]
EOF
)

echo "Build history.json..."

for pipelineDir in $(find public -type d -regex '.*/[0-9]*'); do
  echo pipelineDir: $pipelineDir
  [ -e "$pipelineDir/params.json" ] && params=$(echo $params | jq ". + $(jq '.' "$pipelineDir/params.json")")
done

jq '.' <<<$params

echo "History JSON validation..."

if [[ $(echo $params | jq type) == "\"array\"" ]]; then
  echo "JSON is valid. Update history.json..."
  jq -n "$params" >.public/history.json
  rsync -r .public/* public

  publicZipFilePath="./target/public.zip"

  echo "Zip public folder to $publicZipFilePath"
  zip -o -r -qq "$publicZipFilePath" public
  echo "Zip public folder complete"

  echo "Upload reports cache..."
  export FS_FILE_PATH=$publicZipFilePath
  export FS_UPLOAD_PATH='public.zip'

  sh ./scripts/cache-push.sh
  echo "Reports cache uploaded"

  historyJson=$(jq '.' "public/history.json")

  echo historyJson:

  jq '.' <<<$historyJson
else
  echo "JSON is not valid. Build report was interrupted"
  jq '.' <<<$params
fi

echo "Allure Report Link: " # your link to pages
echo "=================================== BUILD PAGES END ==========================================="
