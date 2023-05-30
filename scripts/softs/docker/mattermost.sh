#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
#------------------------------------------------
# Compose文件版本：v2.4
# 依赖镜像版本：v7.1
#------------------------------------------------
# 涵盖：redis、postgresql等服务
#------------------------------------------------
# Debug：
# docker ps -a | awk '{if($2~"mattermost/"){print $1}}' | xargs docker stop
# docker ps -a | awk '{if($2~"mattermost/"){print $1}}' | xargs docker rm
# docker images | awk '{if($1~"mattermost/"){print $3}}' | xargs docker rmi
# rm -rf /opt/docker_apps/mattermost* && rm -rf /mountdisk/etc/docker_apps/mattermost* && rm -rf /mountdisk/logs/docker_apps/mattermost* && rm -rf /mountdisk/data/docker_apps/mattermost* && rm -rf /opt/docker/data/apps/mattermost* && rm -rf /opt/docker/etc/mattermost* && rm -rf /opt/docker/logs/mattermost* && rm -rf /mountdisk/repo/migrate/clean/mattermost* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/mattermost && rm -rf /mountdisk/repo/backup/mountdisk/etc/docker_apps/mattermost && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/mattermost && rm -rf /mountdisk/repo/backup/mountdisk/data/docker/volumes/000000000000_* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker/volumes/000000000000_* && rm -rf /mountdisk/repo/backup/mountdisk/etc/docker/volumes/000000000000_* && rm -rf /mountdisk/etc/conda_apps/supervisor/boots/mattermost.conf
# rm -rf /mountdisk/repo/backup/opt/docker_apps/mattermost* && rm -rf /mountdisk/repo/backup/mountdisk/etc/docker_apps/mattermost* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/mattermost* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/mattermost* && rm -rf /mountdisk/repo/backup/opt/docker/data/apps/mattermost* && rm -rf /mountdisk/repo/backup/opt/docker/etc/mattermost* && rm -rf /mountdisk/repo/backup/opt/docker/logs/mattermost*
# docker volume ls | awk '{print $2}' | xargs docker volume rm
# docker volume ls | awk 'NR>1{print $2}' | xargs -I {} docker volume inspect {} | jq ".[0].Mountpoint" | xargs -I {} echo {} | xargs ls -lia
#------------------------------------------------
# 安装标题：$title_name
# Compose仓库名称：mattermost/docker
# 主镜像名称：mattermost-enterprise-edition
# 软件端口：8065
# 软件大写分组与简称：HB
# 软件安装名称：mattermost
# 软件工作运行目录：/harbor
# 软件GIT仓储名称：${docker_prefix}
# 软件GIT仓储名称：${git_repo}
#------------------------------------------------
local TMP_DC_MTTM_DOWN_VER="2.4"
local TMP_DC_MTTM_SETUP_INN_APP_PORT=8065
local TMP_DC_MTTM_SETUP_INN_HTTP_PORT=80
local TMP_DC_MTTM_SETUP_INN_HTTPS_PORT=443
local TMP_DC_MTTM_SETUP_INN_CALLS_PORT=8443
local TMP_DC_MTTM_SETUP_OPN_APP_PORT=1${TMP_DC_MTTM_SETUP_INN_APP_PORT}
local TMP_DC_MTTM_SETUP_OPN_HTTP_PORT=100${TMP_DC_MTTM_SETUP_INN_HTTP_PORT}
local TMP_DC_MTTM_SETUP_OPN_HTTPS_PORT=10${TMP_DC_MTTM_SETUP_INN_HTTPS_PORT}
local TMP_DC_MTTM_SETUP_OPN_CALLS_PORT=1${TMP_DC_MTTM_SETUP_INN_CALLS_PORT}

##########################################################################################################

# 1-配置环境
function set_env_dc_mattermost() {
    echo_style_wrap_text "Starting 'configuare install envs', hold on please"

    cd ${__DIR}

    return $?
}

##########################################################################################################

