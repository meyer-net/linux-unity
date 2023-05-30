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
# Debug：
# docker ps -a | awk '{if($2~"goharbor/"){print $1}}' | xargs docker stop
# docker ps -a | awk '{if($2~"goharbor/"){print $1}}' | xargs docker rm
# docker images | awk '{if($1~"goharbor/"){print $3}}' | xargs docker rmi
# rm -rf /opt/docker_apps/goharbor* && rm -rf /mountdisk/etc/docker_apps/goharbor* && rm -rf /mountdisk/logs/docker_apps/goharbor* && rm -rf /mountdisk/data/docker_apps/goharbor* && rm -rf /opt/docker/data/apps/goharbor* && rm -rf /opt/docker/etc/goharbor* && rm -rf /opt/docker/logs/goharbor* && rm -rf /mountdisk/repo/migrate/clean/goharbor_harbor* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/goharbor_harbor && rm -rf /mountdisk/repo/backup/mountdisk/etc/docker_apps/goharbor_harbor && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/goharbor_harbor && rm -rf /mountdisk/repo/backup/mountdisk/data/docker/volumes/000000000000_* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker/volumes/000000000000_* && rm -rf /mountdisk/repo/backup/mountdisk/etc/docker/volumes/000000000000_* && rm -rf /mountdisk/etc/conda_apps/supervisor/boots/goharbor_harbor.conf
# rm -rf /mountdisk/repo/backup/opt/docker_apps/goharbor* && rm -rf /mountdisk/repo/backup/mountdisk/etc/docker_apps/goharbor* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/goharbor* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/goharbor* && rm -rf /mountdisk/repo/backup/opt/docker/data/apps/goharbor* && rm -rf /mountdisk/repo/backup/opt/docker/etc/goharbor* && rm -rf /mountdisk/repo/backup/opt/docker/logs/goharbor*
# docker volume ls | awk '{print $2}' | xargs docker volume rm
# docker volume ls | awk 'NR>1{print $2}' | xargs -I {} docker volume inspect {} | jq ".[0].Mountpoint" | xargs -I {} echo {} | xargs ls -lia
#------------------------------------------------
# 安装标题：$title_name
# 软件名称：goharbor/harbor
# 软件端口：10080
# 软件大写分组与简称：HB
# 软件安装名称：goharbor_harbor
# 软件工作运行目录：/harbor
# 软件GIT仓储名称：${docker_prefix}
# 软件GIT仓储名称：${git_repo}
#------------------------------------------------
local TMP_DC_HB_DOWN_VER="1.10.17"
local TMP_DC_HB_SETUP_INN_HTTP_PORT=80
local TMP_DC_HB_SETUP_INN_HTTPS_PORT=443
local TMP_DC_HB_SETUP_OPN_HTTP_PORT=100${TMP_DC_HB_SETUP_INN_HTTP_PORT}
local TMP_DC_HB_SETUP_OPN_HTTPS_PORT=10${TMP_DC_HB_SETUP_INN_HTTPS_PORT}

##########################################################################################################

# 1-配置环境
function set_env_dc_goharbor_harbor() {
    echo_style_wrap_text "Starting 'configuare install envs', hold on please"

    cd ${__DIR}

    return $?
}

##########################################################################################################

