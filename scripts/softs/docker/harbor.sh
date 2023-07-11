#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
#------------------------------------------------
# 安装镜像版本：v1.10.0(--with-clair --with-chartmuseum) v2.8.0(--with-trivy)
# 依赖镜像版本：v1.10.17
#------------------------------------------------
# 涵盖：redis、postgresql等服务
#------------------------------------------------
# source scripts/softs/docker/harbor.sh
#------------------------------------------------
# Debug：
# dpa -f name="goharbor" | awk 'NR>1{print $1}' | xargs docker stop
# dpa -f name="goharbor" | awk 'NR>1{print $1}' | xargs -I {} docker rm {} && rm -rf /mountdisk/data/docker/containers/{}*
# di | awk '{if($1~"goharbor/"){print $3}}' | xargs docker rmi
# rm -rf /opt/docker_apps/goharbor* && rm -rf /mountdisk/conf/docker_apps/goharbor* && rm -rf /mountdisk/logs/docker_apps/goharbor* && rm -rf /mountdisk/data/docker_apps/goharbor* && rm -rf /opt/docker/data/apps/goharbor* && rm -rf /opt/docker/conf/goharbor* && rm -rf /opt/docker/logs/goharbor* && rm -rf /mountdisk/repo/migrate/clean/goharbor* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/goharbor* && rm -rf /mountdisk/repo/backup/mountdisk/conf/docker_apps/goharbor* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/goharbor* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker/volumes/000000000000_* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker/volumes/000000000000_* && rm -rf /mountdisk/repo/backup/mountdisk/conf/docker/volumes/000000000000_* && rm -rf /mountdisk/conf/conda_apps/supervisor/boots/goharbor*.conf && rm -rf /home/docker/.harbor
# rm -rf /mountdisk/repo/backup/opt/docker_apps/goharbor* && rm -rf /mountdisk/repo/backup/mountdisk/conf/docker_apps/goharbor* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/goharbor* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/goharbor* && rm -rf /mountdisk/repo/backup/opt/docker/data/apps/goharbor* && rm -rf /mountdisk/repo/backup/opt/docker/conf/goharbor* && rm -rf /mountdisk/repo/backup/opt/docker/logs/goharbor*
# dvl | awk '{print $2}' | xargs dvr
# dvl | awk 'NR>1{print $2}' | xargs -I {} dvi {} | jq ".[0].Mountpoint" | xargs -I {} echo {} | xargs ls -lia
#------------------------------------------------
# 安装标题：$title_name
# 软件名称：goharbor/harbor
# 软件端口：10080
# 软件大写分组与简称：HB
# 软件安装名称：goharbor_harbor
# 软件GIT仓储名称：${docker_prefix}
# 软件GIT仓储名称：${git_repo}
#------------------------------------------------
local TMP_DC_HB_DISPLAY_TITLE="harbor"
# 安装仓库（顶层目录使用）
local TMP_DC_HB_SETUP_REPO="goharbor/harbor"
local TMP_DC_HB_DOWN_VER="1.10.17"
local TMP_DC_HB_SETUP_INN_HTTP_PORT=80
local TMP_DC_HB_SETUP_INN_HTTPS_PORT=443
local TMP_DC_HB_SETUP_OPN_HTTP_PORT=101${TMP_DC_HB_SETUP_INN_HTTP_PORT}
local TMP_DC_HB_SETUP_OPN_HTTPS_PORT=11${TMP_DC_HB_SETUP_INN_HTTPS_PORT}

##########################################################################################################

# 1-配置环境
function set_env_dc_harbor() {
    echo_style_wrap_text "Starting 'configuare install envs' <${TMP_DC_HB_SETUP_REPO}>, hold on please"

    cd ${__DIR}

    return $?
}

##########################################################################################################

