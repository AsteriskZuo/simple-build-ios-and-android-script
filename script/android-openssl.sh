#!/bin/sh

source $(cd -P "$(dirname "$0")" && pwd)/android-common.sh

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

set -u

TOOLS_ROOT=$(pwd)

SOURCE="$0"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
pwd_path="$(cd -P "$(dirname "$SOURCE")" && pwd)"

echo pwd_path=${pwd_path}
echo TOOLS_ROOT=${TOOLS_ROOT}

# openssl-1.1.0f has a configure bug
# openssl-1.1.1d has fix configure bug
LIB_VERSION="OpenSSL_1_1_1d"
LIB_NAME="openssl-1.1.1d"
LIB_DEST_DIR="${pwd_path}/../output/android/openssl-universal"

echo "https://www.openssl.org/source/${LIB_NAME}.tar.gz"

# https://github.com/openssl/openssl/archive/OpenSSL_1_1_1d.tar.gz
# https://github.com/openssl/openssl/archive/OpenSSL_1_1_1f.tar.gz
rm -rf "${LIB_DEST_DIR}" "${LIB_NAME}"
[ -f "${LIB_NAME}.tar.gz" ] || curl https://www.openssl.org/source/${LIB_NAME}.tar.gz >${LIB_NAME}.tar.gz

set_android_toolchain_bin

function configure_make() {

    ARCH=$1
    ABI=$2
    ABI_TRIPLE=$3

    log_info_print "configure $ABI start..."

    if [ -d "${LIB_NAME}" ]; then
        rm -fr "${LIB_NAME}"
    fi
    tar xfz "${LIB_NAME}.tar.gz"
    pushd .
    cd "${LIB_NAME}"

    PREFIX_DIR="${pwd_path}/../output/android/openssl-${ABI}"
    if [ -d "${PREFIX_DIR}" ]; then
        rm -fr "${PREFIX_DIR}"
    fi
    mkdir -p "${PREFIX_DIR}"

    OUTPUT_ROOT=${TOOLS_ROOT}/../output/android/openssl-${ABI}
    mkdir -p ${OUTPUT_ROOT}/log

    set_android_toolchain "openssl" "${ARCH}" "${ANDROID_API}"
    set_android_cpu_feature "openssl" "${ARCH}" "${ANDROID_API}"

    export ANDROID_NDK_HOME=${ANDROID_NDK_ROOT}
    echo ANDROID_NDK_HOME=${ANDROID_NDK_HOME}

    android_printf_global_params "$ARCH" "$ABI" "$ABI_TRIPLE" "$PREFIX_DIR" "$OUTPUT_ROOT"

    if [[ "${ARCH}" == "x86_64" ]]; then

        ./Configure android-x86_64 --prefix="${PREFIX_DIR}"

    elif [[ "${ARCH}" == "x86" ]]; then

        ./Configure android-x86 --prefix="${PREFIX_DIR}"

    elif [[ "${ARCH}" == "arm" ]]; then

        ./Configure android-arm --prefix="${PREFIX_DIR}"

    elif [[ "${ARCH}" == "arm64" ]]; then

        ./Configure android-arm64 --prefix="${PREFIX_DIR}"

    else
        log_error_print "not support" && exit 1
    fi

    log_info_print "make $ABI start..."

    make clean >"${OUTPUT_ROOT}/log/${ABI}.log"
    if make -j$(util_get_cpu_count) >>"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1; then
        make install_sw >>"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1
        make install_ssldirs >>"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1
    fi

    popd
}

log_info_print "${PLATFORM_TYPE} ${LIB_NAME} start..."

for ((i = 0; i < ${#ARCHS[@]}; i++)); do
    if [[ $# -eq 0 || "$1" == "${ARCHS[i]}" ]]; then
        configure_make "${ARCHS[i]}" "${ABIS[i]}" "${ABI_TRIPLES[i]}"
    fi
done

log_info_print "${PLATFORM_TYPE} ${LIB_NAME} end..."