# 4-1-1：规格化软件目录格式
function formal_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs' <${TMP_DC_HB_SETUP_SERVICE_KEY}>, hold on please"
    
    # 开始标准化
    ## 创建链接规则"
    echo_style_text "View the 'symlink create':↓"
    ### 日志
    #### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/logs/compose/registry.log -> /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose/registry.log
    path_not_exists_link "${TMP_DC_HB_SETUP_LOGS_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}/${TMP_DC_HB_SETUP_SERVICE_KEY}.log" "" "${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}/${TMP_DC_HB_SETUP_SERVICE_KEY}.log"
    #### /opt/docker/logs/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/compose/registry.log -> /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose/registry.log
    #### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/compose/registry.log -> /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose/registry.log
    path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_LOGS_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}/${TMP_DC_HB_SETUP_SERVICE_KEY}.log" "" "${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}/${TMP_DC_HB_SETUP_SERVICE_KEY}.log"
    
    ### 数据
    #### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/data -> /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/registry
    path_not_exists_link "${TMP_DC_HB_SETUP_DATA_DIR}" "" "${TMP_DC_HB_SETUP_LNK_DATA_DIR}"
    #### /opt/docker/data/apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17 -> /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/registry
    #### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17 -> /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/registry
    path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_DATA_DIR}" "" "${TMP_DC_HB_SETUP_LNK_DATA_DIR}"
    
    ### ETC
    #### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/etc/compose -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    path_not_exists_link "${TMP_DC_HB_SETUP_ETC_DIR}/compose" "" "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/compose/${TMP_DC_HB_SETUP_SERVICE_KEY}"
    #### /opt/docker/etc/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/compose -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    #### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/compose -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_ETC_DIR}/compose" "" "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/compose/${TMP_DC_HB_SETUP_SERVICE_KEY}"

    # 有可能未创建容器，有容器的情况下才操作日志
    if [ -n "${TMP_DC_HB_SETUP_CTN_ID}" ]; then
        #### /mountdisk/data/docker/containers/${CTN_ID}
        local TMP_DC_HB_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_DC_HB_SETUP_CTN_ID}"
        #### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry
        local TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR="${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/container/${TMP_DC_HB_SETUP_SERVICE_KEY}"
        
        #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry
        path_swap_link "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}" "${TMP_DC_HB_SETUP_CTN_DIR}"
        #### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/etc/container -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry
        path_not_exists_link "${TMP_DC_HB_SETUP_ETC_DIR}/container" "" "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}"
        #### /opt/docker/etc/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/container -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry
        #### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/container -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry
        path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_ETC_DIR}/container" "" "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}"
        
        #### /opt/docker/logs/goharbor_harbor/v1.10.0/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        #### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        path_not_exists_link "${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_HB_SETUP_CTN_ID}-json.log" "" "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}/${TMP_DC_HB_SETUP_CTN_ID}-json.log"
        #### /opt/docker/logs/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        #### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_LOGS_DIR}/container/${TMP_DC_HB_SETUP_CTN_ID}-json.log" "" "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}/${TMP_DC_HB_SETUP_CTN_ID}-json.log"

        # 预实验部分        
        ## 目录调整完修改启动参数
        ## 修改启动参数
        echo "${TMP_SPLITER2}"
        echo_style_text "Starting 'inspect change', hold on please"

        # 挂载目录(标记需挂载的磁盘，必须停止服务才能修改，否则会无效)
        cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}
        ## docker_container_hostconfig_binds_echo 覆盖不到全部，有特殊复制直接在流程中拷贝出来并指定映射关系。
        docker_change_container_volume_migrate "${TMP_DC_HB_SETUP_CTN_ID}" "$(docker_container_hostconfig_binds_echo "${TMP_DC_HB_SETUP_CTN_ID}")"
        # docker_change_container_volume_migrate "${TMP_DC_HB_SETUP_CTN_ID}" "$(docker_container_hostconfig_binds_echo "${TMP_DC_HB_SETUP_CTN_ID}")" "" $([[ -z "${TMP_DC_HB_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    fi

    return $?
}

##########################################################################################################

# 4-1-2：设置软件
function conf_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration' <${TMP_DC_HB_SETUP_SERVICE_KEY}>, hold on please"

    # 开始配置

    return $?
}

##########################################################################################################

# 4-1-3：启动后检测脚本
# 参数1：最终启动名称
# 参数2：最终启动端口
function boot_check_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    # 当前启动端口
    local TMP_DC_HB_SETUP_CTN_CURRENT_PORT=${2}

    # 实验部分  
    ## 有可能未创建容器，有容器的情况下才打印
    echo_style_wrap_text "Starting 'boot check' <${1}>, hold on please"
    if [ -n "${TMP_DC_HB_SETUP_CTN_ID}" ]; then
        function _boot_check_dc_goharbor_harbor()
        {
            if [ -n "${TMP_DC_HB_SETUP_CTN_CURRENT_PORT}" ]; then
                echo_style_text "View the 'container visit'↓:"
                curl -s http://localhost:${2}
                echo

                # 授权iptables端口访问
                echo_soft_port "${2}"
                
                # 生成web授权访问脚本
                echo_web_service_init_scripts "${TMP_DC_CPL_HB_SETUP_MARK_NAME}_${TMP_DC_HB_SETUP_IMG_VER}-${1}${LOCAL_ID}" "${TMP_DC_CPL_HB_SETUP_MARK_NAME}-${1}${LOCAL_ID}-webui.${SYS_DOMAIN}" ${2} "${LOCAL_HOST}"
            fi
        }

        docker_container_print "${TMP_DC_HB_SETUP_CTN_ID}" "_boot_check_dc_goharbor_harbor"
    fi
}

