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
# docker ps -a --no-trunc | awk '{if($2~"postgres"){print $1}}' | xargs docker stop
# docker ps -a --no-trunc | awk '{if($2~"postgres"){print $1}}' | xargs docker rm
# docker images | awk '{if($1~"postgres"){print $3}}' | xargs docker rmi
# rm -rf /opt/docker_apps/library_postgres* && rm -rf /mountdisk/conf/docker_apps/library_postgres* && rm -rf /mountdisk/logs/docker_apps/library_postgres* && rm -rf /mountdisk/data/docker_apps/library_postgres* && rm -rf /opt/docker/data/apps/library_postgres* && rm -rf /opt/docker/conf/library_postgres* && rm -rf /opt/docker/logs/library_postgres* && rm -rf /mountdisk/repo/migrate/clean/library_postgres*
# rm -rf /mountdisk/repo/backup/opt/docker_apps/library_postgres* && rm -rf /mountdisk/repo/backup/mountdisk/conf/docker_apps/library_postgres* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/library_postgres* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/library_postgres* && rm -rf /mountdisk/repo/backup/opt/docker/data/apps/library_postgres* && rm -rf /mountdisk/repo/backup/opt/docker/conf/library_postgres* && rm -rf /mountdisk/repo/backup/opt/docker/logs/library_postgres*
# docker volume ls | awk 'NR>1{print $2}' | xargs docker volume rm
#------------------------------------------------
local TMP_DC_PSQ_SETUP_INN_PORT=5432
local TMP_DC_PSQ_SETUP_OPN_PORT=1${TMP_DC_PSQ_SETUP_INN_PORT}

##########################################################################################################

# 1-配置环境
function set_env_dc_library_postgres() {
    echo_style_wrap_text "Starting 'configuare install envs', hold on please"

    cd ${__DIR}

    return $?
}

##########################################################################################################

