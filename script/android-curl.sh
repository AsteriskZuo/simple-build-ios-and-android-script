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
echo "# Build android curl shell script.                                            #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# GNU bash (version 3.2.57 test success on macOS)                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/openssl_for_ios_and_android             #" >/dev/null
echo "###############################################################################" >/dev/null

# set -x

curl_zip_file=""
curl_zip_file_no_suffix=""
curl_zip_file_path=""
curl_zip_file_no_suffix_path=""
curl_input_dir=""
curl_output_dir=""
openssl_output_dir=""
nghttp2_output_dir=""

function android_curl_printf_variable() {
    log_var_print "curl_input_dir =                $curl_input_dir"
    log_var_print "curl_output_dir =               $curl_output_dir"
    log_var_print "curl_zip_file =                 $curl_zip_file"
    log_var_print "curl_zip_file_no_suffix =       $curl_zip_file_no_suffix"
    log_var_print "curl_zip_file_path =            $curl_zip_file_path"
    log_var_print "curl_zip_file_no_suffix_path =  $curl_zip_file_no_suffix_path"
    log_var_print "openssl_output_dir =            $openssl_output_dir"
    log_var_print "nghttp2_output_dir =            $nghttp2_output_dir"
}

function android_curl_pre_tool_check() {

    openssl_output_dir="${COMMON_OUTPUT_DIR}/${COMMON_PLATFORM_TYPE}/$(common_get_library_name_from_id 1)"
    if [ ! -d "${openssl_output_dir}" ]; then
        common_die "Please build the openssl library first!"
    fi
    nghttp2_output_dir="${COMMON_OUTPUT_DIR}/${COMMON_PLATFORM_TYPE}/$(common_get_library_name_from_id 2)"
    if [ ! -d "${nghttp2_output_dir}" ]; then
        common_die "Please build the nghttp2 library first!"
    fi

    curl_input_dir="${COMMON_INPUT_DIR}/${COMMON_LIBRARY_NAME}"
    curl_output_dir="${COMMON_OUTPUT_DIR}/${COMMON_PLATFORM_TYPE}/${COMMON_LIBRARY_NAME}"

    curl_zip_file="${COMMON_DOWNLOAD_ADRESS##*/}"
    curl_zip_file_no_suffix=${curl_zip_file%.tar.gz}
    curl_zip_file_path="${curl_input_dir}/${curl_zip_file}"
    curl_zip_file_no_suffix_path="${curl_input_dir}/${curl_zip_file_no_suffix}"

    util_create_dir "${curl_input_dir}"
    util_create_dir "${curl_output_dir}"

    android_curl_printf_variable

}

function android_curl_pre_download_zip() {
    local library_id=$1
    util_download_file "$COMMON_DOWNLOAD_ADRESS" "$curl_zip_file_path"
}

function android_curl_build_unzip() {
    local library_id=$1
    util_unzip "$curl_zip_file_path" "${curl_input_dir}" "$curl_zip_file_no_suffix"
}

function android_curl_build_config_make() {
    local library_id=$1
    local library_arch=$2

    local library_arch_path="${curl_output_dir}/${library_arch}"
    util_remove_dir "$library_arch_path"
    util_create_dir "${library_arch_path}/log"

    openssl_output_arch_lib_dir="${openssl_output_dir}/${library_arch}/lib"
    if [ ! -d "${openssl_output_arch_lib_dir}" ]; then
        common_die "Please build the openssl ${library_arch} library first!"
    fi
    nghttp2_output_arch_lib_dir="${nghttp2_output_dir}/${library_arch}/lib"
    if [ ! -d "${nghttp2_output_arch_lib_dir}" ]; then
        common_die "Please build the nghttp2 ${library_arch} library first!"
    fi

    export LDFLAGS="${LDFLAGS} -L${openssl_output_arch_lib_dir} -L${nghttp2_output_arch_lib_dir}"

    android_printf_arch_variable

    pushd .
    cd "$curl_zip_file_no_suffix_path"

    if [[ "${library_arch}" == "x86-64" ]]; then

        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}" --enable-ipv6 --with-ssl="${openssl_output_dir}/${library_arch}" --with-nghttp2="${nghttp2_output_dir}/${library_arch}" >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "x86" ]]; then

        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}" --enable-ipv6 --with-ssl="${openssl_output_dir}/${library_arch}" --with-nghttp2="${nghttp2_output_dir}/${library_arch}" >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "armeabi-v7a" ]]; then

        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}" --enable-ipv6 --with-ssl="${openssl_output_dir}/${library_arch}" --with-nghttp2="${nghttp2_output_dir}/${library_arch}" >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "arm64-v8a" ]]; then

        # --enable-shared need nghttp2 cpp compile
        ./configure --host=$(android_get_build_host "${library_arch}") --prefix="${library_arch_path}" --disable-shared --enable-ipv6 --with-ssl="${openssl_output_dir}/${library_arch}" --with-nghttp2="${nghttp2_output_dir}/${library_arch}" >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    else
        common_die "not support $library_arch"
    fi

    common_build_make "${library_arch_path}" "clean" "-j$(util_get_cpu_count)" "install"

    popd
}

function android_curl_archive() {
    local library_name=$1
}