##########################################################################################################

# x4-1：执行步骤
# 参数1：当前yaml节点信息
# 参数2：当前yaml节点索引
# 参数3：当前yaml节点key（由docker-compose.yml设定结构为准），例harbor的keys core/log/db/nginx/registry
function exec_step_dc_goharbor_harbor() {
	# 变量覆盖特性，其它方法均可读取
	## 执行传入参数
	local TMP_DC_HB_SETUP_SERVICE_NODE=${1}
	local TMP_DC_HB_SETUP_SERVICE_INDEX=${2}
	local TMP_DC_HB_SETUP_SERVICE_KEY=${3}
    
    ### harbor-core
    local TMP_DC_HB_SETUP_SERVICE_CTN_NAME=$(echo "${1}" | yq ".container_name")
    ### goharbor/harbor-core:v1.10.0
    local TMP_DC_HB_SETUP_SERVICE_IMG_FULL_NAME=$(echo "${1}" | yq ".image") 
    
    # 检索绑定查询到的容器信息(特殊使用时才会用到)
    function _exec_step_dc_goharbor_harbor()
    {
        # 定义检索参数
        local TMP_DC_HB_SETUP_IMG_ID=${1}
        local TMP_DC_HB_SETUP_CTN_ID=${2}
        # local TMP_DC_HB_SETUP_CTN_SID="${TMP_DC_HB_SETUP_CTN_ID:0:12}"
        ## goharbor/harbor-core
        local TMP_DC_HB_SETUP_IMG_NAME=${3}
        ## goharbor_registry-photon
        local TMP_DC_HB_SETUP_IMG_MARK_NAME=${3/\//_}
        ## v1.10.0
        local TMP_DC_HB_SETUP_IMG_VER=${4}
        ## /bin/sh
        local TMP_DC_HB_SETUP_CTN_CMD=${5}
        ## --env=xxx
        local TMP_DC_HB_SETUP_CTN_ARGS=${6}
        ## 10080
        local TMP_DC_HB_SETUP_CTN_PORT=$(echo "${6}" | grep -oP "(?<=-p )\d+(?=:\d+)")

        # 统一编排到的路径(需注意日志与配置部分，注意会有多层结构，即不止compose)
        ## /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_HB_SETUP_DIR=${TMP_DC_CPL_HB_SETUP_RELY_DIR}/${TMP_DC_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_IMG_VER}
        ## /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose/registry
        # local TMP_DC_HB_SETUP_LNK_LOGS_DIR=${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}/${TMP_DC_HB_SETUP_SERVICE_KEY}
        ## /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/compose/registry
        local TMP_DC_HB_SETUP_LNK_DATA_DIR=${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}/${TMP_DC_HB_SETUP_SERVICE_KEY}
        ## /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/compose/registry
        # local TMP_DC_HB_SETUP_LNK_ETC_DIR=${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}/${TMP_DC_HB_SETUP_SERVICE_KEY}

        # 指定Docker的安装路径部分
        ## /opt/docker/logs/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        ## /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_SETUP_HB_RELY_LNK_LOGS_DIR=${TMP_DC_CPL_SETUP_HB_LNK_LOGS_DIR}/${TMP_DC_HB_SETUP_RELY_MARK}/${TMP_DC_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_IMG_VER}
        ## /opt/docker/data/apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        ## /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_SETUP_HB_RELY_LNK_DATA_DIR=${TMP_DC_CPL_SETUP_HB_LNK_DATA_DIR}/${TMP_DC_HB_SETUP_RELY_MARK}/${TMP_DC_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_IMG_VER}
        ## /opt/docker/etc/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        ## /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_SETUP_HB_RELY_LNK_ETC_DIR=${TMP_DC_CPL_SETUP_HB_LNK_ETC_DIR}/${TMP_DC_HB_SETUP_RELY_MARK}/${TMP_DC_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_IMG_VER}

        # 安装后的规范路径（此处依据实际路径名称修改）
        ## /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/work
        local TMP_DC_HB_SETUP_WORK_DIR=${TMP_DC_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_WORK_MARK}
        ## /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/logs
        local TMP_DC_HB_SETUP_LOGS_DIR=${TMP_DC_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_LOGS_MARK}
        ## /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/data
        local TMP_DC_HB_SETUP_DATA_DIR=${TMP_DC_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_DATA_MARK}
        ## /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/etc
        local TMP_DC_HB_SETUP_ETC_DIR=${TMP_DC_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_ETC_MARK}
        
        echo_style_text "View the 'build yaml'↓:"
        echo "${TMP_DC_HB_SETUP_SERVICE_NODE}" | yq

        formal_dc_goharbor_harbor

        conf_dc_goharbor_harbor
        
        boot_check_dc_goharbor_harbor "${TMP_DC_HB_SETUP_SERVICE_KEY}" "${TMP_DC_HB_SETUP_CTN_PORT}"
    }

    # 从容器中提取启动数据
    echo_style_wrap_text "Starting 'execute step' <${TMP_DC_HB_SETUP_SERVICE_IMG_FULL_NAME}>]('${TMP_DC_HB_SETUP_SERVICE_CTN_NAME}'/'${TMP_DC_HB_SETUP_SERVICE_KEY}'), hold on please"
    docker_container_param_check_action "${TMP_DC_HB_SETUP_SERVICE_CTN_NAME}" "_exec_step_dc_goharbor_harbor"
    
    return $?
}

##########################################################################################################

# x3-2：规格化软件目录格式
function formal_adjust_cps_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}

    echo_style_wrap_text "Starting 'formal adjust compose dirs', hold on please"

    # 创建链接规则
    echo_style_text "View the 'symlink create':↓"
    ## 日志
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/logs -> /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_HB_SETUP_LOGS_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}"
    ### /opt/docker/logs/goharbor_harbor/v1.10.0 -> /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_SETUP_HB_LNK_LOGS_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}"
    ## 数据
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/data -> /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_HB_SETUP_DATA_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}"
    ### /opt/docker/data/apps/goharbor_harbor/v1.10.0 -> /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_SETUP_HB_LNK_DATA_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}"
    ## ETC
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/etc -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_HB_SETUP_ETC_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}"
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/compose/common/config -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/compose
    path_not_exists_link "${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}/common/config" "" "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/compose"
    ### /opt/docker/etc/goharbor_harbor/v1.10.0 -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0
    path_not_exists_link "${TMP_DC_CPL_SETUP_HB_LNK_ETC_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}"

    return $?
}

