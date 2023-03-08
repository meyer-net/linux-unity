#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
#------------------------------------------------
# 软件名称：appflowyio/appflowy_client
# 软件端口：$soft_port
# 软件大写分组与简称：AFL
# 软件安装名称：appflowyio_appflowy_client
#------------------------------------------------
local TMP_AFL_SETUP_INN_PORT=80
local TMP_AFL_SETUP_OPN_PORT=1${TMP_AFL_SETUP_INN_PORT}

##########################################################################################################

# 1-配置环境
function set_env_dc_appflowyio_appflowy_client() {
    cd ${__DIR}

    return $?
}

##########################################################################################################

# 2-安装软件
function setup_dc_appflowyio_appflowy_client() {
    echo_style_wrap_text "Starting 'install', hold on please"

    function _setup_dc_appflowyio_appflowy_client_cp_source() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'workingdir copy'↓:"

        # 拷贝应用目录
        docker cp -a ${TMP_AFL_SETUP_CTN_ID}:$work_dir ${1} >& /dev/null
        
        # 查看列表
        ls -lia ${1}
    }

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_pcreate ${TMP_AFL_SETUP_WORK_DIR} "_setup_dc_appflowyio_appflowy_client_cp_source"

    cd ${TMP_AFL_SETUP_WORK_DIR}

    # 开始安装

    return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_dc_appflowyio_appflowy_client() {
    cd ${TMP_AFL_SETUP_WORK_DIR}

    echo_style_wrap_text "Starting 'formal dirs', hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移
    ### 日志
    #### /mountdisk/logs/docker_apps/appflowyio_appflowy_client/imgver111111
    # function _formal_dc_appflowyio_appflowy_client_cp_logs() {
    #     echo "${TMP_SPLITER2}"
    #     echo_style_text "View the 'logs copy'↓:"

    #     # 拷贝日志目录
    #     ## /mountdisk/logs/docker_apps/appflowyio_appflowy_client/imgver111111/app_output
    #     # mkdir -pv ${1}/app_output
    #     # docker cp -a ${TMP_AFL_SETUP_CTN_ID}:/var/logs/${TMP_AFL_SETUP_APP_MARK} ${1}/app_output >& /dev/null
    #     docker cp -a ${TMP_AFL_SETUP_CTN_ID}:$work_dir/${TMP_AFL_SETUP_LOGS_MARK} ${1}/app_output >& /dev/null
    #
    #     # 查看列表
    #     ls -lia ${1}
    # }
    soft_path_restore_confirm_create "${TMP_AFL_SETUP_LNK_LOGS_DIR}" "_formal_dc_appflowyio_appflowy_client_cp_logs"

    ### 数据
    #### /mountdisk/data/docker_apps/appflowyio_appflowy_client/imgver111111
    function _formal_dc_appflowyio_appflowy_client_cp_data() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'data copy'↓:"

        # 拷贝日志目录
        # mkdir -pv ${1}
        # docker cp -a ${TMP_AFL_SETUP_CTN_ID}:/var/lib/${TMP_AFL_SETUP_APP_MARK} ${1} >& /dev/null
        docker cp -a ${TMP_AFL_SETUP_CTN_ID}:$work_dir/${TMP_AFL_SETUP_DATA_MARK} ${1} >& /dev/null
        
        # 查看列表
        ls -lia ${1}
    }
    soft_path_restore_confirm_pcreate "${TMP_AFL_SETUP_LNK_DATA_DIR}" "_formal_dc_appflowyio_appflowy_client_cp_data"

    ### ETC - ①-1Y：存在配置文件：原路径文件放给真实路径
    ### ETC目录规范
    #### /mountdisk/data/docker/containers/${CTN_ID}
    local TMP_AFL_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_AFL_SETUP_CTN_ID}"
    #### /mountdisk/etc/docker_apps/appflowyio_appflowy_client/imgver111111/container
    local TMP_AFL_SETUP_LNK_ETC_CTN_DIR="${TMP_AFL_SETUP_LNK_ETC_DIR}/container"
    #### /mountdisk/etc/docker_apps/appflowyio_appflowy_client/imgver111111
    function _formal_dc_appflowyio_appflowy_client_cp_etc() {
    #     echo "${TMP_SPLITER2}"
    #     echo_style_text "View the 'etc copy'↓:"

    #     # 拷贝日志目录
    #     ## /mountdisk/etc/docker_apps/appflowyio_appflowy_client/imgver111111/app
    #     # docker cp -a ${TMP_AFL_SETUP_CTN_ID}:$work_dir/${TMP_AFL_SETUP_ETC_MARK} ${1}/app >& /dev/null
    #     docker cp -a ${TMP_AFL_SETUP_CTN_ID}:/etc/${TMP_AFL_SETUP_APP_MARK} ${1}/app >& /dev/null
    #     ls -lia ${1}
    
    #     # 移除本地配置目录(挂载)
    #     rm -rf ${TMP_AFL_SETUP_WORK_DIR}/${TMP_AFL_SETUP_ETC_MARK}
        #### /mountdisk/data/docker/containers/${CTN_ID} ©&<- /mountdisk/etc/docker_apps/appflowyio_appflowy_client/imgver111111/container
        soft_path_restore_confirm_swap "${TMP_AFL_SETUP_LNK_ETC_CTN_DIR}" "${TMP_AFL_SETUP_CTN_DIR}"
    }
    soft_path_restore_confirm_create "${TMP_AFL_SETUP_LNK_ETC_DIR}" "_formal_dc_appflowyio_appflowy_client_cp_etc"
   
    ### 迁移ETC下LOGS归位
    #### [ 废弃，logs路径会被强制修改未docker root dir对应的数据目录，一旦软连接会被套出多层路径，如下（且修改无效）：
    ##### "LogPath": "/mountdisk/data/docker/containers/4f8b1ca03fe001037e3d701079f094bb5f2a65da089305825546df486c082c22/mountdisk/logs/docker_apps/appflowyio_appflowy_client/imgver111111/docker_output/4f8b1ca03fe001037e3d701079f094bb5f2a65da089305825546df486c082c22-json.log"
    #### /mountdisk/etc/docker_apps/appflowyio_appflowy_client/imgver111111/container/${CTN_ID}-json.log ©&<- /mountdisk/logs/docker_apps/appflowyio_appflowy_client/imgver111111/docker_output/${CTN_ID}-json.log
    # soft_path_restore_confirm_move "${TMP_AFL_SETUP_LNK_LOGS_DIR}/docker_output/${TMP_AFL_SETUP_CTN_ID}-json.log" "${TMP_AFL_SETUP_LNK_ETC_CTN_DIR}/${TMP_AFL_SETUP_CTN_ID}-json.log"
    #### ]

    ## 创建链接规则
    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'symlink create':↓"
    ### 日志
    #### /opt/docker_apps/appflowyio_appflowy_client/imgver111111/logs -> /mountdisk/logs/docker_apps/appflowyio_appflowy_client/imgver111111
    path_not_exists_link "${TMP_AFL_SETUP_LOGS_DIR}" "" "${TMP_AFL_SETUP_LNK_LOGS_DIR}"
    #### /opt/docker/logs/appflowyio_appflowy_client/imgver111111 -> /mountdisk/logs/docker_apps/appflowyio_appflowy_client/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/logs/${TMP_AFL_SETUP_IMG_MARK_NAME}/${TMP_AFL_SETUP_CTN_VER}" "" "${TMP_AFL_SETUP_LNK_LOGS_DIR}"
    #### /mountdisk/logs/docker_apps/appflowyio_appflowy_client/imgver111111/docker_output/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/appflowyio_appflowy_client/imgver111111/container/${CTN_ID}-json.log
    path_not_exists_link "${TMP_AFL_SETUP_LNK_LOGS_DIR}/docker_output/${TMP_AFL_SETUP_CTN_ID}-json.log" "" "${TMP_AFL_SETUP_LNK_ETC_CTN_DIR}/${TMP_AFL_SETUP_CTN_ID}-json.log"
    ### 数据
    #### /opt/docker_apps/appflowyio_appflowy_client/imgver111111/workspace -> /mountdisk/data/docker_apps/appflowyio_appflowy_client/imgver111111
    path_not_exists_link "${TMP_AFL_SETUP_DATA_DIR}" "" "${TMP_AFL_SETUP_LNK_DATA_DIR}"
    #### /opt/docker/data/apps/appflowyio_appflowy_client/imgver111111 -> /mountdisk/data/docker_apps/appflowyio_appflowy_client/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/data/apps/${TMP_AFL_SETUP_IMG_MARK_NAME}/${TMP_AFL_SETUP_CTN_VER}" "" "${TMP_AFL_SETUP_LNK_DATA_DIR}"
    ### ETC
    #### /opt/docker_apps/appflowyio_appflowy_client/imgver111111/etc -> /mountdisk/etc/docker_apps/appflowyio_appflowy_client/imgver111111
    path_not_exists_link "${TMP_AFL_SETUP_ETC_DIR}" "" "${TMP_AFL_SETUP_LNK_ETC_DIR}"
    #### /opt/docker/etc/appflowyio_appflowy_client/imgver111111 -> /mountdisk/etc/docker_apps/appflowyio_appflowy_client/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/etc/${TMP_AFL_SETUP_IMG_MARK_NAME}/${TMP_AFL_SETUP_CTN_VER}" "" "${TMP_AFL_SETUP_LNK_ETC_DIR}"
    #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/etc/docker_apps/appflowyio_appflowy_client/imgver111111/container
    path_not_exists_link "${TMP_AFL_SETUP_CTN_DIR}" "" "${TMP_AFL_SETUP_LNK_ETC_CTN_DIR}"

    # 预实验部分        
    ## 目录调整完修改启动参数
    ## 修改启动参数
    # local TMP_AFL_SETUP_CTN_TMP="/tmp/${TMP_AFL_SETUP_IMG_MARK_NAME}/${TMP_AFL_SETUP_CTN_VER}"
    # soft_path_restore_confirm_create "${TMP_AFL_SETUP_CTN_TMP}"
    # ${TMP_AFL_SETUP_CTN_TMP}:/tmp"
    #
    # ${TMP_AFL_SETUP_WORK_DIR}:$work_dir"
    # ${TMP_AFL_SETUP_LNK_LOGS_DIR}/app_output:/var/logs/${TMP_AFL_SETUP_APP_MARK}"
    # ${TMP_AFL_SETUP_LNK_LOGS_DIR}/app_output:$work_dir/${TMP_AFL_SETUP_LOGS_MARK}"
    # ${TMP_AFL_SETUP_LNK_DATA_DIR}:$work_dir/${TMP_AFL_SETUP_DATA_MARK}"
    # ${TMP_AFL_SETUP_LNK_DATA_DIR}:/var/lib/${TMP_AFL_SETUP_APP_MARK}"
    # ${TMP_AFL_SETUP_LNK_ETC_DIR}/app:$work_dir/${TMP_AFL_SETUP_ETC_MARK}
    # ${TMP_AFL_SETUP_LNK_ETC_DIR}/app:/etc/${TMP_AFL_SETUP_APP_MARK}
    echo "${TMP_SPLITER2}"
    echo_style_text "Starting 'inspect change', hold on please"

    # 挂载目录(必须停止服务才能修改，否则会无效)
    docker_change_container_volume_migrate "${TMP_AFL_SETUP_CTN_ID}" "${TMP_AFL_SETUP_WORK_DIR}:$work_dir ${TMP_AFL_SETUP_LNK_DATA_DIR}:$work_dir/${TMP_AFL_SETUP_DATA_MARK}"
    
    # # 给该一次性容器取个别名，以后就可以直接使用whaler了
    # alias whaler="docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock:ro pegleg/whaler"

    return $?
}

