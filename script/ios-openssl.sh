#!/bin/sh

echo "###############################################################################" >/dev/null
echo "# Script Summary:                                                             #" >/dev/null
echo "# Author:                  yu.zuo                                             #" >/dev/null
echo "# Update Date:             2020.05.28                                         #" >/dev/null
echo "# Script version:          1.0.0                                              #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/simple-build-ios-and-android-script     #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Brief introduction:                                                         #" >/dev/null
echo "# Build ios openssl shell script.                                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# GNU bash (version 3.2.57 test success on macOS)                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/openssl_for_ios_and_android             #" >/dev/null
echo "###############################################################################" >/dev/null

# set -x

openssl_zip_file=""
openssl_zip_file_no_suffix=""
openssl_zip_file_path=""
openssl_zip_file_no_suffix_path=""
openssl_input_dir=""
openssl_output_dir=""

function ios_openssl_printf_variable() {
    log_var_print "openssl_input_dir =                $openssl_input_dir"
    log_var_print "openssl_output_dir =               $openssl_output_dir"
    log_var_print "openssl_zip_file =                 $openssl_zip_file"
    log_var_print "openssl_zip_file_no_suffix =       $openssl_zip_file_no_suffix"
    log_var_print "openssl_zip_file_path =            $openssl_zip_file_path"
    log_var_print "openssl_zip_file_no_suffix_path =  $openssl_zip_file_no_suffix_path"
}

function ios_openssl_pre_tool_check() {

    openssl_input_dir="${COMMON_INPUT_DIR}/${COMMON_LIBRARY_NAME}"
    openssl_output_dir="${COMMON_OUTPUT_DIR}/${COMMON_PLATFORM_TYPE}/${COMMON_LIBRARY_NAME}"

    openssl_zip_file="${COMMON_DOWNLOAD_ADRESS##*/}"
    openssl_zip_file_no_suffix=${openssl_zip_file%.tar.gz}
    openssl_zip_file_path="${openssl_input_dir}/${openssl_zip_file}"
    openssl_zip_file_no_suffix_path="${openssl_input_dir}/${openssl_zip_file_no_suffix}"

    util_create_dir "${openssl_input_dir}"
    util_create_dir "${openssl_output_dir}"

    ios_openssl_printf_variable

}

function ios_openssl_pre_download_zip() {
    local library_id=$1
    util_download_file "$COMMON_DOWNLOAD_ADRESS" "$openssl_zip_file_path"
}

function ios_openssl_build_unzip() {
    local library_id=$1
    util_unzip "$openssl_zip_file_path" "${openssl_input_dir}" "$openssl_zip_file_no_suffix"
}

function ios_openssl_build_config_make() {
    local library_id=$1
    local library_arch=$2

    local library_arch_path="${openssl_output_dir}/${library_arch}"
    util_remove_dir "$library_arch_path"
    util_create_dir "${library_arch_path}/log"

    ios_set_sysroot "${library_arch}"
    ios_set_cpu_feature "${COMMON_LIBRARY_NAME}" "${library_arch}" "${IOS_API}" "${IOS_SYSROOT}"

    ios_printf_arch_variable

    pushd .
    cd "$openssl_zip_file_no_suffix_path"

    # openssl1.1.1d can be set normally, 1.1.0f does not take effect
    # sed -ie "s!-fno-common!-fno-common -fembed-bitcode !" "Makefile"
    if [[ "${library_arch}" == "x86-64" ]]; then

        ./Configure darwin64-x86_64-cc no-shared --prefix="${library_arch_path}" >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "armv7" ]]; then

        ./Configure iphoneos-cross no-shared --prefix="${library_arch_path}" >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "arm64" ]]; then

        ./Configure iphoneos-cross no-shared --prefix="${library_arch_path}" >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    elif [[ "${library_arch}" == "arm64e" ]]; then

        ./Configure iphoneos-cross no-shared --prefix="${library_arch_path}" >"${library_arch_path}/log/output.log" 2>&1 || common_die "configure error!"

    else
        common_die "not support $library_arch"
    fi

    make clean >>"${library_arch_path}/log/output.log"
    if make -j$(util_get_cpu_count) >>"${library_arch_path}/log/output.log" 2>&1; then
        make install_sw >>"${library_arch_path}/log/output.log" 2>&1
        make install_ssldirs >>"${library_arch_path}/log/output.log" 2>&1
    fi

    popd
}

function ios_openssl_archive() {
    local library_id=$1
    local static_library_ssl_list=()
    local static_library_crypto_list=()
    for ((i = 0; i < ${#IOS_ARCHS[@]}; i++)); do
        local static_library_file_path_ssl="${openssl_output_dir}/${IOS_ARCHS[i]}/lib/libssl.a"
        if [ -f "$static_library_file_path_ssl" ]; then
            static_library_ssl_list[${#static_library_ssl_list[@]}]="$static_library_file_path_ssl"
        fi
        local static_library_file_path_crypto="${openssl_output_dir}/${IOS_ARCHS[i]}/lib/libcrypto.a"
        if [ -f "$static_library_file_path_crypto" ]; then
            static_library_crypto_list[${#static_library_crypto_list[@]}]="$static_library_file_path_crypto"
        fi
    done
    if test ${#static_library_ssl_list[@]} -gt 0 && test ${#static_library_crypto_list[@]} -gt 0; then
        util_remove_dir "${openssl_output_dir}/lipo"
        util_create_dir "${openssl_output_dir}/lipo"
        lipo ${static_library_ssl_list[@]} -create -output "${openssl_output_dir}/lipo/libssl-universal.a"
        lipo ${static_library_crypto_list[@]} -create -output "${openssl_output_dir}/lipo/libcrypto-universal.a"
    fi
}
