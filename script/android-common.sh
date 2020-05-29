#!/bin/sh

source $(cd -P "$(dirname "$0")" && pwd)/_common.sh

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

echo "###############################################################################" >/dev/null
echo "#### Global Variable Partition                                            #####" >/dev/null
echo "###############################################################################" >/dev/null

export COMMON_PLATFORM_TYPE="Android"
export ANDROID_ARCHS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
export ANDROID_TRIPLES=("arm-linux-androideabi" "aarch64-linux-android" "i686-linux-android" "x86_64-linux-android")
export ANDROID_API=23

# for test
# ANDROID_ARCHS=("x86_64")
# ANDROID_TRIPLES=("x86_64-linux-android")
# ANDROID_API=23

echo "###############################################################################" >/dev/null
echo "#### Function Partition                                                   #####" >/dev/null
echo "###############################################################################" >/dev/null

function android_get_toolchain() {
  HOST_OS=$(uname -s)
  case ${HOST_OS} in
  Darwin) HOST_OS=darwin ;;
  Linux) HOST_OS=linux ;;
  FreeBsd) HOST_OS=freebsd ;;
  CYGWIN* | *_NT-*) HOST_OS=cygwin ;;
  esac

  HOST_ARCH=$(uname -m)
  case ${HOST_ARCH} in
  i?86) HOST_ARCH=x86 ;;
  x86_64 | amd64) HOST_ARCH=x86_64 ;;
  esac

  echo "${HOST_OS}-${HOST_ARCH}"
}

function android_get_arch() {
  local common_arch=$1
  case ${common_arch} in
  arm)
    echo "arm-v7a"
    ;;
  arm64)
    echo "arm64-v8a"
    ;;
  x86)
    echo "x86"
    ;;
  x86_64)
    echo "x86-64"
    ;;
  esac
}

function android_get_target_build() {
  local arch=$1
  case ${arch} in
  arm-v7a)
    echo "arm"
    ;;
  arm64-v8a)
    echo "arm64"
    ;;
  x86)
    echo "x86"
    ;;
  x86-64)
    echo "x86_64"
    ;;
  esac
}

function android_get_build_host_internal() {
  local arch=$1
  case ${arch} in
  arm-v7a | arm-v7a-neon)
    echo "arm-linux-androideabi"
    ;;
  arm64-v8a)
    echo "aarch64-linux-android"
    ;;
  x86)
    echo "i686-linux-android"
    ;;
  x86-64)
    echo "x86_64-linux-android"
    ;;
  esac
}

function android_get_build_host() {
  local arch=$(android_get_arch $1)
  android_get_build_host_internal $arch
}

function android_get_clang_target_host() {
  local arch=$1
  local api=$2
  case ${arch} in
  arm-v7a | arm-v7a-neon)
    echo "armv7a-linux-androideabi${api}"
    ;;
  arm64-v8a)
    echo "aarch64-linux-android${api}"
    ;;
  x86)
    echo "i686-linux-android${api}"
    ;;
  x86-64)
    echo "x86_64-linux-android${api}"
    ;;
  esac
}

function android_set_toolchain_bin() {
  export PATH=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/$(android_get_toolchain)/bin:$PATH
  echo PATH=$PATH
}

function android_set_toolchain() {
  local name=$1
  local arch=$(android_get_arch $2)
  local api=$3
  local build_host=$(android_get_build_host_internal "$arch")
  local clang_target_host=$(android_get_clang_target_host "$arch" "$api")

  export AR=${build_host}-ar
  export CC=${clang_target_host}-clang
  export CXX=${clang_target_host}-clang++
  export AS=${build_host}-as
  export LD=${build_host}-ld
  export RANLIB=${build_host}-ranlib
  export STRIP=${build_host}-strip
}

function android_get_common_includes() {
  local toolchain=$(android_get_toolchain)
  echo "-I${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${toolchain}/sysroot/usr/include -I${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${toolchain}/sysroot/usr/local/include"
}
function android_get_common_linked_libraries() {
  local api=$1
  local arch=$2
  local toolchain=$(android_get_toolchain)
  local build_host=$(android_get_build_host_internal "$arch")
  echo "-L${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${toolchain}/${build_host}/lib -L${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${toolchain}/sysroot/usr/lib/${build_host}/${api} -L${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${toolchain}/lib"
}