# 4-1-1：安装软件
function setup_dc_rely_harbor() {
    echo_style_wrap_text "Starting 'install rely' <${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}>, hold on please"

	## /opt/docker_apps/goharbor_harbor/v1.10.0/work/rely/goharbor_registry-photon/v1.10.17
	local TMP_DC_HB_SETUP_WORK_RELY_SERVICE_DIR=${TMP_DC_CPL_HB_SETUP_WORK_DIR}/${DEPLOY_RELY_MARK}/${TMP_DC_HB_SETUP_RELY_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_RELY_IMG_VER}

    # 有容器，且有workdir的情况，且workdir不是根目录的情况
    if [[ -n "${TMP_DC_HB_SETUP_RELY_CTN_ID}" && -n "${TMP_DC_HB_SETUP_RELY_CTN_WORK_DIR}" && "${TMP_DC_HB_SETUP_RELY_CTN_WORK_DIR}" != "/"  ]]; then
        # 工作
        ## /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/work
        function _setup_dc_rely_harbor_cp_work() {
            echo "${TMP_SPLITER2}"
            echo_style_text "[View] the 'workingdir copy rely'↓:"

            # 拷贝应用目录
            docker cp -a ${TMP_DC_HB_SETUP_RELY_CTN_ID}:${TMP_DC_HB_SETUP_RELY_CTN_WORK_DIR} ${1} >& /dev/null
        
            # 修改权限 & 查看列表
            sudo chown -R ${TMP_DC_HB_SETUP_RELY_CTN_UID}:${TMP_DC_HB_SETUP_RELY_CTN_GID} ${1}
            ls -lia ${1}
            echo
        }

        # 创建安装目录(纯属为了规范)
        soft_path_restore_confirm_pcreate ${TMP_DC_HB_SETUP_RELY_SERVICE_WORK_DIR} "_setup_dc_rely_harbor_cp_work"
        
        ### 工作
        #### /opt/docker_apps/goharbor_harbor/v1.10.0/work/rely/goharbor_registry-photon/v1.10.17 -> /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/work
        path_not_exists_link "${TMP_DC_HB_SETUP_WORK_RELY_SERVICE_DIR}" "" "${TMP_DC_HB_SETUP_RELY_SERVICE_WORK_DIR}"

        TMP_DC_HB_SETUP_ATT_MOUNTS="${TMP_DC_HB_SETUP_ATT_MOUNTS} ${TMP_DC_HB_SETUP_RELY_SERVICE_WORK_DIR}:${TMP_DC_HB_SETUP_RELY_CTN_WORK_DIR}:rw,z"
    fi

    cd ${TMP_DC_BLC_SETUP_DIR}

    # 开始安装

    return $?
}

# 4-1-2：规格化软件目录格式
function formal_dc_rely_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs rely' <${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}>, hold on please"
    
    # 开始标准化
    ## 创建链接规则"
    echo_style_text "[View] the 'symlink create rely':↓"

    ### 日志
    #### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/logs/compose/registry.log -> /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose/registry.log
    path_not_exists_link "${TMP_DC_HB_SETUP_RELY_SERVICE_LOGS_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}.log" "" "${TMP_DC_HB_SETUP_RELY_LNK_COMPOSE_LOGS_DIR}.log"
    #### /opt/docker/logs/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/compose/registry.log -> /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose/registry.log
    #### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/compose/registry.log -> /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose/registry.log
    path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_LOGS_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}.log" "" "${TMP_DC_HB_SETUP_RELY_LNK_COMPOSE_LOGS_DIR}.log"
    
    ### 数据
    #### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/data -> /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    path_not_exists_link "${TMP_DC_HB_SETUP_RELY_SERVICE_DATA_DIR}" "" "${TMP_DC_HB_SETUP_RELY_LNK_COMPOSE_DATA_DIR}"
    #### /opt/docker/data/apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17 -> /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    #### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17 -> /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_DATA_DIR}" "" "${TMP_DC_HB_SETUP_RELY_LNK_COMPOSE_DATA_DIR}"

    ### CONF
    #### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/conf/compose -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    path_not_exists_link "${TMP_DC_HB_SETUP_RELY_SERVICE_CONF_DIR}/${DEPLOY_COMPOSE_MARK}" "" "${TMP_DC_HB_SETUP_RELY_LNK_COMPOSE_CONF_DIR}"
    #### /opt/docker/conf/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/compose -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    #### /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/compose -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_CONF_DIR}/${DEPLOY_COMPOSE_MARK}" "" "${TMP_DC_HB_SETUP_RELY_LNK_COMPOSE_CONF_DIR}"

    # 有可能未创建容器，有容器的情况下才操作
    if [ -n "${TMP_DC_HB_SETUP_RELY_CTN_ID}" ]; then        
        #### /mountdisk/data/docker/containers/${CTN_ID}
        local TMP_DC_HB_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_DC_HB_SETUP_RELY_CTN_ID}"
        #### /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/container/registry
        local TMP_DC_HB_SETUP_LNK_CONF_CTN_DIR="${TMP_DC_CPL_HB_SETUP_LNK_CONF_DIR}/container/${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}"
        
        #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/container/registry
        path_swap_link "${TMP_DC_HB_SETUP_LNK_CONF_CTN_DIR}" "${TMP_DC_HB_SETUP_CTN_DIR}"
        #### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/conf/container -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/container/registry
        path_not_exists_link "${TMP_DC_HB_SETUP_RELY_SERVICE_CONF_DIR}/container" "" "${TMP_DC_HB_SETUP_LNK_CONF_CTN_DIR}"
        #### /opt/docker/conf/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/container -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/container/registry
        #### /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/container -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/container/registry
        path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_CONF_DIR}/container" "" "${TMP_DC_HB_SETUP_LNK_CONF_CTN_DIR}"
		
        # 等待容器日志生成
        exec_sleep_until_not_empty "Waitting for [container log] generate '${TMP_DC_HB_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_HB_SETUP_RELY_CTN_ID}-json.log'" "[ -a ${TMP_DC_HB_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_HB_SETUP_RELY_CTN_ID}-json.log ] && echo 1" 10 1
        
        #### /opt/docker/logs/goharbor_harbor/v1.10.0/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        #### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        path_not_exists_link "${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_HB_SETUP_RELY_CTN_ID}-json.log" "" "${TMP_DC_HB_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_HB_SETUP_RELY_CTN_ID}-json.log"
        #### /opt/docker/logs/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        #### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_LOGS_DIR}/container/${TMP_DC_HB_SETUP_RELY_CTN_ID}-json.log" "" "${TMP_DC_HB_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_HB_SETUP_RELY_CTN_ID}-json.log"

        # 预实验部分        
        ## 目录调整完修改启动参数
        ## 修改启动参数
        echo "${TMP_SPLITER2}"
        echo_style_text "Starting 'inspect change rely', hold on please"

        # 挂载目录(标记需挂载的磁盘，必须停止服务才能修改，否则会无效)
        cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}

        ## docker_container_hostconfig_binds_echo 覆盖不到全部，有特殊复制直接在流程中拷贝出来并指定映射关系。
        trim_str "TMP_DC_HB_SETUP_ATT_MOUNTS"
        docker_change_container_volume_migrate "${TMP_DC_HB_SETUP_RELY_CTN_ID}" "${TMP_DC_HB_SETUP_ATT_MOUNTS} $(docker_container_hostconfig_binds_echo "${TMP_DC_HB_SETUP_RELY_CTN_ID}")"
        # docker_change_container_volume_migrate "${TMP_DC_HB_SETUP_RELY_CTN_ID}" "$(docker_container_hostconfig_binds_echo "${TMP_DC_HB_SETUP_RELY_CTN_ID}")" "" $([[ -z "${TMP_DC_HB_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    fi

    return $?
}

