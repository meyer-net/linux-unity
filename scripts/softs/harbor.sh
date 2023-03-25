#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
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

# 2-安装软件
function setup_dc_goharbor_harbor() {
    echo_style_wrap_text "Starting 'install', hold on please"

    function _setup_dc_goharbor_harbor_cp_source() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'compose copy'↓:"

        # 拷贝应用目录
        cp -r ${TMP_DC_CPL_HB_EXTRA_DIR} ${1}
        
        # 查看列表
        ls -lia ${1}
    }

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_pcreate ${TMP_DC_HB_SETUP_COMPOSE_DIR} "_setup_dc_goharbor_harbor_cp_source"

    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    # 开始安装

    return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs', hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移    ### 数据
    #### /mountdisk/data/docker_apps/goharbor_harbor/imgver111111
    function _formal_dc_goharbor_harbor_cp_data() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'data copy'↓:"

        # 拷贝日志目录
        # mkdir -pv ${1}
        # docker cp -a ${TMP_DC_HB_SETUP_CTN_ID}:/var/lib/${TMP_DC_HB_SETUP_APP_MARK} ${1} >& /dev/null
        docker cp -a ${TMP_DC_HB_SETUP_CTN_ID}:/harbor/${TMP_DC_HB_SETUP_DATA_MARK} ${1} >& /dev/null
        
        # 查看列表
        ls -lia ${1}
    }
    soft_path_restore_confirm_pcreate "${TMP_DC_HB_SETUP_LNK_DATA_DIR}" "_formal_dc_goharbor_harbor_cp_data"

    ### ETC - ①-1Y：存在配置文件：原路径文件放给真实路径
    ### ETC目录规范
    #### /mountdisk/data/docker/containers/${CTN_ID}
    local TMP_DC_HB_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_DC_HB_SETUP_CTN_ID}"
    #### /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111/container
    local TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR="${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/container"
    #### /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111
    function _formal_dc_goharbor_harbor_cp_etc() {
    #     echo "${TMP_SPLITER2}"
    #     echo_style_text "View the 'etc copy'↓:"

    #     # 拷贝日志目录
    #     ## /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111/app
    #     # docker cp -a ${TMP_DC_HB_SETUP_CTN_ID}:/harbor/${TMP_DC_HB_SETUP_ETC_MARK} ${1}/app >& /dev/null
    #     docker cp -a ${TMP_DC_HB_SETUP_CTN_ID}:/etc/${TMP_DC_HB_SETUP_APP_MARK} ${1}/app >& /dev/null
    #     ls -lia ${1}
    
    #     # 移除本地配置目录(挂载)
    #     rm -rf ${TMP_DC_HB_SETUP_WORK_DIR}/${TMP_DC_HB_SETUP_ETC_MARK}
        #### /mountdisk/data/docker/containers/${CTN_ID} ©&<- /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111/container
        soft_path_restore_confirm_swap "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}" "${TMP_DC_HB_SETUP_CTN_DIR}"
    }
    soft_path_restore_confirm_create "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}" "_formal_dc_goharbor_harbor_cp_etc"
   
    ### 迁移ETC下LOGS归位
    #### [ 废弃，logs路径会被强制修改未docker root dir对应的数据目录，一旦软连接会被套出多层路径，如下（且修改无效）：
    ##### "LogPath": "/mountdisk/data/docker/containers/4f8b1ca03fe001037e3d701079f094bb5f2a65da089305825546df486c082c22/mountdisk/logs/docker_apps/goharbor_harbor/imgver111111/docker_output/4f8b1ca03fe001037e3d701079f094bb5f2a65da089305825546df486c082c22-json.log"
    #### /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111/container/${CTN_ID}-json.log ©&<- /mountdisk/logs/docker_apps/goharbor_harbor/imgver111111/docker_output/${CTN_ID}-json.log
    # soft_path_restore_confirm_move "${TMP_DC_HB_SETUP_LNK_LOGS_DIR}/docker_output/${TMP_DC_HB_SETUP_CTN_ID}-json.log" "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}/${TMP_DC_HB_SETUP_CTN_ID}-json.log"
    #### ]

    ## 创建链接规则
    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'symlink create':↓"
    ### 日志
    #### /opt/docker_apps/goharbor_harbor/imgver111111/logs -> /mountdisk/logs/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${TMP_DC_HB_SETUP_LOGS_DIR}" "" "${TMP_DC_HB_SETUP_LNK_LOGS_DIR}"
    #### /opt/docker/logs/goharbor_harbor/imgver111111 -> /mountdisk/logs/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/logs/${TMP_DC_CPS_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_CTN_VER}" "" "${TMP_DC_HB_SETUP_LNK_LOGS_DIR}"
    #### /mountdisk/logs/docker_apps/goharbor_harbor/imgver111111/docker_output/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111/container/${CTN_ID}-json.log
    path_not_exists_link "${TMP_DC_HB_SETUP_LNK_LOGS_DIR}/docker_output/${TMP_DC_HB_SETUP_CTN_ID}-json.log" "" "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}/${TMP_DC_HB_SETUP_CTN_ID}-json.log"
    ### 数据
    #### /opt/docker_apps/goharbor_harbor/imgver111111/workspace -> /mountdisk/data/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${TMP_DC_HB_SETUP_DATA_DIR}" "" "${TMP_DC_HB_SETUP_LNK_DATA_DIR}"
    #### /opt/docker/data/apps/goharbor_harbor/imgver111111 -> /mountdisk/data/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/data/apps/${TMP_DC_CPS_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_CTN_VER}" "" "${TMP_DC_HB_SETUP_LNK_DATA_DIR}"
    ### ETC
    #### /opt/docker_apps/goharbor_harbor/imgver111111/etc -> /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${TMP_DC_HB_SETUP_ETC_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}"
    #### /opt/docker/etc/goharbor_harbor/imgver111111 -> /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/etc/${TMP_DC_CPS_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_CTN_VER}" "" "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}"
    #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111/container
    path_not_exists_link "${TMP_DC_HB_SETUP_CTN_DIR}" "" "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}"

    # 预实验部分        
    ## 目录调整完修改启动参数
    ## 修改启动参数
    # local TMP_DC_HB_SETUP_CTN_TMP="/tmp/${TMP_DC_CPS_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_CTN_VER}"
    # soft_path_restore_confirm_create "${TMP_DC_HB_SETUP_CTN_TMP}"
    # ${TMP_DC_HB_SETUP_CTN_TMP}:/tmp"
    #
    # ${TMP_DC_HB_SETUP_WORK_DIR}:/harbor"
    # ${TMP_DC_HB_SETUP_LNK_LOGS_DIR}/app_output:/var/logs/${TMP_DC_HB_SETUP_APP_MARK}"
    # ${TMP_DC_HB_SETUP_LNK_LOGS_DIR}/app_output:/harbor/${TMP_DC_HB_SETUP_LOGS_MARK}"
    # ${TMP_DC_HB_SETUP_LNK_DATA_DIR}:/harbor/${TMP_DC_HB_SETUP_DATA_MARK}"
    # ${TMP_DC_HB_SETUP_LNK_DATA_DIR}:/var/lib/${TMP_DC_HB_SETUP_APP_MARK}"
    # ${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/app:/harbor/${TMP_DC_HB_SETUP_ETC_MARK}
    # ${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/app:/etc/${TMP_DC_HB_SETUP_APP_MARK}
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

