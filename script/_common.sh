# MIT License

# Copyright (c) 2020 asteriskzuo

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#!/bin/sh

source $(cd -P "$(dirname "$0")" && pwd)/__color_log.sh

echo "###############################################################################" >/dev/null
echo "# Script Summary:                                                             #" >/dev/null
echo "# Author:                  AsteriskZuo                                        #" >/dev/null
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

echo "###############################################################################" >/dev/null
echo "#### Global Variable Partition                                            #####" >/dev/null
echo "###############################################################################" >/dev/null

export COMMON_SCRIPT_NAME="$0"
export COMMON_SCRIPT_DIR=$(util_get_script_dir)
export COMMON_INPUT_DIR=$(util_get_input_dir)
export COMMON_OUTPUT_DIR=$(util_get_output_dir)
export COMMON_PLATFORM_TYPE=""
export COMMON_LIBRARY_ID=""
export COMMON_LIBRARY_NAME=""
export COMMON_LIBRARY_VERSION=""
export COMMON_DOWNLOAD_ADRESS=""

export COMMON_LIBRARY_ID_LIST="
1
2
3
4
"
export COMMON_LIBRARY_NAME_LIST="
openssl
nghttp2
curl
protobuf
"
export COMMON_LIBRARY_VERSION_LIST="
1.1.1d
1.40.0
7.68.0
3.11.4
"
export COMMON_LIBRARY_URL_LIST="
https://www.openssl.org/source/openssl-1.1.1d.tar.gz
https://github.com/nghttp2/nghttp2/releases/download/v1.40.0/nghttp2-1.40.0.tar.gz
https://curl.haxx.se/download/curl-7.68.0.tar.gz
https://github.com/protocolbuffers/protobuf/releases/download/v3.11.4/protobuf-cpp-3.11.4.tar.gz
"

util_create_dir "$COMMON_INPUT_DIR"
util_create_dir "$COMMON_OUTPUT_DIR"

echo "###############################################################################" >/dev/null
echo "#### Function Partition                                                   #####" >/dev/null
echo "###############################################################################" >/dev/null

function common_printf_variable() {
    log_var_print "COMMON_SCRIPT_NAME =           $COMMON_SCRIPT_NAME"
    log_var_print "COMMON_SCRIPT_DIR =            $COMMON_SCRIPT_DIR"
    log_var_print "COMMON_INPUT_DIR =             $COMMON_INPUT_DIR"
    log_var_print "COMMON_OUTPUT_DIR =            $COMMON_OUTPUT_DIR"
    log_var_print "COMMON_PLATFORM_TYPE =         $COMMON_PLATFORM_TYPE"
    log_var_print "COMMON_LIBRARY_ID =            $COMMON_LIBRARY_ID"
    log_var_print "COMMON_LIBRARY_NAME =          $COMMON_LIBRARY_NAME"
    log_var_print "COMMON_LIBRARY_VERSION =       $COMMON_LIBRARY_VERSION"
    log_var_print "COMMON_DOWNLOAD_ADRESS =       $COMMON_DOWNLOAD_ADRESS"
    log_var_print "COMMON_LIBRARY_ID_LIST =       ${COMMON_LIBRARY_ID_LIST}"
    log_var_print "COMMON_LIBRARY_NAME_LIST =     ${COMMON_LIBRARY_NAME_LIST}"
    log_var_print "COMMON_LIBRARY_VERSION_LIST =  ${COMMON_LIBRARY_VERSION_LIST}"
    log_var_print "COMMON_LIBRARY_URL_LIST =      ${COMMON_LIBRARY_URL_LIST}"
}

function common_help() {
    log_info_print "

Usage: $0 [options]
Options: [defaults in brackets after descriptions]

Help options:
  --help|-h                print this message
  --name[=?]               Build the library name, which must be one of the options in the \${COMMON_LIBRARY_NAME_LIST} list.

"
    exit 0
}

function common_get_library_id_from_name() {
    local name=$1
    case $name in
    openssl)
        echo "1"
        ;;
    nghttp2)
        echo "2"
        ;;
    curl)
        echo "3"
        ;;
    protobuf)
        echo "4"
        ;;
    *)
        echo "not support"
        ;;
    esac
}

function common_get_library_name_from_id() {
    echo "$(util_get_list_item $1 $COMMON_LIBRARY_NAME_LIST)"
}

function common_get_library_version_from_id() {
    echo "$(util_get_list_item $1 $COMMON_LIBRARY_VERSION_LIST)"
}

function common_get_library_url_from_id() {
    echo "$(util_get_list_item $1 $COMMON_LIBRARY_URL_LIST)"
}

function common_die() {
    log_error_print "$1" && exit 1
}

echo "###############################################################################" >/dev/null
echo "#### Flow Function Partition                                              #####" >/dev/null
echo "###############################################################################" >/dev/null

function common_pre_tool_check() {
    local library_id=$1
}

function common_pre_download_zip() {
    local library_id=$1
}

function common_build_unzip() {
    local library_id=$1
}

function common_build_config_make() {
    local library_id=$1
    local arch=$2
}

function common_archive() {
    local library_name=$1
}

function common_build_make() {
    local library_arch_path=$1
    shift
    for make_param in $*; do
        echo "[info][make_${make_param}_start]" >>"${library_arch_path}/log/output.log"
        make $make_param >>"${library_arch_path}/log/output.log" 2>&1 || common_die "make $make_commond error!"
    done
}