##########################################################################################################

# 4-1-3：设置软件
function conf_dc_rely_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration rely' <${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}>, hold on please"

    # 开始配置

    return $?
}

##########################################################################################################

# 4-1-4：启动后检测脚本
# 参数1：最终启动名称
# 参数2：最终启动端口
function boot_check_dc_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    # 当前启动名称
    local TMP_DC_HB_SETUP_CTN_CURRENT_NAME=${1}

    # 当前启动端口
    local TMP_DC_HB_SETUP_CTN_CURRENT_PORT=${2}

    # 实验部分  
    ## 有可能未创建容器，有容器的情况下才打印
    echo_style_wrap_text "Starting 'boot check' <${1}>, hold on please"
    if [ -n "${TMP_DC_HB_SETUP_RELY_CTN_ID}" ]; then
        function _boot_check_dc_harbor()
        {
            TMP_DC_HB_SETUP_CTN_CURRENT_PORT=$(echo "${TMP_DC_HB_SETUP_CTN_CURRENT_PORT:-${2}}" | awk 'NR==1')
            if [ -n "${TMP_DC_HB_SETUP_CTN_CURRENT_PORT}" ]; then
                echo "${TMP_SPLITER3}"
                echo_style_text "[View] the 'container visit'↓:"
                curl -s http://localhost:${TMP_DC_HB_SETUP_CTN_CURRENT_PORT}
                echo

                # 授权iptables端口访问
                echo "${TMP_SPLITER2}"
                echo_style_text "[View] echo the 'port'(<${TMP_DC_HB_SETUP_CTN_CURRENT_PORT}>) to iptables:↓"
                echo_soft_port "${TMP_DC_HB_SETUP_CTN_CURRENT_PORT}"
                
                # 生成web授权访问脚本
                echo_web_service_init_scripts "${TMP_DC_CPL_HB_SETUP_MARK_REPO}_${TMP_DC_HB_SETUP_RELY_IMG_VER}-${1}${LOCAL_ID}" "${TMP_DC_CPL_HB_SETUP_MARK_REPO}-${1}${LOCAL_ID}-webui.${SYS_DOMAIN}" ${2} "${LOCAL_HOST}"

                # 结束
                exec_sleep 10 "Boot <${TMP_DC_HB_SETUP_CTN_CURRENT_NAME}> over, please checking the setup log, this will stay [%s] secs to exit"
            fi
        }

        docker_container_print "${TMP_DC_HB_SETUP_RELY_CTN_ID}" "_boot_check_dc_harbor"
    fi
}

##########################################################################################################

