#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
#------------------------------------------------
# 测试时版本：v1.10.17
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
local TMP_DC_HB_SETUP_INN_HTTP_PORT="80"
local TMP_DC_HB_SETUP_INN_HTTPS_PORT="443"
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
    #### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/etc -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    path_not_exists_link "${TMP_DC_HB_SETUP_ETC_DIR}" "" "${TMP_DC_HB_SETUP_LNK_ETC_DIR}"
    #### /opt/docker/etc/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17 -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    #### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17 -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/compose/registry
    path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_ETC_DIR}" "" "${TMP_DC_HB_SETUP_LNK_ETC_DIR}"

    # 有可能未创建容器，有容器的情况下才操作日志
    if [ -n "${TMP_DC_HB_SETUP_CTN_ID}" ]; then
        #### /mountdisk/data/docker/containers/${CTN_ID}
        local TMP_DC_HB_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_DC_HB_SETUP_CTN_ID}"
        #### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry
        local TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR="${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/container/${TMP_DC_HB_SETUP_SERVICE_KEY}"
        
        #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry
        path_swap_link "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}" "${TMP_DC_HB_SETUP_CTN_DIR}"
        
        #### /opt/docker/logs/goharbor_harbor/v1.10.0/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        #### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        path_not_exists_link "${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_HB_SETUP_CTN_ID}-json.log" "" "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}/${TMP_DC_HB_SETUP_CTN_ID}-json.log"
        #### /opt/docker/logs/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        #### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/container/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/container/registry/${CTN_ID}-json.log
        path_not_exists_link "${TMP_DC_SETUP_HB_RELY_LNK_LOGS_DIR}/container/container/${TMP_DC_HB_SETUP_CTN_ID}-json.log" "" "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}/${TMP_DC_HB_SETUP_CTN_ID}-json.log"        
    fi
    
    # 预实验部分        
    ## 目录调整完修改启动参数
    ## 修改启动参数
    # local TMP_DC_HB_SETUP_CTN_TMP="/tmp/${TMP_DC_HB_SETUP_SERVICE_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_SERVICE_IMG_VER}"
    # soft_path_restore_confirm_create "${TMP_DC_HB_SETUP_CTN_TMP}"
    # ${TMP_DC_HB_SETUP_CTN_TMP}:/tmp"
    #
    # ${TMP_DC_HB_SETUP_WORK_DIR}:/harbor"
    # ${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/app_output:/var/logs/${TMP_DC_HB_SETUP_APP_MARK}"
    # ${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/app_output:/harbor/${TMP_DC_HB_SETUP_LOGS_MARK}"
    # ${TMP_DC_HB_SETUP_LNK_DATA_DIR}:/harbor/${TMP_DC_HB_SETUP_DATA_MARK}"
    # ${TMP_DC_HB_SETUP_LNK_DATA_DIR}:/var/lib/${TMP_DC_HB_SETUP_APP_MARK}"
    # ${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/app:/harbor/${TMP_DC_HB_SETUP_ETC_MARK}
    # ${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/app:/etc/${TMP_DC_HB_SETUP_APP_MARK}
    
return
    echo "${TMP_SPLITER2}"
    echo_style_text "Starting 'inspect change', hold on please"

    # 挂载目录(必须停止服务才能修改，否则会无效)
    docker_change_container_volume_migrate "${TMP_DC_HB_SETUP_CTN_ID}" "${TMP_DC_HB_SETUP_WORK_DIR}:/harbor ${TMP_DC_HB_SETUP_LNK_DATA_DIR}:/harbor/${TMP_DC_HB_SETUP_DATA_MARK}"
    # docker_change_container_volume_migrate "${TMP_DC_HB_SETUP_CTN_ID}" "${TMP_DC_HB_SETUP_WORK_DIR}:/harbor ${TMP_DC_HB_SETUP_LNK_DATA_DIR}:/harbor/${TMP_DC_HB_SETUP_DATA_MARK}" "" $([[ -z "${TMP_DC_HB_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    
    # # 给该一次性容器取个别名，以后就可以直接使用whaler了
    # alias whaler="docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock:ro pegleg/whaler"

    return $?
}

##########################################################################################################

