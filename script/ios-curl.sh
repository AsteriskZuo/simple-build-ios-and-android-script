#!/bin/sh

source ./ios-common.sh

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

LIB_VERSION="curl-7_68_0"
LIB_NAME="curl-7.68.0"
LIB_DEST_DIR="${pwd_path}/../output/ios/curl-universal"

echo "https://github.com/curl/curl/releases/download/${LIB_VERSION}/${LIB_NAME}.tar.gz"

# https://curl.haxx.se/download/${LIB_NAME}.tar.gz
# https://github.com/curl/curl/releases/download/curl-7_69_0/curl-7.69.0.tar.gz
# https://github.com/curl/curl/releases/download/curl-7_68_0/curl-7.68.0.tar.gz
DEVELOPER=$(xcode-select -print-path)
SDK_VERSION=$(xcrun -sdk iphoneos --show-sdk-version)
rm -rf "${LIB_DEST_DIR}" "${LIB_NAME}"
[ -f "${LIB_NAME}.tar.gz" ] || curl -LO https://github.com/curl/curl/releases/download/${LIB_VERSION}/${LIB_NAME}.tar.gz >${LIB_NAME}.tar.gz

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

    PREFIX_DIR="${pwd_path}/../output/ios/curl-${ARCH}"
    if [ -d "${PREFIX_DIR}" ]; then
        rm -fr "${PREFIX_DIR}"
    fi
    mkdir -p "${PREFIX_DIR}"

    OUTPUT_ROOT=${TOOLS_ROOT}/../output/ios/curl-${ARCH}
    mkdir -p ${OUTPUT_ROOT}/log

    set_android_cpu_feature "nghttp2" "${ARCH}" "${IOS_MIN_TARGET}" "${CROSS_TOP}/SDKs/${CROSS_SDK}"

    OPENSSL_OUT_DIR="${pwd_path}/../output/ios/openssl-${ARCH}"
    NGHTTP2_OUT_DIR="${pwd_path}/../output/ios/nghttp2-${ARCH}"

    export LDFLAGS="${LDFLAGS} -L${OPENSSL_OUT_DIR}/lib -L${NGHTTP2_OUT_DIR}/lib"

    ios_printf_global_params "$ARCH" "$SDK" "$PLATFORM" "$PREFIX_DIR" "$OUTPUT_ROOT"

    if [[ "${ARCH}" == "x86_64" ]]; then

        ./Configure --host=$(ios_get_build_host "$ARCH") --prefix="${PREFIX_DIR}" --disable-shared --enable-static --enable-ipv6 --without-libidn2 --with-ssl=${OPENSSL_OUT_DIR} --with-nghttp2=${NGHTTP2_OUT_DIR} >"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1

    elif [[ "${ARCH}" == "armv7" ]]; then

        ./Configure --host=$(ios_get_build_host "$ARCH") --prefix="${PREFIX_DIR}" --disable-shared --enable-static --enable-ipv6 --with-ssl=${OPENSSL_OUT_DIR} --with-nghttp2=${NGHTTP2_OUT_DIR} >"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1

    elif [[ "${ARCH}" == "arm64" ]]; then

        ./Configure --host=$(ios_get_build_host "$ARCH") --prefix="${PREFIX_DIR}" --disable-shared --enable-static --enable-ipv6 --with-ssl=${OPENSSL_OUT_DIR} --with-nghttp2=${NGHTTP2_OUT_DIR} >"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1
    
    elif [[ "${ARCH}" == "arm64e" ]]; then

        ./Configure --host=$(ios_get_build_host "$ARCH") --prefix="${PREFIX_DIR}" --disable-shared --enable-static --enable-ipv6 --with-ssl=${OPENSSL_OUT_DIR} --with-nghttp2=${NGHTTP2_OUT_DIR} >"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1

    else
        log_error_print "not support" && exit 1
    fi

    log_info_print "make $ARCH start..."

    make clean >>"${OUTPUT_ROOT}/log/${ARCH}.log"
    if make -j8 >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1; then
        make install >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1
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
    LIB_PATHS=("${ARCHS[@]/#/${pwd_path}/../output/ios/curl-}")
    LIB_PATHS=("${LIB_PATHS[@]/%//lib/${LIB_SRC}}")
    lipo ${LIB_PATHS[@]} -create -output "${LIB_DST}"
}
mkdir -p "${LIB_DEST_DIR}"
lipo_library "libcurl.a" "${LIB_DEST_DIR}/libcurl-universal.a"

log_info_print "${PLATFORM_TYPE} ${LIB_NAME} end..."