# x4-1：执行步骤
# 参数1：当前yaml节点信息
# 参数2：当前yaml节点索引
# 参数3：当前yaml节点key（由docker-compose.yml设定结构为准），例harbor的keys core/log/db/nginx/registry
function exec_step_dc_rely_harbor() {
	# 变量覆盖特性，其它方法均可读取
    
    ### goharbor/harbor-core:v1.10.0
    local TMP_DC_HB_SETUP_SERVICE_IMG_FULL_NAME=$(echo "${TMP_DC_HB_SETUP_SERVICE_NODE}" | yq ".image") 
    ### harbor-core(未设定container_name的场景)
    local TMP_DC_HB_SETUP_SERVICE_CTN_NAME=$(echo "${TMP_DC_HB_SETUP_SERVICE_NODE}" | yq ".container_name")
    
    # 检索绑定查询到的容器信息(特殊使用时才会用到)
    function _exec_step_dc_rely_harbor()
    {
        # 定义检索参数
        local TMP_DC_HB_SETUP_RELY_IMG_ID=${1}
        local TMP_DC_HB_SETUP_RELY_CTN_ID=${2}
        # local TMP_DC_HB_SETUP_CTN_SID="${TMP_DC_HB_SETUP_RELY_CTN_ID:0:12}"
        ## goharbor/harbor-core
        local TMP_DC_HB_SETUP_RELY_IMG_NAME=${3}
        ## goharbor_registry-photon
        local TMP_DC_HB_SETUP_RELY_IMG_MARK_NAME=${3/\//_}
        ## v1.10.0
        local TMP_DC_HB_SETUP_RELY_IMG_VER=${4}
        ## /bin/sh
        local TMP_DC_HB_SETUP_RELY_CTN_CMD=${5}
        ## --env=xxx
        local TMP_DC_HB_SETUP_RELY_CTN_ARGS=${6}
        ## 10080
        local TMP_DC_HB_SETUP_CTN_PORT=$(echo "${6}" | grep -oP "(?<=-p )\d+(?=:\d+)")
        ## /harbor
        local TMP_DC_HB_SETUP_RELY_CTN_WORK_DIR="$(echo "${6}" | grep -oP "(?<=--workdir\=)[^\s]+")"
        if [ -z "${TMP_DC_HB_SETUP_RELY_CTN_WORK_DIR}" ]; then
            TMP_DC_HB_SETUP_RELY_CTN_WORK_DIR=$(docker container inspect --format '{{.Config.WorkingDir}}' ${TMP_DC_HB_SETUP_RELY_CTN_ID})
        fi

        # 默认取进入时的目录
        if [ -z "${TMP_DC_HB_SETUP_RELY_CTN_WORK_DIR}" ]; then
            TMP_DC_HB_SETUP_RELY_CTN_WORK_DIR=$(docker_bash_channel_exec "${2}" "pwd")
        fi

        # 获取授权用户的UID/GID
        local TMP_DC_HB_SETUP_RELY_CTN_USER="$(echo "${6}" | grep -oP "(?<=--user\=)[^\s]+")"
        if [ -z "${TMP_DC_HB_SETUP_RELY_CTN_USER}" ]; then
            TMP_DC_HB_SETUP_RELY_CTN_USER=$(docker_bash_channel_exec "${2}" "whoami")
        fi
        
        local TMP_DC_HB_SETUP_RELY_CTN_UID=$(docker_bash_channel_exec "${2}" "id -u ${TMP_DC_HB_SETUP_RELY_CTN_USER}")
        local TMP_DC_HB_SETUP_RELY_CTN_GID=$(docker_bash_channel_exec "${2}" "id -g ${TMP_DC_HB_SETUP_RELY_CTN_USER}")

        # 统一编排到的路径(需注意日志与配置部分，注意会有多层结构，即不止compose)
        ## !!!-1 路径由 habor.yml决定了logs根目录位置：/mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose
        ## !!!-2 路径由 habor.yml决定了data根目录位置：/mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/compose
        ## !!!-3 路径由 prepare决定了conf根目录位置：/mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/compose
        ## /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose/registry
        local TMP_DC_HB_SETUP_RELY_LNK_COMPOSE_LOGS_DIR=${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}
        ## /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/compose/registry
        local TMP_DC_HB_SETUP_RELY_LNK_COMPOSE_DATA_DIR=${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}
        ## /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/compose/registry
        local TMP_DC_HB_SETUP_RELY_LNK_COMPOSE_CONF_DIR=${TMP_DC_CPL_HB_SETUP_LNK_CONF_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}

        # 指定Docker的安装路径部分
        ## /opt/docker/logs/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        ##T /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_SETUP_HB_RELY_LNK_LOGS_DIR=${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/${DEPLOY_RELY_MARK}/${TMP_DC_HB_SETUP_RELY_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_RELY_IMG_VER}
        ## /opt/docker/data/apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        ##T /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_SETUP_HB_RELY_LNK_DATA_DIR=${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}/${DEPLOY_RELY_MARK}/${TMP_DC_HB_SETUP_RELY_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_RELY_IMG_VER}
        ## /opt/docker/conf/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        ##T /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_SETUP_HB_RELY_LNK_CONF_DIR=${TMP_DC_CPL_HB_SETUP_LNK_CONF_DIR}/${DEPLOY_RELY_MARK}/${TMP_DC_HB_SETUP_RELY_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_RELY_IMG_VER}

        # 安装后的规范路径（此处依据实际路径名称修改）
        ## /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_HB_SETUP_RELY_SERVICE_BASE_DIR=${TMP_DC_CPL_HB_SETUP_RELY_DIR}/${TMP_DC_HB_SETUP_RELY_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_RELY_IMG_VER}
        ##T /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/work
        local TMP_DC_HB_SETUP_RELY_SERVICE_WORK_DIR=${TMP_DC_HB_SETUP_RELY_SERVICE_BASE_DIR}/${DEPLOY_WORK_MARK}
        ## /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/logs
        local TMP_DC_HB_SETUP_RELY_SERVICE_LOGS_DIR=${TMP_DC_HB_SETUP_RELY_SERVICE_BASE_DIR}/${DEPLOY_LOGS_MARK}
        ## /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/data
        local TMP_DC_HB_SETUP_RELY_SERVICE_DATA_DIR=${TMP_DC_HB_SETUP_RELY_SERVICE_BASE_DIR}/${DEPLOY_DATA_MARK}
        ## /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/conf
        local TMP_DC_HB_SETUP_RELY_SERVICE_CONF_DIR=${TMP_DC_HB_SETUP_RELY_SERVICE_BASE_DIR}/${DEPLOY_CONF_MARK}
        
        echo_style_text "[View] the 'build yaml'↓:"
        echo "${TMP_DC_HB_SETUP_SERVICE_NODE}" | yq

        ## 标准启动参数
        local TMP_DC_HB_SETUP_ATT_MOUNTS=""

        setup_dc_rely_harbor

        formal_dc_rely_harbor

        conf_dc_rely_harbor
        
        boot_check_dc_harbor "${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}" "${TMP_DC_HB_SETUP_CTN_PORT}"
    }

    # 从容器中提取启动数据
    echo_style_wrap_text "Starting 'execute step rely' <${TMP_DC_HB_SETUP_SERVICE_IMG_FULL_NAME}>('${TMP_DC_HB_SETUP_SERVICE_CTN_NAME}'/'${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}'), hold on please"
    docker_container_param_check_action "${TMP_DC_HB_SETUP_SERVICE_CTN_NAME}" "_exec_step_dc_rely_harbor"
    
    return $?
}

##########################################################################################################

# x3-2：规格化软件目录格式
function formal_adjust_cps_dc_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}

    echo_style_wrap_text "Starting 'formal adjust compose dirs', hold on please"
	
    ## 指定Docker的安装路径部分
    ### /opt/docker/logs/goharbor_harbor/v1.10.0 & /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_SETUP_HB_DC_LOGS_DIR=${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${TMP_DC_CPL_HB_SETUP_MARK_REPO}/${TMP_DC_CPL_HB_SETUP_VER}
    ### /opt/docker/data/apps/goharbor_harbor/v1.10.0 & /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_SETUP_HB_DC_DATA_DIR=${DOCKER_SETUP_DIR}/${DEPLOY_DATA_MARK}/apps/${TMP_DC_CPL_HB_SETUP_MARK_REPO}/${TMP_DC_CPL_HB_SETUP_VER}
    ### /opt/docker/conf/goharbor_harbor/v1.10.0 & /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_SETUP_HB_DC_CONF_DIR=${DOCKER_SETUP_DIR}/${DEPLOY_CONF_MARK}/${TMP_DC_CPL_HB_SETUP_MARK_REPO}/${TMP_DC_CPL_HB_SETUP_VER}

    # 创建链接规则
    echo_style_text "[View] the 'symlink create':↓"

    ## 日志
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/logs -> /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_HB_SETUP_LOGS_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}"
    ### /opt/docker/logs/goharbor_harbor/v1.10.0 -> /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_SETUP_HB_DC_LOGS_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}"
    ## 数据
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/data -> /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_HB_SETUP_DATA_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}"
    ### /opt/docker/data/apps/goharbor_harbor/v1.10.0 -> /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_SETUP_HB_DC_DATA_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}"
    ## CONF
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/conf -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_HB_SETUP_CONF_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_CONF_DIR}"
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/compose/common/config -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/compose
    path_not_exists_link "${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}/common/config" "" "${TMP_DC_CPL_HB_SETUP_LNK_CONF_DIR}/${DEPLOY_COMPOSE_MARK}"
    ### /opt/docker/conf/goharbor_harbor/v1.10.0 -> /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_SETUP_HB_DC_CONF_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_CONF_DIR}"
    
    return $?
}

