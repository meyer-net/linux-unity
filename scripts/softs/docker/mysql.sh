#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
#------------------------------------------------
# 安装版本：
#------------------------------------------------
# Debug：
# docker ps -a --no-trunc | awk '{if($2~"mysql"){print $1}}' | xargs docker stop
# docker ps -a --no-trunc | awk '{if($2~"mysql"){print $1}}' | xargs docker rm
# docker images | awk '{if($1~"mysql"){print $3}}' | xargs docker rmi
# rm -rf /opt/docker_apps/library_mysql* && rm -rf /mountdisk/etc/docker_apps/library_mysql* && rm -rf /mountdisk/logs/docker_apps/library_mysql* && rm -rf /mountdisk/data/docker_apps/library_mysql* && rm -rf /opt/docker/data/apps/library_mysql* && rm -rf /opt/docker/etc/library_mysql* && rm -rf /opt/docker/logs/library_mysql* && rm -rf /mountdisk/repo/migrate/clean/library_mysql* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/library_mysql* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/library_mysql* && rm -rf /mountdisk/repo/backup/mountdisk/etc/docker_apps/library_mysql*
# docker volume ls | awk 'NR>1{print $2}' | xargs docker volume rm
#------------------------------------------------
# 安装标题：$title_name
# 软件名称：library/mysql
# 软件端口：3306
# 软件大写分组与简称：MSQ
# 软件安装名称：mysql
# 软件工作运行目录：$work_dir
# 软件GIT仓储名称：${docker_prefix}
# 软件GIT仓储名称：${git_repo}
#------------------------------------------------
local TMP_DC_MSQ_SETUP_INN_PORT=3306
local TMP_DC_MSQ_SETUP_OPN_PORT=1${TMP_DC_MSQ_SETUP_INN_PORT}

##########################################################################################################

# 1-配置环境
function set_env_dc_library_mysql() {
    echo_style_wrap_text "Starting 'configuare install envs', hold on please"

    cd ${__DIR}

    return $?
}

# ##########################################################################################################

