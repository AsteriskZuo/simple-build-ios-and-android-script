#!/bin/sh

echo "###############################################################################" >/dev/null
echo "# Script Summary:                                                             #" >/dev/null
echo "# Author:                  yu.zuo                                             #" >/dev/null
echo "# Update Date:             2020.05.28                                         #" >/dev/null
echo "# Script version:          1.0.0                                              #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/simple-build-ios-and-android-script     #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Brief introduction:                                                         #" >/dev/null
echo "# Build iOS and Android C&&C++ common library.                                #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# GNU bash (version 3.2.57 test success on macOS)                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/openssl_for_ios_and_android             #" >/dev/null
echo "###############################################################################" >/dev/null

function util_get_cpu_count() {
    if [ "$(uname)" == "Darwin" ]; then
        echo $(sysctl -n hw.physicalcpu)
    else
        echo $(nproc)
    fi
}

function util_print_current_datetime() {
    echo $(date +%Y-%m-%d\ %H:%M:%S)
}

function util_get_current_datetime() {
    local lv_var=$1
    eval $lv_var='$(date +%Y-%m-%d\ %H:%M:%S)'
}

function util_util_dir_is_empty() {
    local lv_dir=$1
    local lv_result=$2
    local lv_file_list=(`ls $lv_dir`)
    if [ 0 -lt ${#lv_file_list[@]} ]; then
        eval $lv_result="no"
    else
        eval $lv_result="yes"
    fi
}