# x3-3：配置.env/compose.yml
function conf_adjust_cps_dc_harbor() {
    echo_style_wrap_text "Starting 'configuration compose.yml & .env', hold on please"
	# 修改配置文件
    cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}

    # 1：修改.env
    ## !!!由于原始脚本限定在install.sh中执行了prepare，所以此处在预编译完成后且安装前将其禁用
    sed -i "s@^./prepare@#./prepare@g" install.sh

    # 2：修改docker-compose.yml(新增初始目录挂载支援)
    function _conf_adjust_cps_dc_harbor_support_empty_certs()
    {
        # 必须创建一个目录，否则会出现错误 ls: /harbor_cust_cert: No such file or directory
        if [[ "${3}" == "chartmuseum" || "${3}" == "clair" || "${3}" == "registryctl" || "${3}" == "registry" ]]; then
            mkdir -pv common/harbor_cust_cert
            yq -i ".services.${3}.volumes = .services.${3}.volumes + [\"./common/harbor_cust_cert:/harbor_cust_cert:rw,z\"]" docker-compose.yml
        fi
    }
    yaml_split_action "$(cat docker-compose.yml | yq '.services')" "_conf_adjust_cps_dc_harbor_support_empty_certs"

    # 3：修改docker-compose.yml（担心network在本机环境下产生冲突，此处不传递）
    docker_compose_yml_formal_exec "${TMP_DC_CPL_HB_SETUP_NAME%%/*}"

    return $?
}