##########################################################################################################

# 4-设置软件
function conf_dc_appflowyio_appflowy_client() {
    cd ${TMP_AFL_SETUP_WORK_DIR}

    echo_style_wrap_text "Starting 'configuration', hold on please"

    # 开始配置
    # docker exec docker exec -u root -w $work_dir -it ${TMP_AFL_SETUP_CTN_ID} sh -c "sed -i \"s@os.tmpdir()@\'\/usr\/src\/app\'@g\" src/utils.js"

    return $?
}

##########################################################################################################

# 5-测试软件
function test_dc_appflowyio_appflowy_client() {
    cd ${TMP_AFL_SETUP_WORK_DIR}

    # 实验部分
    echo_style_wrap_text "Starting 'test', hold on please"

    return $?
}

##########################################################################################################

# 6-启动后检测脚本
# 参数1：启动后的进程ID
# 参数2：最终启动端口
# 参数3：最终启动版本
# 参数3：最终启动命令
# 参数4：最终启动参数
function boot_check_dc_appflowyio_appflowy_client() {
    cd ${TMP_AFL_SETUP_WORK_DIR}

    # 实验部分
    echo_style_wrap_text "Starting 'boot check', hold on please"

    if [ -n "${TMP_AFL_SETUP_CTN_PORT}" ]; then
        echo_style_text "View the 'container visit'↓:"
        curl -s http://localhost:${TMP_AFL_SETUP_CTN_PORT}
    fi

    echo_soft_port "TMP_AFL_SETUP_OPN_PORT"
}

