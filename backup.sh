#!/bin/bash

CONFIG_FILE="./backup_config"
LANGUAGE="en"

if [ "$LANGUAGE" == "es" ]; then
    source messages_es.conf
else
    source messages_en.conf
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo $MSG_FIRST_RUN
    echo $MSG_PROVIDE_INFO

    read -p "$MSG_FOLDER_PATH" CARPETA_ORIGEN
    read -p "$MSG_BACKUP_PATH" BACKUP_DESTINO
    read -p "$MSG_LOG_PATH" LOG_FILE
    read -p "$MSG_WEBHOOK_URL" WEBHOOK_URL

    echo "CARPETA_ORIGEN=$CARPETA_ORIGEN" > $CONFIG_FILE
    echo "BACKUP_DESTINO=$BACKUP_DESTINO" >> $CONFIG_FILE
    echo "LOG_FILE=$LOG_FILE" >> $CONFIG_FILE
    echo "WEBHOOK_URL=$WEBHOOK_URL" >> $CONFIG_FILE
else
    source $CONFIG_FILE
fi

echo "$MSG_START_BACKUP $(date)" >> $LOG_FILE
tar -czvf $BACKUP_DESTINO/backup_$(date +%Y%m%d_%H%M%S).tar.gz $CARPETA_ORIGEN >> $LOG_FILE 2>&1
if [ $? -eq 0 ]; then
    echo "$MSG_SUCCESS_BACKUP $(date)" >> $LOG_FILE
else
    echo "$MSG_ERROR_BACKUP $(date)" >> $LOG_FILE
fi
curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\": \"$(cat $LOG_FILE)\"}" \
     $WEBHOOK_URL

> $LOG_FILE