# 2-安装软件
function setup_dc_library_postgres() {
    echo_style_wrap_text "Starting 'install', hold on please"

    function _setup_dc_library_postgres_cp_source() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'workingdir copy'↓:"

        # 拷贝应用目录
        docker cp -a ${TMP_DC_PSQ_SETUP_CTN_ID}:/usr/lib/${TMP_DC_PSQ_DEPLOY_APP_MARK} ${1} >& /dev/null
    
        # 修改权限 & 查看列表
        sudo chown -R 2000:2000 ${1}
        ls -lia ${1}
    }

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_pcreate ${TMP_DC_PSQ_SETUP_WORK_DIR} "_setup_dc_library_postgres_cp_source"

    cd ${TMP_DC_PSQ_SETUP_DIR}

    # 开始安装

    return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_dc_library_postgres() {
    cd ${TMP_DC_PSQ_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs', hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移
    ### 日志
    #### /mountdisk/logs/docker_apps/library_postgres/imgver111111
    function _formal_dc_library_postgres_cp_logs() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'logs copy'↓:"

        # 拷贝日志目录
        ## /mountdisk/logs/docker_apps/library_postgres/imgver111111/app
        docker cp -a ${TMP_DC_PSQ_SETUP_CTN_ID}:/var/log/${TMP_DC_PSQ_DEPLOY_APP_MARK} ${1}/app >& /dev/null
        
        # 授权
        sudo chown -R 2000:2000 ${1}
    
        # 查看列表
        ls -lia ${1}/app
    }
    
    soft_path_restore_confirm_create "${TMP_DC_PSQ_SETUP_LNK_LOGS_DIR}" "_formal_dc_library_postgres_cp_logs"

    ### 数据
    #### /mountdisk/data/docker_apps/library_postgres/imgver111111
    function _formal_dc_library_postgres_cp_data() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'data copy'↓:"

        # 拷贝日志目录
        docker cp -a ${TMP_DC_PSQ_SETUP_CTN_ID}:/var/lib/${TMP_DC_PSQ_DEPLOY_APP_MARK}/data ${1} >& /dev/null
        # docker_bash_channel_exec "${TMP_DC_PSQ_SETUP_CTN_ID}" "pg_ctl stop -D /var/lib/${TMP_DC_PSQ_DEPLOY_APP_MARK}/data -s -m fast && rm -rf /var/lib/${TMP_DC_PSQ_DEPLOY_APP_MARK}/data"
        
        # 授权
        sudo chown -R 2000:2000 ${1}
        
        # 查看列表
        ls -lia ${1}
    }
    soft_path_restore_confirm_pcreate "${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}" "_formal_dc_library_postgres_cp_data"

    ### CONF - ①-1Y：存在配置文件：原路径文件放给真实路径
    #### /mountdisk/data/docker/containers/${CTN_ID}
    local TMP_DC_PSQ_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_DC_PSQ_SETUP_CTN_ID}"
    #### /mountdisk/conf/docker_apps/library_postgres/imgver111111/container
    local TMP_DC_PSQ_SETUP_LNK_CONF_CTN_DIR="${TMP_DC_PSQ_SETUP_LNK_CONF_DIR}/container"
    #### /mountdisk/conf/docker_apps/library_postgres/imgver111111
    function _formal_dc_library_postgres_cp_conf() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'conf copy'↓:"

        # 拷贝配置目录
        ## /mountdisk/conf/docker_apps/library_postgres/imgver111111/app
        docker cp -a ${TMP_DC_PSQ_SETUP_CTN_ID}:/etc/${TMP_DC_PSQ_DEPLOY_APP_MARK} ${1}/app >& /dev/null

        # 授权
        sudo chown -R 2000:2000 ${1}
        
        ls -lia ${1}/app
    
        #### /mountdisk/data/docker/containers/${CTN_ID} ©&<- /mountdisk/conf/docker_apps/library_postgres/imgver111111/container
        soft_path_restore_confirm_swap "${TMP_DC_PSQ_SETUP_LNK_CONF_CTN_DIR}" "${TMP_DC_PSQ_SETUP_CTN_DIR}"
    }
    soft_path_restore_confirm_create "${TMP_DC_PSQ_SETUP_LNK_CONF_DIR}" "_formal_dc_library_postgres_cp_conf"

    #### /mountdisk/conf/docker_apps/library_postgres/imgver111111/data
    function _formal_dc_library_postgres_lnk_conf() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'conf link'↓:"

        # 废弃，容器中无法检测到路径
        # #### /mountdisk/data/docker_apps/library_postgres/imgver111111/postgresql.conf -> /mountdisk/conf/docker_apps/library_postgres/imgver111111/data/postgresql.conf
        # path_swap_link "${1}/postgresql.conf" "${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}/postgresql.conf"
        # #### /mountdisk/data/docker_apps/library_postgres/imgver111111/pg_hba.conf -> /mountdisk/conf/docker_apps/library_postgres/imgver111111/data/pg_hba.conf
        # path_swap_link "${1}/pg_hba.conf" "${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}/pg_hba.conf"
        # #### /mountdisk/data/docker_apps/library_postgres/imgver111111/pg_ident.conf -> /mountdisk/conf/docker_apps/library_postgres/imgver111111/data/pg_ident.conf
        # path_swap_link "${1}/pg_ident.conf" "${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}/pg_ident.conf"

        # 反向link，不然在容器中检测不到文件路径
        #### /mountdisk/conf/docker_apps/library_postgres/imgver111111/data/postgresql.conf -> /mountdisk/data/docker_apps/library_postgres/imgver111111/postgresql.conf
        path_not_exists_link "${1}/postgresql.conf" "" "${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}/postgresql.conf"
        #### /mountdisk/conf/docker_apps/library_postgres/imgver111111/data/pg_hba.conf -> /mountdisk/data/docker_apps/library_postgres/imgver111111/pg_hba.conf
        path_not_exists_link "${1}/pg_hba.conf" "" "${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}/pg_hba.conf"
        #### /mountdisk/conf/docker_apps/library_postgres/imgver111111/data/pg_ident.conf -> /mountdisk/data/docker_apps/library_postgres/imgver111111/pg_ident.conf
        path_not_exists_link "${1}/pg_ident.conf" "" "${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}/pg_ident.conf"

        ls -lia ${1}
    }
    soft_path_restore_confirm_pcreate "${TMP_DC_PSQ_SETUP_LNK_CONF_DIR}/data" "_formal_dc_library_postgres_lnk_conf"
   
    ## 创建链接规则
    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'symlink create':↓"
    ### 日志
    #### /opt/docker_apps/library_postgres/imgver111111/logs -> /mountdisk/logs/docker_apps/library_postgres/imgver111111
    path_not_exists_link "${TMP_DC_PSQ_SETUP_LOGS_DIR}" "" "${TMP_DC_PSQ_SETUP_LNK_LOGS_DIR}"
    #### /opt/docker/logs/library_postgres/imgver111111 -> /mountdisk/logs/docker_apps/library_postgres/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_PSQ_SETUP_CTN_VER}" "" "${TMP_DC_PSQ_SETUP_LNK_LOGS_DIR}"
    #### /mountdisk/logs/docker_apps/library_postgres/imgver111111/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/library_postgres/imgver111111/container/${CTN_ID}-json.log
    path_not_exists_link "${TMP_DC_PSQ_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_PSQ_SETUP_CTN_ID}-json.log" "" "${TMP_DC_PSQ_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_PSQ_SETUP_CTN_ID}-json.log"
    ### 数据
    #### /opt/docker_apps/library_postgres/imgver111111/data -> /mountdisk/data/docker_apps/library_postgres/imgver111111
    path_not_exists_link "${TMP_DC_PSQ_SETUP_DATA_DIR}" "" "${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}"
    #### /opt/docker/data/apps/library_postgres/imgver111111 -> /mountdisk/data/docker_apps/library_postgres/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_DATA_MARK}/apps/${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_PSQ_SETUP_CTN_VER}" "" "${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}"
    ### CONF
    #### /opt/docker_apps/library_postgres/imgver111111/conf -> /mountdisk/conf/docker_apps/library_postgres/imgver111111
    path_not_exists_link "${TMP_DC_PSQ_SETUP_CONF_DIR}" "" "${TMP_DC_PSQ_SETUP_LNK_CONF_DIR}"
    #### /opt/docker/conf/library_postgres/imgver111111 -> /mountdisk/conf/docker_apps/library_postgres/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_CONF_MARK}/${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_PSQ_SETUP_CTN_VER}" "" "${TMP_DC_PSQ_SETUP_LNK_CONF_DIR}"
    #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/conf/docker_apps/library_postgres/imgver111111/container
    path_not_exists_link "${TMP_DC_PSQ_SETUP_CTN_DIR}" "" "${TMP_DC_PSQ_SETUP_LNK_CONF_CTN_DIR}"

    # 预实验部分        
    ## 目录调整完修改启动参数
    ## 修改启动参数
    # local TMP_DC_PSQ_SETUP_CTN_TMP="/tmp/${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_PSQ_SETUP_CTN_VER}"
    # soft_path_restore_confirm_create "${TMP_DC_PSQ_SETUP_CTN_TMP}"
    # ${TMP_DC_PSQ_SETUP_CTN_TMP}:/tmp"
    #
    # ${TMP_DC_PSQ_SETUP_WORK_DIR}:/usr/lib/${TMP_DC_PSQ_DEPLOY_APP_MARK}"
    # ${TMP_DC_PSQ_SETUP_LNK_LOGS_DIR}/app:/var/log/${TMP_DC_PSQ_DEPLOY_APP_MARK}"
    # ${TMP_DC_PSQ_SETUP_LNK_LOGS_DIR}/app:/usr/lib/${TMP_DC_PSQ_DEPLOY_APP_MARK}/${DEPLOY_LOGS_MARK}"
    # ${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}:/usr/lib/${TMP_DC_PSQ_DEPLOY_APP_MARK}/${DEPLOY_DATA_MARK}"
    # ${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}:/var/lib/${TMP_DC_PSQ_DEPLOY_APP_MARK}"
    # ${TMP_DC_PSQ_SETUP_LNK_CONF_DIR}/app:/usr/lib/${TMP_DC_PSQ_DEPLOY_APP_MARK}/${DEPLOY_CONF_MARK}
    # ${TMP_DC_PSQ_SETUP_LNK_CONF_DIR}/app:/etc/${TMP_DC_PSQ_DEPLOY_APP_MARK}
    echo "${TMP_SPLITER2}"
    echo_style_text "Starting 'inspect change', hold on please"

    # 挂载目录(必须停止服务才能修改，否则会无效)
    # if [ $(echo "${TMP_DC_PSQ_SETUP_SOFT_VER%.*} <= 5.7" | bc) == 1 ]; then
    docker_change_container_volume_migrate "${TMP_DC_PSQ_SETUP_CTN_ID}" "${TMP_DC_PSQ_SETUP_LNK_LOGS_DIR}/app:/var/log/${TMP_DC_PSQ_DEPLOY_APP_MARK} ${TMP_DC_PSQ_SETUP_LNK_DATA_DIR}:/var/lib/${TMP_DC_PSQ_DEPLOY_APP_MARK}/data ${TMP_DC_PSQ_SETUP_LNK_CONF_DIR}/app:/etc/${TMP_DC_PSQ_DEPLOY_APP_MARK}" "" $([[ -z "${TMP_DC_PSQ_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    # fi

    return $?
}

##########################################################################################################

# 4-设置软件
function conf_dc_library_postgres() {
    cd ${TMP_DC_PSQ_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration', hold on please"

    # 开始配置
    file_content_not_exists_echo "^superuser_reserved_connections.*" ${TMP_DC_PSQ_SETUP_LNK_CONF_DIR}/postgresql.conf "superuser_reserved_connections = 10"

    return $?
}

##########################################################################################################

# 5-测试软件
function test_dc_library_postgres() {
    cd ${TMP_DC_PSQ_SETUP_DIR}
    
    echo_style_wrap_text "Starting 'test', hold on please"

    # 实验部分
    ## 1：检测启停
    docker container stop ${TMP_DC_PSQ_SETUP_CTN_ID}
    docker container start ${TMP_DC_PSQ_SETUP_CTN_ID}

    return $?
}

##########################################################################################################

# 6-启动后检测脚本
function boot_check_dc_library_postgres() {
    cd ${TMP_DC_PSQ_SETUP_DIR}

    # 实验部分
    echo_style_wrap_text "Starting 'boot check', hold on please"

    if [ -n "${TMP_DC_PSQ_SETUP_CTN_PORT}" ]; then
        echo_style_text "View the 'container visit'↓:"
        curl -s http://localhost:${TMP_DC_PSQ_SETUP_CTN_PORT}
        echo

        # 授权iptables端口访问
        echo_soft_port "TMP_DC_PSQ_SETUP_OPN_PORT"
        
        # 生成web授权访问脚本
        # echo_web_service_init_scripts "library_postgres${LOCAL_ID}" "library_postgres${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_DC_PSQ_SETUP_OPN_PORT} "${LOCAL_HOST}"
    fi
    
    # 授权开机启动
    echo "${TMP_SPLITER2}"
    echo_style_text "View echo the 'supervisor startup conf'↓:"
    # echo_startup_supervisor_config "${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}" "${TMP_DC_PSQ_SETUP_DIR}" "systemctl start ${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}.service" "" "999" "" "" false 0
    echo_startup_supervisor_config "${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}" "${TMP_DC_PSQ_SETUP_DIR}" "bin/${TMP_DC_PSQ_SETUP_IMG_MARK_NAME} start"
}

##########################################################################################################

# 7-1 下载扩展/驱动/插件
function down_ext_dc_library_postgres() {
    cd ${TMP_DC_PSQ_SETUP_DIR}

    echo_style_wrap_text "Starting 'download exts', hold on please"

    return $?
}

# 7-2 安装与配置扩展/驱动/插件
function setup_ext_dc_library_postgres() {
    cd ${TMP_DC_PSQ_SETUP_DIR}

    echo_style_wrap_text "Starting 'install exts', hold on please"

    return $?
}

##########################################################################################################

# 8-重新配置（有些软件安装完后需要重新配置）
function reconf_dc_library_postgres()
{
    cd ${TMP_DC_PSQ_SETUP_DIR}
	
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
function exec_step_dc_library_postgres() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_DC_PSQ_SETUP_CTN_ID="${1}"
    # local TMP_DC_PSQ_SETUP_PS_SID="${TMP_DC_PSQ_SETUP_CTN_ID:0:12}"
    local TMP_DC_PSQ_SETUP_CTN_PORT="${2}"
    # imgver111111/imgver111111_v1670000000
    local TMP_DC_PSQ_SETUP_CTN_VER="${3}"
    local TMP_DC_PSQ_SETUP_CTN_CMD="${4}"
    local TMP_DC_PSQ_SETUP_CTN_ARGS="${5}"
    
    # 软件内部标识版本（$3已返回该版本号，仅测试选择15.3的场景）
    local TMP_DC_PSQ_SETUP_SOFT_VER=$(docker_bash_channel_exec "${1}" 'psql --version | grep -oP "(?<=\) ).+(?= \(Debian)"')

    ## 统一编排到的路径
    local TMP_DC_PSQ_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_PSQ_SETUP_CTN_VER}
    local TMP_DC_PSQ_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_PSQ_SETUP_CTN_VER}
    local TMP_DC_PSQ_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_PSQ_SETUP_CTN_VER}
    local TMP_DC_PSQ_SETUP_LNK_CONF_DIR=${DOCKER_APP_CONF_DIR}/${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}/${TMP_DC_PSQ_SETUP_CTN_VER}

    ## 统一标记名称(存在于安装目录的真实名称)
    local TMP_DC_PSQ_DEPLOY_APP_MARK="postgresql"

    ## 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_DC_PSQ_SETUP_WORK_DIR=${TMP_DC_PSQ_SETUP_DIR}/${DEPLOY_WORK_MARK}
    local TMP_DC_PSQ_SETUP_LOGS_DIR=${TMP_DC_PSQ_SETUP_DIR}/${DEPLOY_LOGS_MARK}
    local TMP_DC_PSQ_SETUP_DATA_DIR=${TMP_DC_PSQ_SETUP_DIR}/${DEPLOY_DATA_MARK}
    local TMP_DC_PSQ_SETUP_CONF_DIR=${TMP_DC_PSQ_SETUP_DIR}/${DEPLOY_CONF_MARK}
    
    echo_style_wrap_text "Starting 'execute step' <${TMP_DC_PSQ_SETUP_IMG_NAME}>:[${TMP_DC_PSQ_SETUP_CTN_VER}]('${TMP_DC_PSQ_SETUP_CTN_ID}'), hold on please"

    set_env_dc_library_postgres

    setup_dc_library_postgres

    formal_dc_library_postgres

    conf_dc_library_postgres

    test_dc_library_postgres

    # down_ext_dc_library_postgres
    # setup_ext_dc_library_postgres

    boot_check_dc_library_postgres

    reconf_dc_library_postgres
    
    # 结束
    exec_sleep 30 "Install <${TMP_DC_PSQ_SETUP_IMG_NAME}> over, please checking the setup log, this will stay 30 secs to exit"

    return $?
}

