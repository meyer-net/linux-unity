#!/bin/bash
####################################################################################
# 运行时，自动弹出配置slack提示
####################################################################################

#---------- DIR ---------- {
# Set magic variables for current file & dir
__DIR="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"
__FILE="${__DIR}/$(basename ${BASH_SOURCE[0]})"
__CONF="$(
    cd
    pwd
)"
readonly __DIR __FILE __CONF
#---------- DIR ---------- }

# 清理系统缓存后执行
echo 3 >/proc/sys/vm/drop_caches

function Usage(){
cat << HELP
Usage: unity_specialstart NAME[:TAG]
unity_specialstart list all tags for docker image on a remote registry.
Example:
    unity_specialstart (default nginx)
HELP
}
ARG=$1
if [[ "$ARG" =~ "-h" ]];then
    Usage
    exit 0
fi

# 初始基本参数启动目录
function bootstrap() {
    cd ${__DIR}

    # 全部给予执行权限
    chmod +x -R common/*.sh
    source common/common_vars.sh
    source common/common.sh

    # 定制化的脚本，独有的依赖系统通知
    chmod +x -R special/*.sh
    source special/slack.sh

    #https://www.cnblogs.com/wu-wu/p/11214503.html
    path_not_exists_create "${CRTB_LOGS_DIR}"

    choice_type
}

function choice_type() {
    echo_title

    exec_if_choice "CHOICE_CTX" "Please choice your startup type" "Svn.Updater,Svn.Packager,Kong.Api,Auto.Cert,Exit" "${TMP_SPLITER}" "special"

    return $?
}

if [ "${BASH_SOURCE[0]:-}" != "${0}" ]; then
    export -f bootstrap
else
    bootstrap ${@}
    exit $?
fi