# x3-1：解析compose文件，并安装
#    参数1：（忽略）镜像名称，例 goharbor/prepare
#    参数2：（忽略）镜像版本，例 latest
#    参数3：（忽略）启动命令，例 /bin/sh
#    参数4：（忽略）启动参数，例 --volume /etc/localtime:/etc/localtime
#    参数5：（忽略）快照类型(还原时有效)，例 image/container/dockerfile
#    参数6：（忽略）快照来源，例 snapshot/clean/hub/commit，默认snapshot
function exec_resolve_compose_dc_harbor_loop()
{
    cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}

	# 变量覆盖特性，其它方法均可读取
    ## 安装后的规范路径（此处依据实际路径名称修改）
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/rely
    local TMP_DC_CPL_HB_SETUP_RELY_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${DEPLOY_RELY_MARK}
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/work
    local TMP_DC_CPL_HB_SETUP_WORK_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${DEPLOY_WORK_MARK}
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/logs
    local TMP_DC_CPL_HB_SETUP_LOGS_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${DEPLOY_LOGS_MARK}
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/data
    local TMP_DC_CPL_HB_SETUP_DATA_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${DEPLOY_DATA_MARK}
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/conf
    local TMP_DC_CPL_HB_SETUP_CONF_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${DEPLOY_CONF_MARK}
    
    if [[ -a docker-compose.yml ]]; then
        # 3-2：调整整体目录
        formal_adjust_cps_dc_harbor
        
        # x3-3：配置.env/compose.yml
        conf_adjust_cps_dc_harbor

        ## compose安装后操作
        ### 参数1：镜像名称，例 goharbor/registry-photon
        ### 参数2：镜像版本，例 1.10.17
        ### 参数3：启动命令，例 /bin/sh
        ### 参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
        function _exec_resolve_compose_dc_harbor()
        {
            # 4-1：安装后操作
            cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}

            # 当前yaml节点image名称
            local TMP_DC_HB_SETUP_RELY_SERVICE_IMAGE=${1//library\//}
            # 当前yaml节点key（由docker-compose.yml设定结构为准），例service的keys registry
            local TMP_DC_HB_SETUP_RELY_SERVICE_KEY=$(echo "${TMP_DC_CPS_HB_COMPOSE_YML}" | yq ".services.[] | select(.image == \"${TMP_DC_HB_SETUP_RELY_SERVICE_IMAGE}:${2}\") | key")
            
            # 在yaml中找不到配置的情况，直接放弃
            if [ -z "${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}" ]; then
                echo "${TMP_SPLITER2}"
                echo_style_text "'Warning': Cannot found 'key' from 'image'(<${TMP_DC_HB_SETUP_RELY_SERVICE_IMAGE}:${2}>) in compose.yml, execute step return"
                return
            fi
            
            # 当前yaml节点信息
            local TMP_DC_HB_SETUP_SERVICE_NODE=$(echo "${TMP_DC_CPS_HB_COMPOSE_YML}" | yq ".services.${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}")

            # 当前yaml节点索引
            local TMP_DC_HB_SETUP_SERVICE_INDEX=$(diff -e <(echo "${TMP_DC_CPS_HB_COMPOSE_YML}" | yq '.services | keys') <(echo "${TMP_DC_CPS_HB_COMPOSE_YML}" | yq ".services | keys | del(.[] | select(.==\"${TMP_DC_HB_SETUP_RELY_SERVICE_KEY}\"))") | grep -oE "[0-9]+" | xargs -I {} echo {}-1 | bc)
            
            # # 有DB初始化操作，等待60秒
            # if [ "${TMP_DC_HB_SETUP_RELY_SERVICE_IMAGE}" == "goharbor/harbor-db" ]; then
            #     exec_sleep 60 "Waitting <database> 'initial', pls checking <database> 'change', this will stay [60 secs] to exit"
            # fi

            # 执行操作
            exec_step_dc_rely_harbor
        }
        
        # 执行部署
        function _exec_deploy_compose_dc_harbor()
        {
            # 执行compose安装
            echo_style_wrap_text "Starting 'execute' [compose] 'deploy', hold on please"
            
            bash install.sh

            # 有DB初始化操作，等待120秒
            echo && exec_sleep 120 "Waitting <${TMP_DC_HB_DISPLAY_TITLE}> 'initial', pls checking <database & config> 'change', this will stay [120 secs] to exit"
        }
            
        # 无环境文件的场景 
        local TMP_DC_CPS_HB_COMPOSE_YML=$(cat docker-compose.yml)
        local TMP_DC_CPS_HB_MAIN_VER="$(echo "$(yq '.services.core.image' docker-compose.yml)" | cut -d':' -f2)"

        ## 有脚本的场景
        soft_docker_compose_check_upgrade_action "${TMP_DC_HB_SETUP_REPO}*" "${TMP_DC_CPS_HB_MAIN_VER}" "_exec_deploy_compose_dc_harbor" "_exec_resolve_compose_dc_harbor"

        return $?
    fi
}

