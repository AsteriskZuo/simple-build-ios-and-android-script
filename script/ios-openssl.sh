#!/bin/sh

source $(cd -P "$(dirname "$0")" && pwd)/ios-common.sh

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
LIB_DEST_DIR="${pwd_path}/../output/ios/openssl-universal"

echo "https://www.openssl.org/source/${LIB_NAME}.tar.gz"

# https://github.com/openssl/openssl/archive/OpenSSL_1_1_1d.tar.gz
# https://github.com/openssl/openssl/archive/OpenSSL_1_1_1f.tar.gz
DEVELOPER=$(xcode-select -print-path)
SDK_VERSION=$(xcrun -sdk iphoneos --show-sdk-version)
rm -rf "${LIB_DEST_DIR}" "${LIB_NAME}"
[ -f "${LIB_NAME}.tar.gz" ] || curl https://www.openssl.org/source/${LIB_NAME}.tar.gz >${LIB_NAME}.tar.gz

function configure_make() {

    ARCH=$1
    SDK=$2
    PLATFORM=$3

    log_info_print "configure $ARCH start..."

    if [ -d "${LIB_NAME}" ]; then
        rm -fr "${LIB_NAME}"
    fi
    tar xfz "${LIB_NAME}.tar.gz"
    pushd .
    cd "${LIB_NAME}"

    export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
    export CROSS_SDK="${PLATFORM}${SDK_VERSION}.sdk"

    if [ ! -d ${CROSS_TOP}/SDKs/${CROSS_SDK} ]; then
        log_error_print "ERROR: iOS SDK version:'${SDK_VERSION}' incorrect, SDK in your system is:"
        xcodebuild -showsdks | grep iOS
        exit -1
    fi

    PREFIX_DIR="${pwd_path}/../output/ios/openssl-${ARCH}"
    if [ -d "${PREFIX_DIR}" ]; then
        rm -fr "${PREFIX_DIR}"
    fi
    mkdir -p "${PREFIX_DIR}"

    OUTPUT_ROOT=${TOOLS_ROOT}/../output/ios/openssl-${ARCH}
    mkdir -p ${OUTPUT_ROOT}/log

    set_android_cpu_feature "nghttp2" "${ARCH}" "${IOS_MIN_TARGET}" "${CROSS_TOP}/SDKs/${CROSS_SDK}"
    
    ios_printf_global_params "$ARCH" "$SDK" "$PLATFORM" "$PREFIX_DIR" "$OUTPUT_ROOT"

    unset IPHONEOS_DEPLOYMENT_TARGET

    if [[ "${ARCH}" == "x86_64" ]]; then

        # openssl1.1.1d can be set normally, 1.1.0f does not take effect
        ./Configure darwin64-x86_64-cc no-shared --prefix="${PREFIX_DIR}"

    elif [[ "${ARCH}" == "armv7" ]]; then

        # openssl1.1.1d can be set normally, 1.1.0f does not take effect
        ./Configure iphoneos-cross no-shared --prefix="${PREFIX_DIR}"
        sed -ie "s!-fno-common!-fno-common -fembed-bitcode !" "Makefile"

    elif [[ "${ARCH}" == "arm64" ]]; then

        # openssl1.1.1d can be set normally, 1.1.0f does not take effect
        ./Configure iphoneos-cross no-shared --prefix="${PREFIX_DIR}"
        sed -ie "s!-fno-common!-fno-common -fembed-bitcode !" "Makefile"

    elif [[ "${ARCH}" == "arm64e" ]]; then

        # openssl1.1.1d can be set normally, 1.1.0f does not take effect
        ./Configure iphoneos-cross no-shared --prefix="${PREFIX_DIR}"
        sed -ie "s!-fno-common!-fno-common -fembed-bitcode !" "Makefile"

    else
        log_error_print "not support" && exit 1
    fi

    log_info_print "make $ARCH start..."

    make clean >"${OUTPUT_ROOT}/log/${ARCH}.log"
    if make -j8 >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1; then
        make install_sw >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1
        make install_ssldirs >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1
    fi

    popd
}

log_info_print "${PLATFORM_TYPE} ${LIB_NAME} start..."

for ((i = 0; i < ${#ARCHS[@]}; i++)); do
    if [[ $# -eq 0 || "$1" == "${ARCHS[i]}" ]]; then
        configure_make "${ARCHS[i]}" "${SDKS[i]}" "${PLATFORMS[i]}"
    fi
done

log_info_print "lipo start..."

function lipo_library() {
    LIB_SRC=$1
    LIB_DST=$2
    LIB_PATHS=("${ARCHS[@]/#/${pwd_path}/../output/ios/openssl-}")
    LIB_PATHS=("${LIB_PATHS[@]/%//lib/${LIB_SRC}}")
    lipo ${LIB_PATHS[@]} -create -output "${LIB_DST}"
}
mkdir -p "${LIB_DEST_DIR}"
lipo_library "libcrypto.a" "${LIB_DEST_DIR}/libcrypto-universal.a"
lipo_library "libssl.a" "${LIB_DEST_DIR}/libssl-universal.a"

log_info_print "${PLATFORM_TYPE} ${LIB_NAME} end..."
