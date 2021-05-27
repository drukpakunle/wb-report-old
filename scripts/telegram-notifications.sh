#!/bin/bash

MESSAGE=$TELEGRAM_STATUS_MESSAGE%0A'link:%20'$CI_PIPELINE_URL

curl 'https://api.telegram.org/bot'"$TELEGRAM_BOT_TOKEN"'/sendMessage?chat_id='"$TELEGRAM_GROUP_ID"'&text='"$MESSAGE" > /dev/null
