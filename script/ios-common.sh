#!/bin/sh

source ./_common.sh

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

export PLATFORM_TYPE="iOS"
export IOS_MIN_TARGET="8.0"
export ARCHS=("armv7" "arm64" "arm64e" "x86_64")
export SDKS=("iphoneos" "iphoneos" "iphoneos" "iphonesimulator")
export PLATFORMS=("iPhoneOS" "iPhoneOS" "iphoneos" "iPhoneSimulator")

# for test !!!
# export ARCHS=("armv7")
# export SDKS=("iphoneos")
# export PLATFORMS=("iPhoneOS")

function get_android_arch() {
    local common_arch=$1
    case ${common_arch} in
    armv7)
        echo "armv7"
        ;;
    arm64)
        echo "arm64"
        ;;
    arm64e)
        echo "arm64e"
        ;;
    x86)
        echo "x86"
        ;;
    x86_64)
        echo "x86-64"
        ;;
    esac
}

function ios_get_build_host() {
    local arch=$(get_android_arch $1)
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

function set_android_cpu_feature() {
    local name=$1
    local arch=$(get_android_arch $2)
    local ios_min_target=$3
    local sysroot=$4
    case ${arch} in
    armv7)
        export CC="xcrun -sdk iphoneos clang -arch armv7"
        export CXX="xcrun -sdk iphoneos clang++ -arch armv7"
        export CFLAGS="-arch armv7 -target armv7-ios-darwin -march=armv7 -mcpu=cortex-a8 -mfpu=neon -mfloat-abi=softfp -Wno-unused-function -fstrict-aliasing -Oz -Wno-ignored-optimization-argument -DIOS -isysroot ${sysroot} -fembed-bitcode -miphoneos-version-min=${ios_min_target} -I${sysroot}/usr/include"
        export LDFLAGS="-arch armv7 -target armv7-ios-darwin -march=armv7 -isysroot ${sysroot} -fembed-bitcode -L${sysroot}/usr/lib "
        export CXXFLAGS="-std=c++14 -arch armv7 -target armv7-ios-darwin -march=armv7 -mcpu=cortex-a8 -mfpu=neon -mfloat-abi=softfp -fstrict-aliasing -fembed-bitcode -DIOS -miphoneos-version-min=${ios_min_target} -I${sysroot}/usr/include"
        ;;
    arm64)
        export CC="xcrun -sdk iphoneos clang -arch arm64"
        export CXX="xcrun -sdk iphoneos clang++ -arch arm64"
        export CFLAGS="-arch arm64 -target aarch64-ios-darwin -march=armv8 -mcpu=generic -Wno-unused-function -fstrict-aliasing -Oz -Wno-ignored-optimization-argument -DIOS -isysroot ${sysroot} -fembed-bitcode -miphoneos-version-min=${ios_min_target} -I${sysroot}/usr/include"
        export LDFLAGS="-arch arm64 -target aarch64-ios-darwin -march=armv8 -isysroot ${sysroot} -fembed-bitcode -L${sysroot}/usr/lib "
        export CXXFLAGS="-std=c++14 -arch arm64 -target aarch64-ios-darwin -march=armv8 -mcpu=generic -fstrict-aliasing -fembed-bitcode -DIOS -miphoneos-version-min=${ios_min_target} -I${sysroot}/usr/include"
        ;;
    arm64e)
        # -march=armv8.3 ???
        export CC="xcrun -sdk iphoneos clang -arch arm64e"
        export CXX="xcrun -sdk iphoneos clang++ -arch arm64e"
        export CFLAGS="-arch arm64e -target aarch64-ios-darwin -Wno-unused-function -fstrict-aliasing -DIOS -isysroot ${sysroot} -fembed-bitcode -miphoneos-version-min=${ios_min_target} -I${sysroot}/usr/include"
        export LDFLAGS="-arch arm64e -target aarch64-ios-darwin -isysroot ${sysroot} -fembed-bitcode -L${sysroot}/usr/lib "
        export CXXFLAGS="-std=c++14 -arch arm64e -target aarch64-ios-darwin -fstrict-aliasing -fembed-bitcode -DIOS -miphoneos-version-min=${ios_min_target} -I${sysroot}/usr/include"
        ;;
    x86)
        export CC="xcrun -sdk iphonesimulator clang -arch x86"
        export CXX="xcrun -sdk iphonesimulator clang++ -arch x86"
        export CFLAGS="-arch x86 -target x86-ios-darwin -march=i386 -msse4.2 -mpopcnt -m64 -mtune=intel -Wno-unused-function -fstrict-aliasing -O2 -Wno-ignored-optimization-argument -DIOS -isysroot ${sysroot} -mios-simulator-version-min=${ios_min_target} -I${sysroot}/usr/include"
        export LDFLAGS="-arch x86 -target x86-ios-darwin -march=i386 -isysroot ${sysroot} -L${sysroot}/usr/lib "
        export CXXFLAGS="-std=c++14 -arch x86 -target x86-ios-darwin -march=i386 -msse4.2 -mpopcnt -m64 -mtune=intel -fstrict-aliasing -DIOS -mios-simulator-version-min=${ios_min_target} -I${sysroot}/usr/include"
        ;;
    x86-64)
        export CC="xcrun -sdk iphonesimulator clang -arch x86_64"
        export CXX="xcrun -sdk iphonesimulator clang++ -arch x86_64"
        export CFLAGS="-arch x86_64 -target x86_64-ios-darwin -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel -Wno-unused-function -fstrict-aliasing -O2 -Wno-ignored-optimization-argument -DIOS -isysroot ${sysroot} -mios-simulator-version-min=${ios_min_target} -I${sysroot}/usr/include"
        export LDFLAGS="-arch x86_64 -target x86_64-ios-darwin -march=x86-64 -isysroot ${sysroot} -L${sysroot}/usr/lib "
        export CXXFLAGS="-std=c++14 -arch x86_64 -target x86_64-ios-darwin -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel -fstrict-aliasing -DIOS -mios-simulator-version-min=${ios_min_target} -I${sysroot}/usr/include"
        ;;
    *)
        log_error_print "not support" && exit 1
        ;;
    esac
}

function ios_printf_global_params() {
    local arch=$1
    local type=$2
    local platform=$3
    local in_dir=$4
    local out_dir=$5
    echo -e "arch =           $arch"
    echo -e "type =           $type"
    echo -e "platform =       $platform"
    echo -e "PLATFORM_TYPE =  $PLATFORM_TYPE"
    echo -e "IOS_MIN_TARGET = $IOS_MIN_TARGET"
    echo -e "in_dir =         $in_dir"
    echo -e "out_dir =        $out_dir"
    echo -e "CC =             $CC"
    echo -e "CXX =            $CXX"
    echo -e "CFLAGS =         $CFLAGS"
    echo -e "CXXFLAGS =       $CXXFLAGS"
    echo -e "LDFLAGS =        $LDFLAGS"
}