##########################################################################################################

# 7-1 下载扩展/驱动/插件
function down_ext_dc_appflowyio_appflowy_client() {
    cd ${TMP_AFL_SETUP_WORK_DIR}

    echo_style_wrap_text "Starting 'download exts', hold on please"

    return $?
}

# 7-2 安装与配置扩展/驱动/插件
function setup_ext_dc_appflowyio_appflowy_client() {
    cd ${TMP_AFL_SETUP_WORK_DIR}

    echo_style_wrap_text "Starting 'install exts', hold on please"

    return $?
}

##########################################################################################################

# 8-重新配置（有些软件安装完后需要重新配置）
function reconf_dc_appflowyio_appflowy_client()
{
    echo_style_wrap_text "Starting 'reconf', hold on please"

    # 授权iptables端口访问
    # echo_soft_port ${2}

    # 生成web授权访问脚本
    #echo_web_service_init_scripts "appflowyio_appflowy_client${LOCAL_ID}" "appflowyio_appflowy_client${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_AFL_SETUP_OPN_PORT} "${LOCAL_HOST}"

	return $?
}

##########################################################################################################

# x3-执行步骤
#    参数1：启动后的进程ID
#    参数2：最终启动端口
#    参数3：最终启动版本
#    参数4：最终启动命令
#    参数5：最终启动参数
function exec_step_appflowyio_appflowy_client() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_AFL_SETUP_CTN_ID="${1}"
    # local TMP_AFL_SETUP_PS_SID="${TMP_AFL_SETUP_CTN_ID:0:12}"
    local TMP_AFL_SETUP_CTN_PORT="${2}"
    # imgver111111/imgver111111_v1670000000
    local TMP_AFL_SETUP_CTN_VER="${3}"
    local TMP_AFL_SETUP_CTN_CMD="${4}"
    local TMP_AFL_SETUP_CTN_ARGS="${5}"

    # 统一编排到的路径
    local TMP_AFL_CURRENT_DIR=$(pwd)
    local TMP_AFL_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_AFL_SETUP_IMG_MARK_NAME}/${TMP_AFL_SETUP_CTN_VER}
    local TMP_AFL_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_AFL_SETUP_IMG_MARK_NAME}/${TMP_AFL_SETUP_CTN_VER}
    local TMP_AFL_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_AFL_SETUP_IMG_MARK_NAME}/${TMP_AFL_SETUP_CTN_VER}
    local TMP_AFL_SETUP_LNK_ETC_DIR=${DOCKER_APP_ATT_DIR}/${TMP_AFL_SETUP_IMG_MARK_NAME}/${TMP_AFL_SETUP_CTN_VER}

    # 统一标记名称(存在于安装目录的真实名称)
    local TMP_AFL_SETUP_WORK_MARK="work"
    local TMP_AFL_SETUP_LOGS_MARK="logs"
    local TMP_AFL_SETUP_DATA_MARK="data"
    local TMP_AFL_SETUP_ETC_MARK="etc"
    local TMP_AFL_SETUP_APP_MARK="chrome"

    # 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_AFL_SETUP_WORK_DIR=${TMP_AFL_SETUP_DIR}/${TMP_AFL_SETUP_WORK_MARK}
    local TMP_AFL_SETUP_LOGS_DIR=${TMP_AFL_SETUP_DIR}/${TMP_AFL_SETUP_LOGS_MARK}
    local TMP_AFL_SETUP_DATA_DIR=${TMP_AFL_SETUP_DIR}/${TMP_AFL_SETUP_DATA_MARK}
    local TMP_AFL_SETUP_ETC_DIR=${TMP_AFL_SETUP_DIR}/${TMP_AFL_SETUP_ETC_MARK}
    
    echo_style_wrap_text "Starting 'execute step' <${TMP_AFL_SETUP_IMG_NAME}>:[${TMP_AFL_SETUP_CTN_VER}]('${TMP_AFL_SETUP_CTN_ID}'), hold on please"

    set_env_dc_appflowyio_appflowy_client

    setup_dc_appflowyio_appflowy_client

    formal_dc_appflowyio_appflowy_client

    conf_dc_appflowyio_appflowy_client

    test_dc_appflowyio_appflowy_client

    # down_ext_dc_appflowyio_appflowy_client
    # setup_ext_dc_appflowyio_appflowy_client

    boot_check_dc_appflowyio_appflowy_client

    reconf_dc_appflowyio_appflowy_client

    return $?
}

