#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#
#------------------------------------------------
# 安装标题：Browserless/Chrome
# 软件名称：browserless_chrome
# 软件端口：3000
# 软件大写分组与简称：DC_BLC
# 软件安装名称：browserless_chrome
# 软件工作目录：/usr/src/app
# 软件GIT仓储名称：${docker_prefix}
# 软件GIT仓储名称：${git_repo}
#------------------------------------------------
local TMP_DC_BLC_SETUP_INN_PORT=3000
local TMP_DC_BLC_SETUP_OPN_PORT=1${TMP_DC_BLC_SETUP_INN_PORT}

##########################################################################################################

# 1-配置环境
function set_env_dc_browserless_chrome() {
    cd ${__DIR}

    return $?
}

##########################################################################################################

# 2-安装软件
function setup_dc_browserless_chrome() {
    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'install', hold on please"

    function _setup_dc_browserless_chrome_cp_source() {
        echo "${TMP_SPLITER2}"
        echo_text_style "View the 'workingdir copy'↓:"

        # 拷贝应用目录
        docker cp -a ${TMP_DC_BLC_SETUP_PS_ID}:/usr/src/app ${1}
        ls -lia ${1}
    }

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_pcreate ${TMP_DC_BLC_SETUP_DIR} "_setup_dc_browserless_chrome_cp_source"

    cd ${TMP_DC_BLC_SETUP_DIR}

    # 开始安装

    return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_dc_browserless_chrome() {
    cd ${TMP_DC_BLC_SETUP_DIR}

    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'formal dirs', hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移
    ### 日志
    # function _formal_dc_browserless_chrome_cp_logs() {
    #     echo "${TMP_SPLITER2}"
    #     echo_text_style "View the 'logs copy'↓:"

    #     # 拷贝日志目录
    #     # mkdir -pv ${1}/app_output
    #     docker cp -a ${TMP_DC_BLC_SETUP_PS_ID}:/var/logs/chrome ${1}/app_output
    #     ls -lia ${1}
    # }
    soft_path_restore_confirm_create "${TMP_DC_BLC_SETUP_LNK_LOGS_DIR}" "_formal_dc_browserless_chrome_cp_logs"

    ### 数据
    function _formal_dc_browserless_chrome_cp_data() {
        echo "${TMP_SPLITER2}"
        echo_text_style "View the 'data copy'↓:"

        # ???临时
        mv ${TMP_DC_BLC_SETUP_DATA_DIR} ${1}_clean_${LOCAL_TIMESTAMP}

        # 拷贝日志目录
        docker cp -a ${TMP_DC_BLC_SETUP_PS_ID}:/usr/src/app/workspace ${1}
        ls -lia ${1}
    }
    soft_path_restore_confirm_pcreate "${TMP_DC_BLC_SETUP_LNK_DATA_DIR}" "_formal_dc_browserless_chrome_cp_data"

    # ### ETC - ①-1Y：存在配置文件：原路径文件放给真实路径
    # function _formal_dc_browserless_chrome_cp_etc() {
    #     echo "${TMP_SPLITER2}"
    #     echo_text_style "View the 'config copy'↓:"

    #     # 拷贝日志目录
    #     docker cp -a ${TMP_DC_BLC_SETUP_PS_ID}:/usr/src/app/config ${1}
    #     docker cp -a ${TMP_DC_BLC_SETUP_PS_ID}:/etc/browserless_chrome ${1}
    #     ls -lia ${1}
    # }
    # soft_path_restore_confirm_pcreate "${TMP_DC_BLC_SETUP_LNK_ETC_DIR}" "_formal_dc_browserless_chrome_cp_etc"

    ## 创建链接规则
    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'symlink create':↓"
    ### 日志
    #### 日志1：所有场景都适用
    path_not_exists_link "${TMP_DC_BLC_SETUP_LOGS_DIR}" "" "${TMP_DC_BLC_SETUP_LNK_LOGS_DIR}"
	path_not_exists_link "${TMP_DC_BLC_SETUP_LOGS_DIR}/docker_output/${TMP_DC_BLC_SETUP_PS_ID}.json.log" "" "${DOCKER_SETUP_DIR}/data/containers/${TMP_DC_BLC_SETUP_PS_ID}/${TMP_DC_BLC_SETUP_PS_ID}-json.log"
    #### 日志2：具有内部日志的场景
    # path_not_exists_link "${TMP_DC_BLC_SETUP_LOGS_DIR}/app_output" "" "${TMP_DC_BLC_SETUP_LNK_LOGS_DIR}"
    ### 数据
    path_not_exists_link "${TMP_DC_BLC_SETUP_DATA_DIR}" "" "${TMP_DC_BLC_SETUP_LNK_DATA_DIR}"
    ### ETC
    # path_not_exists_link "${TMP_DC_BLC_SETUP_ETC_DIR}" "" "${TMP_DC_BLC_SETUP_LNK_ETC_DIR}"

    # 预实验部分
    ## 容器非挂载时执行???
        ## 目录调整完修改启动参数
        echo "${TMP_SPLITER2}"
        echo_text_style "Starting 'inspect change', hold on please"

        # # 给该一次性容器取个别名，以后就可以直接使用whaler了
        # alias whaler="docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock:ro pegleg/whaler"

        ## 重新启动并构建新容器
        echo "${TMP_SPLITER2}"
        echo_text_style "Stoping 'all running containers' & docker service, hold on please"
        local TMP_DC_BLC_STOP_IDS=$(docker ps -a | grep -v "^CONTAINER ID" | cut -d' ' -f1 | xargs docker container stop)
        echo "${TMP_DC_BLC_STOP_IDS}"
        systemctl stop docker.socket
        systemctl stop docker.service

        ## 修改启动参数
        local TMP_DC_BLC_SETUP_CTN_TMP="/tmp/${TMP_DC_BLC_SETUP_BOOT_IMG_MARK}/${TMP_DC_BLC_SETUP_PS_VER}"
        path_not_exists_create "${TMP_DC_BLC_SETUP_CTN_TMP}"
        change_docker_container_inspect_mount "${TMP_DC_BLC_SETUP_PS_ID}" "${TMP_DC_BLC_SETUP_CTN_TMP}" "/tmp"
        change_docker_container_inspect_mount "${TMP_DC_BLC_SETUP_PS_ID}" "${TMP_DC_BLC_SETUP_DIR}" "/usr/src/app"
        # change_docker_container_inspect_mount "${TMP_DC_BLC_SETUP_PS_ID}" "${TMP_DC_BLC_SETUP_LNK_LOGS_DIR}/app_output" "/tmp"
        # change_docker_container_inspect_mount "${TMP_DC_BLC_SETUP_PS_ID}" "${TMP_DC_BLC_SETUP_LNK_LOGS_DIR}/app_output" "/var/logs/chrome"
        change_docker_container_inspect_mount "${TMP_DC_BLC_SETUP_PS_ID}" "${TMP_DC_BLC_SETUP_LNK_DATA_DIR}" "/usr/src/app/workspace"
        # change_docker_container_inspect_mount "${TMP_DC_BLC_SETUP_PS_ID}" "${TMP_DC_BLC_SETUP_LNK_ETC_DIR}" "/usr/src/app/config

        ## 重启容器
        echo "${TMP_SPLITER2}"
        echo_text_style "Starting docker service & 'stopped containers' (<${TMP_DC_BLC_STOP_IDS}>), hold on please"
        systemctl start docker.service
        echo "${TMP_DC_BLC_STOP_IDS}" | xargs docker start

    return $?
}

##########################################################################################################

# 4-设置软件
function conf_dc_browserless_chrome() {
    cd ${TMP_DC_BLC_SETUP_DIR}

    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'configuration', hold on please"

    # 开始配置
    # ## 授权权限，否则无法写入
    # create_user_if_not_exists $setup_owner $setup_owner_group
    # chown -R $setup_owner:$setup_owner_group ${TMP_DC_BLC_SETUP_DIR}
    # chown -R $setup_owner:$setup_owner_group ${TMP_DC_BLC_SETUP_LNK_LOGS_DIR}
    # chown -R $setup_owner:$setup_owner_group ${TMP_DC_BLC_SETUP_LNK_DATA_DIR}
    # chown -R $setup_owner:$setup_owner_group ${TMP_DC_BLC_SETUP_LNK_ETC_DIR}

    return $?
}

##########################################################################################################

# 5-测试软件
function test_dc_browserless_chrome() {
    cd ${TMP_DC_BLC_SETUP_DIR}
    # 实验部分

    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'test', hold on please"

    return $?
}

##########################################################################################################

# 6-启动后检测脚本
# 参数1：启动后的进程ID
# 参数2：最终启动端口
# 参数3：最终启动版本
# 参数3：最终启动命令
# 参数4：最终启动参数
function boot_check_dc_browserless_chrome() {
    cd ${TMP_DC_BLC_SETUP_DIR}
    # 实验部分

    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'boot check', hold on please"

    if [ -n "${TMP_DC_BLC_SETUP_PS_PORT}" ]; then
        echo "${TMP_SPLITER2}"
        echo_text_style "View the 'container visit'↓:"
        curl -s http://localhost:${TMP_DC_BLC_SETUP_PS_PORT}
    fi
}

##########################################################################################################

# 7-1 下载扩展/驱动/插件
function down_ext_dc_browserless_chrome() {
    cd ${TMP_DC_BLC_SETUP_DIR}

    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'download exts', hold on please"

    return $?
}

# 7-2 安装与配置扩展/驱动/插件
function setup_ext_dc_browserless_chrome() {
    cd ${TMP_DC_BLC_SETUP_DIR}

    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'install exts', hold on please"

    return $?
}

##########################################################################################################

# 8-重新配置（有些软件安装完后需要重新配置）
function reconf_dc_browserless_chrome()
{
    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'reconf', hold on please"

    # 授权iptables端口访问
    # echo_soft_port ${2}

    # 生成web授权访问脚本
    #echo_web_service_init_scripts "browserless_chrome${LOCAL_ID}" "browserless_chrome${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_DC_BLC_SETUP_OPN_PORT} "${LOCAL_HOST}"

	return $?
}

##########################################################################################################

# x3-执行步骤
#    参数1：启动后的进程ID
#    参数2：最终启动端口
#    参数3：最终启动版本
#    参数4：最终启动命令
#    参数5：最终启动参数
function exec_step_browserless_chrome() {
    local TMP_DC_BLC_SETUP_PS_ID="${1}"
    # local TMP_DC_BLC_SETUP_PS_SID="${TMP_DC_BLC_SETUP_PS_ID:0:12}"
    local TMP_DC_BLC_SETUP_PS_PORT="${2}"
    local TMP_DC_BLC_SETUP_PS_VER="${3}"
    local TMP_DC_BLC_SETUP_PS_CMD="${4}"
    local TMP_DC_BLC_SETUP_PS_ARGS="${5}"
    
    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'execute step' <${TMP_DC_BLC_SETUP_BOOT_IMG}>:[${TMP_DC_BLC_SETUP_PS_VER}]('${TMP_DC_BLC_SETUP_PS_ID}'), hold on please"

    set_env_dc_browserless_chrome

    setup_dc_browserless_chrome

    formal_dc_browserless_chrome

    conf_dc_browserless_chrome

    test_dc_browserless_chrome

    # down_ext_dc_browserless_chrome
    # setup_ext_dc_browserless_chrome

    boot_check_dc_browserless_chrome

    reconf_dc_browserless_chrome

    return $?
}

##########################################################################################################

# x2-简略启动，获取初始化软件（形成启动后才可抽取目录信息）
#    参数1：镜像名称，例 browserless/chrome
#    参数2：镜像版本，例 latest/1673604625
#    参数3：快照类型(还原时有效)，例 image/container/dockerfile
#    参数4：快照来源(还原时有效)，例 snapshot/clean，默认snapshot
function boot_build_dc_browserless_chrome() {
    # 初始接受参数
    local TMP_DC_BLC_SETUP_BOOT_IMG="${1}"
    local TMP_DC_BLC_SETUP_BOOT_IMG_MARK="${1/\//_}"
    local TMP_DC_BLC_SETUP_BOOT_VER="${2}"
    local TMP_DC_BLC_SETUP_BOOT_TYPE="${3}"
    local TMP_DC_BLC_SETUP_BOOT_STORE="${4}"

    # 变量覆盖特性，其它方法均可读取
    local TMP_DC_BLC_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_BLC_SETUP_BOOT_IMG_MARK}/${TMP_DC_BLC_SETUP_BOOT_VER}
    local TMP_DC_BLC_CURRENT_DIR=$(pwd)

    # 统一编排到的路径
    local TMP_DC_BLC_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_BLC_SETUP_BOOT_IMG_MARK}/${TMP_DC_BLC_SETUP_BOOT_VER}
    local TMP_DC_BLC_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_BLC_SETUP_BOOT_IMG_MARK}/${TMP_DC_BLC_SETUP_BOOT_VER}
    local TMP_DC_BLC_SETUP_LNK_ETC_DIR=${DOCKER_APP_ATT_DIR}/${TMP_DC_BLC_SETUP_BOOT_IMG_MARK}/${TMP_DC_BLC_SETUP_BOOT_VER}

    # 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_DC_BLC_SETUP_LOGS_DIR=${TMP_DC_BLC_SETUP_DIR}/logs
    local TMP_DC_BLC_SETUP_DATA_DIR=${TMP_DC_BLC_SETUP_DIR}/workspace
    local TMP_DC_BLC_SETUP_ETC_DIR=${TMP_DC_BLC_SETUP_DIR}/etc

    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'build container' <${TMP_DC_BLC_SETUP_BOOT_IMG}>:[${TMP_DC_BLC_SETUP_BOOT_VER}], hold on please"
    
    # 标准启动参数
    local TMP_DC_BLC_SETUP_PRE_ARG_TIME="--volume=/etc/localtime:/etc/localtime"
    local TMP_DC_BLC_SETUP_PRE_ARG_PORTS="-p ${TMP_DC_BLC_SETUP_OPN_PORT}:${TMP_DC_BLC_SETUP_INN_PORT}"
    local TMP_DC_BLC_SETUP_PRE_ARG_ENVS="--env=PREBOOT_CHROME=true --env=CONNECTION_TIMEOUT=-1 --env=MAX_CONCURRENT_SESSIONS=10 --env=WORKSPACE_DELETE_EXPIRED=true --env=WORKSPACE_EXPIRE_DAYS=7"
    local TMP_DC_BLC_SETUP_PRE_ARGS="${TMP_DC_BLC_SETUP_PRE_ARG_PORTS} --restart always ${TMP_DC_BLC_SETUP_PRE_ARG_ENVS} ${TMP_DC_BLC_SETUP_PRE_ARG_TIME}"
    
    local TMP_DC_BLC_SETUP_PRE_ARG_CMD=""

    # 开始启动
    soft_docker_boot_print "${TMP_DC_BLC_SETUP_BOOT_IMG}" "${TMP_DC_BLC_SETUP_BOOT_VER}" "${TMP_DC_BLC_SETUP_PRE_ARG_CMD}" "${TMP_DC_BLC_SETUP_PRE_ARGS}" "" "exec_step_browserless_chrome"

    return $?
}

##########################################################################################################

# x1-下载/安装/更新软件
function check_setup_dc_browserless_chrome() {
    echo_text_style "Checking 'install' <${1}>, hold on please"

    # 更新/安装 ？？？暂未提供更新选择
    soft_docker_check_upgrade_setup "${1}" "boot_build_dc_browserless_chrome"

    return $?
}

##########################################################################################################

#安装主体
setup_soft_basic "browserless/chrome" "check_setup_dc_browserless_chrome"
