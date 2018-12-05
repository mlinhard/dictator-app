#!/bin/bash

source bin/commons.sh

title=$1
content=$2
service=dictator-app

if [ "$content" == "candidate" ]; then
    service=dictator-app-candidate
fi

if [ "$content" == "loop" ]; then
    while :
    do
	    curl -d "{\"title\":\"$title\", \"content\":\"$content\"}" -H "Content-type: application/json" http://$service.$APP_DOMAIN/api/news/article
	    sleep 1
    done
else
    curl -d "{\"title\":\"$title\", \"content\":\"$content\"}" -H "Content-type: application/json" http://$service.$APP_DOMAIN/api/news/article
fi