# 4-1-2：设置软件
function conf_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration' <${TMP_DC_HB_SETUP_SERVICE_KEY}>, hold on please"

    # 开始配置
    # docker_bash_channel_exec "${TMP_DC_HB_SETUP_CTN_ID}" "sed -i \"s@os.tmpdir()@\'\/usr\/src\/app\'@g\" src/utils.js" "t" "root" "/harbor"

    return $?
}

##########################################################################################################

# 4-1-3：启动后检测脚本
# 参数1：最终启动名称
# 参数2：最终启动端口
function boot_http_check_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    # 实验部分
    echo_style_wrap_text "Starting 'boot http check' <${1}>, hold on please"
    if [ -n "${2}" ]; then
        echo_style_text "View the 'container visit'↓:"
        curl -s http://localhost:${2}
        echo

        echo_soft_port "TMP_DC_HB_SETUP_OPN_HTTP_PORT"
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
    ### goharbor/harbor-core
    local TMP_DC_HB_SETUP_SERVICE_IMG_NAME=$(echo "${TMP_DC_HB_SETUP_SERVICE_IMG_FULL_NAME}" |  cut -d':' -f1)
    ### goharbor_registry-photon
    local TMP_DC_HB_SETUP_SERVICE_IMG_MARK_NAME="${TMP_DC_HB_SETUP_SERVICE_IMG_NAME/\//_}"
    ### v1.10.0
    local TMP_DC_HB_SETUP_SERVICE_IMG_VER=$(echo "${TMP_DC_HB_SETUP_SERVICE_IMG_FULL_NAME}" | cut -d':' -f2 | awk '$1=$1')
    
    ## 定义检索参数
    local TMP_DC_HB_SETUP_IMG_ID=""
    local TMP_DC_HB_SETUP_IMG_NAME=""
    local TMP_DC_HB_SETUP_IMG_VER=""
    local TMP_DC_HB_SETUP_CTN_ID=""
    # local TMP_DC_HB_SETUP_PS_SID="${TMP_DC_HB_SETUP_CTN_ID:0:12}"
    local TMP_DC_HB_SETUP_CTN_PORT=""
    # v1.10.0/v1.10.0_v1670000000
    local TMP_DC_HB_SETUP_CTN_CMD=""
    local TMP_DC_HB_SETUP_CTN_ARGS=""

    # 检索绑定查询到的容器信息
    function _exec_step_dc_goharbor_harbor_bind_ctn_data()
    {
        TMP_DC_HB_SETUP_IMG_ID=${1}
        TMP_DC_HB_SETUP_CTN_ID=${2}
        TMP_DC_HB_SETUP_IMG_NAME=${3}
        TMP_DC_HB_SETUP_CTN_PORT=$(echo "${6}" | grep -oP "(?<=-p )\d+(?=:\d+)")
        TMP_DC_HB_SETUP_IMG_VER=${4}
        TMP_DC_HB_SETUP_CTN_CMD=${5}
        TMP_DC_HB_SETUP_CTN_ARGS=${6}
    }
    echo_style_text "Starting 'bind service container' <${TMP_DC_HB_SETUP_SERVICE_IMG_NAME}>:[${TMP_DC_HB_SETUP_SERVICE_IMG_VER}]('${TMP_DC_HB_SETUP_SERVICE_CTN_NAME}'), hold on please"
    docker_container_param_check_action "${TMP_DC_HB_SETUP_SERVICE_CTN_NAME}" "_exec_step_dc_goharbor_harbor_bind_ctn_data"
    
    function _exec_step_dc_goharbor_harbor()
    {
        ## 统一编排到的路径
        ### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_HB_SETUP_DIR=${TMP_DC_CPL_HB_SETUP_RELY_DIR}/${TMP_DC_HB_SETUP_SERVICE_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_SERVICE_IMG_VER}
        ### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose/registry
        # local TMP_DC_HB_SETUP_LNK_LOGS_DIR=${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}/${TMP_DC_HB_SETUP_SERVICE_KEY}
        ### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/compose/registry
        local TMP_DC_HB_SETUP_LNK_DATA_DIR=${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}/${TMP_DC_HB_SETUP_SERVICE_KEY}
        ### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/compose/registry
        local TMP_DC_HB_SETUP_LNK_ETC_DIR=${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}/${TMP_DC_HB_SETUP_SERVICE_KEY}

        ## 指定Docker的安装路径部分
        #### /opt/docker/logs/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        #### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_SETUP_HB_RELY_LNK_LOGS_DIR=${TMP_DC_CPL_SETUP_HB_LNK_LOGS_DIR}/${TMP_DC_HB_SETUP_RELY_MARK}/${TMP_DC_HB_SETUP_SERVICE_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_SERVICE_IMG_VER}
        #### /opt/docker/data/apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        #### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_SETUP_HB_RELY_LNK_DATA_DIR=${TMP_DC_CPL_SETUP_HB_LNK_DATA_DIR}/${TMP_DC_HB_SETUP_RELY_MARK}/${TMP_DC_HB_SETUP_SERVICE_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_SERVICE_IMG_VER}
        #### /opt/docker/etc/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        #### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17
        local TMP_DC_SETUP_HB_RELY_LNK_ETC_DIR=${TMP_DC_CPL_SETUP_HB_LNK_ETC_DIR}/${TMP_DC_HB_SETUP_RELY_MARK}/${TMP_DC_HB_SETUP_SERVICE_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_SERVICE_IMG_VER}

        ## 安装后的规范路径（此处依据实际路径名称修改）
        ### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/work
        local TMP_DC_HB_SETUP_WORK_DIR=${TMP_DC_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_WORK_MARK}
        ### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/logs
        local TMP_DC_HB_SETUP_LOGS_DIR=${TMP_DC_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_LOGS_MARK}
        ### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/data
        local TMP_DC_HB_SETUP_DATA_DIR=${TMP_DC_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_DATA_MARK}
        ### /opt/docker_apps/goharbor_harbor/v1.10.0/rely/goharbor_registry-photon/v1.10.17/etc
        local TMP_DC_HB_SETUP_ETC_DIR=${TMP_DC_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_ETC_MARK}
        
        echo_style_wrap_text "Starting 'execute service step' <${TMP_DC_HB_SETUP_SERVICE_IMG_NAME}>:[${TMP_DC_HB_SETUP_SERVICE_IMG_VER}]('${TMP_DC_HB_SETUP_SERVICE_KEY}'), hold on please"
        echo_style_text "View the 'build yaml'↓:"
        echo "${TMP_DC_HB_SETUP_SERVICE_NODE}" | yq

        formal_dc_goharbor_harbor

        conf_dc_goharbor_harbor
        
        boot_http_check_dc_goharbor_harbor "${TMP_DC_HB_SETUP_SERVICE_KEY}" "${TMP_DC_HB_SETUP_CTN_PORT}"
    }

    # 轮询镜像与匹配镜像一致才执行
    equals_action "${TMP_DC_HB_SETUP_SERVICE_IMG_FULL_NAME}" "${TMP_DC_HB_SETUP_IMG_NAME}:${TMP_DC_HB_SETUP_IMG_VER}" "_exec_step_dc_goharbor_harbor"

    return $?
}

