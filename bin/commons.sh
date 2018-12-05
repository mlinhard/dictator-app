#!/bin/bash

source build.conf

function check_def() {
    if [ "${!1}x" == "x" ]; then
        echo "Please define $1"
        exit 1
    fi
}

function replace_env() {
    esc_value=`echo $2 | sed 's/\//\\\\\//g'`
    sed -i "s/\${${1}}/${esc_value}/g" $3
}

function replace_env_kube() {
    tofind="\${${1}}"
    for f in `grep "$tofind" -Rl kube --include=*.yml`
    do
        replace_env ${1} ${2} $f
    done
}

function get_pod_name() {
    local app
    local ver
    local lab
    local cnt
    app=$1
    ver=$2
    if [ "$ver" == "-" ]; then
        lab="app=$app"
    else
        lab="app=$app,version=$ver"
    fi
    cnt=`kubectl get pod -l $lab -o json | jq '.items | length'`
    if [ "$cnt" != "1" ]; then
        echo "There are multiple $app pods version $ver"
        kubectl get pod -l $lab
        exit 1
    fi
    kubectl get pod -l $lab -o jsonpath={$.items[0].metadata.name}
}

check_def APP_DOMAIN
check_def GOOGLE_PROJECT
check_def GCR_PREFIX

export APP_DOMAIN
export GOOGLE_PROJECT
export GCR_PREFIX

export APP_VERSION=`git describe --tags`
