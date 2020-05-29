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

function android_nghttp2_pre_tool_check() {
  echo "$COMMON_LIBRARY_NAME"
}

function android_nghttp2_pre_download_zip() {
  local library_id=$1
  local url_file_name=${COMMON_DOWNLOAD_ADRESS##*/}
  local saved_zip_path="${COMMON_INPUT_DIR}/${COMMON_LIBRARY_NAME}/${url_file_name}"
  if [ ! -r ${saved_zip_path} ]; then
    curl -SL "$COMMON_DOWNLOAD_ADRESS" -o "$saved_zip_path" || ret="no"
    if [ "no" = $ret ]; then
      rm -rf "$saved_zip_path" && exit 1
    fi
  fi
}

function android_nghttp2_build_unzip() {
  local library_id=$1
  local url_file_name=${COMMON_DOWNLOAD_ADRESS##*/}
  local saved_zip_path="${COMMON_INPUT_DIR}/${COMMON_LIBRARY_NAME}/${url_file_name}"
  local unzip_output_dir=${url_file_name%.tar.gz}
  local unzip_src=$4
  if [ -d "${unzip_output_dir}" ]; then
    rm -rf "${unzip_output_dir}"
  fi
  local ret="yes"
  tar -x -C "$unzip_output_dir" -f "$saved_zip_path" || ret="no"
  if [ "no" = ret ]; then
    rm -rf "$saved_zip_path" && exit 1
  fi
}

function android_nghttp2_build_config() {
  local library_name=$1
  local arch=$2
  common_build_config $library_name $arch
}

function android_nghttp2_buid_make() {
  local library_name=$1
  common_buid_make $library_name
}

function android_nghttp2_archive() {
  local library_name=$1
  common_archive $library_name
}























set -u

echo "nghttp2 load success"

export LIB_VERSION="v1.40.0"
export LIB_NAME="nghttp2-1.40.0"
export DOWNLOAD_ADRESS="https://github.com/nghttp2/nghttp2/releases/download/${LIB_VERSION}/${LIB_NAME}.tar.gz"

log_info_print "${PLATFORM_TYPE} ${LIB_NAME} build start..."
log_info_print "${PLATFORM_TYPE} ${LIB_NAME} download start..."
util_download_file "$DOWNLOAD_ADRESS" "${INPUT_DIR}/${LIB_NAME}.tar.gz"
log_info_print "${PLATFORM_TYPE} ${LIB_NAME} download end..."

android_set_toolchain_bin

function configure_make() {

    ARCH=$1
    ABI=$2
    ABI_TRIPLE=$3

    log_info_print "${PLATFORM_TYPE} ${LIB_NAME} ${ABI} configure start..."

    util_unzip "${INPUT_DIR}/${LIB_NAME}.tar.gz" "$INPUT_DIR" "$LIB_NAME"

    pushd .
    cd "${INPUT_DIR}/${LIB_NAME}" || exit 1

    PREFIX_DIR="${OUTPUT_DIR}/${PLATFORM_TYPE}-${LIB_NAME}-${ABI}"
    util_remove_dir "$PREFIX_DIR"
    util_create_dir "${PREFIX_DIR}/log"

    android_set_toolchain "nghttp2" "${ARCH}" "${ANDROID_API}"
    android_set_cpu_feature "nghttp2" "${ARCH}" "${ANDROID_API}"

    export ANDROID_NDK_HOME=${ANDROID_NDK_ROOT}
    echo ANDROID_NDK_HOME=${ANDROID_NDK_HOME}

    android_printf_global_params "$ARCH" "$ABI" "$ABI_TRIPLE" "${INPUT_DIR}/${LIB_NAME}" "$PREFIX_DIR"

    if [[ "${ARCH}" == "x86_64" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") --prefix="${PREFIX_DIR}" --disable-app --disable-threads --enable-lib-only >"${PREFIX_DIR}/log/output.log" 2>&1

    elif [[ "${ARCH}" == "x86" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") --prefix="${PREFIX_DIR}" --disable-app --disable-threads --enable-lib-only >"${PREFIX_DIR}/log/output.log" 2>&1

    elif [[ "${ARCH}" == "arm" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") --prefix="${PREFIX_DIR}" --disable-app --disable-threads --enable-lib-only >"${PREFIX_DIR}/log/output.log" 2>&1

    elif [[ "${ARCH}" == "arm64" ]]; then

        # --disable-lib-only need xml2 supc++ stdc++14
        ./configure --host=$(android_get_build_host "${ARCH}") --prefix="${PREFIX_DIR}" --disable-app --disable-threads --enable-lib-only >"${PREFIX_DIR}/log/output.log" 2>&1

    else
        log_error_print "not support" && exit 1
    fi

    log_info_print "${PLATFORM_TYPE} ${LIB_NAME} ${ABI} configure end..."
    log_info_print "${PLATFORM_TYPE} ${LIB_NAME} ${ABI} make start..."

    make clean >>"${PREFIX_DIR}/log/output.log"
    if make -j$(util_get_cpu_count) >>"${PREFIX_DIR}/log/output.log" 2>&1; then
        make install >>"${PREFIX_DIR}/log/output.log" 2>&1
    fi

    log_info_print "${PLATFORM_TYPE} ${LIB_NAME} ${ABI} make end..."

    popd
}

for ((i = 0; i < ${#ARCHS[@]}; i++)); do
    if [[ $# -eq 0 || "$1" == "${ARCHS[i]}" ]]; then
        configure_make "${ARCHS[i]}" "${ABIS[i]}" "${ABI_TRIPLES[i]}"
    fi
done

log_info_print "${PLATFORM_TYPE} ${LIB_NAME} build end..."