##########################################################################################################

# # x3-2-1：规格化软件目录格式
# function formal_cps_dc_goharbor_harbor() {
#     cd ${TMP_DC_CPL_HB_SETUP_COMPOSE_DIR}

#     echo_style_wrap_text "Starting 'formal compose dirs' <${TMP_DC_CPS_HB_IMG_NAME}>:[${TMP_DC_CPS_HB_IMG_VER}], hold on please"

#     # 开始标准化
#     ## 还原 & 创建 & 迁移    
#     ### ETC(唯有ETC尚未能指定)
#     #### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/registry
#     #### 传入卷信息，分多卷与单点
#     # 参数1：当前节点内容
#     # 参数2：当前节点索引
#     # 参数3：当前节点key
#     function _formal_dc_goharbor_harbor_formal_exec()
#     {
#         # .service.core.volumes[0]
#         local TMP_DC_CPS_HB_YML_VOL_ITEM="${TMP_DC_CPS_HB_YML_NODE}${TMP_DC_CPS_HB_YML_CURRENT_NODE}[${2}]"
#         docker_compose_formal_print_node_volumes "${1}" "${TMP_DC_CPL_HB_ETC_REL_NODE}" "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}" "${TMP_DC_CPS_HB_YML_VOL_ITEM}"
#     }

#     # 调整env_file节点匹配
#     echo_style_text "View the 'etc env file formal'↓:"
#     local TMP_DC_CPS_HB_YML_CURRENT_NODE=".env_file"
#     yaml_split_action "$(echo "${TMP_DC_CPS_HB_SERVICE_NODE}" | yq "${TMP_DC_CPS_HB_YML_CURRENT_NODE}")" "_formal_dc_goharbor_harbor_formal_exec"
#     echo "[-]"
#     cat docker-compose.yml | yq "${TMP_DC_CPS_HB_YML_NODE}${TMP_DC_CPS_HB_YML_CURRENT_NODE}"

