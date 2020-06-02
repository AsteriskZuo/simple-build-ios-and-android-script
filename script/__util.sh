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

function util_init_log() {
    if test -t 1 && which tput >/dev/null 2>&1; then
        ncolors=$(tput colors)
        if test -n "$ncolors" && test $ncolors -ge 8; then
            bold_color=$(tput bold)
            warn_color=$(tput setaf 3)
            error_color=$(tput setaf 1)
            reset_color=$(tput sgr0)
        fi
        # 72 used instead of 80 since that's the default of pr
        ncols=$(tput cols)
    fi
    : ${ncols:=72}
}

function util_die() {
    echo "$error_color$bold_color$@$reset_color" && exit 1
}

function util_debug() {
    PS4='+line:${LINENO} '
    set -x
}

function util_get_cpu_count() {
    if [ "$(uname)" == "Darwin" ]; then
        echo $(sysctl -n hw.physicalcpu)
    else
        echo $(nproc)
    fi
}

function util_get_mac_version() {
    local var=$(sw_vers | grep ProductVersion)
    echo "${var#*:}"
}

function util_print_current_datetime() {
    echo $(date +%Y-%m-%d\ %H:%M:%S)
}

function util_get_current_datetime() {
    local lv_var=$1
    eval $lv_var='$(date +%Y-%m-%d\ %H:%M:%S)'
}

function util_dir_is_empty() {
    local lv_dir=$1
    local lv_result=$2
    local lv_file_list=($(ls $lv_dir))
    if [ 0 -lt ${#lv_file_list[@]} ]; then
        eval $lv_result="no"
    else
        eval $lv_result="yes"
    fi
}

function util_append() {
    local var=$1
    shift
    eval "$var=\"\$$var$*\""
}

function util_prepend() {
    local var=$1
    shift
    eval "$var=\"$*\$$var\""
}

function util_reverse() {
    eval '
        reverse_out=
        for v in $'$1'; do
            reverse_out="$v $reverse_out"
        done
        '$1'=$reverse_out
    '
}

function util_get_dir_from_filename() {
    local var=$1
    echo "${var%/*}"
}

function util_get_script_dir() {
    echo "$(cd -P "$(dirname "$0")" && pwd)"
}

function util_get_input_dir() {
    local var=$(util_get_script_dir)
    local ret=$(util_get_dir_from_filename "$var")
    util_append ret "/input"
    echo "$ret"
}

function util_get_output_dir() {
    local var=$(util_get_script_dir)
    local ret=$(util_get_dir_from_filename "$var")
    util_append ret "/output"
    echo "$ret"
}

function util_is_in() {
    local value=$1
    shift
    for var in $*; do
        [ $var = $value ] && return 0
    done
    return 1
}

function util_get_list_item() {
    local index=$1 # from 1 start
    local i=1
    shift
    for var in $*; do
        if [ "$i" = "$index" ]; then
            echo "$var" && return 0
        fi
        ((i++))
    done
    return 1
}

function util_toupper() {
    echo "$@" | tr abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ
}

function util_tolower() {
    echo "$@" | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz
}

function util_c_escape() {
    echo "$*" | sed 's/["\\]/\\\0/g'
}

function util_sh_quote() {
    local v=$(echo "$1" | sed "s/'/'\\\\''/g")
    test "x$v" = "x${v#*[!A-Za-z0-9_/.+-]}" || v="'$v'"
    echo "$v"
}

function util_cleanws() {
    echo "$@" | sed 's/^ *//;s/[[:space:]][[:space:]]*/ /g;s/ *$//'
}

function util_remove_substr() {
    local substr=$1
    shift
    local str=$*
    echo "$str" | sed "s/$substr//g"
}

function util_filter() {
    local pat=$1
    shift
    for v; do
        eval "case '$v' in $pat) printf '%s ' '$v' ;; esac"
    done
}

function util_filter_out() {
    local pat=$1
    shift
    for v; do
        eval "case '$v' in $pat) ;; *) printf '%s ' '$v' ;; esac"
    done
}

function util_create_dir() {
    mkdir -p "$1"
}

function util_remove_dir() {
    rm -rf "$1"
}

function util_download_file() {
    local url=$1
    local zip=$2
    local ret="yes"
    if [ ! -r ${zip} ]; then
        curl -SL "$url" -o "$zip" || ret="no"
        if [ "no" = $ret ]; then
            rm -rf "$zip" && util_die "download zip ${zip} fail."
        fi
    fi
}

function util_unzip() {
    local zip=$1
    local dir=$2
    local file=$3
    if [ -d "${dir}/${file}" ]; then
        rm -rf "${dir}/${file}"
    fi
    local ret="yes"
    tar -x -C "$dir" -f "$zip" || ret="no"
    if [ "no" = ret ]; then
        rm -rf "$zip" && util_die "unzip ${zip} fail."
    fi
}

function util_load_script() {
    source $1 || util_die "load script $1 fail."
}

util_init_log
