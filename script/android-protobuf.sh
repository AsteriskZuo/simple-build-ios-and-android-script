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

echo "###############################################################################" >/dev/null
echo "# Script Summary:                                                             #" >/dev/null
echo "# Author:                  AsteriskZuo                                        #" >/dev/null
echo "# Update Date:             2020.05.28                                         #" >/dev/null
echo "# Script version:          1.0.0                                              #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/simple-build-ios-and-android-script     #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Brief introduction:                                                         #" >/dev/null
echo "# Build android protobuf shell script.                                        #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# GNU bash (version 3.2.57 test success on macOS)                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/openssl_for_ios_and_android             #" >/dev/null
echo "###############################################################################" >/dev/null

# set -x

protobuf_zip_file=""
protobuf_zip_file_no_suffix=""
protobuf_zip_file_path=""
protobuf_zip_file_no_suffix_path=""
protobuf_input_dir=""
protobuf_output_dir=""

function android_protobuf_printf_variable() {
    log_var_print "protobuf_input_dir =                $protobuf_input_dir"
    log_var_print "protobuf_output_dir =               $protobuf_output_dir"
    log_var_print "protobuf_zip_file =                 $protobuf_zip_file"
    log_var_print "protobuf_zip_file_no_suffix =       $protobuf_zip_file_no_suffix"
    log_var_print "protobuf_zip_file_path =            $protobuf_zip_file_path"
    log_var_print "protobuf_zip_file_no_suffix_path =  $protobuf_zip_file_no_suffix_path"
}

function android_protobuf_pre_tool_check() {

    local protobuf_version=$(protoc --version)
    util_is_in "$COMMON_LIBRARY_VERSION" "$protobuf_version" || common_die "Protobuf is not installed on the system, see the protobuf installation instructions. (ref: https://github.com/protocolbuffers/protobuf/blob/master/src/README.md)"

    protobuf_input_dir="${COMMON_INPUT_DIR}/${COMMON_LIBRARY_NAME}"
    protobuf_output_dir="${COMMON_OUTPUT_DIR}/${COMMON_PLATFORM_TYPE}/${COMMON_LIBRARY_NAME}"

    protobuf_zip_file="${COMMON_DOWNLOAD_ADRESS##*/}"
    protobuf_zip_file_no_suffix=$(util_remove_substr "cpp-" ${protobuf_zip_file%.tar.gz})
    protobuf_zip_file_path="${protobuf_input_dir}/${protobuf_zip_file}"
    protobuf_zip_file_no_suffix_path="${protobuf_input_dir}/${protobuf_zip_file_no_suffix}"

    util_create_dir "${protobuf_input_dir}"
    util_create_dir "${protobuf_output_dir}"

    android_protobuf_printf_variable

}

function android_protobuf_pre_download_zip() {
    local library_id=$1
    util_download_file "$COMMON_DOWNLOAD_ADRESS" "$protobuf_zip_file_path"
}

function android_protobuf_build_unzip() {
    local library_id=$1
    util_unzip "$protobuf_zip_file_path" "${protobuf_input_dir}" "$protobuf_zip_file_no_suffix"
}

function android_protobuf_build_config_make() {
    local library_id=$1
    local library_arch=$2

    local library_arch_path="${protobuf_output_dir}/${library_arch}"
    util_remove_dir "$library_arch_path"
    util_create_dir "${library_arch_path}/log"

    export LDFLAGS="$LDFLAGS -Wunused-command-line-argument -llog"

    android_printf_arch_variable

    pushd .
    cd "$protobuf_zip_file_no_suffix_path"

    if [[ "${library_arch}" == "x86-64" ]]; then

        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}" --with-protoc=protobuf_command >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "x86" ]]; then

        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}" --with-protoc=protobuf_command >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "armeabi-v7a" ]]; then

        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}" --with-protoc=protobuf_command >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "arm64-v8a" ]]; then

        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}" --with-protoc=protobuf_command >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    else
        common_die "not support $library_arch"
    fi

    common_build_make "${library_arch_path}" "clean" "-j$(util_get_cpu_count)" "install"

    popd
}

function android_protobuf_archive() {
    local library_name=$1
}