#     echo "${TMP_SPLITER2}"
#     echo_style_text "View the 'etc volumes formal'↓:"
#     # /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/registry
#     TMP_DC_CPS_HB_YML_CURRENT_NODE=".volumes"
#     yaml_split_action "$(echo "${TMP_DC_CPS_HB_SERVICE_NODE}" | yq "${TMP_DC_CPS_HB_YML_CURRENT_NODE}")" "_formal_dc_goharbor_harbor_formal_exec"
#     echo "[-]"
#     cat docker-compose.yml | yq "${TMP_DC_CPS_HB_YML_NODE}${TMP_DC_CPS_HB_YML_CURRENT_NODE}"
    
#     return $?
# }

##########################################################################################################

# # x3-2：执行composer对应step操作（预配置目录信息）
# # 参数1：当前yaml节点信息
# # 参数2：当前yaml节点索引
# # 参数3：当前yaml节点key（由docker-compose.yml设定结构为准），例harbor的keys core/log/db/nginx/registry
# function exec_compose_step_dc_goharbor_harbor() {
# 	# 变量覆盖特性，其它方法均可读取
# 	## 执行传入参数
# 	local TMP_DC_CPS_HB_SERVICE_NODE=${1}
# 	local TMP_DC_CPS_HB_SERVICE_INDEX=${2}
# 	local TMP_DC_CPS_HB_SERVICE_KEY=${3}
    
#     ## 统一编排到的路径
#     ### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/registry
#     local TMP_DC_CPS_HB_SETUP_LNK_LOGS_DIR=${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}/${TMP_DC_CPS_HB_SERVICE_KEY}
#     ### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0/registry
#     local TMP_DC_CPS_HB_SETUP_LNK_DATA_DIR=${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}/${TMP_DC_CPS_HB_SERVICE_KEY}
#     ### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/registry
#     local TMP_DC_CPS_HB_SETUP_LNK_ETC_DIR=${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/${TMP_DC_CPS_HB_SERVICE_KEY}
    
#     ## 安装后的规范路径（此处依据实际路径名称修改）
#     ### /opt/docker_apps/goharbor_harbor/v1.10.0/work/registry
#     # local TMP_DC_CPS_HB_SETUP_WORK_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_WORK_MARK}/${TMP_DC_CPS_HB_SERVICE_KEY}
#     ### /opt/docker_apps/goharbor_harbor/v1.10.0/logs/registry
#     local TMP_DC_CPS_HB_SETUP_LOGS_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_LOGS_MARK}/${TMP_DC_CPS_HB_SERVICE_KEY}
#     ### /opt/docker_apps/goharbor_harbor/v1.10.0/data/registry
#     local TMP_DC_CPS_HB_SETUP_DATA_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_DATA_MARK}/${TMP_DC_CPS_HB_SERVICE_KEY}
#     ### /opt/docker_apps/goharbor_harbor/v1.10.0/etc/registry
#     # local TMP_DC_CPS_HB_SETUP_ETC_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_ETC_MARK}/${TMP_DC_CPS_HB_SERVICE_KEY}

#     ### goharbor/harbor:v1.10.0
#     local TMP_DC_CPS_HB_IMG_FULL_NAME=$(echo "${1}" | yq ".image")
#     local TMP_DC_CPS_HB_IMG_NAME=$(echo "${TMP_DC_CPS_HB_IMG_FULL_NAME}" |  cut -d':' -f1)
#     ### 参照data,log的规则命名
#     local TMP_DC_CPS_HB_IMG_VER=$(echo "${TMP_DC_CPS_HB_IMG_FULL_NAME}" | cut -d':' -f2 | awk '$1=$1')

#     # 当前yml相对路径 .services.core
#     local TMP_DC_CPS_HB_YML_NODE=".services.${TMP_DC_CPS_HB_SERVICE_KEY}"
        
#     cd ${TMP_DC_CPL_HB_EXTRA_DIR}

#     echo_style_wrap_text "Starting 'execute compose step' <${TMP_DC_CPS_HB_IMG_NAME}>:[${TMP_DC_CPS_HB_IMG_VER}], hold on please"
#     echo "${TMP_DC_CPS_HB_SERVICE_NODE}" | yq