function android_set_cpu_feature() {
  local name=$1
  local arch=$(android_get_arch $2)
  local api=$3
  case ${arch} in
  arm-v7a | arm-v7a-neon)
    export CFLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -Wno-unused-function -fno-integrated-as -fstrict-aliasing -fPIC -DANDROID -D__ANDROID_API__=${api} -Os -ffunction-sections -fdata-sections $(android_get_common_includes)"
    export CXXFLAGS="-std=c++14 -Os -ffunction-sections -fdata-sections"
    export LDFLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -Wl,--fix-cortex-a8 -Wl,--gc-sections -Os -ffunction-sections -fdata-sections $(android_get_common_linked_libraries ${api} ${arch})"
    export CPPFLAGS=${CFLAGS}
    ;;
  arm64-v8a)
    export CFLAGS="-march=armv8-a -Wno-unused-function -fno-integrated-as -fstrict-aliasing -fPIC -DANDROID -D__ANDROID_API__=${api} -Os -ffunction-sections -fdata-sections $(android_get_common_includes)"
    export CXXFLAGS="-std=c++14 -Os -ffunction-sections -fdata-sections"
    export LDFLAGS="-march=armv8-a -Wl,--gc-sections -Os -ffunction-sections -fdata-sections $(android_get_common_linked_libraries ${api} ${arch})"
    export CPPFLAGS=${CFLAGS}
    ;;
  x86)
    export CFLAGS="-march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32 -Wno-unused-function -fno-integrated-as -fstrict-aliasing -fPIC -DANDROID -D__ANDROID_API__=${api} -Os -ffunction-sections -fdata-sections $(android_get_common_includes)"
    export CXXFLAGS="-std=c++14 -Os -ffunction-sections -fdata-sections"
    export LDFLAGS="-march=i686 -Wl,--gc-sections -Os -ffunction-sections -fdata-sections $(android_get_common_linked_libraries ${api} ${arch})"
    export CPPFLAGS=${CFLAGS}
    ;;
  x86-64)
    export CFLAGS="-march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel -Wno-unused-function -fno-integrated-as -fstrict-aliasing -fPIC -DANDROID -D__ANDROID_API__=${api} -Os -ffunction-sections -fdata-sections $(android_get_common_includes)"
    export CXXFLAGS="-std=c++14 -Os -ffunction-sections -fdata-sections"
    export LDFLAGS="-march=x86-64 -Wl,--gc-sections -Os -ffunction-sections -fdata-sections $(android_get_common_linked_libraries ${api} ${arch})"
    export CPPFLAGS=${CFLAGS}
    ;;
  esac
}

function android_printf_variable() {
  log_var_print "ANDROID_ARCHS =  ${ANDROID_ARCHS[@]}"
  log_var_print "ANDROID_TRIPLES = ${ANDROID_TRIPLES[@]}"
  log_var_print "ANDROID_API =    $ANDROID_API"
}

function android_printf_arch_variable() {
  log_var_print "AR =             $AR"
  log_var_print "CC =             $CC"
  log_var_print "CXX =            $CXX"
  log_var_print "AS =             $AS"
  log_var_print "LD =             $LD"
  log_var_print "RANLIB =         $RANLIB"
  log_var_print "STRIP =          $STRIP"
  log_var_print "CFLAGS =         $CFLAGS"
  log_var_print "CXXFLAGS =       $CXXFLAGS"
  log_var_print "LDFLAGS =        $LDFLAGS"
  log_var_print "CPPFLAGS =       $CPPFLAGS"
}

function android_help() {
  common_help
}

function android_get_shell_script_path() {
  echo "${COMMON_SCRIPT_DIR}/$(util_toupper $COMMON_PLATFORM_TYPE)-${COMMON_LIBRARY_NAME}.sh"
}

echo "###############################################################################" >/dev/null
echo "#### Flow Function Partition                                              #####" >/dev/null
echo "###############################################################################" >/dev/null

function android_pre_tool_check() {
  local library_id=$1
  local pre_tool_check="android_${COMMON_LIBRARY_NAME}_pre_tool_check"
  common_pre_tool_check $library_id
  eval ${pre_tool_check} $library_id
}

function android_pre_download_zip() {
  local library_id=$1
  local pre_download_zip="android_${COMMON_LIBRARY_NAME}_pre_download_zip"
  common_pre_download_zip $library_id
  eval ${pre_download_zip} $library_id
}

function android_build_unzip() {
  local library_id=$1
  local build_unzip="android_${COMMON_LIBRARY_NAME}_build_unzip"
  common_build_unzip $library_id
  eval ${build_unzip} $library_id
}

function android_build_config() {
  local library_id=$1
  local build_config="android_${COMMON_LIBRARY_NAME}_build_config"
  common_build_config $library_id
  eval ${build_config} $library_id
}

function android_buid_make() {
  local library_id=$1
  local buid_make="android_${COMMON_LIBRARY_NAME}_buid_make"
  common_buid_make $library_id
  eval ${buid_make} $library_id
}

function android_archive() {
  local library_id=$1
  local archive="android_${COMMON_LIBRARY_NAME}_archive"
  common_archive $library_id
  eval ${archive} $library_id
}