# x3-1：解析compose文件，并安装
#    参数1：（忽略）镜像名称，例 goharbor/prepare
#    参数2：（忽略）镜像版本，例 latest
#    参数3：（忽略）启动命令，例 /bin/sh
#    参数4：（忽略）启动参数，例 --volume /etc/localtime:/etc/localtime
#    参数5：（忽略）快照类型(还原时有效)，例 image/container/dockerfile
#    参数6：（忽略）快照来源，例 snapshot/clean/hub/commit，默认snapshot
function resolve_compose_dc_goharbor_harbor_loop()
{
	# 变量覆盖特性，其它方法均可读取
    ## 安装后的规范路径（此处依据实际路径名称修改）
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/rely
    local TMP_DC_CPL_HB_SETUP_RELY_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_RELY_MARK}
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/work
    # local TMP_DC_CPL_HB_SETUP_WORK_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_WORK_MARK}
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/logs
    local TMP_DC_CPL_HB_SETUP_LOGS_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_LOGS_MARK}
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/data
    local TMP_DC_CPL_HB_SETUP_DATA_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_DATA_MARK}
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/etc
    local TMP_DC_CPL_HB_SETUP_ETC_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_ETC_MARK}

    ## 指定Docker的安装路径部分
    ### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_SETUP_HB_LNK_LOGS_DIR=${DOCKER_SETUP_DIR}/${TMP_DC_HB_SETUP_LOGS_MARK}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_SETUP_VER}
    ### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_SETUP_HB_LNK_DATA_DIR=${DOCKER_SETUP_DIR}/${TMP_DC_HB_SETUP_DATA_MARK}/apps/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_SETUP_VER}
    ### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_SETUP_HB_LNK_ETC_DIR=${DOCKER_SETUP_DIR}/${TMP_DC_HB_SETUP_ETC_MARK}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_SETUP_VER}
    
    if [[ -a docker-compose.yml ]]; then
    
        # 3-2：解析执行
        # echo_style_wrap_text "Starting 'configuration' <compose> 'yaml', hold on please"
        # yaml_split_action "$(cat docker-compose.yml | yq '.services')" "exec_compose_step_dc_goharbor_harbor"

        # 3-2：调整整体目录
        formal_adjust_cps_dc_goharbor_harbor
        
        # !!!由于原始脚本限定在install.sh中执行了prepare，所以此处在预编译完成后且安装前将其禁用
        sed -i "s@^./prepare@#./prepare@g" install.sh

        # 执行compose安装
        echo_style_wrap_text "Starting 'execute' <compose> 'action', hold on please"
        bash install.sh

        # 4-1：安装后操作
        yaml_split_action "$(cat docker-compose.yml | yq '.services')" "exec_step_dc_goharbor_harbor"
       
        return $?
    fi
}

