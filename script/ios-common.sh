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

export COMMON_PLATFORM_TYPE="ios"
export IOS_ARCHS=("armv7" "arm64" "arm64e" "x86-64")
export IOS_TRIPLES=("armv7-ios-darwin" "aarch64-ios-darwin" "aarch64-ios-darwin" "x86_64-ios-darwin")
export IOS_API=8.0
export IOS_SYSROOT=""

# for test
# IOS_ARCHS=("x86-64")
# IOS_TRIPLES=("x86_64-ios-darwin")
# IOS_API=8.0

echo "###############################################################################" >/dev/null
echo "#### Function Partition                                                   #####" >/dev/null
echo "###############################################################################" >/dev/null

function ios_get_sdk_name() {
    local arch=$1
    case ${arch} in
    armv7 | armv7s | arm64 | arm64e)
        echo "iphoneos"
        ;;
    x86 | x86-64)
        echo "iphonesimulator"
        ;;
    esac
}

function ios_get_sdk_path() {
    local arch=$1
    echo "$(xcrun --sdk $(ios_get_sdk_name $arch) --show-sdk-path)"
}

function ios_set_sysroot() {
    local arch=$1
    IOS_SYSROOT="$(ios_get_sdk_path $arch)"
}

function ios_get_build_host() {
    local arch=$1
    case ${arch} in
    armv7)
        echo "armv7-ios-darwin"
        ;;
    arm64)
        echo "aarch64-ios-darwin"
        ;;
    arm64e)
        echo "aarch64-ios-darwin"
        ;;
    x86)
        echo "x86-ios-darwin"
        ;;
    x86-64)
        echo "x86_64-ios-darwin"
        ;;
    esac
}

function ios_set_cpu_feature() {
    local name=$1
    local arch=$2
    local api=$3
    local sysroot=$4
    case ${arch} in
    armv7)
        export CC="xcrun -sdk iphoneos clang -arch armv7"
        export CXX="xcrun -sdk iphoneos clang++ -arch armv7"
        export CFLAGS="-arch armv7 -target armv7-ios-darwin -march=armv7 -mcpu=cortex-a8 -mfpu=neon -mfloat-abi=softfp -Wno-unused-function -fstrict-aliasing -Oz -Wno-ignored-optimization-argument -DIOS -isysroot ${sysroot} -fembed-bitcode -miphoneos-version-min=${api} -I${sysroot}/usr/include"
        export LDFLAGS="-arch armv7 -target armv7-ios-darwin -march=armv7 -isysroot ${sysroot} -fembed-bitcode -L${sysroot}/usr/lib "
        export CXXFLAGS="-std=c++14 -arch armv7 -target armv7-ios-darwin -march=armv7 -mcpu=cortex-a8 -mfpu=neon -mfloat-abi=softfp -fstrict-aliasing -fembed-bitcode -DIOS -miphoneos-version-min=${api} -I${sysroot}/usr/include"
        ;;
    arm64)
        export CC="xcrun -sdk iphoneos clang -arch arm64"
        export CXX="xcrun -sdk iphoneos clang++ -arch arm64"
        export CFLAGS="-arch arm64 -target aarch64-ios-darwin -march=armv8 -mcpu=generic -Wno-unused-function -fstrict-aliasing -Oz -Wno-ignored-optimization-argument -DIOS -isysroot ${sysroot} -fembed-bitcode -miphoneos-version-min=${api} -I${sysroot}/usr/include"
        export LDFLAGS="-arch arm64 -target aarch64-ios-darwin -march=armv8 -isysroot ${sysroot} -fembed-bitcode -L${sysroot}/usr/lib "
        export CXXFLAGS="-std=c++14 -arch arm64 -target aarch64-ios-darwin -march=armv8 -mcpu=generic -fstrict-aliasing -fembed-bitcode -DIOS -miphoneos-version-min=${api} -I${sysroot}/usr/include"
        ;;
    arm64e)
        # -march=armv8.3 ???
        export CC="xcrun -sdk iphoneos clang -arch arm64e"
        export CXX="xcrun -sdk iphoneos clang++ -arch arm64e"
        export CFLAGS="-arch arm64e -target aarch64-ios-darwin -Wno-unused-function -fstrict-aliasing -DIOS -isysroot ${sysroot} -fembed-bitcode -miphoneos-version-min=${api} -I${sysroot}/usr/include"
        export LDFLAGS="-arch arm64e -target aarch64-ios-darwin -isysroot ${sysroot} -fembed-bitcode -L${sysroot}/usr/lib "
        export CXXFLAGS="-std=c++14 -arch arm64e -target aarch64-ios-darwin -fstrict-aliasing -fembed-bitcode -DIOS -miphoneos-version-min=${api} -I${sysroot}/usr/include"
        ;;
    x86)
        export CC="xcrun -sdk iphonesimulator clang -arch x86"
        export CXX="xcrun -sdk iphonesimulator clang++ -arch x86"
        export CFLAGS="-arch x86 -target x86-ios-darwin -march=i386 -msse4.2 -mpopcnt -m64 -mtune=intel -Wno-unused-function -fstrict-aliasing -O2 -Wno-ignored-optimization-argument -DIOS -isysroot ${sysroot} -mios-simulator-version-min=${api} -I${sysroot}/usr/include"
        export LDFLAGS="-arch x86 -target x86-ios-darwin -march=i386 -isysroot ${sysroot} -L${sysroot}/usr/lib "
        export CXXFLAGS="-std=c++14 -arch x86 -target x86-ios-darwin -march=i386 -msse4.2 -mpopcnt -m64 -mtune=intel -fstrict-aliasing -DIOS -mios-simulator-version-min=${api} -I${sysroot}/usr/include"
        ;;
    x86-64)
        export CC="xcrun -sdk iphonesimulator clang -arch x86_64"
        export CXX="xcrun -sdk iphonesimulator clang++ -arch x86_64"
        export CFLAGS="-arch x86_64 -target x86_64-ios-darwin -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel -Wno-unused-function -fstrict-aliasing -O2 -Wno-ignored-optimization-argument -DIOS -isysroot ${sysroot} -mios-simulator-version-min=${api} -I${sysroot}/usr/include"
        export LDFLAGS="-arch x86_64 -target x86_64-ios-darwin -march=x86-64 -isysroot ${sysroot} -L${sysroot}/usr/lib "
        export CXXFLAGS="-std=c++14 -arch x86_64 -target x86_64-ios-darwin -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel -fstrict-aliasing -DIOS -mios-simulator-version-min=${api} -I${sysroot}/usr/include"
        ;;
    *)
        common_die "not support $arch"
        ;;
    esac
}

