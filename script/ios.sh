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

source $(cd -P "$(dirname "$0")" && pwd)/ios-common.sh

log_head_print "###############################################################################"
log_head_print "# Script Summary:                                                             #"
log_head_print "# Author:                  AsteriskZuo                                        #"
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
    ios_help
fi

for opt; do
    optval="${opt#*=}"
    case "$opt" in
    --help | -h)
        ios_help
        ;;
    --name=*)
        if util_is_in $optval $COMMON_LIBRARY_NAME_LIST; then
            export COMMON_LIBRARY_NAME=($optval)
            export COMMON_LIBRARY_ID="$(common_get_library_id_from_name "$COMMON_LIBRARY_NAME")"
            export COMMON_LIBRARY_VERSION=$(common_get_library_version_from_id $COMMON_LIBRARY_ID)
            export COMMON_DOWNLOAD_ADRESS=$(common_get_library_url_from_id $COMMON_LIBRARY_ID)
        else
            common_die "${optval} is not in list. please refer \${COMMON_LIBRARY_NAME_LIST}"
        fi
        ;;
    *)
        ios_help
        ;;
    esac
done

common_printf_variable
ios_printf_variable

util_load_script "$(ios_get_shell_script_path ${COMMON_LIBRARY_ID})"

log_warning_print "build ${COMMON_LIBRARY_ID} ${COMMON_LIBRARY_NAME} ${COMMON_LIBRARY_VERSION} start..."

ios_pre_tool_check "${COMMON_LIBRARY_ID}"
ios_pre_download_zip "${COMMON_LIBRARY_ID}"
for ((i = 0; i < ${#IOS_ARCHS[@]}; i++)); do
    ios_build_unzip "${COMMON_LIBRARY_ID}" "${IOS_ARCHS[i]}"
    ios_build_config_make "${COMMON_LIBRARY_ID}" "${IOS_ARCHS[i]}"
done
ios_archive "${COMMON_LIBRARY_ID}"

log_warning_print "build ${COMMON_LIBRARY_ID} ${COMMON_LIBRARY_NAME} ${COMMON_LIBRARY_VERSION} end..."
