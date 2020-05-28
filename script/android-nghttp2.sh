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

LIB_VERSION="v1.40.0"
LIB_NAME="nghttp2-1.40.0"
LIB_DEST_DIR="${pwd_path}/../output/android/nghttp2-universal"
DOWNLOAD_ADRESS="https://github.com/nghttp2/nghttp2/releases/download/${LIB_VERSION}/${LIB_NAME}.tar.gz"

util_download_file "$DOWNLOAD_ADRESS" "${INPUT_DIR}/${LIB_NAME}.tar.gz"

set_android_toolchain_bin

function configure_make() {

    ARCH=$1
    ABI=$2
    ABI_TRIPLE=$3

    log_info_print "configure $ABI start..."

    util_unzip "${INPUT_DIR}/${LIB_NAME}.tar.gz" "$INPUT_DIR" "$LIB_NAME"

    pushd .
    cd "${INPUT_DIR}/${LIB_NAME}"

    PREFIX_DIR="${OUTPUT_DIR}/${PLATFORM_TYPE}-${LIB_NAME}-${ABI}"
    util_remove_dir "$PREFIX_DIR"
    util_create_dir "${PREFIX_DIR}/log"

    set_android_toolchain "nghttp2" "${ARCH}" "${ANDROID_API}"
    set_android_cpu_feature "nghttp2" "${ARCH}" "${ANDROID_API}"

    export ANDROID_NDK_HOME=${ANDROID_NDK_ROOT}
    echo ANDROID_NDK_HOME=${ANDROID_NDK_HOME}

    android_printf_global_params "$ARCH" "$ABI" "$ABI_TRIPLE" "$INPUT_DIR" "$PREFIX_DIR"

    if [[ "${ARCH}" == "x86_64" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") --prefix="${PREFIX_DIR}" --disable-app --disable-threads --enable-lib-only >"${PREFIX_DIR}/log/${ABI}.log" 2>&1

    elif [[ "${ARCH}" == "x86" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") --prefix="${PREFIX_DIR}" --disable-app --disable-threads --enable-lib-only >"${PREFIX_DIR}/log/${ABI}.log" 2>&1

    elif [[ "${ARCH}" == "arm" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") --prefix="${PREFIX_DIR}" --disable-app --disable-threads --enable-lib-only >"${PREFIX_DIR}/log/${ABI}.log" 2>&1

    elif [[ "${ARCH}" == "arm64" ]]; then

        # --disable-lib-only need xml2 supc++ stdc++14
        ./configure --host=$(android_get_build_host "${ARCH}") --prefix="${PREFIX_DIR}" --disable-app --disable-threads --enable-lib-only >"${PREFIX_DIR}/log/${ABI}.log" 2>&1

    else
        log_error_print "not support" && exit 1
    fi

    log_info_print "make $ABI start..."

    make clean >>"${PREFIX_DIR}/log/${ABI}.log"
    if make -j$(util_get_cpu_count) >>"${PREFIX_DIR}/log/${ABI}.log" 2>&1; then
        make install >>"${PREFIX_DIR}/log/${ABI}.log" 2>&1
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