#     # x3-2-1：
#     formal_cps_dc_goharbor_harbor

#     return $?
# }

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
    local TMP_DC_CPL_SETUP_HB_LNK_LOGS_DIR=${DOCKER_SETUP_DIR}/${TMP_DC_HB_SETUP_LOGS_MARK}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_MARK_VER}
    ### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_SETUP_HB_LNK_DATA_DIR=${DOCKER_SETUP_DIR}/${TMP_DC_HB_SETUP_DATA_MARK}/apps/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_MARK_VER}
    ### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_SETUP_HB_LNK_ETC_DIR=${DOCKER_SETUP_DIR}/${TMP_DC_HB_SETUP_ETC_MARK}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_MARK_VER}
    
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
    local TMP_DC_CPL_HB_SETUP_ADMIN_PASSWD=$(console_input "$(rand_passwd 'harbor' 'svr' "${TMP_DC_CPL_HB_MARK_VER}")" "Please sure your 'harbo' <admin password>" "y")
    yq -i '.harbor_admin_password = "'${TMP_DC_CPL_HB_SETUP_ADMIN_PASSWD}'"' harbor.yml

    local TMP_DC_CPL_HB_SETUP_DB_PASSWD=$(console_input "$(rand_passwd 'harbor' 'db' "${TMP_DC_CPL_HB_MARK_VER}")" "Please sure your 'harbo' <database password>" "y")
    yq -i '.database.password = "'${TMP_DC_CPL_HB_SETUP_DB_PASSWD}'"' harbor.yml

    # 注释不需要的节点配置
    comment_yaml_file_node_item "harbor.yml" ".https"
    
    # 调整配置指向路径
    ## /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/compose
    sed -i "s@^config_dir=@config_dir=${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK} #@g" prepare
    
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
    local TMP_DC_CPL_HB_SETUP_MARK_NAME="${1/\//_}"
	# local TMP_DC_CPL_HB_SETUP_DIR=${2}
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
    
    ## 版本获取
    local TMP_DC_CPL_HB_MARK_VER="v$(yq '._version' harbor.yml)"
    local TMP_DC_CPL_HB_SETUP_VER="v${4:-${TMP_DC_CPL_HB_MARK_VER}}"
    
    echo_style_wrap_text "Starting 'configuration' <compile> 'yaml', hold on please"
    
    ## 安装后的规范路径（此处依据实际路径名称修改）
    ### /opt/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_HB_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_MARK_VER}
    ### /opt/docker_apps/goharbor_harbor/v1.10.0/compose
    local TMP_DC_CPL_HB_SETUP_COMPOSE_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}
    
    ## 统一编排到的路径
    ### /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_MARK_VER}
    ### /mountdisk/data/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_MARK_VER}
    ### /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0
    local TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR=${DOCKER_APP_ATT_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_MARK_VER}
    
    # 2-2：目录迁移
    formal_cpl_dc_goharbor_harbor
    
    # x2-3：修改配置
    conf_cpl_dc_goharbor_harbor
       
    # 重装/更新/安装
    echo_style_wrap_text "Starting 'build' <compose> 'yaml' & 'execute compile', hold on please"
    
    # 检测安装
    soft_docker_compose_check_upgrade_action "goharbor/prepare" "${TMP_DC_CPL_HB_SETUP_VER}" "bash prepare --with-clair --with-chartmuseum" "bash install.sh" "resolve_compose_dc_goharbor_harbor_loop"

    # 检测浏览
    boot_http_check_dc_goharbor_harbor "${TMP_DC_CPL_HB_SETUP_NAME}" "${TMP_DC_HB_SETUP_OPN_HTTP_PORT}"
    return $?
}

# x1：下载/安装/更新软件
# 参数1：软件安装名称
function download_package_dc_goharbor_harbor() {
	# 当前路径（仅记录）
	local TMP_DC_HB_CURRENT_DIR=$(pwd)
    
    echo_style_wrap_text "Download 'install package' <${1}>, hold on please"

    # 选择及下载安装版本
    soft_setup_docker_git_wget "${1}" "${1}" "https://github.com/${1}/releases/download/v%s/harbor-offline-installer-v%s.tgz" "1.10.17" "build_compose_dc_goharbor_harbor"
    return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "goharbor/harbor" "download_package_dc_goharbor_harbor"