##########################################################################################################

# x2-2：迁移compose
function formal_cpl_dc_harbor() {
    echo_style_wrap_text "Starting 'formal compile' <${TMP_DC_HB_SETUP_REPO}>, hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移    
    function _formal_cpl_dc_harbor_cp_source() {
        echo_style_text "Starting 'compile migrate'↓:"

        # 拷贝应用目录
        cp -r ${TMP_DC_CPL_HB_EXTRA_DIR} ${1}

        echo_style_text "[View] the 'compile migrate'↓:"
    
        # 修改权限 & 查看列表
        ls -lia ${1}
		echo
    }

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_pcreate ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR} "_formal_cpl_dc_harbor_cp_source"
    
    # 进入compose目录
    cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}
        
    ### 日志(日志初始尚未能创建，compose之后才会创建)
    #### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0
    soft_path_restore_confirm_create "${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}"
    ### 数据(数据初始尚未能创建，compose之后才会创建)
    #### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    soft_path_restore_confirm_create "${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}"
    ### CONF(仅判断还原)
    #### /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0
    soft_path_restore_confirm_create "${TMP_DC_CPL_HB_SETUP_LNK_CONF_DIR}"
    
    return $?
}

# x2-3：修改编译配置
function conf_cpl_dc_harbor() {
    echo_style_wrap_text "Starting 'configuration' <${TMP_DC_HB_SETUP_REPO}> [compile] 'attrs', hold on please"

	# 修改配置文件
    cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}
    yq -i '.hostname = "'${LOCAL_HOST}'"' harbor.yml
    yq -i '.http.port = "'${TMP_DC_HB_SETUP_OPN_HTTP_PORT}'"' harbor.yml
    yq -i '.https.port = "'${TMP_DC_HB_SETUP_OPN_HTTPS_PORT}'"' harbor.yml
    yq -i '.log.local.location = "'${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/${DEPLOY_COMPOSE_MARK}'"' harbor.yml
    yq -i '.data_volume = "'${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}/${DEPLOY_COMPOSE_MARK}'"' harbor.yml

    # 设定DB密码
    local TMP_DC_CPL_HB_SETUP_ADMIN_PASSWD=$(console_input "$(rand_simple_passwd 'harbor' 'svr' "${TMP_DC_CPL_HB_COMPOSE_VER}")" "Please sure your 'harbo' <admin password>" "y")
    yq -i '.harbor_admin_password = "'${TMP_DC_CPL_HB_SETUP_ADMIN_PASSWD}'"' harbor.yml

    local TMP_DC_CPL_HB_SETUP_DB_PASSWD=$(console_input "$(rand_passwd 'harbor' 'db' "${TMP_DC_CPL_HB_COMPOSE_VER}")" "Please sure your 'harbo' dependency <database password>" "y")
    yq -i '.database.password = "'${TMP_DC_CPL_HB_SETUP_DB_PASSWD}'"' harbor.yml
    
    # 输出配置
    local TMP_DC_CPL_HB_SETUP_ENV_HOME=$(su - docker -c "pwd")
    file_content_not_exists_echo "^http:\/\/127.0.0.1:${TMP_DC_HB_SETUP_OPN_HTTP_PORT}\@admin\@.*" ${TMP_DC_CPL_HB_SETUP_ENV_HOME}/.harbor "http://127.0.0.1:${TMP_DC_HB_SETUP_OPN_HTTP_PORT}@admin@${TMP_DC_CPL_HB_SETUP_ADMIN_PASSWD}"

    # 注释不需要的节点配置
    comment_yaml_file_node_item "harbor.yml" ".https"
    
    # 调整配置指向路径
    ## /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/compose
    sed -i "s@^config_dir=@config_dir=${TMP_DC_CPL_HB_SETUP_LNK_CONF_DIR}/${DEPLOY_COMPOSE_MARK} #@g" prepare

    return $?
}