##########################################################################################################

# x2-简略启动，获取初始化软件（形成启动后才可抽取目录信息）
#    参数1：镜像名称，例 postgres
#    参数2：镜像版本，例 latest
#    参数3：启动命令，例 /bin/sh
#    参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#    参数5：快照类型(还原时有效)，例 image/container/dockerfile
#    参数6：快照来源，例 snapshot/clean/hub/commit，默认snapshot
function boot_build_dc_library_postgres() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_DC_PSQ_SETUP_IMG_NAME="${1}"
    local TMP_DC_PSQ_SETUP_IMG_MARK_NAME="${1/\//_}"
    local TMP_DC_PSQ_SETUP_IMG_VER="${2}"
    local TMP_DC_PSQ_SETUP_CTN_ARG_CMD="${3}"
    local TMP_DC_PSQ_SETUP_CTN_ARGS="${4}"
    local TMP_DC_PSQ_SETUP_IMG_SNAP_TYPE="${5}"
    local TMP_DC_PSQ_SETUP_IMG_STORE="${6}"

    echo_style_wrap_text "Starting 'build container' <${TMP_DC_PSQ_SETUP_IMG_NAME}>:[${TMP_DC_PSQ_SETUP_IMG_VER}], hold on please"

    # 设置密码
    local TMP_DC_PSQ_SETUP_DB_PASSWD=$(console_input "$(rand_simple_passwd 'psql' 'db' "${TMP_DC_PSQ_SETUP_IMG_VER}")" "Please sure your 'postgresql' <database password>" "y")
    
    ## 标准启动参数
    local TMP_DC_PSQ_SETUP_PRE_ARG_MOUNTS="--volume=/etc/localtime:/etc/localtime:ro"
    local TMP_DC_PSQ_SETUP_PRE_ARG_NETWORKS="--network=${DOCKER_NETWORK}"
    local TMP_DC_PSQ_SETUP_PRE_ARG_PORTS="-p ${TMP_DC_PSQ_SETUP_OPN_PORT}:${TMP_DC_PSQ_SETUP_INN_PORT}"
    local TMP_DC_PSQ_SETUP_PRE_ARG_ENVS="--env=TZ=Asia/Shanghai --privileged=true --expose ${TMP_DC_PSQ_SETUP_OPN_PORT} --env=POSTGRES_PASSWORD=${TMP_DC_PSQ_SETUP_DB_PASSWD}"
    local TMP_DC_PSQ_SETUP_PRE_ARGS="--name=${TMP_DC_PSQ_SETUP_IMG_MARK_NAME}_${TMP_DC_PSQ_SETUP_IMG_VER} ${TMP_DC_PSQ_SETUP_PRE_ARG_PORTS} ${TMP_DC_PSQ_SETUP_PRE_ARG_NETWORKS} --restart=always ${TMP_DC_PSQ_SETUP_PRE_ARG_ENVS} ${TMP_DC_PSQ_SETUP_PRE_ARG_MOUNTS}"

    # 参数覆盖, 镜像参数覆盖启动设定
    echo_style_text "<Container> 'pre' args && cmd↓:"
    echo "Args：${TMP_DC_PSQ_SETUP_PRE_ARGS:-None}"
    echo "Cmd：${TMP_DC_PSQ_SETUP_CTN_ARG_CMD:-None}"
    
    echo "${TMP_SPLITER3}"
    echo_style_text "<Container> 'ctn' args && cmd↓:"
    echo "Args：${TMP_DC_PSQ_SETUP_CTN_ARGS:-None}"
    echo "Cmd：${TMP_DC_PSQ_SETUP_CTN_ARG_CMD:-None}"
    
    echo "${TMP_SPLITER3}"
    echo_style_text "Starting 'combine container' <${TMP_DC_PSQ_SETUP_IMG_NAME}>:[${TMP_DC_PSQ_SETUP_IMG_VER}] boot args, hold on please"
    docker_image_args_combine_bind "TMP_DC_PSQ_SETUP_PRE_ARGS" "TMP_DC_PSQ_SETUP_CTN_ARGS"
    echo_style_text "<Container> 'combine' args && cmd↓:"
    echo "Args：${TMP_DC_PSQ_SETUP_PRE_ARGS:-None}"
    echo "Cmd：${TMP_DC_PSQ_SETUP_CTN_ARG_CMD:-None}"

    # 开始启动
    docker_image_boot_print "${TMP_DC_PSQ_SETUP_IMG_NAME}" "${TMP_DC_PSQ_SETUP_IMG_VER}" "${TMP_DC_PSQ_SETUP_CTN_ARG_CMD}" "${TMP_DC_PSQ_SETUP_PRE_ARGS}" "" "exec_step_dc_library_postgres"
    
    return $?
}

##########################################################################################################

# x1-下载/安装/更新软件
function check_setup_dc_library_postgres() {
	# 当前路径（仅记录）
    local TMP_DC_PSQ_CURRENT_DIR=$(pwd)

    echo_style_wrap_text "Checking 'install' <${1}>, hold on please"

    # 重装/更新/安装
    soft_docker_check_choice_upgrade_action "${1}" "boot_build_dc_library_postgres"

    return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "library/postgres" "check_setup_dc_library_postgres"