# 4-设置软件
function conf_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration', hold on please"

    # 开始配置
    # docker_bash_channel_exec "${TMP_DC_HB_SETUP_CTN_ID}" "sed -i \"s@os.tmpdir()@\'\/usr\/src\/app\'@g\" src/utils.js" "t" "root" "/harbor"

    return $?
}

##########################################################################################################

# 5-测试软件
function test_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}
    
    echo_style_wrap_text "Starting 'test', hold on please"

    # 实验部分

    return $?
}

##########################################################################################################

# 6-启动后检测脚本
# 参数1：启动后的进程ID
# 参数2：最终启动端口
# 参数3：最终启动版本
# 参数3：最终启动命令
# 参数4：最终启动参数
function boot_check_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    # 实验部分
    echo_style_wrap_text "Starting 'boot check', hold on please"

    if [ -n "${TMP_DC_HB_SETUP_CTN_PORT}" ]; then
        echo_style_text "View the 'container visit'↓:"
        curl -s http://localhost:${TMP_DC_HB_SETUP_CTN_PORT}
        echo
    fi

    echo_soft_port "TMP_DC_HB_SETUP_OPN_HTTP_PORT"
}

##########################################################################################################

# 7-1 下载扩展/驱动/插件
function down_ext_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'download exts', hold on please"

    return $?
}

