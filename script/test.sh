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
echo "# This is test script.                                                        #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# GNU bash (version 3.2.57 test success on macOS)                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/openssl_for_ios_and_android             #" >/dev/null
echo "###############################################################################" >/dev/null

# 获取当前执行脚本所在绝对目录
# echo "$(cd -P "$(dirname "$0")" && pwd)"
# echo "$(cd -P "$(dirname "$0")"; pwd)"

# 字符串常规操作
# ref: http://c.biancheng.net/view/1120.html
# ${string: start :length}	从 string 字符串的左边第 start 个字符开始，向右截取 length 个字符。
# ${string: start}	从 string 字符串的左边第 start 个字符开始截取，直到最后。
# ${string: 0-start :length}	从 string 字符串的右边第 start 个字符开始，向右截取 length 个字符。
# ${string: 0-start}	从 string 字符串的右边第 start 个字符开始截取，直到最后。
# ${string#*chars}	从 string 字符串第一次出现 *chars 的位置开始，截取 *chars 右边的所有字符。
# ${string##*chars}	从 string 字符串最后一次出现 *chars 的位置开始，截取 *chars 右边的所有字符。
# ${string%*chars}	从 string 字符串第一次出现 *chars 的位置开始，截取 *chars 左边的所有字符。
# ${string%%*chars}	从 string 字符串最后一次出现 *chars 的位置开始，截取 *chars 左边的所有字符
# url="http://c.biancheng.net/view/1120.html"
# echo $(util_get_dir_from_filename "$url")

# 获取输入和输出绝对目录
# util_get_input_dir
# util_get_output_dir

# list=("1" "2" "3" "4")
# echo $v
# list="
# 1
# 2
# 3
# 4
# "
# name="2"
# util_filter "$list

# 测试遍历数组
# COMPONENT_LIST="
# 1wer
# 2wer
# 3sdfsdf
# 4rwer
# "
# for n in $COMPONENT_LIST; do
#     echo "n=$n"
# done
# ret=$(util_get_list_item 3 $COMPONENT_LIST)
# echo "ret=$ret"
# common_get_library_name_from_id 4

# 测试间接调用方法
# function func_name()
# {
#     echo $1
# }
# var="func_name"
# eval $var "hahah"
# COMMON_DOWNLOAD_ADRESS="https://github.com/protocolbuffers/protobuf/releases/download/v3.12.2/protobuf-all-3.12.2.tar.gz"
# url_file_name=${COMMON_DOWNLOAD_ADRESS##*/}
# unzip_output_dir=${url_file_name%.tar.gz}
# echo "url_file_name=$url_file_name"
# echo "unzip_output_dir=$unzip_output_dir"

# 测试逻辑运算符
# COMPONENT_LIST="
# 1wer
# 2wer
# 3sdfsdf
# 4rwer
# "
# ITEM="1234"
# function die() {
#     echo "error"
#     exit 1
# }
# util_is_in "$ITEM" "$COMPONENT_LIST" || common_die "error1"
# echo "lalala"
# util_is_in "$ITEM" "$COMPONENT_LIST" || common_die 'sdfsdf ${COMPONENT_LIST}'
# echo "lskdjfksd"

# 测试 log_info_print
# log_info_print "123"
# var="1234"
# log_info_print "12 ${var}"
# set -u
# function test_param() {
#     local ssss=$1
#     echo "sdfe" >/dev/null
# }
# test_param "sdf"

# PS4='Line ${LINENO}: '
# set -x
# function sdfsdff() {
#     echo "haha"
# }
# echo "sssdf"

# 测试调试行数
# PS4='[line:${LINENO}]'
# set -x
# echo sdfsd
# function test () {
#     echo "hjss"
# }
# test