##########################################################################################################

# x2-2：迁移compose
function formal_cpl_dc_goharbor_harbor() {
    echo_style_wrap_text "Starting 'formal compile', hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移    
    function _formal_cpl_dc_goharbor_harbor_cp_source() {
        echo_style_text "View the 'compile migrate'↓:"

        # 拷贝应用目录
        cp -r ${TMP_DC_CPL_HB_EXTRA_DIR} ${1}
        
        # 查看列表
        ls -lia ${1}
    }

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_pcreate ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR} "_formal_cpl_dc_goharbor_harbor_cp_source"
    
    # 进入compose目录
    cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}
        
    ### 日志(日志初始尚未能创建，compose之后才会创建)
    #### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0
    soft_path_restore_confirm_create "${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}"
    ### 数据(数据初始尚未能创建，compose之后才会创建)
    #### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    soft_path_restore_confirm_create "${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}"
    ### ETC(仅判断还原)
    #### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0
    soft_path_restore_confirm_create "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}"
    
    return $?
}

# x2-3：修改配置
function conf_cpl_dc_goharbor_harbor() {
    echo_style_wrap_text "Starting 'configuration migrate compile', hold on please"

	# 修改配置文件
    cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}
    yq -i '.hostname = "'${LOCAL_HOST}'"' harbor.yml
    yq -i '.http.port = "'${TMP_DC_HB_SETUP_OPN_HTTP_PORT}'"' harbor.yml
    yq -i '.https.port = "'${TMP_DC_HB_SETUP_OPN_HTTPS_PORT}'"' harbor.yml
    yq -i '.log.local.location = "'${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}'"' harbor.yml
    yq -i '.data_volume = "'${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}'"' harbor.yml

    # 设定DB密码
    local TMP_DC_CPL_HB_SETUP_ADMIN_PASSWD=$(console_input "$(rand_passwd 'harbor' 'svr' "${TMP_DC_CPL_HB_COMPOSE_VER}")" "Please sure your 'harbo' <admin password>" "y")
    yq -i '.harbor_admin_password = "'${TMP_DC_CPL_HB_SETUP_ADMIN_PASSWD}'"' harbor.yml

    local TMP_DC_CPL_HB_SETUP_DB_PASSWD=$(console_input "$(rand_passwd 'harbor' 'db' "${TMP_DC_CPL_HB_COMPOSE_VER}")" "Please sure your 'harbo' <database password>" "y")
    yq -i '.database.password = "'${TMP_DC_CPL_HB_SETUP_DB_PASSWD}'"' harbor.yml

    # 注释不需要的节点配置
    comment_yaml_file_node_item "harbor.yml" ".https"
    
    # 调整配置指向路径
    ## /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/compose
    sed -i "s@^config_dir=@config_dir=${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK} #@g" prepare

    # 输出配置
    su - docker -c "echo 'http://127.0.0.1:${TMP_DC_HB_SETUP_OPN_HTTP_PORT}@admin@${TMP_DC_CPL_HB_SETUP_ADMIN_PASSWD}' >> .harbor"
    
    return $?
}

