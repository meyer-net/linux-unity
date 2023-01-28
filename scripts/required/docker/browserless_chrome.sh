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
local TMP_SETUP_DOCKER_SNAP_BLC_ARG_TIME="-v /etc/localtime:/etc/localtime"
local TMP_DC_BLC_SETUP_PORT=13000

##########################################################################################################

# 1-配置环境
function set_env_dc_browserless_chrome() {
    cd ${__DIR}

    return $?
}

##########################################################################################################

# 2-安装软件
function setup_dc_browserless_chrome() {
    echo
    echo_text_style "Install <browserless/chrome>, waiting for a moment"
    echo "${TMP_SPLITER}"

    function _setup_dc_browserless_chrome_cp_source() {
        echo "${TMP_SPLITER2}"
        echo_text_style "View the 'source code copy'↓:"

        # 拷贝应用目录
        docker cp -a ${TMP_SETUP_DOCKER_BLC_PS_ID}:/usr/src/app/* ${1}/
        ls -lia
    }

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create ${TMP_DC_BLC_SETUP_DIR} "_setup_dc_browserless_chrome_cp_source"

    cd ${TMP_DC_BLC_SETUP_DIR}

    # 开始安装

    return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_dc_browserless_chrome() {
    cd ${TMP_DC_BLC_SETUP_DIR}

    echo
    echo_text_style "Formal <browserless/chrome>, waiting for a moment"
    echo "${TMP_SPLITER}"

    # 开始标准化
    ## 还原 & 创建 & 迁移
    ### 日志
    # function _formal_dc_browserless_chrome_cp_logs() {
    #     echo "${TMP_SPLITER2}"
    #     echo_text_style "View the 'logs copy'↓:"

    #     # 拷贝日志目录
    #     docker cp -a ${_TMP_DOCKER_SNAP_CREATE_PS_ID}:/usr/src/app/logs ${1}/app_output
    #     ls -lia
    # }
    soft_path_restore_confirm_create "${TMP_DC_BLC_SETUP_LNK_LOGS_DIR}" "_formal_dc_browserless_chrome_cp_logs"

    ### 数据
    function _formal_dc_browserless_chrome_cp_data() {
        echo "${TMP_SPLITER2}"
        echo_text_style "View the 'data copy'↓:"

        # 拷贝日志目录
        # docker cp -a ${_TMP_DOCKER_SNAP_CREATE_PS_ID}:/var/liowserless_chrome/* ${1}/
        docker cp -a ${_TMP_DOCKER_SNAP_CREATE_PS_ID}:/usr/src/app/workspace/* ${1}/
        ls -lia
    }
    soft_path_restore_confirm_create "${TMP_DC_BLC_SETUP_LNK_DATA_DIR}" "_formal_dc_browserless_chrome_cp_data"

    # ### ETC - ①-1Y：存在配置文件：原路径文件放给真实路径
    # function _formal_dc_browserless_chrome_cp_etc() {
    #     echo "${TMP_SPLITER2}"
    #     echo_text_style "View the 'config copy'↓:"

    #     # 拷贝日志目录
    #     docker cp -a ${_TMP_DOCKER_SNAP_CREATE_PS_ID}:/usr/src/app/config/* ${1}/
    #     docker cp -a ${_TMP_DOCKER_SNAP_CREATE_PS_ID}:/etc/browserless_chrome/* ${1}/
    #     ls -lia
    # }
    # soft_path_restore_confirm_create "${TMP_DC_BLC_SETUP_LNK_ETC_DIR}" "_formal_dc_browserless_chrome_cp_etc"

    ## 创建链接规则
    ### 日志
    #### 日志1：无程序自身日志的场景
	path_not_exists_link "${TMP_DC_BLC_SETUP_LOGS_DIR}/docker_output/${LOCAL_TIMESTAMP}.json.log" "" "${DOCKER_SETUP_DIR}/data/containers/${_TMP_DOCKER_SNAP_CREATE_PS_ID}/${_TMP_DOCKER_SNAP_CREATE_PS_ID}-json.log"
    #### 日志2：具有内部日志的场景
    path_not_exists_link "${TMP_DC_BLC_SETUP_LOGS_DIR}/app_output" "" "${TMP_DC_BLC_SETUP_LNK_LOGS_DIR}"
    ### 数据
    path_not_exists_link "${TMP_DC_BLC_SETUP_DATA_DIR}" "" "${TMP_DC_BLC_SETUP_LNK_DATA_DIR}"
    ### ETC
    path_not_exists_link "${TMP_DC_BLC_SETUP_ETC_DIR}" "" "${TMP_DC_BLC_SETUP_LNK_ETC_DIR}"

    # # 预实验部分
    # ## 目录调整完重启进程(目录调整是否有效的验证点)

    return $?
}

##########################################################################################################

# 4-设置软件
function conf_browserless_chrome() {
    cd ${TMP_DC_BLC_SETUP_DIR}

    echo
    echo_text_style "Configuration <browserless/chrome>, waiting for a moment"
    echo "${TMP_SPLITER}"

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

    echo
    echo_text_style "Test <browserless/chrome>, waiting for a moment"
    echo "${TMP_SPLITER}"

    return $?
}

##########################################################################################################

# 6-1 重建启动软件（此处相当于重新构建了容器）
function boot_rebuild_dc_browserless_chrome() {
    cd ${TMP_DC_BLC_SETUP_DIR}

    echo
    echo_text_style "Boot rebuild <browserless/chrome>, waiting for a moment"
    echo "${TMP_SPLITER}"

    # # 给该一次性容器取个别名，以后就可以直接使用whaler了
    # alias whaler="docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock:ro pegleg/whaler"

    local TMP_SETUP_DOCKER_SNAP_BLC_ARG_WORKDIR="-w /usr/src/app"
    local TMP_SETUP_DOCKER_SNAP_BLC_ARG_PORTS="-p ${TMP_SETUP_DOCKER_BLC_PS_PORT}:3000"
    #  -v ${TMP_DC_BLC_SETUP_LNK_LOGS_DIR}/app_output:/tmp
    #  -v ${TMP_DC_BLC_SETUP_LNK_LOGS_DIR}/app_output:/usr/src/app/logs
    local TMP_SETUP_DOCKER_SNAP_BLC_ARG_MOUNTS="-v ${TMP_DC_BLC_SETUP_DIR}:/usr/src/app -v ${TMP_DC_BLC_SETUP_LNK_LOGS_DIR}/app_output:/tmp"
    local TMP_SETUP_DOCKER_SNAP_BLC_ARG_BASIC="--restart always ${TMP_SETUP_DOCKER_SNAP_BLC_ARG_WORKDIR} ${TMP_SETUP_DOCKER_SNAP_BLC_ARG_PORTS} ${TMP_SETUP_DOCKER_SNAP_BLC_ARG_TIME} ${TMP_SETUP_DOCKER_SNAP_BLC_ARG_MOUNTS}"
    local TMP_SETUP_DOCKER_SNAP_BLC_ARG_ENVS="-e PREBOOT_CHROME=true -e CONNECTION_TIMEOUT=-1 -e MAX_CONCURRENT_SESSIONS=10 -e WORKSPACE_DELETE_EXPIRED=true -e WORKSPACE_EXPIRE_DAYS=7"
    local TMP_SETUP_DOCKER_SNAP_BLC_ARGS="${TMP_SETUP_DOCKER_SNAP_BLC_ARG_BASIC} ${TMP_SETUP_DOCKER_SNAP_BLC_ARG_ENVS}"

    # 重新启动并构建新容器
    soft_docker_boot_print "${TMP_SETUP_DOCKER_BLC_BOOT_IMG}" "${3}" "${4}" "${TMP_SETUP_DOCKER_SNAP_BLC_ARGS}" "docker stop ${1} && docker container rm ${1}" "boot_check_dc_browserless_chrome"

    # 授权iptables端口访问
    echo_soft_port ${2}

    # 生成web授权访问脚本
    #echo_web_service_init_scripts "browserless_chrome${LOCAL_ID}" "browserless_chrome${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_DC_BLC_SETUP_PORT} "${LOCAL_HOST}"

    return $?
}

# 6-2 启动后检测脚本
# 参数1：启动后的进程ID
# 参数2：最终启动端口
# 参数3：最终启动版本
# 参数3：最终启动命令
# 参数4：最终启动参数
function boot_check_dc_browserless_chrome() {
    local TMP_SETUP_DOCKER_BLC_PS_ID=${1}
    local TMP_SETUP_DOCKER_BLC_PS_PORT=${2}

    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container folder /usr/src/app'↓:"
    docker exec -it ${TMP_SETUP_DOCKER_BLC_PS_ID} sh -c "ls -lia /usr/src/app/"

    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container visit'↓:"
    curl -s http://localhost:${TMP_SETUP_DOCKER_BLC_PS_PORT}
}

##########################################################################################################

# 下载扩展/驱动/插件
function down_ext_dc_browserless_chrome() {
    cd ${TMP_DC_BLC_SETUP_DIR}

    echo
    echo_text_style "Download <browserless/chrome> ext, waiting for a moment"
    echo "${TMP_SPLITER}"

    return $?
}

# 安装与配置扩展/驱动/插件
function setup_ext_dc_browserless_chrome() {
    cd ${TMP_DC_BLC_SETUP_DIR}

    echo
    echo_text_style "Install <browserless/chrome> ext, waiting for a moment"
    echo "${TMP_SPLITER}"

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

    echo
    echo_text_style "Execute step <browserless/chrome>, waiting for a moment"
    echo "${TMP_SPLITER}"

    local TMP_SETUP_DOCKER_BLC_PS_ID=${1}
    local TMP_SETUP_DOCKER_BLC_PS_PORT=${2}
    local TMP_SETUP_DOCKER_BLC_PS_VER=${3}
    local TMP_SETUP_DOCKER_BLC_PS_CMD=${4}
    local TMP_SETUP_DOCKER_BLC_PS_ARGS=${5}

    set_env_dc_browserless_chrome

    setup_dc_browserless_chrome

    formal_dc_browserless_chrome

    conf_dc_browserless_chrome

    test_dc_browserless_chrome

    # down_ext_dc_browserless_chrome
    # setup_ext_dc_browserless_chrome

    boot_check_dc_browserless_chrome

    # reconf_dc_browserless_chrome

    return $?
}

##########################################################################################################

# x2-简略启动，获取初始化软件（形成启动后才可抽取目录信息）
#    参数1：镜像名称，例 browserless/chrome
#    参数2：快照版本，例 latest/1673604625
#    参数3：快照类型(还原时有效)，例 image/container/dockerfile
#    参数4：快照来源(还原时有效)，例 snapshot/clean，默认snapshot
function boot_init_dc_browserless_chrome() {

    echo
    echo_text_style "Boot init <browserless/chrome>, waiting for a moment"
    echo "${TMP_SPLITER}"

    # 初始接受参数
    local TMP_SETUP_DOCKER_BLC_BOOT_IMG=${1}
    local TMP_SETUP_DOCKER_BLC_BOOT_VER=${2}
    local TMP_SETUP_DOCKER_BLC_BOOT_TYPE=${3}
    local TMP_SETUP_DOCKER_BLC_BOOT_STORE=${4}

    # 标准启动命令
    local TMP_SETUP_DOCKER_SNAP_BLC_PRE_ARGS="-d ${TMP_SETUP_DOCKER_SNAP_BLC_ARG_TIME}"

    # 执行步骤操作或启动检测
    # 参数1：启动后的进程ID
    # 参数2：最终启动端口
    # 参数3：最终启动版本
    # 参数4：最终启动命令
    # 参数5：最终启动参数
    function exec_step_or_boot_check() {
        exec_step_browserless_chrome "${@}"

        # 启动参数为精简启动的情况下，重置容器
        if [ "${5}" == "${TMP_SETUP_DOCKER_SNAP_BLC_PRE_ARGS}" ]; then
            boot_rebuild_dc_browserless_chrome "${@}"
        fi
    }

    soft_docker_boot_print "${1}" "${2}" "" "${TMP_SETUP_DOCKER_SNAP_BLC_PRE_ARGS}" "" "exec_step_or_boot_check"

    return $?
}

##########################################################################################################

# x1-下载/安装/更新软件
function check_setup_dc_browserless_chrome() {
    # 变量覆盖特性，其它方法均可读取
    local TMP_DC_BLC_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/browserless_chrome
    local TMP_DC_BLC_CURRENT_DIR=$(pwd)

    # 统一编排到的路径
    local TMP_DC_BLC_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/browserless_chrome
    local TMP_DC_BLC_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/browserless_chrome
    local TMP_DC_BLC_SETUP_LNK_ETC_DIR=${ATT_DIR}/browserless_chrome

    # 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_DC_BLC_SETUP_LOGS_DIR=${TMP_DC_BLC_SETUP_DIR}/logs
    local TMP_DC_BLC_SETUP_DATA_DIR=${TMP_DC_BLC_SETUP_DIR}/data
    local TMP_DC_BLC_SETUP_ETC_DIR=${TMP_DC_BLC_SETUP_DIR}/etc

    echo
    echo_text_style "Check install <browserless/chrome>, waiting for a moment"
    echo "${TMP_SPLITER}"

    # 更新/安装 ？？？暂未提供版本选择
    soft_docker_check_upgrade_setup "${1}" "boot_init_dc_browserless_chrome"

    return $?
}

##########################################################################################################

#安装主体
setup_soft_basic "browserless/chrome" "check_setup_dc_browserless_chrome"