# 7-2 安装与配置扩展/驱动/插件
function setup_ext_dc_goharbor_harbor() {
    cd ${TMP_DC_CPL_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'install exts', hold on please"

    return $?
}

##########################################################################################################

# 8-重新配置（有些软件安装完后需要重新配置）
function reconf_dc_goharbor_harbor()
{
    cd ${TMP_DC_CPL_HB_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'reconf', hold on please"

    # 授权iptables端口访问
    # echo_soft_port ${2}

    # 生成web授权访问脚本
    #echo_web_service_init_scripts "goharbor_harbor${LOCAL_ID}" "goharbor_harbor${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_DC_HB_SETUP_OPN_HTTP_PORT} "${LOCAL_HOST}"

	return $?
}

##########################################################################################################

# x3-执行步骤
function exec_step_dc_goharbor_harbor() {
    # 变量覆盖特性，其它方法均可读取
    ## 统一标记名称(存在于安装目录的真实名称)
    local TMP_DC_HB_SETUP_WORK_MARK="work"
    local TMP_DC_HB_SETUP_LOGS_MARK="logs"
    local TMP_DC_HB_SETUP_DATA_MARK="data"
    local TMP_DC_HB_SETUP_ETC_MARK="etc"
    local TMP_DC_HB_SETUP_APP_MARK="harbor"

    ## 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_DC_HB_SETUP_WORK_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_WORK_MARK}/${TMP_DC_HB_CURRENT_SERVICE_KEY}
    local TMP_DC_HB_SETUP_LOGS_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_LOGS_MARK}/${TMP_DC_HB_CURRENT_SERVICE_KEY}
    local TMP_DC_HB_SETUP_DATA_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_DATA_MARK}/${TMP_DC_HB_CURRENT_SERVICE_KEY}
    local TMP_DC_HB_SETUP_ETC_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_ETC_MARK}/${TMP_DC_HB_CURRENT_SERVICE_KEY}
    
    echo_style_wrap_text "Starting 'execute step' <${TMP_DC_CPL_HB_SETUP_NAME}>:[${TMP_DC_CPL_HB_MARK_VER}]('${TMP_DC_HB_CURRENT_SERVICE_KEY}'), hold on please"
    echo_style_text "View the 'build yaml'↓:"
    echo "${1}" | yq

return 
    setup_dc_goharbor_harbor

    reconf_dc_goharbor_harbor

    test_dc_goharbor_harbor
    
    boot_dc_goharbor_harbor

    return $?
}

##########################################################################################################

# x4-1-迁移compose
function migrate_cps_dc_goharbor_harbor() {
    echo_style_wrap_text "Starting 'migrate compose', hold on please"

    function _migrate_cps_dc_goharbor_harbor_cp_source() {
        echo_style_text "View the 'compose copy'↓:"

        # 拷贝应用目录
        cp -r ${TMP_DC_CPL_HB_EXTRA_DIR} ${1}
        
        # 查看列表
        ls -lia ${1}
    }

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_pcreate ${TMP_DC_HB_SETUP_COMPOSE_DIR} "_migrate_cps_dc_goharbor_harbor_cp_source"

    return $?
}

##########################################################################################################