function ios_printf_variable() {
    log_var_print "IOS_ARCHS =    ${IOS_ARCHS[@]}"
    log_var_print "IOS_TRIPLES =  ${IOS_TRIPLES[@]}"
    log_var_print "IOS_API =      $IOS_API"
}

function ios_printf_arch_variable() {
    log_var_print "IOS_SYSROOT =    $IOS_SYSROOT"
    log_var_print "CC =             $CC"
    log_var_print "CXX =            $CXX"
    log_var_print "CFLAGS =         $CFLAGS"
    log_var_print "CXXFLAGS =       $CXXFLAGS"
    log_var_print "LDFLAGS =        $LDFLAGS"
}

function ios_help() {
    common_help
}

function ios_get_shell_script_path() {
    echo "${COMMON_SCRIPT_DIR}/$(util_tolower $COMMON_PLATFORM_TYPE)-${COMMON_LIBRARY_NAME}.sh"
}

echo "###############################################################################" >/dev/null
echo "#### Flow Function Partition                                              #####" >/dev/null
echo "###############################################################################" >/dev/null

function ios_pre_tool_check() {
    log_info_print "ios_pre_tool_check $1 start..."
    local library_id=$1
    local pre_tool_check="ios_${COMMON_LIBRARY_NAME}_pre_tool_check"
    common_pre_tool_check "$library_id"
    eval ${pre_tool_check} "$library_id"
    log_info_print "ios_pre_tool_check $1 end..."
}

function ios_pre_download_zip() {
    log_info_print "ios_pre_download_zip $1 start..."
    local library_id=$1
    local pre_download_zip="ios_${COMMON_LIBRARY_NAME}_pre_download_zip"
    common_pre_download_zip "$library_id"
    eval ${pre_download_zip} "$library_id"
    log_info_print "ios_pre_download_zip $1 end..."
}

function ios_build_unzip() {
    log_info_print "ios_build_unzip $1 $2 start..."
    local library_id=$1
    local library_arch=$2
    local build_unzip="ios_${COMMON_LIBRARY_NAME}_build_unzip"
    common_build_unzip "$library_id"
    eval ${build_unzip} "$library_id"
    log_info_print "ios_build_unzip $1 $2 end..."
}

function ios_build_config_make() {
    log_info_print "ios_build_config_make $1 $2 start..."
    local library_id=$1
    local library_arch=$2
    local build_config_make="ios_${COMMON_LIBRARY_NAME}_build_config_make"
    common_build_config_make "$library_id" "$library_arch"
    eval ${build_config_make} "$library_id" "$library_arch"
    log_info_print "ios_build_config_make $1 $2 end..."
}

function ios_archive() {
    log_info_print "ios_archive $1 start..."
    local library_id=$1
    local archive="ios_${COMMON_LIBRARY_NAME}_archive"
    common_archive "$library_id"
    eval ${archive} "$library_id"
    log_info_print "ios_archive $1 end..."
}