##########################################################################################################

# x2-简略启动，获取初始化软件（形成启动后才可抽取目录信息）
#    参数1：镜像名称，例 appflowyio/appflowy_client
#    参数2：镜像版本，例 latest
#    参数3：启动命令，例 /bin/sh
#    参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#    参数5：快照类型(还原时有效)，例 image/container/dockerfile
#    参数6：快照来源，例 snapshot/clean/hub/commit，默认snapshot
function boot_build_dc_appflowyio_appflowy_client() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_AFL_SETUP_IMG_NAME="${1}"
    local TMP_AFL_SETUP_IMG_MARK_NAME="${1/\//_}"
    local TMP_AFL_SETUP_IMG_VER="${2}"
    local TMP_AFL_SETUP_CTN_ARG_CMD="${3}"
    local TMP_AFL_SETUP_CTN_ARGS="${4}"
    local TMP_AFL_SETUP_IMG_SNAP_TYPE="${5}"
    local TMP_AFL_SETUP_IMG_STORE="${6}"

    echo_style_wrap_text "Starting 'build container' <${TMP_AFL_SETUP_IMG_NAME}>:[${TMP_AFL_SETUP_IMG_VER}], hold on please"
    
    # 标准启动参数
    local TMP_AFL_SETUP_PRE_ARG_TIME="--volume=/etc/localtime:/etc/localtime"
    # local TMP_AFL_SETUP_PRE_ARG_NETWORKS="--network=${DOCKER_NETWORK}"
    local TMP_AFL_SETUP_PRE_ARG_PORTS="-p ${TMP_AFL_SETUP_OPN_PORT}:${TMP_AFL_SETUP_INN_PORT}"
    local TMP_AFL_SETUP_PRE_ARG_ENVS="--env=PREBOOT_CHROME=true --env=CONNECTION_TIMEOUT=-1 --env=MAX_CONCURRENT_SESSIONS=10 --env=WORKSPACE_DELETE_EXPIRED=true --env=WORKSPACE_EXPIRE_DAYS=7"
    local TMP_AFL_SETUP_PRE_ARGS="${TMP_AFL_SETUP_PRE_ARG_PORTS} ${TMP_AFL_SETUP_PRE_ARG_NETWORKS} --restart=always ${TMP_AFL_SETUP_PRE_ARG_ENVS} ${TMP_AFL_SETUP_PRE_ARG_TIME}"

    # 参数覆盖, 镜像参数覆盖启动设定
    echo_style_text "Starting 'combine container' <${TMP_AFL_SETUP_IMG_NAME}>:[${TMP_AFL_SETUP_IMG_VER}] boot args, hold on please"
    echo "${TMP_SPLITER2}"
    echo_style_text "<Container> 'pre' args(${TMP_AFL_SETUP_PRE_ARGS:-"None"}) && cmd(${TMP_AFL_SETUP_CTN_ARG_CMD:-"None"})"
    echo_style_text "<Container> 'ctn' args(${TMP_AFL_SETUP_CTN_ARGS:-"None"}) && cmd(${TMP_AFL_SETUP_CTN_ARG_CMD:-"None"})"
    docker_image_args_combine_bind "TMP_AFL_SETUP_PRE_ARGS" "TMP_AFL_SETUP_CTN_ARGS"
    echo_style_text "<Container> 'combine' args(${TMP_AFL_SETUP_PRE_ARGS:-"None"}) && cmd(${TMP_AFL_SETUP_CTN_ARG_CMD:-"None"})"

    # 开始启动
    docker_image_boot_print "${TMP_AFL_SETUP_IMG_NAME}" "${TMP_AFL_SETUP_IMG_VER}" "${TMP_AFL_SETUP_CTN_ARG_CMD}" "${TMP_AFL_SETUP_PRE_ARGS}" "" "exec_step_appflowyio_appflowy_client"

    return $?
}

##########################################################################################################

# x1-下载/安装/更新软件
function check_setup_dc_appflowyio_appflowy_client() {
    echo_style_wrap_text "Checking 'install' <${1}>, hold on please"

    # 重装/更新/安装
    soft_docker_check_upgrade_action "${1}" "boot_build_dc_appflowyio_appflowy_client"

    return $?
}

##########################################################################################################

#安装主体
soft_setup_basic "appflowyio/appflowy_client" "check_setup_dc_appflowyio_appflowy_client"