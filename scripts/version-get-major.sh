#!/bin/sh

## субскрипт version-waiter.sh. Получаем мажорную версию релиза.

echo $(sh ./scripts/version-getter.sh | sed 's/\([0-9\.]\)_.*/\1/')