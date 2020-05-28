#!/bin/sh

source $(cd -P "$(dirname "$0")" && pwd)/__util.sh

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

echo "# 基本语法介绍:
# 符号含义:
# \\033[0m 关闭所有属性
# \\033[1m 设置高亮度
# \\033[4m 下划线
# \\033[5m 闪烁
# \\033[7m 反显
# \\033[8m 消隐
# \\033[30m 至 \\33[37m 设置前景色
# \\033[40m 至 \\33[47m 设置背景色
# \\033[nA 光标上移n行
# \\033[nB 光标下移n行
# \\033[nC 光标右移n行
# \\033[nD 光标左移n行
# \\033[y;xH设置光标位置
# \\033[2J 清屏
# \\033[K 清除从光标到行尾的内容
# \\033[s 保存光标位置
# \\033[u 恢复光标位置
# \\033[?25l 隐藏光标
# \\033[?25h 显示光标
# 字体颜色:30 - 39
# 30:黑
# 31:红
# 32:绿
# 33:黄
# 34:深蓝
# 35:紫色
# 36:天蓝
# 37:白色 
# 字体背景颜色:40 — 49
# 40:黑
# 41:深红
# 42:绿
# 43:黄色
# 44:蓝色
# 45:紫色
# 46:深绿
# 47:白色
" >/dev/null

echo "###############################################################################" >/dev/null
echo "#### Variable declarations partition                                      #####" >/dev/null
echo "###############################################################################" >/dev/null

LOG_VAR_BOLD="1"
LOG_VAR_UNDERLINE="4"
LOG_VAR_BLINK="5"
LOG_VAR_CONVERT="7"
LOG_VAR_HIDE="8"

#foreground color
LOG_VAR_FG_GREY="30"
LOG_VAR_FG_RED="31"
LOG_VAR_FG_GREEN="32"
LOG_VAR_FG_YELLOW="33"
LOG_VAR_FG_BLUE="34"
LOG_VAR_FG_VIOLET="35"
LOG_VAR_FG_SKY_BLUE="36"
LOG_VAR_FG_WHITE="37"

#background color
LOG_VAR_BG_BLACK="40"
LOG_VAR_BG_RED="41"
LOG_VAR_BG_GREEN="42"
LOG_VAR_BG_YELLOW="43"
LOG_VAR_BG_BLUE="44"
LOG_VAR_BG_VIOLET="45"
LOG_VAR_BG_SKYBLUE="46"
LOG_VAR_BG_WHITE="47"

echo "###############################################################################" >/dev/null
echo "#### Function implementation partition                                    #####" >/dev/null
echo "###############################################################################" >/dev/null

# log_xxx_print function is very easily replaced by echo command-line

function log_basic_print() {
    # background: ${1}
    # foreground: ${2}
    # sytle: ${3}
    # log content: ${4}
    echo "\\033[${1};${2};${3}m${@:4}\\033[0m"
}
function log_basic_print_without_bg() {
    # foreground: ${1}
    # sytle: ${2}
    # log content: ${3}
    echo "\\033[${1};${2}m${@:3}\\033[0m"
}
function log_head_print() {
    local FOREGROUND=$LOG_VAR_FG_YELLOW
    local FONT=$LOG_VAR_BLINK
    echo "\\033[${FOREGROUND};${FONT}m${@}\\033[0m"
}
function log_var_print() {
    local FOREGROUND=$LOG_VAR_FG_SKY_BLUE
    local FONT=$LOG_VAR_BLINK
    echo "  var \\033[${FOREGROUND};${FONT}m${@}\\033[0m"
}
function log_var_split_print() {
    # changed original content for space char
    # Multiple Spaces merge into one space.
    local FOREGROUND=$LOG_VAR_FG_SKY_BLUE
    local FONT=$LOG_VAR_BLINK
    local KEY=$(echo $@ | sed "s/\\=.*$//g")
    # VALUE=$(echo $@ | sed "s/^.*\\=//g")
    local VALUE=${@#*=}
    echo "  \\033[${FOREGROUND};${FONT}m${KEY} \\033[${LOG_VAR_FG_YELLOW}m= \\033[${FOREGROUND}m${VALUE}\\033[0m"
}
function log_debug_print() {
    # high | blue

    # changed original content
    # log_basic_print_without_bg ${LOG_VAR_FG_BLUE} ${LOG_VAR_BLINK} $@

    # not changed original content
    local FOREGROUND=$LOG_VAR_FG_BLUE
    local FONT=$LOG_VAR_BLINK
    local CURRENT_DATETIME
    util_get_current_datetime CURRENT_DATETIME
    echo "[$CURRENT_DATETIME] \\033[${FOREGROUND};${FONT}m${@}\\033[0m"
}
function log_info_print() {
    # high | green
    # log_basic_print_without_bg ${LOG_VAR_FG_GREEN} ${LOG_VAR_BLINK} $@
    local FOREGROUND=$LOG_VAR_FG_GREEN
    local FONT=$LOG_VAR_BLINK
    util_get_current_datetime CURRENT_DATETIME
    echo "[$CURRENT_DATETIME] \\033[${FOREGROUND};${FONT}m${@}\\033[0m"
}
function log_warning_print() {
    # high | bold | purple
    # log_basic_print_without_bg ${LOG_VAR_FG_VIOLET} ${LOG_VAR_BOLD} $@
    local FOREGROUND=$LOG_VAR_FG_VIOLET
    local FONT=$LOG_VAR_BOLD
    echo "\\033[${FOREGROUND};${FONT}m${@}\\033[0m"
}
function log_error_print() {
    # high | bold | red
    # log_basic_print_without_bg ${LOG_VAR_FG_RED} ${LOG_VAR_BOLD} $@
    local FOREGROUND=$LOG_VAR_FG_RED
    local FONT=$LOG_VAR_BOLD
    echo "\\033[${FOREGROUND};${FONT}m${@}\\033[0m"
    exit 1
}
function log_fatal_print() {
    # high | bold | red | blink
    # log_basic_print ${LOG_VAR_BG_GREEN} ${LOG_VAR_FG_RED} ${LOG_VAR_BOLD} $@
    local FOREGROUND=$LOG_VAR_FG_RED
    local BACKGROUND=$LOG_VAR_BG_GREEN
    local FONT=$LOG_VAR_BOLD
    echo "\\033[${FOREGROUND};${BACKGROUND};${FONT}m${@}\\033[0m"
}
function log_print() {
    # log content: ${1}
    echo $@
}