# x2-1：部署操作
# 参数1：软件安装名称
# 参数2：软件安装路径(docker/conda无需采用)
# 参数3：软件解压路径
# 参数4：软件版本
function deploy_compose_dc_harbor() {
	# 变量覆盖特性，其它方法均可读取
	## 执行传入参数
	local TMP_DC_CPL_HB_SETUP_NAME=${1}
    local TMP_DC_CPL_HB_SETUP_MARK_REPO=${TMP_DC_HB_SETUP_REPO/\//_}
	# local TMP_DC_CPL_HB_SETUP_DIR=${2}
    local TMP_DC_CPL_HB_EXTRA_DIR=${3}
    
    ## 统一标记名称(存在于安装目录的真实名称)
    ### 已被全局 DEPLOY_XXX_MARK 替代
        
    # 安装依赖
    set_env_dc_harbor
    
    # 开始编译
    cd ${TMP_DC_CPL_HB_EXTRA_DIR}

    # 创建编译文件(2.8.0开始出现harbor.yml.tmpl，没有harbor.yml)
    if [[ -a harbor.yml.tmpl && ! -a harbor.yml ]]; then
        cp harbor.yml.tmpl harbor.yml
    fi
    
    ## 版本获取
    local TMP_DC_CPL_HB_COMPOSE_VER="$(yq '._version' harbor.yml)"
    local TMP_DC_CPL_HB_SETUP_VER="v${TMP_DC_CPL_HB_COMPOSE_VER:-${4:-${TMP_DC_HB_DOWN_VER}}}"
    
    ## 安装后的规范路径（此处依据实际路径名称修改）
    ## 链接与根版本对的上需注释此处，放开传参
    ### /opt/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_HB_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_REPO}/${TMP_DC_CPL_HB_SETUP_VER}
    ### /opt/docker_apps/goharbor_harbor/v1.10.17/compose
    local TMP_DC_CPL_HB_SETUP_COMPOSE_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${DEPLOY_COMPOSE_MARK}
    
    ## 统一编排到的路径
    ### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_REPO}/${TMP_DC_CPL_HB_SETUP_VER}
    ### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_REPO}/${TMP_DC_CPL_HB_SETUP_VER}
    ### /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_HB_SETUP_LNK_CONF_DIR=${DOCKER_APP_CONF_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_REPO}/${TMP_DC_CPL_HB_SETUP_VER}
    
    # 2-2：目录迁移
    formal_cpl_dc_harbor
    
    # x2-3：修改配置
    conf_cpl_dc_harbor

    # 检测安装
    echo_style_wrap_text "Starting 'execute' <${TMP_DC_HB_SETUP_REPO}> [compile] & 'build' [compose] 'yaml', hold on please"
    soft_docker_compile_check_upgrade_action "goharbor/prepare" "${TMP_DC_CPL_HB_SETUP_VER}" "bash prepare --with-clair --with-chartmuseum" "exec_resolve_compose_dc_harbor_loop"
    # soft_docker_compile_check_upgrade_action "goharbor/prepare" "${TMP_DC_CPL_HB_SETUP_VER}" "bash prepare --with-trivy" "exec_resolve_compose_dc_harbor_loop"
    
    # 检测浏览
    boot_check_dc_harbor "${TMP_DC_CPL_HB_SETUP_NAME}" "${TMP_DC_HB_SETUP_OPN_HTTP_PORT}"

    # 在本地添加仓库指向
    docker_change_insecure_registries "http://127.0.0.1:${TMP_DC_HB_SETUP_OPN_HTTP_PORT}"
        
    # 授权开机启动
    echo_style_wrap_text "Starting 'echo' <${TMP_DC_HB_SETUP_REPO}> [supervisor] 'startup conf', hold on please"
    echo_startup_supervisor_config "${TMP_DC_CPL_HB_SETUP_MARK_REPO}_${TMP_DC_CPL_HB_SETUP_VER}" "${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}" "docker-compose up -d" "" 999 "" "docker" "false" "0"
    
    # 结束
    exec_sleep 30 "Deploy <${TMP_DC_HB_SETUP_REPO}> over, please checking the setup log, this will stay [%s] secs to exit"

    return $?
}

# x1：下载/安装/更新软件
# 参数1：软件安装名称
function download_package_dc_harbor() {
	# 当前路径（仅记录）
	local TMP_DC_HB_CURRENT_DIR=$(pwd)
    
    echo_style_wrap_text "Download 'deploy package' <${TMP_DC_HB_SETUP_REPO}>, hold on please"

    # 选择及下载安装版本(离线安装模式)
    soft_setup_docker_git_wget "${TMP_DC_HB_SETUP_REPO}" "${TMP_DC_HB_SETUP_REPO}" "https://github.com/${TMP_DC_HB_SETUP_REPO}/releases/download/v%s/harbor-offline-installer-v%s.tgz" "${TMP_DC_HB_DOWN_VER}" "deploy_compose_dc_harbor"
    return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "${TMP_DC_HB_DISPLAY_TITLE}" "download_package_dc_harbor"