# x5-1-规格化软件目录格式
function formal_cps_dc_goharbor_harbor() {
    # 配置文件相对路径 common/config/core
    local TMP_DC_CPS_HB_CURRENT_ETC_REL_NODE="${TMP_DC_CPS_HB_ETC_REL_NODE}/${TMP_DC_HB_CURRENT_SERVICE_KEY}"

    cd ${TMP_DC_HB_SETUP_COMPOSE_DIR}

    echo_style_wrap_text "Starting 'formal compose dirs' <${TMP_DC_HB_CURRENT_IMG_NAME}>:[${TMP_DC_HB_CURRENT_IMG_VER}], hold on please"

    # 传入卷信息，分多卷与单点
    # 参数1：当前节点内容
    # 参数2：当前节点索引
    # 参数3：当前节点key
    function _formal_dc_goharbor_harbor_etcs()
    {
        # .service.core.volumes[0]
        local TMP_DC_HB_CURRENT_YML_VOL_ITEM="${TMP_DC_HB_CURRENT_YML_NODE}${TMP_DC_HB_CURRENT_YML_CURRENT_NODE}[${2}]"

        if [ "${1}" != "null" ]; then
            # 匹配节点模型
            local TMP_DC_HB_SETUP_CURRENT_NODE_MODE=$([[ $(echo "${1}" | yq ".source") ]] && echo "node" || echo "item")
            local TMP_DC_HB_SETUP_SOURCE=
            if [ "${TMP_DC_HB_SETUP_CURRENT_NODE_MODE}" == "item" ]; then
                # 匹配KV模型
                TMP_DC_HB_SETUP_SOURCE=$(echo "${1}" | cut -d':' -f1)
            else
                TMP_DC_HB_SETUP_SOURCE=$(echo "${1}" | yq ".source")
            fi

            # 在当前compose目录的情况
            ## 相对路径
            ### 适配 ./common/config/core/app.conf 或 common/config/core/app.conf
            if [ "$(echo "${TMP_DC_HB_SETUP_SOURCE}" | egrep -o '^[.|a-zA-Z]')" ]; then
                # 相对路径 /core/app.conf
                local TMP_DC_HB_SETUP_REL_SOURCE="${TMP_DC_HB_SETUP_SOURCE##*${TMP_DC_CPS_HB_ETC_REL_NODE}}"
                # core
                local TMP_DC_HB_SETUP_REL_KEY=$(echo "${TMP_DC_HB_SETUP_REL_SOURCE}" | cut -d'/' -f2)
                # /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/core
                local TMP_DC_HB_SETUP_CURRENT_LNK_ETC_NODE_SOURCE=${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/${TMP_DC_HB_SETUP_REL_KEY}
                # /opt/docker_apps/goharbor_harbor/v1.10.0/compose/common/config/core
                local TMP_DC_HB_SETUP_CURRENT_CPS_ETC_NODE_SOURCE=$(pwd)/${TMP_DC_CPS_HB_ETC_REL_NODE}/${TMP_DC_HB_SETUP_REL_KEY}
                # /mountdisk/etc/docker_apps/goharbor_harbor/v1.10.0/core/app.conf
                local TMP_DC_HB_SETUP_CURRENT_LNK_ETC_CHANGE_SOURCE=${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}${TMP_DC_HB_SETUP_REL_SOURCE}
                
                if [[ ! -a ${TMP_DC_HB_SETUP_CURRENT_LNK_ETC_NODE_SOURCE} && -a ${TMP_DC_HB_SETUP_CURRENT_CPS_ETC_NODE_SOURCE} ]]; then
                    # 迁移
                    soft_path_restore_confirm_swap "${TMP_DC_HB_SETUP_CURRENT_LNK_ETC_NODE_SOURCE}" "${TMP_DC_HB_SETUP_CURRENT_CPS_ETC_NODE_SOURCE}"
                    ls -lia ${TMP_DC_HB_SETUP_CURRENT_LNK_ETC_NODE_SOURCE}
                    ls -lia ${TMP_DC_HB_SETUP_CURRENT_CPS_ETC_NODE_SOURCE}
                fi

                local TMP_DC_HB_SETUP_CURRENT_LNK_ETC_NODE_SOURCE="${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}${TMP_DC_HB_SETUP_REL_SOURCE}"
                # 修改compose.yml中对应的数据为最新节点
                if [ "${TMP_DC_HB_SETUP_CURRENT_NODE_MODE}" == "item" ]; then
                    if [ "${TMP_DC_HB_CURRENT_YML_CURRENT_NODE}" == ".volume" ]; then
                        local TMP_DC_CPL_HB_SETUP_FULL_TARGET=$(echo "${1}" | awk -F':' '{print $2":"$3}')
                        yq -i ${TMP_DC_HB_CURRENT_YML_VOL_ITEM}' = "'${TMP_DC_HB_SETUP_CURRENT_LNK_ETC_CHANGE_SOURCE}:${TMP_DC_CPL_HB_SETUP_FULL_TARGET}'"' docker-compose.yml
                    else
                        yq -i ${TMP_DC_HB_CURRENT_YML_VOL_ITEM}' = "'${TMP_DC_HB_SETUP_CURRENT_LNK_ETC_CHANGE_SOURCE}'"' docker-compose.yml
                    fi
                else
                    yq -i ${TMP_DC_HB_CURRENT_YML_VOL_ITEM}'.source = "'${TMP_DC_HB_SETUP_CURRENT_LNK_ETC_CHANGE_SOURCE}'"' docker-compose.yml
                fi
            fi
        fi
    }

    # 开始标准化
    ## 还原 & 创建 & 迁移    
    ### ETC目录规范
    #### /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111
    local TMP_DC_HB_SETUP_CURRENT_LNK_ETC_DIR=${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/${TMP_DC_HB_CURRENT_SERVICE_KEY}
    function _formal_dc_goharbor_harbor_cp_etc() {
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'etc format'↓:"

        # 调整env_file节点匹配
        local TMP_DC_HB_CURRENT_YML_CURRENT_NODE=".env_file"
        yaml_split_action "$(echo "${TMP_DC_HB_CURRENT_SERVICE_NODE}" | yq "${TMP_DC_HB_CURRENT_YML_CURRENT_NODE}")" "_formal_dc_goharbor_harbor_etcs"
        cat docker-compose.yml | yq "${TMP_DC_HB_CURRENT_YML_NODE}${TMP_DC_HB_CURRENT_YML_CURRENT_NODE}"
        
        echo "${TMP_SPLITER2}"
        echo_style_text "View the 'volumes format'↓:"
        # /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111/core
        TMP_DC_HB_CURRENT_YML_CURRENT_NODE=".volumes"
        yaml_split_action "$(echo "${TMP_DC_HB_CURRENT_SERVICE_NODE}" | yq "${TMP_DC_HB_CURRENT_YML_CURRENT_NODE}")" "_formal_dc_goharbor_harbor_etcs"
        cat docker-compose.yml | yq "${TMP_DC_HB_CURRENT_YML_NODE}${TMP_DC_HB_CURRENT_YML_CURRENT_NODE}"
    }

    soft_path_restore_confirm_pcreate "${TMP_DC_HB_SETUP_CURRENT_LNK_ETC_DIR}" "_formal_dc_goharbor_harbor_cp_etc"
    
    return

    ## 创建链接规则
    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'symlink create':↓"
    ### 日志
    #### /opt/docker_apps/goharbor_harbor/imgver111111/logs -> /mountdisk/logs/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${TMP_DC_HB_SETUP_LOGS_DIR}" "" "${TMP_DC_HB_SETUP_LNK_LOGS_DIR}"
    #### /opt/docker/logs/goharbor_harbor/imgver111111 -> /mountdisk/logs/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/logs/${TMP_DC_CPS_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_CTN_VER}" "" "${TMP_DC_HB_SETUP_LNK_LOGS_DIR}"
    #### /mountdisk/logs/docker_apps/goharbor_harbor/imgver111111/docker_output/${CTN_ID}-json.log -> /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111/container/${CTN_ID}-json.log
    path_not_exists_link "${TMP_DC_HB_SETUP_LNK_LOGS_DIR}/docker_output/${TMP_DC_HB_SETUP_CTN_ID}-json.log" "" "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}/${TMP_DC_HB_SETUP_CTN_ID}-json.log"
    ### 数据
    #### /opt/docker_apps/goharbor_harbor/imgver111111/workspace -> /mountdisk/data/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${TMP_DC_HB_SETUP_DATA_DIR}" "" "${TMP_DC_HB_SETUP_LNK_DATA_DIR}"
    #### /opt/docker/data/apps/goharbor_harbor/imgver111111 -> /mountdisk/data/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/data/apps/${TMP_DC_CPS_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_CTN_VER}" "" "${TMP_DC_HB_SETUP_LNK_DATA_DIR}"
    ### ETC
    #### /opt/docker_apps/goharbor_harbor/imgver111111/etc -> /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${TMP_DC_HB_SETUP_ETC_DIR}" "" "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}"
    #### /opt/docker/etc/goharbor_harbor/imgver111111 -> /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/etc/${TMP_DC_CPS_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_CTN_VER}" "" "${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}"
    #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/etc/docker_apps/goharbor_harbor/imgver111111/container
    path_not_exists_link "${TMP_DC_HB_SETUP_CTN_DIR}" "" "${TMP_DC_HB_SETUP_LNK_ETC_CTN_DIR}"

    # 预实验部分        
    ## 目录调整完修改启动参数
    ## 修改启动参数
    # local TMP_DC_HB_SETUP_CTN_TMP="/tmp/${TMP_DC_CPS_HB_SETUP_IMG_MARK_NAME}/${TMP_DC_HB_SETUP_CTN_VER}"
    # soft_path_restore_confirm_create "${TMP_DC_HB_SETUP_CTN_TMP}"
    # ${TMP_DC_HB_SETUP_CTN_TMP}:/tmp"
    #
    # ${TMP_DC_HB_SETUP_WORK_DIR}:/harbor"
    # ${TMP_DC_HB_SETUP_LNK_LOGS_DIR}/app_output:/var/logs/${TMP_DC_HB_SETUP_APP_MARK}"
    # ${TMP_DC_HB_SETUP_LNK_LOGS_DIR}/app_output:/harbor/${TMP_DC_HB_SETUP_LOGS_MARK}"
    # ${TMP_DC_HB_SETUP_LNK_DATA_DIR}:/harbor/${TMP_DC_HB_SETUP_DATA_MARK}"
    # ${TMP_DC_HB_SETUP_LNK_DATA_DIR}:/var/lib/${TMP_DC_HB_SETUP_APP_MARK}"
    # ${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/app:/harbor/${TMP_DC_HB_SETUP_ETC_MARK}
    # ${TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR}/app:/etc/${TMP_DC_HB_SETUP_APP_MARK}
    echo "${TMP_SPLITER2}"
    echo_style_text "Starting 'inspect change', hold on please"

    # 挂载目录(必须停止服务才能修改，否则会无效)
    # docker_change_container_volume_migrate "${TMP_DC_HB_SETUP_CTN_ID}" "${TMP_DC_HB_SETUP_WORK_DIR}:/harbor ${TMP_DC_HB_SETUP_LNK_DATA_DIR}:/harbor/${TMP_DC_HB_SETUP_DATA_MARK}"
    # docker_change_container_volume_migrate "${TMP_DC_HB_SETUP_CTN_ID}" "${TMP_DC_HB_SETUP_WORK_DIR}:/harbor ${TMP_DC_HB_SETUP_LNK_DATA_DIR}:/harbor/${TMP_DC_HB_SETUP_DATA_MARK}" "" $([[ -z "${TMP_DC_HB_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    
    return $?
}

##########################################################################################################

# x5-执行composer信息（形成启动后才可抽取目录信息）
# 参数1：当前yaml节点信息
# 参数2：当前yaml节点索引
# 参数3：当前yaml节点key
function exec_compose_step_dc_goharbor_harbor() {
	# 变量覆盖特性，其它方法均可读取
	## 执行传入参数
	local TMP_DC_HB_CURRENT_SERVICE_NODE=${1}
	local TMP_DC_HB_CURRENT_SERVICE_INDEX=${2}
	local TMP_DC_HB_CURRENT_SERVICE_KEY=${3}

    local TMP_DC_HB_CURRENT_IMG_FULL_NAME=$(echo "${1}" | yq ".image")
    local TMP_DC_HB_CURRENT_IMG_NAME=$(echo "${TMP_DC_HB_CURRENT_IMG_FULL_NAME}" |  cut -d':' -f1)
    ### 参照data,log的规则命名
    local TMP_DC_HB_CURRENT_IMG_VER=$(echo "${TMP_DC_HB_CURRENT_IMG_FULL_NAME}" | cut -d':' -f2 | awk '$1=$1')

    # 当前yml相对路径 .services.core
    local TMP_DC_HB_CURRENT_YML_NODE=".services.${TMP_DC_HB_CURRENT_SERVICE_KEY}"
        
    ## 配置文件相对节点（取决于compose.yml中的定义）
    local TMP_DC_CPS_HB_ETC_REL_NODE="common/config"
        
    cd ${TMP_DC_CPL_HB_EXTRA_DIR}

    echo_style_wrap_text "Starting 'execute compose step' <${TMP_DC_HB_CURRENT_IMG_NAME}>:[${TMP_DC_HB_CURRENT_IMG_VER}], hold on please"
    echo "${TMP_DC_HB_CURRENT_SERVICE_NODE}" | yq

    formal_cps_dc_goharbor_harbor

    return $?
}

##########################################################################################################

# x4-解析compose文件，并安装
#    参数1：（忽略）镜像名称，例 goharbor/prepare
#    参数2：（忽略）镜像版本，例 latest
#    参数3：（忽略）启动命令，例 /bin/sh
#    参数4：（忽略）启动参数，例 --volume /etc/localtime:/etc/localtime
#    参数5：（忽略）快照类型(还原时有效)，例 image/container/dockerfile
#    参数6：（忽略）快照来源，例 snapshot/clean/hub/commit，默认snapshot
function resolve_compose_dc_goharbor_harbor_loop()
{
	# 变量覆盖特性，其它方法均可读取
    ## 统一标记名称(存在于安装目录的真实名称)
    local TMP_DC_HB_SETUP_COMPOSE_MARK="compose"

    ## 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_DC_HB_SETUP_COMPOSE_DIR=${TMP_DC_CPL_HB_SETUP_DIR}/${TMP_DC_HB_SETUP_COMPOSE_MARK}

    if [[ -a docker-compose.yml ]]; then
        # 目录迁移
        migrate_cps_dc_goharbor_harbor

        # 解析执行
        echo_style_wrap_text "Starting 'configuration' <compose> 'yaml', hold on please"
        yaml_split_action "$(cat docker-compose.yml | yq '.services')" "exec_compose_step_dc_goharbor_harbor"
cat docker-compose.yml
        return $?
    fi
}

##########################################################################################################

# x3-生成compose.yml
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
    
    # 安装依赖
    set_env_dc_goharbor_harbor
    
    # 开始编译
    cd ${TMP_DC_CPL_HB_EXTRA_DIR}
    
    echo_style_wrap_text "Starting 'configuration' <compile> 'yaml', hold on please"

    ## 版本获取
    local TMP_DC_CPL_HB_MARK_VER="v$(yq '._version' harbor.yml)"
    local TMP_DC_CPL_HB_SETUP_VER="v${4:-${TMP_DC_CPL_HB_MARK_VER}}"
    
    ## 统一编排到的路径
    local TMP_DC_CPL_HB_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_MARK_VER}
    local TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_MARK_VER}
    local TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_MARK_VER}
    local TMP_DC_CPL_HB_SETUP_LNK_ETC_DIR=${DOCKER_APP_ATT_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_NAME}/${TMP_DC_CPL_HB_MARK_VER}

	## 修改配置文件
    yq -i '.hostname = "'${LOCAL_HOST}'"' harbor.yml
    yq -i '.http.port = "'${TMP_DC_HB_SETUP_OPN_HTTP_PORT}'"' harbor.yml
    yq -i '.https.port = "'${TMP_DC_HB_SETUP_OPN_HTTPS_PORT}'"' harbor.yml
    yq -i '.log.local.location = "'${TMP_DC_CPL_HB_SETUP_LNK_LOGS_DIR}'"' harbor.yml
    yq -i '.data_volume = "'${TMP_DC_CPL_HB_SETUP_LNK_DATA_DIR}'"' harbor.yml

    ## 设定DB密码
    local TMP_DC_CPL_HB_SETUP_ADMIN_PASSWD=$(console_input "$(rand_passwd 'harbor' 'svr' "${TMP_DC_CPL_HB_MARK_VER}")" "Please sure your 'harbo' <admin password>" "y")
    yq -i '.harbor_admin_password = "'${TMP_DC_CPL_HB_SETUP_ADMIN_PASSWD}'"' harbor.yml

    local TMP_DC_CPL_HB_SETUP_DB_PASSWD=$(console_input "$(rand_passwd 'harbor' 'db' "${TMP_DC_CPL_HB_MARK_VER}")" "Please sure your 'harbo' <database password>" "y")
    yq -i '.database.password = "'${TMP_DC_CPL_HB_SETUP_DB_PASSWD}'"' harbor.yml

    ## 注释不需要的节点配置
    comment_yaml_file_node_item "harbor.yml" ".https"
   
    # 重装/更新/安装
    echo_style_wrap_text "Starting 'build' <compose> 'yaml' & 'execute compile', hold on please"
    soft_docker_compose_check_upgrade_action "goharbor/prepare" "${TMP_DC_CPL_HB_SETUP_VER}" "bash prepare" "bash install.sh --with-chartmuseum" "resolve_compose_dc_goharbor_harbor_loop"
    return $?
}

# x1-下载/安装/更新软件
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