# 2-安装软件
function setup_dc_library_mysql() {
    echo_style_wrap_text "Starting 'install', hold on please"

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create ${TMP_DC_MSQ_SETUP_WORK_DIR}

    cd ${TMP_DC_MSQ_SETUP_DIR}

    # 开始安装

    return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_dc_library_mysql() {
    cd ${TMP_DC_MSQ_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs', hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移
    ### 日志
    #### /mountdisk/logs/docker_apps/library_mysql/5.7.42
    function _formal_dc_library_mysql_cp_logs() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'logs copy'↓:"

        # 拷贝日志目录
        ## /mountdisk/logs/docker_apps/library_mysql/5.7.42/app
        # $(expr "${TMP_DC_MSQ_SETUP_SOFT_VER%.*} <= 5.7" -eq 1)
        if [ $(echo "${TMP_DC_MSQ_SETUP_SOFT_VER%.*} <= 5.7" | bc) == 1 ]; then
            path_not_exists_create "${1}/app"
            docker cp -a ${TMP_DC_MSQ_SETUP_CTN_ID}:/var/log/${TMP_DC_MSQ_SETUP_APP_MARK}d.log ${1}/app/${TMP_DC_MSQ_SETUP_APP_MARK}d.log >& /dev/null
        else
            docker cp -a ${TMP_DC_MSQ_SETUP_CTN_ID}:/var/log/${TMP_DC_MSQ_SETUP_APP_MARK} ${1}/app >& /dev/null
        fi
    
        # 查看列表
        ls -lia ${1}
    }
    soft_path_restore_confirm_create "${TMP_DC_MSQ_SETUP_LNK_LOGS_DIR}" "_formal_dc_library_mysql_cp_logs"

    ### 数据
    #### /mountdisk/data/docker_apps/library_mysql/5.7.42
    function _formal_dc_library_mysql_cp_data() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'data copy'↓:"

        # 拷贝日志目录
        docker cp -a ${TMP_DC_MSQ_SETUP_CTN_ID}:/var/lib/${TMP_DC_MSQ_SETUP_DATA_MARK} ${1} >& /dev/null
        
        # 查看列表
        ls -lia ${1}
    }
    soft_path_restore_confirm_create "${TMP_DC_MSQ_SETUP_LNK_DATA_DIR}" "_formal_dc_library_mysql_cp_data"

    ### ETC - ①-1Y：存在配置文件：原路径文件放给真实路径
    #### /mountdisk/data/docker/containers/${CTN_ID}
    local TMP_DC_MSQ_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_DC_MSQ_SETUP_CTN_ID}"
    #### /mountdisk/etc/docker_apps/library_mysql/5.7.42/container
    local TMP_DC_MSQ_SETUP_LNK_ETC_CTN_DIR="${TMP_DC_MSQ_SETUP_LNK_ETC_DIR}/container"
    #### /mountdisk/etc/docker_apps/library_mysql/5.7.42
    function _formal_dc_library_mysql_cp_etc() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'etc copy'↓:"

        # 拷贝配置目录
        ## 版本>5.7 or <5.7
        ## /mountdisk/etc/docker_apps/library_mysql/5.7.42/app
        # docker cp -a ${TMP_DC_MSQ_SETUP_CTN_ID}:$work_dir/${TMP_DC_MSQ_SETUP_ETC_MARK} ${1}/app >& /dev/null
        docker cp -a ${TMP_DC_MSQ_SETUP_CTN_ID}:/etc/${TMP_DC_MSQ_SETUP_APP_MARK} ${1}/app >& /dev/null
        ls -lia ${1}
    
    #     # 移除本地配置目录(挂载)
    #     rm -rf ${TMP_DC_MSQ_SETUP_WORK_DIR}/${TMP_DC_MSQ_SETUP_ETC_MARK}
        #### /mountdisk/data/docker/containers/${CTN_ID} ©&<- /mountdisk/etc/docker_apps/library_mysql/5.7.42/container
        soft_path_restore_confirm_swap "${TMP_DC_MSQ_SETUP_LNK_ETC_CTN_DIR}" "${TMP_DC_MSQ_SETUP_CTN_DIR}"
    }
    soft_path_restore_confirm_create "${TMP_DC_MSQ_SETUP_LNK_ETC_DIR}" "_formal_dc_library_mysql_cp_etc"
    
    ## 创建链接规则
    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'symlink create':↓"
    ### 日志
    #### /opt/docker_apps/library_mysql/5.7.42/logs -> /mountdisk/logs/docker_apps/library_mysql/5.7.42
    path_not_exists_link "${TMP_DC_MSQ_SETUP_LOGS_DIR}" "" "${TMP_DC_MSQ_SETUP_LNK_LOGS_DIR}"
    #### /opt/docker/logs/library_mysql/5.7.42 -> /mountdisk/logs/docker_apps/library_mysql/5.7.42
    path_not_exists_link "${DOCKER_SETUP_DIR}/logs/${TMP_DC_MSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_MSQ_SETUP_CTN_VER}" "" "${TMP_DC_MSQ_SETUP_LNK_LOGS_DIR}"
    #### /mountdisk/logs/docker_apps/library_mysql/5.7.42/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/library_mysql/5.7.42/container/${CTN_ID}-json.log
    path_not_exists_link "${TMP_DC_MSQ_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_MSQ_SETUP_CTN_ID}-json.log" "" "${TMP_DC_MSQ_SETUP_LNK_ETC_CTN_DIR}/${TMP_DC_MSQ_SETUP_CTN_ID}-json.log"
    ### 数据
    #### /opt/docker_apps/library_mysql/5.7.42/data -> /mountdisk/data/docker_apps/library_mysql/5.7.42
    path_not_exists_link "${TMP_DC_MSQ_SETUP_DATA_DIR}" "" "${TMP_DC_MSQ_SETUP_LNK_DATA_DIR}"
    #### /opt/docker/data/apps/library_mysql/5.7.42 -> /mountdisk/data/docker_apps/library_mysql/5.7.42
    path_not_exists_link "${DOCKER_SETUP_DIR}/data/apps/${TMP_DC_MSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_MSQ_SETUP_CTN_VER}" "" "${TMP_DC_MSQ_SETUP_LNK_DATA_DIR}"
    ### ETC
    #### /opt/docker_apps/library_mysql/5.7.42/etc -> /mountdisk/etc/docker_apps/library_mysql/5.7.42
    path_not_exists_link "${TMP_DC_MSQ_SETUP_ETC_DIR}" "" "${TMP_DC_MSQ_SETUP_LNK_ETC_DIR}"
    #### /opt/docker/etc/library_mysql/5.7.42 -> /mountdisk/etc/docker_apps/library_mysql/5.7.42
    path_not_exists_link "${DOCKER_SETUP_DIR}/etc/${TMP_DC_MSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_MSQ_SETUP_CTN_VER}" "" "${TMP_DC_MSQ_SETUP_LNK_ETC_DIR}"
    # #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/etc/docker_apps/library_mysql/5.7.42/container
    path_not_exists_link "${TMP_DC_MSQ_SETUP_CTN_DIR}" "" "${TMP_DC_MSQ_SETUP_LNK_ETC_CTN_DIR}"

    # # 预实验部分        
    # ## 目录调整完修改启动参数
    # ## 修改启动参数
    # # local TMP_DC_MSQ_SETUP_CTN_TMP="/tmp/${TMP_DC_MSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_MSQ_SETUP_CTN_VER}"
    # # soft_path_restore_confirm_create "${TMP_DC_MSQ_SETUP_CTN_TMP}"
    # ${TMP_DC_MSQ_SETUP_CTN_TMP}:/tmp"
    #
    # ${TMP_DC_MSQ_SETUP_WORK_DIR}:$work_dir"
    # # ${TMP_DC_MSQ_SETUP_LNK_LOGS_DIR}/app:/var/logs/${TMP_DC_MSQ_SETUP_APP_MARK}"
    # # ${TMP_DC_MSQ_SETUP_LNK_LOGS_DIR}/app:$work_dir/${TMP_DC_MSQ_SETUP_LOGS_MARK}"
    # # ${TMP_DC_MSQ_SETUP_LNK_DATA_DIR}:$work_dir/${TMP_DC_MSQ_SETUP_DATA_MARK}"
    # # ${TMP_DC_MSQ_SETUP_LNK_DATA_DIR}:/var/lib/${TMP_DC_MSQ_SETUP_APP_MARK}"
    # # ${TMP_DC_MSQ_SETUP_LNK_ETC_DIR}/app:$work_dir/${TMP_DC_MSQ_SETUP_ETC_MARK}
    # # ${TMP_DC_MSQ_SETUP_LNK_ETC_DIR}/app:/etc/${TMP_DC_MSQ_SETUP_APP_MARK}
    # echo "${TMP_SPLITER2}"
    # echo_style_text "Starting 'inspect change', hold on please"

    # 挂载目录(必须停止服务才能修改，否则会无效)
    
    if [ $(echo "${TMP_DC_MSQ_SETUP_SOFT_VER%.*} <= 5.7" | bc) == 1 ]; then
        docker_change_container_volume_migrate "${TMP_DC_MSQ_SETUP_CTN_ID}" "${TMP_DC_MSQ_SETUP_LNK_LOGS_DIR}/app/${TMP_DC_MSQ_SETUP_APP_MARK}d.log:/var/logs/${TMP_DC_MSQ_SETUP_APP_MARK}d.log ${TMP_DC_MSQ_SETUP_LNK_DATA_DIR}:/var/lib/${TMP_DC_MSQ_SETUP_APP_MARK} ${TMP_DC_MSQ_SETUP_LNK_ETC_DIR}/app:/etc/${TMP_DC_MSQ_SETUP_APP_MARK}" "" $([[ -z "${TMP_DC_MSQ_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    else
        docker_change_container_volume_migrate "${TMP_DC_MSQ_SETUP_CTN_ID}" "${TMP_DC_MSQ_SETUP_LNK_LOGS_DIR}/app:/var/logs/${TMP_DC_MSQ_SETUP_APP_MARK} ${TMP_DC_MSQ_SETUP_LNK_DATA_DIR}:/var/lib/${TMP_DC_MSQ_SETUP_APP_MARK} ${TMP_DC_MSQ_SETUP_LNK_ETC_DIR}/app:/etc/${TMP_DC_MSQ_SETUP_APP_MARK}" "" $([[ -z "${TMP_DC_MSQ_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    fi

    return $?
}

##########################################################################################################

# 4-设置软件
function conf_dc_library_mysql() {
    cd ${TMP_DC_MSQ_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration', hold on please"

    # 开始配置
    # docker_bash_channel_exec "${TMP_DC_MSQ_SETUP_CTN_ID}" "sed -i \"s@os.tmpdir()@\'\/usr\/src\/app\'@g\" src/utils.js" "t" "root" "$work_dir"

    return $?
}

##########################################################################################################

# 5-测试软件
function test_dc_library_mysql() {
    cd ${TMP_DC_MSQ_SETUP_DIR}
    
    echo_style_wrap_text "Starting 'test', hold on please"

    # 实验部分

    return $?
}

##########################################################################################################

# 6-启动后检测脚本
function boot_check_dc_library_mysql() {
    cd ${TMP_DC_MSQ_SETUP_DIR}

    # 实验部分
    echo_style_wrap_text "Starting 'boot check', hold on please"

    if [ -n "${TMP_DC_MSQ_SETUP_CTN_PORT}" ]; then
        echo_style_text "View the 'container port'↓:"
        lsof -i:${TMP_DC_MSQ_SETUP_CTN_PORT}
        echo

        # 授权iptables端口访问
        echo_soft_port "TMP_DC_MSQ_SETUP_OPN_PORT"
    fi
}

##########################################################################################################

# 7-1 下载扩展/驱动/插件
function down_ext_dc_library_mysql() {
    cd ${TMP_DC_MSQ_SETUP_DIR}

    echo_style_wrap_text "Starting 'download exts', hold on please"

    return $?
}

# 7-2 安装与配置扩展/驱动/插件
function setup_ext_dc_library_mysql() {
    cd ${TMP_DC_MSQ_SETUP_DIR}

    echo_style_wrap_text "Starting 'install exts', hold on please"

    return $?
}

##########################################################################################################

# 8-重新配置（有些软件安装完后需要重新配置）
function reconf_dc_library_mysql()
{
    cd ${TMP_DC_MSQ_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'reconf', hold on please"

	return $?
}

##########################################################################################################

# x3-执行步骤
#    参数1：启动后的进程ID
#    参数2：最终启动端口
#    参数3：最终启动版本
#    参数4：最终启动命令
#    参数5：最终启动参数
function exec_step_dc_library_mysql() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_DC_MSQ_SETUP_CTN_ID="${1}"
    # local TMP_DC_MSQ_SETUP_PS_SID="${TMP_DC_MSQ_SETUP_CTN_ID:0:12}"
    local TMP_DC_MSQ_SETUP_CTN_PORT="${2}"
    # 5.7.42/5.7.42_v1670000000
    local TMP_DC_MSQ_SETUP_CTN_VER="${3}"
    local TMP_DC_MSQ_SETUP_CTN_CMD="${4}"
    local TMP_DC_MSQ_SETUP_CTN_ARGS="${5}"
    
    # 软件内部标识版本（$3已返回该版本号，仅测试选择5.7.42的场景）
    local TMP_DC_MSQ_SETUP_SOFT_VER=$(docker_bash_channel_exec "${1}" 'mysql -V | grep -oP "(?<=Distrib ).+(?=,)"')

    ## 统一编排到的路径
    local TMP_DC_MSQ_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_MSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_MSQ_SETUP_CTN_VER}
    local TMP_DC_MSQ_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_MSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_MSQ_SETUP_CTN_VER}
    local TMP_DC_MSQ_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_MSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_MSQ_SETUP_CTN_VER}
    local TMP_DC_MSQ_SETUP_LNK_ETC_DIR=${DOCKER_APP_ATT_DIR}/${TMP_DC_MSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_MSQ_SETUP_CTN_VER}

    ## 统一标记名称(存在于安装目录的真实名称)
    local TMP_DC_MSQ_SETUP_WORK_MARK="work"
    local TMP_DC_MSQ_SETUP_LOGS_MARK="logs"
    local TMP_DC_MSQ_SETUP_DATA_MARK="data"
    local TMP_DC_MSQ_SETUP_ETC_MARK="etc"
    local TMP_DC_MSQ_SETUP_APP_MARK="mysql"

    ## 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_DC_MSQ_SETUP_WORK_DIR=${TMP_DC_MSQ_SETUP_DIR}/${TMP_DC_MSQ_SETUP_WORK_MARK}
    local TMP_DC_MSQ_SETUP_LOGS_DIR=${TMP_DC_MSQ_SETUP_DIR}/${TMP_DC_MSQ_SETUP_LOGS_MARK}
    local TMP_DC_MSQ_SETUP_DATA_DIR=${TMP_DC_MSQ_SETUP_DIR}/${TMP_DC_MSQ_SETUP_DATA_MARK}
    local TMP_DC_MSQ_SETUP_ETC_DIR=${TMP_DC_MSQ_SETUP_DIR}/${TMP_DC_MSQ_SETUP_ETC_MARK}
    
    echo_style_wrap_text "Starting 'execute step' <${TMP_DC_MSQ_SETUP_IMG_NAME}>:[${TMP_DC_MSQ_SETUP_CTN_VER}]('${TMP_DC_MSQ_SETUP_CTN_ID}'), hold on please"

    set_env_dc_library_mysql

    setup_dc_library_mysql

    formal_dc_library_mysql

    conf_dc_library_mysql

    test_dc_library_mysql

    # down_ext_dc_library_mysql
    # setup_ext_dc_library_mysql

    boot_check_dc_library_mysql

    reconf_dc_library_mysql

    return $?
}

##########################################################################################################

# x2-简略启动，获取初始化软件（形成启动后才可抽取目录信息）
#    参数1：镜像名称，例 library/mysql
#    参数2：镜像版本，例 latest
#    参数3：启动命令，例 /bin/sh
#    参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#    参数5：快照类型(还原时有效)，例 image/container/dockerfile
#    参数6：快照来源，例 snapshot/clean/hub/commit，默认snapshot
function boot_build_dc_library_mysql() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_DC_MSQ_SETUP_IMG_NAME="${1}"
    local TMP_DC_MSQ_SETUP_IMG_MARK_NAME="${1/\//_}"
    local TMP_DC_MSQ_SETUP_IMG_VER="${2}"
    local TMP_DC_MSQ_SETUP_CTN_ARG_CMD="${3}"
    local TMP_DC_MSQ_SETUP_CTN_ARGS="${4}"
    local TMP_DC_MSQ_SETUP_IMG_SNAP_TYPE="${5}"
    local TMP_DC_MSQ_SETUP_IMG_STORE="${6}"

    echo_style_wrap_text "Starting 'build container' <${TMP_DC_MSQ_SETUP_IMG_NAME}>:[${TMP_DC_MSQ_SETUP_IMG_VER}], hold on please"
    
    ## 标准启动参数
    local TMP_DC_MSQ_SETUP_PRE_ARG_MOUNTS="--volume=/etc/localtime:/etc/localtime:ro"
    # local TMP_DC_MSQ_SETUP_PRE_ARG_NETWORKS="--network=${DOCKER_NETWORK}"
    local TMP_DC_MSQ_SETUP_PRE_ARG_PORTS="-p ${TMP_DC_MSQ_SETUP_OPN_PORT}:${TMP_DC_MSQ_SETUP_INN_PORT}"
    # 获取宿主机root权限
    local TMP_DC_MSQ_SETUP_DB_PASSWD=$(console_input "$(rand_passwd 'mysql' 'db' "${TMP_DC_MSQ_SETUP_IMG_VER}")" "Please sure your 'mysql' <database password>" "y")
    local TMP_DC_MSQ_SETUP_PRE_ARG_ENVS="--privileged=true --env=MYSQL_ROOT_PASSWORD=${TMP_DC_MSQ_SETUP_DB_PASSWD}" 
    local TMP_DC_MSQ_SETUP_PRE_ARGS="--name=${TMP_DC_MSQ_SETUP_IMG_MARK_NAME}_${TMP_DC_MSQ_SETUP_IMG_VER} ${TMP_DC_MSQ_SETUP_PRE_ARG_PORTS} ${TMP_DC_MSQ_SETUP_PRE_ARG_NETWORKS} --restart=always ${TMP_DC_MSQ_SETUP_PRE_ARG_ENVS} ${TMP_DC_MSQ_SETUP_PRE_ARG_MOUNTS}"

    # 参数覆盖, 镜像参数覆盖启动设定
    echo_style_text "<Container> 'pre' args && cmd↓:"
    echo "Args：${TMP_DC_MSQ_SETUP_PRE_ARGS:-None}"
    echo "Cmd：${TMP_DC_MSQ_SETUP_CTN_ARG_CMD:-None}"
    
    echo "${TMP_SPLITER3}"
    echo_style_text "<Container> 'ctn' args && cmd↓:"
    echo "Args：${TMP_DC_MSQ_SETUP_CTN_ARGS:-None}"
    echo "Cmd：${TMP_DC_MSQ_SETUP_CTN_ARG_CMD:-None}"
    
    echo "${TMP_SPLITER3}"
    echo_style_text "Starting 'combine container' <${TMP_DC_MSQ_SETUP_IMG_NAME}>:[${TMP_DC_MSQ_SETUP_IMG_VER}] boot args, hold on please"
    docker_image_args_combine_bind "TMP_DC_MSQ_SETUP_PRE_ARGS" "TMP_DC_MSQ_SETUP_CTN_ARGS"
    echo_style_text "<Container> 'combine' args && cmd↓:"
    echo "Args：${TMP_DC_MSQ_SETUP_PRE_ARGS:-None}"
    echo "Cmd：${TMP_DC_MSQ_SETUP_CTN_ARG_CMD:-None}"

    # 开始启动
    docker_image_boot_print "${TMP_DC_MSQ_SETUP_IMG_NAME}" "${TMP_DC_MSQ_SETUP_IMG_VER}" "${TMP_DC_MSQ_SETUP_CTN_ARG_CMD}" "${TMP_DC_MSQ_SETUP_PRE_ARGS}" "" "exec_step_dc_library_mysql"

    return $?
}

##########################################################################################################

# x1-下载/安装/更新软件
function check_setup_dc_library_mysql() {
	# 当前路径（仅记录）
    local TMP_DC_MSQ_CURRENT_DIR=$(pwd)

    echo_style_wrap_text "Checking 'install' <${1}>, hold on please"

    # 重装/更新/安装
    soft_docker_check_choice_upgrade_action "${1}" "boot_build_dc_library_mysql"

    return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "library/mysql" "check_setup_dc_library_mysql"