# x2-1：生成compose.yml
# 参数1：软件安装名称
# 参数2：软件安装路径(docker/conda无需采用)
# 参数3：软件解压路径
# 参数4：软件版本
function build_compose_dc_goharbor_harbor() {
	# 变量覆盖特性，其它方法均可读取
	## 执行传入参数
	local TMP_DC_CPL_HB_SETUP_NAME=${1}
    local TMP_DC_CPL_HB_SETUP_MARK_NAME=${1/\//_}
	local TMP_DC_CPL_HB_SETUP_DIR=${2}
    local TMP_DC_CPL_HB_EXTRA_DIR=${3}
    
    ## 统一标记名称(存在于安装目录的真实名称)
    local TMP_DC_HB_SETUP_COMPOSE_MARK="compose"
    local TMP_DC_HB_SETUP_RELY_MARK="rely"
    local TMP_DC_HB_SETUP_WORK_MARK="work"
    local TMP_DC_HB_SETUP_LOGS_MARK="logs"
    local TMP_DC_HB_SETUP_DATA_MARK="data"
    local TMP_DC_HB_SETUP_ETC_MARK="etc"
        
    # 安装依赖
    set_env_dc_goharbor_harbor
    
    # 开始编译
    cd ${TMP_DC_CPL_HB_EXTRA_DIR}

    # 创建编译文件(2.8.0开始出现harbor.yml.tmpl，没有harbor.yml)
    if [[ -a harbor.yml.tmpl && ! -a harbor.yml ]]; then
        cp harbor.yml.tmpl harbor.yml
    fi
    
    ## 版本获取
    local TMP_DC_CPL_HB_COMPOSE_VER="$(yq '._version' harbor.yml)"
    local TMP_DC_CPL_HB_SETUP_VER="v${TMP_DC_CPL_HB_COMPOSE_VER:-${4:-${TMP_DC_HB_DOWN_VER}}}"
    
    echo_style_wrap_text "Starting 'configuration' <compile> 'yaml', hold on please"
    
    ## 安装后的规范路径（此处依据实际路径名称修改）
    ### /opt/docker_apps/goharbor_harbor/v1.10.0
    # local TMP_DC_CPL_HB_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_SETUP_VER}
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/compose
    local TMP_DC_CPL_HB_SETUP_COMPOSE_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}
    
    ## 统一编排到的路径
    ### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_SETUP_VER}
    ### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_SETUP_VER}
    ### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR=${DOCKER_APP_ATT_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_SETUP_VER}
    
    # 2-2：目录迁移
    formal_cpl_dc_goharbor_harbor
    
    # x2-3：修改配置
    conf_cpl_dc_goharbor_harbor
       
    # 重装/更新/安装
    echo_style_wrap_text "Starting 'build' <compose> 'yaml' & 'execute' <compile>, hold on please"
    
    # 检测安装
    soft_docker_compose_check_upgrade_action "goharbor/prepare" "${TMP_DC_CPL_HB_SETUP_VER}" "bash prepare --with-clair --with-chartmuseum" "resolve_compose_dc_goharbor_harbor_loop"
    # soft_docker_compose_check_upgrade_action "goharbor/prepare" "${TMP_DC_CPL_HB_SETUP_VER}" "bash prepare --with-trivy" "resolve_compose_dc_goharbor_harbor_loop"

    # 检测浏览
    boot_check_dc_goharbor_harbor "${TMP_DC_CPL_HB_SETUP_NAME}" "${TMP_DC_HB_SETUP_OPN_HTTP_PORT}"

    # 在本地添加仓库指向
    docker_change_insecure_registries "http://127.0.0.1:${TMP_DC_HB_SETUP_OPN_HTTP_PORT}"
        
    # 授权开机启动
    echo "${TMP_SPLITER2}"
    echo_style_text "View echo the 'supervisor startup conf'↓:"
    echo_startup_supervisor_config "${TMP_DC_CPL_HB_SETUP_MARK_NAME}" "${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}" "docker-compose up -d" "" 999 "" "docker" "false" "0"
    
    # 结束
    exec_sleep 10 "Deploy <goharbor/harbor> over, please checking the setup log, this will stay 10 secs to exit"

    return $?
}

# x1：下载/安装/更新软件
# 参数1：软件安装名称
function download_package_dc_goharbor_harbor() {
	# 当前路径（仅记录）
	local TMP_DC_HB_CURRENT_DIR=$(pwd)
    
    echo_style_wrap_text "Download 'install package' <${1}>, hold on please"

    # 选择及下载安装版本
    soft_setup_docker_git_wget "${1}" "${1}" "https://github.com/${1}/releases/download/v%s/harbor-offline-installer-v%s.tgz" "${TMP_DC_HB_DOWN_VER}" "build_compose_dc_goharbor_harbor"
    return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "goharbor/harbor" "download_package_dc_goharbor_harbor"