# 4-1-1：规格化软件目录格式
function formal_dc_mattermost() {
    cd ${TMP_DC_CPL_MTTM_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs' <${TMP_DC_MTTM_SETUP_SERVICE_KEY}>, hold on please"
    
    # 开始标准化
    ## 创建链接规则"
    echo_style_text "View the 'symlink create':↓"
    ### 日志
    #### /opt/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/logs/compose/registry.log -> /mountdisk/logs/docker_apps/mattermost/v2.4/compose/registry.log
    path_not_exists_link "${TMP_DC_MTTM_SETUP_LOGS_DIR}/${TMP_DC_MTTM_SETUP_COMPOSE_MARK}/${TMP_DC_MTTM_SETUP_SERVICE_KEY}.log" "" "${TMP_DC_CPL_MTTM_SETUP_LNK_LOGS_DIR}/${TMP_DC_MTTM_SETUP_COMPOSE_MARK}/${TMP_DC_MTTM_SETUP_SERVICE_KEY}.log"
    #### /opt/docker/logs/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/compose/registry.log -> /mountdisk/logs/docker_apps/mattermost/v2.4/compose/registry.log
    #### /mountdisk/logs/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/compose/registry.log -> /mountdisk/logs/docker_apps/mattermost/v2.4/compose/registry.log
    path_not_exists_link "${TMP_DC_SETUP_MTTM_RELY_LNK_LOGS_DIR}/${TMP_DC_MTTM_SETUP_COMPOSE_MARK}/${TMP_DC_MTTM_SETUP_SERVICE_KEY}.log" "" "${TMP_DC_CPL_MTTM_SETUP_LNK_LOGS_DIR}/${TMP_DC_MTTM_SETUP_COMPOSE_MARK}/${TMP_DC_MTTM_SETUP_SERVICE_KEY}.log"
    
    ### 数据
    #### /opt/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/data -> /mountdisk/data/docker_apps/mattermost/v2.4/registry
    path_not_exists_link "${TMP_DC_MTTM_SETUP_DATA_DIR}" "" "${TMP_DC_MTTM_SETUP_LNK_DATA_DIR}"
    #### /opt/docker/data/apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1 -> /mountdisk/data/docker_apps/mattermost/v2.4/registry
    #### /mountdisk/data/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1 -> /mountdisk/data/docker_apps/mattermost/v2.4/registry
    path_not_exists_link "${TMP_DC_SETUP_MTTM_RELY_LNK_DATA_DIR}" "" "${TMP_DC_MTTM_SETUP_LNK_DATA_DIR}"
    
    ### ETC
    #### /opt/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/etc/compose -> /mountdisk/etc/docker_apps/mattermost/v2.4/compose/registry
    path_not_exists_link "${TMP_DC_MTTM_SETUP_ETC_DIR}/compose" "" "${TMP_DC_CPL_MTTM_SETUP_LNK_ETC_DIR}/compose/${TMP_DC_MTTM_SETUP_SERVICE_KEY}"
    #### /opt/docker/etc/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/compose -> /mountdisk/etc/docker_apps/mattermost/v2.4/compose/registry
    #### /mountdisk/etc/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/compose -> /mountdisk/etc/docker_apps/mattermost/v2.4/compose/registry
    path_not_exists_link "${TMP_DC_SETUP_MTTM_RELY_LNK_ETC_DIR}/compose" "" "${TMP_DC_CPL_MTTM_SETUP_LNK_ETC_DIR}/compose/${TMP_DC_MTTM_SETUP_SERVICE_KEY}"

    # 有可能未创建容器，有容器的情况下才操作日志
    if [ -n "${TMP_DC_MTTM_SETUP_CTN_ID}" ]; then
        #### /mountdisk/data/docker/containers/${CTN_ID}
        local TMP_DC_MTTM_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_DC_MTTM_SETUP_CTN_ID}"
        #### /mountdisk/etc/docker_apps/mattermost/v2.4/container/registry
        local TMP_DC_MTTM_SETUP_LNK_ETC_CTN_DIR="${TMP_DC_CPL_MTTM_SETUP_LNK_ETC_DIR}/container/${TMP_DC_MTTM_SETUP_SERVICE_KEY}"
        
        #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/etc/docker_apps/mattermost/v2.4/container/registry
        path_swap_link "${TMP_DC_MTTM_SETUP_LNK_ETC_CTN_DIR}" "${TMP_DC_MTTM_SETUP_CTN_DIR}"
        #### /opt/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/etc/container -> /mountdisk/etc/docker_apps/mattermost/v2.4/container/registry
        path_not_exists_link "${TMP_DC_MTTM_SETUP_ETC_DIR}/container" "" "${TMP_DC_MTTM_SETUP_LNK_ETC_CTN_DIR}"
        #### /opt/docker/etc/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/container -> /mountdisk/etc/docker_apps/mattermost/v2.4/container/registry
        #### /mountdisk/etc/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/container -> /mountdisk/etc/docker_apps/mattermost/v2.4/container/registry
        path_not_exists_link "${TMP_DC_SETUP_MTTM_RELY_LNK_ETC_DIR}/container" "" "${TMP_DC_MTTM_SETUP_LNK_ETC_CTN_DIR}"
        
        #### /opt/docker/logs/mattermost/v2.4/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/mattermost/v2.4/container/registry/${CTN_ID}-json.log
        #### /mountdisk/logs/docker_apps/mattermost/v2.4/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/mattermost/v2.4/container/registry/${CTN_ID}-json.log
        path_not_exists_link "${TMP_DC_CPL_MTTM_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_MTTM_SETUP_CTN_ID}-json.log" "" "${TMP_DC_MTTM_SETUP_LNK_ETC_CTN_DIR}/${TMP_DC_MTTM_SETUP_CTN_ID}-json.log"
        #### /opt/docker/logs/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/mattermost/v2.4/container/registry/${CTN_ID}-json.log
        #### /mountdisk/logs/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/mattermost/v2.4/container/registry/${CTN_ID}-json.log
        path_not_exists_link "${TMP_DC_SETUP_MTTM_RELY_LNK_LOGS_DIR}/container/${TMP_DC_MTTM_SETUP_CTN_ID}-json.log" "" "${TMP_DC_MTTM_SETUP_LNK_ETC_CTN_DIR}/${TMP_DC_MTTM_SETUP_CTN_ID}-json.log"

        # 预实验部分        
        ## 目录调整完修改启动参数
        ## 修改启动参数
        echo "${TMP_SPLITER2}"
        echo_style_text "Starting 'inspect change', hold on please"

        # 挂载目录(标记需挂载的磁盘，必须停止服务才能修改，否则会无效)
        cd ${TMP_DC_CPL_MTTM_SETUP_COMPOSE_DIR}
        ## docker_container_hostconfig_binds_echo 覆盖不到全部，有特殊复制直接在流程中拷贝出来并指定映射关系。
        docker_change_container_volume_migrate "${TMP_DC_MTTM_SETUP_CTN_ID}" "$(docker_container_hostconfig_binds_echo "${TMP_DC_MTTM_SETUP_CTN_ID}")"
        # docker_change_container_volume_migrate "${TMP_DC_MTTM_SETUP_CTN_ID}" "$(docker_container_hostconfig_binds_echo "${TMP_DC_MTTM_SETUP_CTN_ID}")" "" $([[ -z "${TMP_DC_MTTM_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    fi

    return $?
}

##########################################################################################################

