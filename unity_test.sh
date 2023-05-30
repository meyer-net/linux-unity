#!/bin/bash
#------------------------------------------------
#      Linux softs install scripts by env
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# Mark：启动
#------------------------------------------------
# Git代理参考：https://ghproxy.com
#------------------------------------------------

#---------- DIR ---------- {
# Set magic variables for current file & dir
__DIR="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"
__FILE="${__DIR}/$(basename ${BASH_SOURCE[0]})"
__CONF="$(cd; pwd)"
readonly __DIR __FILE __CONF
#---------- DIR ---------- }

##########################################################################################################

# 初始基本参数启动目录
function func_test() {
}

##########################################################################################################

# 初始基本参数启动目录
function bootstrap() {
    cd ${__DIR}

    # 全部给予执行权限
    chmod +x -R scripts/*.sh
    chmod +x -R common/*.sh
    source common/common_vars.sh
    source common/${MAJOR_OS_LOWER}/common.sh
    source common/${MAJOR_OS_LOWER}/${MAJOR_VERS}/overwrite_vars.sh
    source common/bind_vars.sh

    # source common/requirements.sh
    # source common/functions.sh

    func_test

    echo_style_text "Execute over"
}

##########################################################################################################

if [ "${BASH_SOURCE[0]:-}" != "${0}" ]; then
    export -f bootstrap
else
    bootstrap ${@}
    exit $?
fi