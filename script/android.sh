#!/bin/sh

source $(cd -P "$(dirname "$0")" && pwd)/android-common.sh

log_head_print "###############################################################################"
log_head_print "# Script Summary:                                                             #"
log_head_print "# Author:                  yu.zuo                                             #"
log_head_print "# Update Date:             2020.05.28                                         #"
log_head_print "# Script version:          1.0.0                                              #"
log_head_print "# Url: https://github.com/AsteriskZuo/simple-build-ios-and-android-script     #"
log_head_print "#                                                                             #"
log_head_print "# Brief introduction:                                                         #"
log_head_print "# Build iOS and Android C&&C++ common library.                                #"
log_head_print "#                                                                             #"
log_head_print "# Prerequisites:                                                              #"
log_head_print "# GNU bash (version 3.2.57 test success on macOS)                             #"
log_head_print "#                                                                             #"
log_head_print "# Reference:                                                                  #"
log_head_print "# Url: https://github.com/AsteriskZuo/openssl_for_ios_and_android             #"
log_head_print "###############################################################################"

set -u
# util_debug

opt_count=$#
opt=$*

if [ "Darwin" != $(uname -s) ]; then
    common_die "This is not MacOS."
fi

if [ ! $opt ]; then
    android_help
fi

for opt; do
    optval="${opt#*=}"
    case "$opt" in
    --help | -h)
        android_help
        ;;
    --name=*)
        if util_is_in $optval $COMMON_LIBRARY_NAME_LIST; then
            export COMMON_LIBRARY_NAME=($optval)
            export COMMON_LIBRARY_ID="$(common_get_library_id_from_name "$COMMON_LIBRARY_NAME")"
            export COMMON_LIBRARY_VERSION=$(common_get_library_version_from_id $COMMON_LIBRARY_ID)
            export COMMON_DOWNLOAD_ADRESS=$(common_get_library_url_from_id $COMMON_LIBRARY_ID)
        else
            common_die 'name is not in list. please refer ${COMMON_LIBRARY_NAME_LIST}'
        fi
        ;;
    *)
        android_help
        ;;
    esac
done

common_printf_variable
android_printf_variable

util_load_script "$(android_get_shell_script_path ${COMMON_LIBRARY_ID})"

log_warning_print "build ${COMMON_LIBRARY_ID} ${COMMON_LIBRARY_NAME} ${COMMON_LIBRARY_VERSION} start..."

android_set_toolchain_bin
android_pre_tool_check "${COMMON_LIBRARY_ID}"
android_pre_download_zip "${COMMON_LIBRARY_ID}"
for ((i = 0; i < ${#ANDROID_ARCHS[@]}; i++)); do
    android_build_unzip "${COMMON_LIBRARY_ID}" "${ANDROID_ARCHS[i]}"
    android_build_config_make "${COMMON_LIBRARY_ID}" "${ANDROID_ARCHS[i]}"
done
android_archive "${COMMON_LIBRARY_ID}"

log_warning_print "build ${COMMON_LIBRARY_ID} ${COMMON_LIBRARY_NAME} ${COMMON_LIBRARY_VERSION} end..."