# 4-1-2：设置软件
function conf_dc_mattermost() {
    cd ${TMP_DC_CPL_MTTM_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration' <${TMP_DC_MTTM_SETUP_SERVICE_KEY}>, hold on please"

    # 开始配置

    return $?
}

##########################################################################################################

# 4-1-3：启动后检测脚本
# 参数1：最终启动名称
# 参数2：最终启动端口
function boot_check_dc_mattermost() {
    cd ${TMP_DC_CPL_MTTM_SETUP_DIR}

    # 当前启动端口
    local TMP_DC_MTTM_SETUP_CTN_CURRENT_PORT=${2}

    # 实验部分  
    ## 有可能未创建容器，有容器的情况下才打印
    echo_style_wrap_text "Starting 'boot check' <${1}>, hold on please"
    if [ -n "${TMP_DC_MTTM_SETUP_CTN_ID}" ]; then
        function _boot_check_dc_mattermost()
        {
            if [ -n "${TMP_DC_MTTM_SETUP_CTN_CURRENT_PORT}" ]; then
                echo_style_text "View the 'container visit'↓:"
                curl -s http://localhost:${2}
                echo

                # 授权iptables端口访问
                echo_soft_port "${2}"
                
                # 生成web授权访问脚本
                echo_web_service_init_scripts "${TMP_DC_CPL_MTTM_SETUP_MARK_NAME}_${TMP_DC_MTTM_SETUP_IMG_VER}-${1}${LOCAL_ID}" "${TMP_DC_CPL_MTTM_SETUP_MARK_NAME}-${1}${LOCAL_ID}-webui.${SYS_DOMAIN}" ${2} "${LOCAL_HOST}"
            fi
        }

        docker_container_print "${TMP_DC_MTTM_SETUP_CTN_ID}" "_boot_check_dc_mattermost"
    fi
}

##########################################################################################################

# x4-1：执行步骤
# 参数1：当前yaml节点信息
# 参数2：当前yaml节点索引
# 参数3：当前yaml节点key（由docker-compose.yml设定结构为准），例service的keys core/log/postgres/nginx/registry
function exec_step_dc_mattermost() {
	# 变量覆盖特性，其它方法均可读取
	## 执行传入参数
	local TMP_DC_MTTM_SETUP_SERVICE_NODE=${1}
	local TMP_DC_MTTM_SETUP_SERVICE_INDEX=${2}
	local TMP_DC_MTTM_SETUP_SERVICE_KEY=${3}
    
    ### mattermost-enterprise-edition
    local TMP_DC_MTTM_SETUP_SERVICE_CTN_NAME=$(echo "${1}" | yq ".container_name")
    ### mattermost-enterprise-edition:v2.4
    local TMP_DC_MTTM_SETUP_SERVICE_IMG_FULL_NAME=$(echo "${1}" | yq ".image") 
    
    # 检索绑定查询到的容器信息(特殊使用时才会用到)
    function _exec_step_dc_mattermost()
    {
        # 定义检索参数
        local TMP_DC_MTTM_SETUP_IMG_ID=${1}
        local TMP_DC_MTTM_SETUP_CTN_ID=${2}
        # local TMP_DC_MTTM_SETUP_CTN_SID="${TMP_DC_MTTM_SETUP_CTN_ID:0:12}"
        ## mattermost-enterprise-edition
        local TMP_DC_MTTM_SETUP_IMG_NAME=${3}
        ## mattermost_mattermost-enterprise-edition
        local TMP_DC_MTTM_SETUP_IMG_MARK_NAME=${3/\//_}
        ## v2.4
        local TMP_DC_MTTM_SETUP_IMG_VER=${4}
        ## /bin/sh
        local TMP_DC_MTTM_SETUP_CTN_CMD=${5}
        ## --env=xxx
        local TMP_DC_MTTM_SETUP_CTN_ARGS=${6}
        ## 8065
        local TMP_DC_MTTM_SETUP_CTN_PORT=$(echo "${6}" | grep -oP "(?<=-p )\d+(?=:\d+)")

        # 统一编排到的路径(需注意日志与配置部分，注意会有多层结构，即不止compose)
        ## /opt/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1
        local TMP_DC_MTTM_SETUP_DIR=${TMP_DC_CPL_MTTM_SETUP_RELY_DIR}/${TMP_DC_MTTM_SETUP_IMG_MARK_NAME}/${TMP_DC_MTTM_SETUP_IMG_VER}
        ## /mountdisk/logs/docker_apps/mattermost/v2.4/compose/registry
        # local TMP_DC_MTTM_SETUP_LNK_LOGS_DIR=${TMP_DC_CPL_MTTM_SETUP_LNK_LOGS_DIR}/${TMP_DC_MTTM_SETUP_COMPOSE_MARK}/${TMP_DC_MTTM_SETUP_SERVICE_KEY}
        ## /mountdisk/data/docker_apps/mattermost/v2.4/compose/registry
        local TMP_DC_MTTM_SETUP_LNK_DATA_DIR=${TMP_DC_CPL_MTTM_SETUP_LNK_DATA_DIR}/${TMP_DC_MTTM_SETUP_COMPOSE_MARK}/${TMP_DC_MTTM_SETUP_SERVICE_KEY}
        ## /mountdisk/etc/docker_apps/mattermost/v2.4/compose/registry
        # local TMP_DC_MTTM_SETUP_LNK_ETC_DIR=${TMP_DC_CPL_MTTM_SETUP_LNK_ETC_DIR}/${TMP_DC_MTTM_SETUP_COMPOSE_MARK}/${TMP_DC_MTTM_SETUP_SERVICE_KEY}

        # 指定Docker的安装路径部分
        ## /opt/docker/logs/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1
        ## /mountdisk/logs/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1
        local TMP_DC_SETUP_MTTM_RELY_LNK_LOGS_DIR=${TMP_DC_CPL_SETUP_MTTM_LNK_LOGS_DIR}/${TMP_DC_MTTM_SETUP_RELY_MARK}/${TMP_DC_MTTM_SETUP_IMG_MARK_NAME}/${TMP_DC_MTTM_SETUP_IMG_VER}
        ## /opt/docker/data/apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1
        ## /mountdisk/data/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1
        local TMP_DC_SETUP_MTTM_RELY_LNK_DATA_DIR=${TMP_DC_CPL_SETUP_MTTM_LNK_DATA_DIR}/${TMP_DC_MTTM_SETUP_RELY_MARK}/${TMP_DC_MTTM_SETUP_IMG_MARK_NAME}/${TMP_DC_MTTM_SETUP_IMG_VER}
        ## /opt/docker/etc/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1
        ## /mountdisk/etc/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1
        local TMP_DC_SETUP_MTTM_RELY_LNK_ETC_DIR=${TMP_DC_CPL_SETUP_MTTM_LNK_ETC_DIR}/${TMP_DC_MTTM_SETUP_RELY_MARK}/${TMP_DC_MTTM_SETUP_IMG_MARK_NAME}/${TMP_DC_MTTM_SETUP_IMG_VER}

        # 安装后的规范路径（此处依据实际路径名称修改）
        ## /opt/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/work
        local TMP_DC_MTTM_SETUP_WORK_DIR=${TMP_DC_MTTM_SETUP_DIR}/${TMP_DC_MTTM_SETUP_WORK_MARK}
        ## /opt/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/logs
        local TMP_DC_MTTM_SETUP_LOGS_DIR=${TMP_DC_MTTM_SETUP_DIR}/${TMP_DC_MTTM_SETUP_LOGS_MARK}
        ## /opt/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/data
        local TMP_DC_MTTM_SETUP_DATA_DIR=${TMP_DC_MTTM_SETUP_DIR}/${TMP_DC_MTTM_SETUP_DATA_MARK}
        ## /opt/docker_apps/mattermost/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/etc
        local TMP_DC_MTTM_SETUP_ETC_DIR=${TMP_DC_MTTM_SETUP_DIR}/${TMP_DC_MTTM_SETUP_ETC_MARK}
        
        echo_style_text "View the 'build yaml'↓:"
        echo "${TMP_DC_MTTM_SETUP_SERVICE_NODE}" | yq

        formal_dc_mattermost

        conf_dc_mattermost
        
        boot_check_dc_mattermost "${TMP_DC_MTTM_SETUP_SERVICE_KEY}" "${TMP_DC_MTTM_SETUP_CTN_PORT}"
    }

    # 从容器中提取启动数据
    echo_style_wrap_text "Starting 'execute step' <${TMP_DC_MTTM_SETUP_SERVICE_IMG_FULL_NAME}>]('${TMP_DC_MTTM_SETUP_SERVICE_CTN_NAME}'/'${TMP_DC_MTTM_SETUP_SERVICE_KEY}'), hold on please"
    docker_container_param_check_action "${TMP_DC_MTTM_SETUP_SERVICE_CTN_NAME}" "_exec_step_dc_mattermost"
    
    return $?
}

##########################################################################################################

# x3-2：规格化软件目录格式
function formal_adjust_cps_dc_mattermost() {
    cd ${TMP_DC_CPL_MTTM_SETUP_COMPOSE_DIR}

    echo_style_wrap_text "Starting 'formal adjust compose dirs', hold on please"

    # 创建链接规则
    echo_style_text "View the 'symlink create':↓"
    ## 日志
    ### /opt/docker_apps/mattermost/v2.4/logs -> /mountdisk/logs/docker_apps/mattermost/v2.4
    path_not_exists_link "${TMP_DC_CPL_MTTM_SETUP_LOGS_DIR}" "" "${TMP_DC_CPL_MTTM_SETUP_LNK_LOGS_DIR}"
    ### /opt/docker/logs/mattermost/v2.4 -> /mountdisk/logs/docker_apps/mattermost/v2.4
    path_not_exists_link "${TMP_DC_CPL_SETUP_MTTM_LNK_LOGS_DIR}" "" "${TMP_DC_CPL_MTTM_SETUP_LNK_LOGS_DIR}"
    ## 数据
    ### /opt/docker_apps/mattermost/v2.4/data -> /mountdisk/data/docker_apps/mattermost/v2.4
    path_not_exists_link "${TMP_DC_CPL_MTTM_SETUP_DATA_DIR}" "" "${TMP_DC_CPL_MTTM_SETUP_LNK_DATA_DIR}"
    ### /opt/docker/data/apps/mattermost/v2.4 -> /mountdisk/data/docker_apps/mattermost/v2.4
    path_not_exists_link "${TMP_DC_CPL_SETUP_MTTM_LNK_DATA_DIR}" "" "${TMP_DC_CPL_MTTM_SETUP_LNK_DATA_DIR}"
    ## ETC
    ### /opt/docker_apps/mattermost/v2.4/etc -> /mountdisk/etc/docker_apps/mattermost/v2.4
    path_not_exists_link "${TMP_DC_CPL_MTTM_SETUP_ETC_DIR}" "" "${TMP_DC_CPL_MTTM_SETUP_LNK_ETC_DIR}"
    ### /opt/docker_apps/mattermost/v2.4/compose/common/config -> /mountdisk/etc/docker_apps/mattermost/v2.4/compose
    path_not_exists_link "${TMP_DC_CPL_MTTM_SETUP_COMPOSE_DIR}/common/config" "" "${TMP_DC_CPL_MTTM_SETUP_LNK_ETC_DIR}/compose"
    ### /opt/docker/etc/mattermost/v2.4 -> /mountdisk/etc/docker_apps/mattermost/v2.4
    path_not_exists_link "${TMP_DC_CPL_SETUP_MTTM_LNK_ETC_DIR}" "" "${TMP_DC_CPL_MTTM_SETUP_LNK_ETC_DIR}"

    return $?
}

# x3-1：解析compose文件，并安装
#    参数1：（忽略）镜像名称，例 mattermost/prepare
#    参数2：（忽略）镜像版本，例 latest
#    参数3：（忽略）启动命令，例 /bin/sh
#    参数4：（忽略）启动参数，例 --volume /etc/localtime:/etc/localtime
#    参数5：（忽略）快照类型(还原时有效)，例 image/container/dockerfile
#    参数6：（忽略）快照来源，例 snapshot/clean/hub/commit，默认snapshot
function resolve_compose_dc_mattermost_loop()
{
	# 变量覆盖特性，其它方法均可读取
    ## 安装后的规范路径（此处依据实际路径名称修改）
    ### /opt/docker_apps/mattermost/v2.4/rely
    local TMP_DC_CPL_MTTM_SETUP_RELY_DIR=${TMP_DC_CPL_MTTM_SETUP_DIR}/${TMP_DC_MTTM_SETUP_RELY_MARK}
    ### /opt/docker_apps/mattermost/v2.4/work
    # local TMP_DC_CPL_MTTM_SETUP_WORK_DIR=${TMP_DC_CPL_MTTM_SETUP_DIR}/${TMP_DC_MTTM_SETUP_WORK_MARK}
    ### /opt/docker_apps/mattermost/v2.4/logs
    local TMP_DC_CPL_MTTM_SETUP_LOGS_DIR=${TMP_DC_CPL_MTTM_SETUP_DIR}/${TMP_DC_MTTM_SETUP_LOGS_MARK}
    ### /opt/docker_apps/mattermost/v2.4/data
    local TMP_DC_CPL_MTTM_SETUP_DATA_DIR=${TMP_DC_CPL_MTTM_SETUP_DIR}/${TMP_DC_MTTM_SETUP_DATA_MARK}
    ### /opt/docker_apps/mattermost/v2.4/etc
    local TMP_DC_CPL_MTTM_SETUP_ETC_DIR=${TMP_DC_CPL_MTTM_SETUP_DIR}/${TMP_DC_MTTM_SETUP_ETC_MARK}

    ## 指定Docker的安装路径部分
    ### /mountdisk/logs/docker_apps/mattermost/v2.4
    local TMP_DC_CPL_SETUP_MTTM_LNK_LOGS_DIR=${DOCKER_SETUP_DIR}/${TMP_DC_MTTM_SETUP_LOGS_MARK}/${TMP_DC_CPL_MTTM_SETUP_MARK_NAME}/${TMP_DC_CPL_MTTM_SETUP_VER}
    ### /mountdisk/data/docker_apps/mattermost/v2.4
    local TMP_DC_CPL_SETUP_MTTM_LNK_DATA_DIR=${DOCKER_SETUP_DIR}/${TMP_DC_MTTM_SETUP_DATA_MARK}/apps/${TMP_DC_CPL_MTTM_SETUP_MARK_NAME}/${TMP_DC_CPL_MTTM_SETUP_VER}
    ### /mountdisk/etc/docker_apps/mattermost/v2.4
    local TMP_DC_CPL_SETUP_MTTM_LNK_ETC_DIR=${DOCKER_SETUP_DIR}/${TMP_DC_MTTM_SETUP_ETC_MARK}/${TMP_DC_CPL_MTTM_SETUP_MARK_NAME}/${TMP_DC_CPL_MTTM_SETUP_VER}
    
    if [[ -a docker-compose.yml ]]; then
    
        # 3-2：解析执行
        # echo_style_wrap_text "Starting 'configuration' <compose> 'yaml', hold on please"
        # yaml_split_action "$(cat docker-compose.yml | yq '.services')" "exec_compose_step_dc_mattermost"

        # 3-2：调整整体目录
        formal_adjust_cps_dc_mattermost
        
        # !!!由于原始脚本限定在install.sh中执行了prepare，所以此处在预编译完成后且安装前将其禁用
        sed -i "s@^./prepare@#./prepare@g" install.sh

        # 执行compose安装
        echo_style_wrap_text "Starting 'execute' <compose> 'action', hold on please"
        bash install.sh

        # 4-1：安装后操作
        yaml_split_action "$(cat docker-compose.yml | yq '.services')" "exec_step_dc_mattermost"
       
        return $?
    fi
}

##########################################################################################################

# x2-2：迁移compose
function formal_cpl_dc_mattermost() {
    echo_style_wrap_text "Starting 'formal compile', hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移    
    function _formal_cpl_dc_mattermost_cp_source() {
        echo_style_text "View the 'compile migrate'↓:"

        # 拷贝应用目录
        cp -r ${TMP_DC_CPL_MTTM_EXTRA_DIR} ${1}
        
        # 查看列表
        ls -lia ${1}
    }

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_pcreate ${TMP_DC_CPL_MTTM_SETUP_COMPOSE_DIR} "_formal_cpl_dc_mattermost_cp_source"
    
    # 进入compose目录
    cd ${TMP_DC_CPL_MTTM_SETUP_COMPOSE_DIR}
        
    ### 日志(日志初始尚未能创建，compose之后才会创建)
    #### /mountdisk/logs/docker_apps/mattermost/v2.4
    soft_path_restore_confirm_create "${TMP_DC_CPL_MTTM_SETUP_LNK_LOGS_DIR}"
    ### 数据(数据初始尚未能创建，compose之后才会创建)
    #### /mountdisk/data/docker_apps/mattermost/v2.4
    soft_path_restore_confirm_create "${TMP_DC_CPL_MTTM_SETUP_LNK_DATA_DIR}"
    ### ETC(仅判断还原)
    #### /mountdisk/etc/docker_apps/mattermost/v2.4
    soft_path_restore_confirm_create "${TMP_DC_CPL_MTTM_SETUP_LNK_ETC_DIR}"
    
    return $?
}

# x2-3：修改配置
function conf_cpl_dc_mattermost() {
    echo_style_wrap_text "Starting 'configuration migrate compile', hold on please"

	# 修改配置文件
    cd ${TMP_DC_CPL_MTTM_SETUP_COMPOSE_DIR}
    path_not_exists_action ".env" "cp env.example .env"

    local TMP_DC_CPL_MTTM_PSQ_HOST=
    local TMP_DC_CPL_MTTM_PSQ_PORT=
    local TMP_DC_CPL_MTTM_PSQ_LOGIN_NAME=$(cat .env | grep -oP "(?<=^POSTGRES_USER=).+")
    local TMP_DC_CPL_MTTM_PSQ_LOGIN_PASSWORD=$(cat .env | grep -oP "(?<=^POSTGRES_PASSWORD=).+")
    local TMP_DC_CPL_MTTM_PSQ_MAIN_DB=$(cat .env | grep -oP "(?<=^POSTGRES_DB=).+")

    ## 1：判断本地存在则使用本地默认值，通过输入值来判断是否使用自定义的postgres
    ### 1-1-Y：配置变量参数
    #### 禁用节点
    function _conf_cpl_dc_mattermost_disable_postgresql() {
        sed -i "s@^POSTGRES_IMAGE_TAG=@#POSTGRES_IMAGE_TAG=@g" .env
        sed -i "s@^POSTGRES_DATA_PATH=@#POSTGRES_DATA_PATH=@g" .env
        comment_yaml_file_node_item "docker-compose.yml" ".services.postgres"
        comment_yaml_file_node_item "docker-compose.yml" ".services.mattermost.depends_on"
    }

    function _conf_cpl_dc_mattermost_custom_postgresql() {
        local TMP_DC_CPL_MTTM_PSQ_LCL_CTNS=$(docker ps -a --no-trunc | awk "{if(\$2~\"postgres\"){ print \$2\":\"\$1}}")
        # local TMP_DC_CPL_MTTM_PSQ_LCL_CTNS=$(docker ps -a --no-trunc | awk "{ print \$2\":\"\$1}")

        # 选择修改的容器
        local TMP_DC_CPL_MTTM_PSQ_CTN_CHOICE="${TMP_DC_CPL_MTTM_PSQ_LCL_CTNS}"
        ## 大于一条，则开启选择是否使用 自定义的本地容器
        local TMP_DC_CPL_MTTM_PSQ_LCL_CTN_COUNTS=$(echo "${TMP_DC_CPL_MTTM_PSQ_LCL_CTNS}" | wc -l)
        if [ $(echo "${TMP_DC_CPL_MTTM_PSQ_LCL_CTN_COUNTS}-1" | bc) -gt 0 ]; then
            # local TMP_DC_CPL_MTTM_PSQ_USE_LOCAL="Y"
            # confirm_yn_action "TMP_DC_CPL_MTTM_PSQ_USE_LOCAL" "Checked 'depends' <postgresql> on [local] was exists, please 'sure' u will use 'still or not'" "__soft_cmd_check_confirm_git_action '${1}'" "echo_style_text \"Checked 'command'(<${1}>-'git') was ${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC}ed\""
            bind_if_choice "TMP_DC_CPL_MTTM_PSQ_CTN_CHOICE" "Please choice which 'container' u want to execute on" "${TMP_DC_CPL_MTTM_PSQ_LCL_CTNS}"
        fi

        TMP_DC_CPL_MTTM_PSQ_HOST="127.0.0.1"
        TMP_DC_CPL_MTTM_PSQ_PORT=15432
        local TMP_DC_CPL_MTTM_PSQ_ADMIN_USER="postgres"
        local TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD=

        local TMP_DC_CPL_MTTM_PSQ_CTN_ID=$(echo "${TMP_DC_CPL_MTTM_PSQ_CTN_CHOICE}" | cut -d':' -f3)
        if [ -n "${TMP_DC_CPL_MTTM_PSQ_CTN_ID}" ]; then
            local TMP_DC_CPL_MTTM_PSQ_CTN_RUNLIKE=$(su_bash_env_conda_channel_exec "runlike ${TMP_DC_CPL_MTTM_PSQ_CTN_ID}")    
            if [ -z "${TMP_DC_CPL_MTTM_PSQ_CTN_RUNLIKE}" ]; then
                echo_style_text "Cannot print 'runlike' from 'container' <${TMP_DC_CPL_MTTM_PSQ_CTN_ID}>"
                exit -1
            fi
            
            local TMP_DC_CPL_MTTM_PSQ_PORT_PAIR=$(echo "${TMP_DC_CPL_MTTM_PSQ_CTN_RUNLIKE}" | grep -oP "(?<=-p )[0-9|:]+(?=\s*)")

            TMP_DC_CPL_MTTM_PSQ_PORT=$(echo "${TMP_DC_CPL_MTTM_PSQ_PORT_PAIR}" | cut -d':' -f1)
            TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD=$(echo "${TMP_DC_CPL_MTTM_PSQ_CTN_RUNLIKE}" | grep -oP "(?<=--env=POSTGRES_PASSWORD=)\S+")
        fi
        
        TMP_DC_CPL_MTTM_PSQ_HOST=$(console_input "TMP_DC_CPL_MTTM_PSQ_HOST" "Please ender your 'postgres' <host>")
        TMP_DC_CPL_MTTM_PSQ_PORT=$(console_input "TMP_DC_CPL_MTTM_PSQ_PORT" "Please ender your 'postgres' <port> of [${TMP_DC_CPL_MTTM_PSQ_HOST}]")

        if [[ "${TMP_DC_CPL_MTTM_PSQ_ADMIN_USER}" != "127.0.0.1" && "${TMP_DC_CPL_MTTM_PSQ_ADMIN_USER}" != "localhost" ]]; then
            TMP_DC_CPL_MTTM_PSQ_ADMIN_USER=$(console_input "TMP_DC_CPL_MTTM_PSQ_ADMIN_USER" "Please ender your 'postgres' <user> of [${TMP_DC_CPL_MTTM_PSQ_HOST}]:[${TMP_DC_CPL_MTTM_PSQ_PORT}]")
        fi

        if [[ "${TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD}" != "127.0.0.1" && "${TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD}" != "localhost" ]]; then
            TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD=$(console_input "TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD" "Please ender your 'postgres' <password> of [${TMP_DC_CPL_MTTM_PSQ_ADMIN_USER}]@[${TMP_DC_CPL_MTTM_PSQ_HOST}]:[${TMP_DC_CPL_MTTM_PSQ_PORT}]" "y")
        fi

        TMP_DC_CPL_MTTM_PSQ_LOGIN_PASSWORD=$(rand_simple_passwd 'mattermost' 'db' "${TMP_DC_CPL_MTTM_SETUP_VER}")

        # !!!此处之所以分为多段，且用-d后台执行&重启进程，纯属因DEBUG过程中，每次执行脚本时用户或DB创建了，但是进程被阻塞所致。
        local TMP_DC_CPL_MTTM_PSQ_CREATE_DB_SH=$(cat <<EOF
echo "Starting create database ${green}${TMP_DC_CPL_MTTM_PSQ_MAIN_DB}${reset}..."
PGPASSWORD='${TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD}' psql -h ${TMP_DC_CPL_MTTM_PSQ_HOST} -p ${TMP_DC_CPL_MTTM_PSQ_PORT} -U ${TMP_DC_CPL_MTTM_PSQ_ADMIN_USER} -d postgres << ${EOF_TAG} 
CREATE DATABASE ${TMP_DC_CPL_MTTM_PSQ_MAIN_DB} WITH ENCODING 'UTF8';
\l
\du
${EOF_TAG}
EOF
)
        
        local TMP_DC_CPL_MTTM_PSQ_SET_MASTER_USR_SH=$(cat <<EOF
echo "Starting create user ${green}${TMP_DC_CPL_MTTM_PSQ_LOGIN_NAME}${reset}..."
# PGPASSWORD="${TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD}" psql -h ${TMP_DC_CPL_MTTM_PSQ_HOST} -p ${TMP_DC_CPL_MTTM_PSQ_PORT} -U ${TMP_DC_CPL_MTTM_PSQ_ADMIN_USER} -d postgres -c "CREATE ROLE ${TMP_DC_CPL_MTTM_PSQ_LOGIN_NAME} LOGIN ENCRYPTED PASSWORD '${TMP_DC_CPL_MTTM_PSQ_LOGIN_PASSWORD}';"
PGPASSWORD='${TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD}' psql -h ${TMP_DC_CPL_MTTM_PSQ_HOST} -p ${TMP_DC_CPL_MTTM_PSQ_PORT} -U ${TMP_DC_CPL_MTTM_PSQ_ADMIN_USER} -d postgres << ${EOF_TAG} 
CREATE USER ${TMP_DC_CPL_MTTM_PSQ_LOGIN_NAME} LOGIN CONNECTION LIMIT 3 ENCRYPTED PASSWORD '${TMP_DC_CPL_MTTM_PSQ_LOGIN_PASSWORD}';
SELECT * FROM pg_user;
${EOF_TAG}
EOF
)

        # 如果在本地存在docker环境的postgres
        if [ -n "${TMP_DC_CPL_MTTM_PSQ_CTN_ID}" ]; then
            # 插入并执行SQL脚本
            docker_bash_channel_echo_exec "${TMP_DC_CPL_MTTM_PSQ_CTN_ID}" "${TMP_DC_CPL_MTTM_PSQ_CREATE_DB_SH}" "/tmp/init_mattermost_db.sh" "." 'td' 'postgres'     
            docker_bash_channel_echo_exec "${TMP_DC_CPL_MTTM_PSQ_CTN_ID}" "${TMP_DC_CPL_MTTM_PSQ_SET_MASTER_USR_SH}" "/tmp/init_mattermost_usr.sh" "." 'td' 'postgres'

            # 修改配置完重启            
            if [[ "${TMP_DC_CPL_MTTM_PSQ_HOST}" == "127.0.0.1" || "${TMP_DC_CPL_MTTM_PSQ_HOST}" == "localhost" ]]; then  
                docker_bash_channel_exec "${TMP_DC_CPL_MTTM_PSQ_CTN_ID}" "pg_ctl restart && echo" "" "postgres"
            else
                echo_style_text "If u cannot create 'database' <${TMP_DC_CPL_MTTM_PSQ_MAIN_DB}> or 'user' <${TMP_DC_CPL_MTTM_PSQ_LOGIN_NAME}>, pls check manual or kill thread('pg_ctl restart') on command"
            fi     

            echo_style_text "Pls check 'database' <${TMP_DC_CPL_MTTM_PSQ_MAIN_DB}> and 'user' <${TMP_DC_CPL_MTTM_PSQ_LOGIN_NAME}> exists on [${TMP_DC_CPL_MTTM_PSQ_ADMIN_USER}]@[${TMP_DC_CPL_MTTM_PSQ_HOST}]:[${TMP_DC_CPL_MTTM_PSQ_PORT}], then <ender> 'any key' to go on"
            read -e _

            local TMP_DC_CPL_MTTM_PSQ_CHECK_MASTER_SH=$(cat <<EOF
echo
PGPASSWORD="${TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD}" psql -h ${TMP_DC_CPL_MTTM_PSQ_HOST} -p ${TMP_DC_CPL_MTTM_PSQ_PORT} -U ${TMP_DC_CPL_MTTM_PSQ_ADMIN_USER} -d postgres << ${EOF_TAG}
\l
\du
SELECT * FROM pg_user;
${EOF_TAG}
EOF
)

            docker_bash_channel_echo_exec "${TMP_DC_CPL_MTTM_PSQ_CTN_ID}" "${TMP_DC_CPL_MTTM_PSQ_CHECK_MASTER_SH}" "/tmp/check_init_mattermost.sh" "." "t"
        else
            echo_style_text "Pls 'execute follow scripts manual' on <remote postgres> [service]："
            echo "${TMP_SPLITER}"
            echo "${TMP_DC_CPL_MTTM_PSQ_CREATE_DB_SH}"
            echo "${TMP_DC_CPL_MTTM_PSQ_SET_MASTER_USR_SH}"
            echo "${TMP_SPLITER}"
            echo_style_text "If u cannot create 'database' <${TMP_DC_CPL_MTTM_PSQ_MAIN_DB}> or 'user' <${TMP_DC_CPL_MTTM_PSQ_LOGIN_NAME}>, pls check manual or kill thread('pg_ctl restart') on command"
            echo_style_text "Pls check 'database' <${TMP_DC_CPL_MTTM_PSQ_MAIN_DB}> and 'user' <${TMP_DC_CPL_MTTM_PSQ_LOGIN_NAME}> exists on [${TMP_DC_CPL_MTTM_PSQ_ADMIN_USER}]@[${TMP_DC_CPL_MTTM_PSQ_HOST}]:[${TMP_DC_CPL_MTTM_PSQ_PORT}], then <ender> 'any key' to go on"
            read -e _
        fi

        _conf_cpl_dc_mattermost_disable_postgresql
    }

    local TMP_DC_CPL_MTTM_PSQ_USE_CUSTOM="Y"
    confirm_yn_action "TMP_DC_CPL_MTTM_PSQ_USE_CUSTOM" "Please 'sure' u will use <postgresql> [custom] 'still or not'" "_conf_cpl_dc_mattermost_custom_postgresql" "_conf_cpl_dc_mattermost_disable_postgresql"
    
    # TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD=$(console_input "TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD" "Please ender your 'postgres' <password> of <${TMP_DC_CPL_MTTM_PSQ_ADMIN_USER}>@[${TMP_DC_CPL_MTTM_PSQ_HOST}]:[${TMP_DC_CPL_MTTM_PSQ_PORT}]" "y")
echo "y |${TMP_DC_CPL_MTTM_PSQ_HOST}|"
echo "y |${TMP_DC_CPL_MTTM_PSQ_PORT}|"
echo "y |${TMP_DC_CPL_MTTM_PSQ_ADMIN_USER}|"
echo "y |${TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD}|"
exit -1    
    ### 1-1-N：配置变量参数
    sed -i "s@^POSTGRES_PASSWORD=.*@POSTGRES_PASSWORD=${TMP_DC_CPL_MTTM_PSQ_ADMIN_PASSWORD}@g" .env
    # sed -i "s@^RESTART_POLICY=.*@@g" .env
    sed -i "s@^POSTGRES_DATA_PATH=.*@@g" .env

    ## 2：配置变量参数
    sed -i "s@^MATTERMOST_LOGS_PATH=.*@MATTERMOST_LOGS_PATH=${TMP_DC_CPL_MTTM_SETUP_LNK_LOGS_DIR}@g" .env
    sed -i "s@^MATTERMOST_DATA_PATH=.*@MATTERMOST_DATA_PATH=${TMP_DC_CPL_MTTM_SETUP_LNK_DATA_DIR}@g" .env
    sed -i "s@^MATTERMOST_CONFIG_PATH=.*@MATTERMOST_CONFIG_PATH=${TMP_DC_CPL_MTTM_SETUP_LNK_ETC_DIR}@g" .env
    sed -i "s@^MATTERMOST_PLUGINS_PATH=.*@MATTERMOST_PLUGINS_PATH=${TMP_DC_CPL_MTTM_SETUP_COMPOSE_DIR}/plugins@g" .env
    sed -i "s@^MATTERMOST_CLIENT_PLUGINS_PATH=.*@MATTERMOST_CLIENT_PLUGINS_PATH=${TMP_DC_CPL_MTTM_SETUP_COMPOSE_DIR}/client/plugins@g" .env
    sed -i "s@^MATTERMOST_BLEVE_INDEXES_PATH=.*@MATTERMOST_BLEVE_INDEXES_PATH=${TMP_DC_CPL_MTTM_SETUP_COMPOSE_DIR}/bleve-indexes@g" .env
    # sed -i "s@^CALLS_PORT=.*@@g" .env

    sed -i "s@^NGINX_@#NGINX_@g" .env
    sed -i "s@^CERT_PATH=@#CERT_PATH=@g" .env
    sed -i "s@^KEY_PATH=@#KEY_PATH=@g" .env
    sed -i "s@^HTTP_PORT=@#HTTP_PORT=@g" .env
    sed -i "s@^HTTPS_PORT=@#HTTPS_PORT=@g" .env
    sed -i "s@^CALLS_PORT=@#CALLS_PORT=@g" .env

    sed -i "s@^APP_PORT=@APP_PORT=${TMP_DC_MTTM_SETUP_OPN_APP_PORT}@g" .env
    sed -i "s@^HTTP_PORT=@HTTP_PORT=${TMP_DC_MTTM_SETUP_OPN_HTTP_PORT}@g" .env
    sed -i "s@^HTTPS_PORT=@HTTPS_PORT=${TMP_DC_MTTM_SETUP_OPN_HTTPS_PORT}@g" .env
    sed -i "s@^CALLS_PORT=@CALLS_PORT=${TMP_DC_MTTM_SETUP_OPN_CALLS_PORT}@g" .env
        
    return $?
}

# x2-1：生成compose.yml
# 参数1：软件安装名称
# 参数2：软件安装路径(docker/conda无需采用)
# 参数3：软件解压路径
# 参数4：软件版本（取决于是否存在release版本号）
function build_compose_dc_mattermost() {
	# 变量覆盖特性，其它方法均可读取
	## 执行传入参数
	local TMP_DC_CPL_MTTM_SETUP_NAME=${1}
    local TMP_DC_CPL_MTTM_SETUP_MARK_NAME=${1/\//_}
	# local TMP_DC_CPL_MTTM_SETUP_DIR=${2}
    local TMP_DC_CPL_MTTM_EXTRA_DIR=${3}
    
    ## 统一标记名称(存在于安装目录的真实名称)
    local TMP_DC_MTTM_SETUP_COMPOSE_MARK="compose"
    local TMP_DC_MTTM_SETUP_RELY_MARK="rely"
    local TMP_DC_MTTM_SETUP_WORK_MARK="work"
    local TMP_DC_MTTM_SETUP_LOGS_MARK="logs"
    local TMP_DC_MTTM_SETUP_DATA_MARK="data"
    local TMP_DC_MTTM_SETUP_ETC_MARK="etc"
        
    # 安装依赖
    set_env_dc_mattermost
    
    # 开始编译
    cd ${TMP_DC_CPL_MTTM_EXTRA_DIR}
    
    ## 版本获取
    local TMP_DC_CPL_MTTM_COMPOSE_VER="$(yq '.version' docker-compose.yml)"
    local TMP_DC_CPL_MTTM_SETUP_VER="v${TMP_DC_CPL_MTTM_COMPOSE_VER:-${4}}"
    
    echo_style_wrap_text "Starting 'configuration' <compile> 'yaml', hold on please"
    
    ## 安装后的规范路径（此处依据实际路径名称修改）
    ### /opt/docker_apps/mattermost/v2.4/
    local TMP_DC_CPL_MTTM_SETUP_DIR=${2}/${TMP_DC_CPL_MTTM_SETUP_VER}
    ### /opt/docker_apps/mattermost/v2.4/compose
    local TMP_DC_CPL_MTTM_SETUP_COMPOSE_DIR=${TMP_DC_CPL_MTTM_SETUP_DIR}/${TMP_DC_MTTM_SETUP_COMPOSE_MARK}
    
    ## 统一编排到的路径
    ### /mountdisk/logs/docker_apps/mattermost/v2.4
    local TMP_DC_CPL_MTTM_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_CPL_MTTM_SETUP_MARK_NAME}/${TMP_DC_CPL_MTTM_SETUP_VER}
    ### /mountdisk/data/docker_apps/mattermost/v2.4
    local TMP_DC_CPL_MTTM_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_CPL_MTTM_SETUP_MARK_NAME}/${TMP_DC_CPL_MTTM_SETUP_VER}
    ### /mountdisk/etc/docker_apps/mattermost/v2.4
    local TMP_DC_CPL_MTTM_SETUP_LNK_ETC_DIR=${DOCKER_APP_ATT_DIR}/${TMP_DC_CPL_MTTM_SETUP_MARK_NAME}/${TMP_DC_CPL_MTTM_SETUP_VER}

    # 2-2：目录迁移
    formal_cpl_dc_mattermost
    
    # x2-3：修改配置
    conf_cpl_dc_mattermost
       
    
read -e TTTT
    # 重装/更新/安装
    echo_style_wrap_text "Starting 'build' <compose> 'yaml' & 'execute' <compile>, hold on please"
    
    # 检测安装
    soft_docker_compose_check_upgrade_action "mattermost/prepare" "${TMP_DC_CPL_MTTM_SETUP_VER}" "bash prepare --with-clair --with-chartmuseum" "resolve_compose_dc_mattermost_loop"
    # soft_docker_compose_check_upgrade_action "mattermost/prepare" "${TMP_DC_CPL_MTTM_SETUP_VER}" "bash prepare --with-trivy" "resolve_compose_dc_mattermost_loop"

    # 检测浏览
    boot_check_dc_mattermost "${TMP_DC_CPL_MTTM_SETUP_NAME}" "${TMP_DC_MTTM_SETUP_OPN_HTTP_PORT}"
        
    # 授权开机启动
    echo "${TMP_SPLITER2}"
    echo_style_text "View echo the 'supervisor startup conf'↓:"
    echo_startup_supervisor_config "${TMP_DC_CPL_MTTM_SETUP_MARK_NAME}" "${TMP_DC_CPL_MTTM_SETUP_COMPOSE_DIR}" "docker-compose up -d" "" 999 "" "docker" "false" "0"
    
    # 结束
    exec_sleep 10 "Deploy <mattermost/docker> over, please checking the setup log, this will stay 10 secs to exit"

    return $?
}

# x1：下载/安装/更新软件
# 参数1：软件安装名称
function download_package_dc_mattermost() {
	# 当前路径（仅记录）
	local TMP_DC_MTTM_CURRENT_DIR=$(pwd)
    
    echo_style_wrap_text "Download 'install package' <${1}>, hold on please"

    # 选择及下载安装版本
    # soft_setup_docker_git_wget "${1}" "${1}" "https://github.com/${1}/releases/download/v%s/harbor-offline-installer-v%s.tgz" "${TMP_DC_MTTM_DOWN_VER}" "build_compose_dc_mattermost"
    soft_setup_docker_git "${1}" "https://github.com/mattermost/docker" "build_compose_dc_mattermost" "echo_style_text '<${1}> already installed'"
    return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "mattermost/docker" "download_package_dc_mattermost"