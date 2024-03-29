#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#         
#         
#		  
#------------------------------------------------
# Compose文件版本：v$down_ver
# 依赖镜像版本：v$img_ver
#------------------------------------------------
# 涵盖：mysql、postgresql等服务
#------------------------------------------------
# source scripts/softs/docker/$soft_setup_name.sh
#------------------------------------------------
# Debug：
# dpa -f name="$img_from_repo" | awk 'NR>1{print $1}' | xargs docker stop
# dpa -f name="$img_from_repo" | awk 'NR>1{print $1}' | xargs -I {} docker rm {} && rm -rf /mountdisk/data/docker/containers/{}*
# di | awk '{if($1~"$img_from_repo/"){print $3}}' | xargs docker rmi
# rm -rf /opt/docker_apps/$compose_from_repo* && rm -rf /mountdisk/conf/docker_apps/$compose_from_repo* && rm -rf /mountdisk/logs/docker_apps/$compose_from_repo* && rm -rf /mountdisk/data/docker_apps/$compose_from_repo* && rm -rf /opt/docker/data/apps/$compose_from_repo* && rm -rf /opt/docker/conf/$compose_from_repo* && rm -rf /opt/docker/logs/$compose_from_repo* && rm -rf /mountdisk/repo/migrate/clean/$compose_from_repo* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/$compose_from_repo && rm -rf /mountdisk/repo/backup/mountdisk/conf/docker_apps/$compose_from_repo && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/$compose_from_repo && rm -rf /mountdisk/repo/backup/mountdisk/data/docker/volumes/000000000000_* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker/volumes/000000000000_* && rm -rf /mountdisk/repo/backup/mountdisk/conf/docker/volumes/000000000000_* && rm -rf /mountdisk/conf/conda_apps/supervisor/boots/$compose_from_repo*.conf
# rm -rf /mountdisk/repo/backup/opt/docker_apps/$compose_from_repo* && rm -rf /mountdisk/repo/backup/mountdisk/conf/docker_apps/$compose_from_repo* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/$compose_from_repo* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/$compose_from_repo* && rm -rf /mountdisk/repo/backup/opt/docker/data/apps/$compose_from_repo* && rm -rf /mountdisk/repo/backup/opt/docker/conf/$compose_from_repo* && rm -rf /mountdisk/repo/backup/opt/docker/logs/$compose_from_repo*
# dvl | awk '{print $2}' | xargs dv rm
# dvl | awk 'NR>1{print $2}' | xargs -I {} docker volume inspect {} | jq ".[0].Mountpoint" | xargs -I {} echo {} | xargs ls -lia
#------------------------------------------------
# 软件安装标题：$soft_title
#      例：mattermost
# 软件安装名称：$soft_setup_name
#      例：mattermost
# 软件归属库：$compose_from_repo
#        例：mattermost
# Compose仓库名称：$compose_repo
#             例：mattermost/docker
# 主镜像名称：$repo_main_img_mark_name
#       例：mattermost-enterprise-edition
# 主镜像key：$repo_main_svr_key
#       例：mattermost
# 镜像归属库：$img_from_repo
#        例：mattermost
# 仓库标记名称：$repo_mark_name
#       例：mattermost_docker
# 软件端口：$soft_port
#       例：8065
# 下载版本：$down_ver
#       例：2.4
# 镜像版本：$img_ver
#       例：7
# 软件大写分组与简称：$soft_upper_short_name
#               例：HB
# 软件GIT仓储名称：${docker_prefix}
# 软件GIT仓储名称：${git_repo}
#------------------------------------------------
local TMP_DC_$soft_upper_short_name_DISPLAY_TITLE="$soft_title"
local TMP_DC_$soft_upper_short_name_SETUP_REPO="$compose_repo"
local TMP_DC_$soft_upper_short_name_DOWN_VER="$down_ver"
local TMP_DC_$soft_upper_short_name_SETUP_INN_APP_PORT=$soft_port
local TMP_DC_$soft_upper_short_name_SETUP_INN_HTTP_PORT=80
local TMP_DC_$soft_upper_short_name_SETUP_INN_HTTPS_PORT=443
local TMP_DC_$soft_upper_short_name_SETUP_OPN_APP_PORT=1${TMP_DC_$soft_upper_short_name_SETUP_INN_APP_PORT}
local TMP_DC_$soft_upper_short_name_SETUP_OPN_HTTP_PORT=102${TMP_DC_$soft_upper_short_name_SETUP_INN_HTTP_PORT}
local TMP_DC_$soft_upper_short_name_SETUP_OPN_HTTPS_PORT=12${TMP_DC_$soft_upper_short_name_SETUP_INN_HTTPS_PORT}

##########################################################################################################

# 1-配置环境
function set_env_dc_$soft_setup_name() {
    echo_style_wrap_text "Starting 'configuare' <${TMP_DC_$soft_upper_short_name_SETUP_REPO}> 'deploy' [envs], hold on please"

    cd ${__DIR}

    return $?
}

##########################################################################################################

# x4-1-1：安装软件
function setup_dc_rely_$soft_setup_name() {
    cd ${TMP_DC_BLC_SETUP_DIR}

    echo_style_wrap_text "Starting 'install rely' <${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}>, hold on please"

    ## /opt/docker_apps/$repo_mark_name/v$down_ver/work/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver
    local TMP_DC_$soft_upper_short_name_SETUP_WORK_RELY_SERVICE_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_WORK_DIR}/${DEPLOY_RELY_MARK}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_NAME}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_VER}

    # 有容器，且有workdir的情况，且workdir不是根目录的情况
    if [[ -n "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}" && -n "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_WORK_DIR}" && "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_WORK_DIR}" != "/" ]]; then
        # 工作
        ## /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/work
        function _setup_dc_rely_$soft_setup_name_cp_work() {
            echo "${TMP_SPLITER2}"
            echo_style_text "[View] the 'workingdir copy rely'↓:"

            # 拷贝应用目录
            docker cp -a ${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}:${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_WORK_DIR} ${1} >& /dev/null

            # 删除重复目录
            # docker container inspect ${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID} | jq ".[].Mounts[].Destination" | grep -oP "(?<=\"${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_WORK_DIR}/).+(?=\")" | xargs -I {} rm -rf ${1}/{}
            
            # 修改权限 & 查看列表
            sudo chown -R ${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_UID}:${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_GID} ${1}
            ls -lia ${1}
            echo
        }

        # 创建安装目录(纯属为了规范)
        soft_path_restore_confirm_pcreate "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_WORK_DIR}" "_setup_dc_rely_$soft_setup_name_cp_work"
        
        ### 工作（真实目录存在依赖包内）
        #### /opt/docker_apps/$repo_mark_name/v$down_ver/work/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver -> /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/work
        path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_WORK_RELY_SERVICE_DIR}" "" "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_WORK_DIR}"

        TMP_DC_$soft_upper_short_name_SETUP_ATT_MOUNTS="${TMP_DC_$soft_upper_short_name_SETUP_ATT_MOUNTS} ${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_WORK_DIR}:${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_WORK_DIR}:rw,z"
    fi

    cd ${TMP_DC_BLC_SETUP_DIR}

    # 开始安装

    return $?
}

# x4-1-2：规格化软件目录格式
function formal_dc_rely_$soft_setup_name() {
    cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs rely' <${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}>, hold on please"

    # 开始标准化
    ## 创建链接规则"
    echo_style_text "[View] the 'symlink create rely':↓"

    ### 日志
    #### 1：没有文件夹
    # #### /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/logs/compose/$repo_main_svr_key.log -> /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key.log
    # path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_LOGS_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}.log" "" "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_COMPOSE_LOGS_DIR}.log"
    # #### /opt/docker/logs/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/compose/$repo_main_svr_key.log -> /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key.log
    # #### /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/compose/$repo_main_svr_key.log -> /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key.log
    # path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_LOGS_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}.log" "" "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_COMPOSE_LOGS_DIR}.log"
    #### 2：有文件夹
    #### /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/logs/compose/$repo_main_svr_key/$repo_main_svr_key.log -> /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key/$repo_main_svr_key.log
    path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_LOGS_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}.log" "" "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_COMPOSE_LOGS_DIR}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}.log"
    #### /opt/docker/logs/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/compose/$repo_main_svr_key/$repo_main_svr_key.log -> /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key/$repo_main_svr_key.log
    #### /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/compose/$repo_main_svr_key/$repo_main_svr_key.log -> /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key/$repo_main_svr_key.log
    path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_LOGS_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}.log" "" "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_COMPOSE_LOGS_DIR}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}.log"
    
    ### 数据
    #### /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/data -> /mountdisk/data/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key
    path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_DATA_DIR}" "" "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_COMPOSE_DATA_DIR}"
    #### /opt/docker/data/apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver -> /mountdisk/data/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key
    #### /mountdisk/data/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver -> /mountdisk/data/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key
    path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_DATA_DIR}" "" "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_COMPOSE_DATA_DIR}"
    
    ### CONF
    #### /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/conf/compose -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key
    path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_CONF_DIR}/${DEPLOY_COMPOSE_MARK}" "" "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_COMPOSE_CONF_DIR}"
    #### /opt/docker/conf/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/compose -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key
    #### /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/compose -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key
    path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_CONF_DIR}/${DEPLOY_COMPOSE_MARK}" "" "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_COMPOSE_CONF_DIR}"

    # 有可能未创建容器，有容器的情况下才操作日志
    if [ -n "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}" ]; then
        #### /mountdisk/data/docker/containers/${CTN_ID}
        local TMP_DC_$soft_upper_short_name_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}"
        #### /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/container/$repo_main_svr_key
        local TMP_DC_$soft_upper_short_name_SETUP_LNK_CONF_CTN_DIR="${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_CONF_DIR}/container/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}"
        
        #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/container/$repo_main_svr_key
        path_swap_link "${TMP_DC_$soft_upper_short_name_SETUP_LNK_CONF_CTN_DIR}" "${TMP_DC_$soft_upper_short_name_SETUP_CTN_DIR}"
        #### /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/conf/container -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/container/$repo_main_svr_key
        path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_CONF_DIR}/container" "" "${TMP_DC_$soft_upper_short_name_SETUP_LNK_CONF_CTN_DIR}"
        #### /opt/docker/conf/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/container -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/container/$repo_main_svr_key
        #### /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/container -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/container/$repo_main_svr_key
        path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_CONF_DIR}/container" "" "${TMP_DC_$soft_upper_short_name_SETUP_LNK_CONF_CTN_DIR}"

        # 等待容器日志生成
        exec_sleep_until_not_empty "Waitting for [container log] generate '${TMP_DC_$soft_upper_short_name_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}-json.log'" "[ -a ${TMP_DC_$soft_upper_short_name_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}-json.log ] && echo 1" 10 1

        #### /opt/docker/logs/$repo_mark_name/v$down_ver/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/container/$repo_main_svr_key/${CTN_ID}-json.log
        #### /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/container/$repo_main_svr_key/${CTN_ID}-json.log
        path_not_exists_link "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}-json.log" "" "${TMP_DC_$soft_upper_short_name_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}-json.log"
        #### /opt/docker/logs/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/container/$repo_main_svr_key/${CTN_ID}-json.log
        #### /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/container/$repo_main_svr_key/${CTN_ID}-json.log
        path_not_exists_link "${TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_LOGS_DIR}/container/${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}-json.log" "" "${TMP_DC_$soft_upper_short_name_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}-json.log"

        # 预实验部分        
        ## 目录调整完修改启动参数
        ## 修改启动参数
        echo "${TMP_SPLITER2}"
        echo_style_text "Starting 'inspect change rely' <${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}>, hold on please"

        # 挂载目录(标记需挂载的磁盘，必须停止服务才能修改，否则会无效)
        cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}

        ## docker_container_hostconfig_binds_echo 覆盖不到全部，有特殊复制直接在流程中拷贝出来并指定映射关系。
        docker_change_container_volume_migrate "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}" "${TMP_DC_$soft_upper_short_name_SETUP_ATT_MOUNTS} $(docker_container_hostconfig_binds_echo "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}")"
        # docker_change_container_volume_migrate "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}" "$(docker_container_hostconfig_binds_echo "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}")" "" $([[ -z "${TMP_DC_$soft_upper_short_name_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    fi

    return $?
}

##########################################################################################################

# x4-1-3：设置软件
function conf_dc_rely_$soft_setup_name() {
    cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration rely' <${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}>, hold on please"

    # 开始配置

    return $?
}

##########################################################################################################

# x2-4 / x4-1-4：启动后检测脚本
# 参数1：最终启动名称
# 参数2：最终启动端口
function boot_check_dc_$soft_setup_name() {
    cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR}

    # 当前启动名称
    local TMP_DC_$soft_upper_short_name_SETUP_CTN_CURRENT_NAME=${1}

    # 当前启动端口
    local TMP_DC_$soft_upper_short_name_SETUP_CTN_CURRENT_PORT=${2}

    # 实验部分  
    ## 有可能未创建容器，有容器的情况下才打印
    echo_style_wrap_text "Starting 'boot check' <${1}>, hold on please"
    if [ -n "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}" ]; then
        function _boot_check_dc_$soft_setup_name()
        {
            TMP_DC_$soft_upper_short_name_SETUP_CTN_CURRENT_PORT=$(echo "${TMP_DC_$soft_upper_short_name_SETUP_CTN_CURRENT_PORT:-${2}}" | awk 'NR==1')
            if [ -n "${TMP_DC_$soft_upper_short_name_SETUP_CTN_CURRENT_PORT}" ]; then
                echo "${TMP_SPLITER3}"
                echo_style_text "[View] the 'container visit'↓:"
                curl -s http://localhost:${TMP_DC_$soft_upper_short_name_SETUP_CTN_CURRENT_PORT}
                echo

                # 授权iptables端口访问
                echo "${TMP_SPLITER2}"
                echo_style_text "[View] echo the 'port'(<${TMP_DC_$soft_upper_short_name_SETUP_CTN_CURRENT_PORT}>) to iptables:↓"
                echo_soft_port "${TMP_DC_$soft_upper_short_name_SETUP_CTN_CURRENT_PORT}"
                
                # 生成web授权访问脚本
                echo_web_service_init_scripts "${TMP_DC_CPL_$soft_upper_short_name_SETUP_MARK_REPO}_${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_VER}-${1}${LOCAL_ID}" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_MARK_REPO}-${1}${LOCAL_ID}-webui.${SYS_DOMAIN}" "${TMP_DC_$soft_upper_short_name_SETUP_CTN_CURRENT_PORT}" "${LOCAL_HOST}"
                
                # 结束
                exec_sleep 10 "Boot <${TMP_DC_$soft_upper_short_name_SETUP_CTN_CURRENT_NAME}> over, please checking the setup log, this will stay %s secs to exit"
            fi
        }

        docker_container_print "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID}" "_boot_check_dc_$soft_setup_name"
    fi
}

# x4-1-5：输出容器端口
function port_echo_dc_rely_$soft_setup_name()
{
    cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'echo port rely' <${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}>, hold on please"

    function _port_echo_dc_rely_$soft_setup_name_exec() {
        # local TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_PORT_PAIR="${1}"
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_OPN_PORT=$(echo "${1}" | cut -d':' -f1)
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_INN_PORT=$(echo "${1}" | cut -d':' -f2)
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_INN_PORT_TYPE=$(echo "${TMP_DC_$soft_upper_short_name_SETUP_RELY_INN_PORT}" | awk -F'/' '{print $2}')
        
        # 授权iptables端口访问
        echo_style_text "[View] echo the '${TMP_DC_$soft_upper_short_name_SETUP_RELY_INN_PORT_TYPE:-tcp} port'(<${TMP_DC_$soft_upper_short_name_SETUP_RELY_OPN_PORT}>) to iptables:↓"
        echo_soft_port "${TMP_DC_$soft_upper_short_name_SETUP_RELY_OPN_PORT}" "" "${TMP_DC_$soft_upper_short_name_SETUP_RELY_INN_PORT_TYPE}"
        echo
    }

    local TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_PORT_PAIRS=$(echo "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ARGS}" | grep -oP "(?<=-p )\S+")
    items_split_action "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_PORT_PAIRS}" "_port_echo_dc_rely_$soft_setup_name_exec"
}

##########################################################################################################

# x4-1：执行步骤
function exec_step_dc_rely_$soft_setup_name() {
    # 始终回归compose目录
    cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}

	# 变量覆盖特性，其它方法均可读取    
    ### $repo_main_img_mark_name:v$down_ver
    local TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_IMG_FULL_NAME=$(echo "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_NODE}" | yq ".image") 
    ### $repo_main_img_mark_name
    local TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_CTN_NAME=$(echo "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_NODE}" | yq ".container_name")
    
    # 检索绑定查询到的容器信息(特殊使用时才会用到)
    function _exec_step_dc_rely_$soft_setup_name()
    {
        # 定义检索参数
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_ID=${1}
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID=${2}
        # local TMP_DC_$soft_upper_short_name_SETUP_CTN_SID="${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID:0:12}"
        ## $repo_main_img_mark_name
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_NAME=${3}
        ## $compose_from_repo_$repo_main_img_mark_name
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_NAME=${3/\//_}
        ## $img_ver
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_VER=${4}
        ## /bin/sh
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_CMD=${5}
        ## --env=xxx
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ARGS=${6}
        ## 8065
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_PORT=$(echo "${6}" | grep -oP "(?<=-p )\d+(?=:\d+)" | awk 'NR==1')

        ## /$soft_setup_name
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_WORK_DIR=$(echo "${6}" | grep -oP "(?<=--workdir\=)[^\s]+")
        if [ -z "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_WORK_DIR}" ]; then
            TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_WORK_DIR=$(docker container inspect --format '{{.Config.WorkingDir}}' ${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_ID})
        fi

        # 默认取进入时的目录
        if [ -z "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_WORK_DIR}" ]; then
            TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_WORK_DIR=$(docker_bash_channel_exec "${2}" "pwd")
        fi

        # 获取授权用户的UID/GID
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_USER=$(echo "${6}" | grep -oP "(?<=--user\=)[^\s]+")
        if [ -z "${TMP_DC_$soft_upper_short_SETUP_RELY_CTN_USER}" ]; then
            TMP_DC_$soft_upper_short_SETUP_RELY_CTN_USER=$(docker_bash_channel_exec "${2}" "whoami")
        fi
        
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_UID=$(docker_bash_channel_exec "${2}" "id -u ${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_USER}")
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_GID=$(docker_bash_channel_exec "${2}" "id -g ${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_USER}")
        
        ## v$img_ver
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_VER=$(echo "${4}" | grep -oP "(?<=v).+")
        if [ -z "${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_VER}" ]; then
            TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_VER="v${4}"
        fi

        # 统一编排到的路径(需注意日志与配置部分，注意会有多层结构，即不止compose)
        ## /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_COMPOSE_LOGS_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}
        ## /mountdisk/data/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_COMPOSE_DATA_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_DATA_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}
        ## /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/compose/$repo_main_svr_key
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_COMPOSE_CONF_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_CONF_DIR}/${DEPLOY_COMPOSE_MARK}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}

        # 指定Docker的安装路径部分
        ## /opt/docker/logs/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver
        ## /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_LOGS_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}/${DEPLOY_RELY_MARK}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_NAME}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_VER}
        ## /opt/docker/data/apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver
        ## /mountdisk/data/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_DATA_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_DATA_DIR}/${DEPLOY_RELY_MARK}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_NAME}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_VER}
        ## /opt/docker/conf/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver
        ## /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_LNK_CONF_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_CONF_DIR}/${DEPLOY_RELY_MARK}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_NAME}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_VER}

        # 安装后的规范路径（此处依据实际路径名称修改）
        ## /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_BASE_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_RELY_DIR}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_NAME}/${TMP_DC_$soft_upper_short_name_SETUP_RELY_IMG_MARK_VER}
        ##TRUE-LINK /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/work
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_WORK_DIR=${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_BASE_DIR}/${DEPLOY_WORK_MARK}
        ## /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/logs
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_LOGS_DIR=${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_BASE_DIR}/${DEPLOY_LOGS_MARK}
        ## /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/data
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_DATA_DIR=${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_BASE_DIR}/${DEPLOY_DATA_MARK}
        ## /opt/docker_apps/$repo_mark_name/v$down_ver/rely/$img_from_repo_$repo_main_img_mark_name/v$img_ver/conf
        local TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_CONF_DIR=${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_BASE_DIR}/${DEPLOY_CONF_MARK}
        
        echo_style_text "[View] the 'build yaml'↓:"
        echo "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_NODE}" | yq

        ## 标准启动参数
        local TMP_DC_$soft_upper_short_name_SETUP_ATT_MOUNTS=""
        
        setup_dc_rely_$soft_setup_name

        formal_dc_rely_$soft_setup_name

        conf_dc_rely_$soft_setup_name
        
        boot_check_dc_$soft_setup_name "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}" "${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_PORT}"

        port_echo_dc_rely_$soft_setup_name
    }
    
    # 从容器中提取启动数据
    echo_style_wrap_text "Starting 'execute step rely' <${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_IMG_FULL_NAME}>('${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_CTN_NAME}'/'${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}'), hold on please"
    
    docker_container_param_check_action "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_CTN_NAME}" "_exec_step_dc_rely_$soft_setup_name"
    
    return $?
}

##########################################################################################################

# x3-2：规格化软件目录格式
function formal_adjust_cps_dc_$soft_setup_name() {
    cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}

    echo_style_wrap_text "Starting 'formal adjust' <${TMP_DC_$soft_upper_short_name_SETUP_REPO}> [compose] 'dirs', hold on please"

    # 指定Docker的安装路径部分变量
    ## /opt/docker/logs/$repo_mark_name/v$soft_ver（/mountdisk/logs/docker_apps/$repo_mark_name/v$soft_ver）
    local TMP_DC_CPL_SETUP_$soft_upper_short_name_DC_LOGS_DIR=${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_MARK_REPO}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}
    ## /opt/docker/data/apps/$repo_mark_name/v$soft_ver（/mountdisk/data/docker_apps/$repo_mark_name/v$soft_ver）
    local TMP_DC_CPL_SETUP_$soft_upper_short_name_DC_DATA_DIR=${DOCKER_SETUP_DIR}/${DEPLOY_DATA_MARK}/apps/${TMP_DC_CPL_$soft_upper_short_name_SETUP_MARK_REPO}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}
    ## /opt/docker/conf/$repo_mark_name/v$soft_ver（/mountdisk/conf/docker_apps/$repo_mark_name/v$soft_ver）
    local TMP_DC_CPL_SETUP_$soft_upper_short_name_DC_CONF_DIR=${DOCKER_SETUP_DIR}/${DEPLOY_CONF_MARK}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_MARK_REPO}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}

    # 创建链接规则
    echo_style_text "[View] the 'symlink create':↓"

    ## 日志
    ### /opt/docker_apps/$repo_mark_name/v$down_ver/logs -> /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver
    path_not_exists_link "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LOGS_DIR}" "" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"
    ### /opt/docker/logs/$repo_mark_name/v$down_ver -> /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver
    path_not_exists_link "${TMP_DC_CPL_SETUP_$soft_upper_short_name_DC_LOGS_DIR}" "" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"
    ## 数据
    ### /opt/docker_apps/$repo_mark_name/v$down_ver/data -> /mountdisk/data/docker_apps/$repo_mark_name/v$down_ver
    path_not_exists_link "${TMP_DC_CPL_$soft_upper_short_name_SETUP_DATA_DIR}" "" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"
    ### /opt/docker/data/apps/$repo_mark_name/v$down_ver -> /mountdisk/data/docker_apps/$repo_mark_name/v$down_ver
    path_not_exists_link "${TMP_DC_CPL_SETUP_$soft_upper_short_name_DC_DATA_DIR}" "" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"
    ## CONF
    ### /opt/docker_apps/$repo_mark_name/v$down_ver/conf -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver
    path_not_exists_link "${TMP_DC_CPL_$soft_upper_short_name_SETUP_CONF_DIR}" "" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_CONF_DIR}"
    ### /opt/docker_apps/$repo_mark_name/v$down_ver/compose/common/config -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver/compose
    # path_not_exists_link "${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}/common/config" "" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_CONF_DIR}/${DEPLOY_COMPOSE_MARK}"
    ### /opt/docker/conf/$repo_mark_name/v$down_ver -> /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver
    path_not_exists_link "${TMP_DC_CPL_SETUP_$soft_upper_short_name_DC_CONF_DIR}" "" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_CONF_DIR}"
    
    # 设置权限
    ## !!! 特殊需求，预先创建对应需要的目录。否则会出现错误：
    ## Error: failed to load configuration: could not create config file: open /xxx: permission denied
    
    # 授权写入
    # sudo chown -R ${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_UID}:${TMP_DC_$soft_upper_short_name_SETUP_RELY_CTN_GID} ${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}/${DEPLOY_COMPOSE_MARK}/$soft_setup_name ${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_DATA_DIR}/${DEPLOY_COMPOSE_MARK}/$soft_setup_name ${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_CONF_DIR}/${DEPLOY_COMPOSE_MARK}/$soft_setup_name 

    return $?
}

# x3-3：配置.env/compose.yml
function conf_adjust_cps_dc_$soft_setup_name() {
    cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}

    echo_style_wrap_text "Starting 'configuration adjust' <${TMP_DC_$soft_upper_short_name_SETUP_REPO}> 'compose.yml & .env', hold on please"
	# 修改配置文件
    # 1：修改.env
    local TMP_DC_CPS_$soft_upper_short_name_PSQ_IMG_TAG=$(cat .env | grep -oP "(?<=^POSTGRES_IMAGE_TAG=).+")
    local TMP_DC_CPS_$soft_upper_short_name_PSQ_HOST="postgres"
    local TMP_DC_CPS_$soft_upper_short_name_PSQ_PORT=5432
    local TMP_DC_CPS_$soft_upper_short_name_PSQ_LOGIN_NAME=$(cat .env | grep -oP "(?<=^POSTGRES_USER=).+")
    local TMP_DC_CPS_$soft_upper_short_name_PSQ_LOGIN_PASSWORD=$(rand_simple_passwd '$soft_setup_name' 'db' "${TMP_DC_CPS_$soft_upper_short_name_PSQ_IMG_TAG:-${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}}")
    local TMP_DC_CPS_$soft_upper_short_name_PSQ_MAIN_DB=$(cat .env | grep -oP "(?<=^POSTGRES_DB=).+")

    ## 1.1：判断本地存在则使用本地默认值，通过输入值来判断是否使用自定义的postgres
    ### 1.1-Y：配置变量参数
    function _conf_cps_dc_$soft_setup_name_custom_postgresql() {
        cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}

        # 重新赋值更改过后的变量
        TMP_DC_CPS_$soft_upper_short_name_PSQ_HOST="${1}"
        TMP_DC_CPS_$soft_upper_short_name_PSQ_PORT=${2}
        # TMP_DC_CPS_$soft_upper_short_name_PSQ_LOGIN_NAME="${3}"
        # TMP_DC_CPS_$soft_upper_short_name_PSQ_LOGIN_PASSWORD="${4}"
        # TMP_DC_CPS_$soft_upper_short_name_PSQ_MAIN_DB="${5}"
       
        # 修改配置文件
        ## 禁用节点
        sed -i "s@^POSTGRES_IMAGE_TAG=@#POSTGRES_IMAGE_TAG=@g" .env
        sed -i "s@^POSTGRES_DATA_PATH=@#POSTGRES_DATA_PATH=@g" .env
        comment_yaml_file_node_item "docker-compose.yml" ".services.$repo_main_svr_key.depends_on"
        comment_yaml_file_node_item "docker-compose.yml" ".services.postgres"
    }

    ### 流程化选择，安装绑定参数变量
    confirm_postgresql_setup_step_action "${TMP_DC_CPS_$soft_upper_short_name_PSQ_HOST}" "${TMP_DC_CPS_$soft_upper_short_name_PSQ_PORT}" "${TMP_DC_CPS_$soft_upper_short_name_PSQ_LOGIN_NAME}" "${TMP_DC_CPS_$soft_upper_short_name_PSQ_LOGIN_PASSWORD}" "${TMP_DC_CPS_$soft_upper_short_name_PSQ_MAIN_DB}" "_conf_cps_dc_$soft_setup_name_custom_postgresql"

    ### 1.1-N：配置变量参数
    file_content_not_exists_echo "^POSTGRES_HOST=.*" .env "POSTGRES_HOST=${TMP_DC_CPS_$soft_upper_short_name_PSQ_HOST}"
    file_content_not_exists_echo "^POSTGRES_PORT=.*" .env "POSTGRES_PORT=${TMP_DC_CPS_$soft_upper_short_name_PSQ_PORT}"
    sed -i "s@^POSTGRES_PASSWORD=.*@POSTGRES_PASSWORD=${TMP_DC_CPS_$soft_upper_short_name_PSQ_LOGIN_PASSWORD}@g" .env
    sed -i "/^MM_SQLSETTINGS_DATASOURCE=.*/d" .env
    file_content_not_exists_echo "^MM_SQLSETTINGS_DATASOURCE=.*" .env "MM_SQLSETTINGS_DATASOURCE=postgres://\\\${POSTGRES_USER}:\\\${POSTGRES_PASSWORD}@\\\${POSTGRES_HOST}:\\\${POSTGRES_PORT}/\\\${POSTGRES_DB}?sslmode=disable&connect_timeout=60"
    
    ## 1.2：配置变量参数(由compose.yml中指定存储编译安装时的数据，并存放在对等的compose目录中，即默认预制数据)
    ### 按情况调整基础目录(目录需对应services节点下的keys)
    #### $soft_setup_name
    sed -i "s@^LOGS_PATH=.*@LOGS_PATH=${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}/${DEPLOY_COMPOSE_MARK}/$soft_setup_name@g" .env
    sed -i "s@^DATA_PATH=.*@DATA_PATH=${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_DATA_DIR}/${DEPLOY_COMPOSE_MARK}/$soft_setup_name@g" .env
    sed -i "s@^CONFIG_PATH=.*@CONFIG_PATH=${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_CONF_DIR}/${DEPLOY_COMPOSE_MARK}/$soft_setup_name@g" .env
    
    #### postgres
    sed -i "s@^POSTGRES_DATA_PATH=.*@POSTGRES_DATA_PATH=${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_DATA_DIR}/${DEPLOY_COMPOSE_MARK}/postgres@g" .env

    ### 按情况调整占用端口
    #### $soft_setup_name
    sed -i "s@^DOMAIN=.*@DOMAIN=0.0.0.0@g" .env
    sed -i "s@^APP_PORT=.*@APP_PORT=${TMP_DC_$soft_upper_short_name_SETUP_OPN_APP_PORT}@g" .env
    #### $soft_setup_name
    sed -i "s@^NGINX_@#NGINX_@g" .env
    sed -i "s@^HTTP_PORT=.*@HTTP_PORT=${TMP_DC_$soft_upper_short_name_SETUP_OPN_HTTP_PORT}@g" .env
    sed -i "s@^HTTPS_PORT=.*@HTTPS_PORT=${TMP_DC_$soft_upper_short_name_SETUP_OPN_HTTPS_PORT}@g" .env
    
    sed -i "s@^HTTP_PORT=@#HTTP_PORT=@g" .env
    sed -i "s@^HTTPS_PORT=@#HTTPS_PORT=@g" .env

    # 2：修改docker-compose.yml
    docker_compose_yml_formal_exec "${TMP_DC_$soft_upper_short_name_SETUP_REPO%%/*}" "${DOCKER_NETWORK}" "$(pwd)"

    return $?
}

# x3-1：解析compose文件，并安装
#    参数1：（忽略）镜像名称，例 $compose_from_repo/prepare
#    参数2：（忽略）镜像版本，例 latest
#    参数3：（忽略）启动命令，例 /bin/sh
#    参数4：（忽略）启动参数，例 --volume /etc/localtime:/etc/localtime
#    参数5：（忽略）快照类型(还原时有效)，例 image/container/dockerfile
#    参数6：（忽略）快照来源，例 snapshot/clean/hub/commit，默认snapshot
function exec_resolve_compose_dc_$soft_setup_name_loop()
{
    cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}

	# 变量覆盖特性，其它方法均可读取
    ## 安装后的规范路径（此处依据实际路径名称修改）
    ### /opt/docker_apps/$repo_mark_name/v$down_ver/rely
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_RELY_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR}/${DEPLOY_RELY_MARK}
    ## /opt/docker_apps/$repo_mark_name/v$down_ver/work
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_WORK_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR}/${DEPLOY_WORK_MARK}
    ### /opt/docker_apps/$repo_mark_name/v$down_ver/logs
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_LOGS_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR}/${DEPLOY_LOGS_MARK}
    ### /opt/docker_apps/$repo_mark_name/v$down_ver/data
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_DATA_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR}/${DEPLOY_DATA_MARK}
    ### /opt/docker_apps/$repo_mark_name/v$down_ver/conf
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_CONF_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR}/${DEPLOY_CONF_MARK}

    if [[ -a docker-compose.yml ]]; then
        # 3-2：调整整体目录
        formal_adjust_cps_dc_$soft_setup_name

        # x3-3：配置.env/compose.yml
        ## 有环境文件的场景，需先执行拷贝
        path_not_exists_action ".env" "cp env.example .env"
        conf_adjust_cps_dc_$soft_setup_name

        ## compose安装后操作
        ### 参数1：镜像名称，例 $compose_from_repo/$repo_main_img_mark_name
        ### 参数2：镜像版本，例 $img_ver
        ### 参数3：启动命令，例 /bin/sh
        ### 参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
        function _exec_resolve_compose_dc_$soft_setup_name()
        {
            # 4-1：安装后操作
            cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}
            # yaml_split_action "$(cat docker-compose.yml | yq '.services')" "exec_step_dc_rely_$soft_setup_name"

            # 当前yaml节点image名称
            local TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_IMAGE=${1//library\//}
            # 当前yaml节点key（由docker-compose.yml设定结构为准），例service的keys $repo_main_svr_key
            local TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY=$(echo "${TMP_DC_CPL_$soft_upper_short_name_COMPOSE_YML}" | yq ".services.[] | select(.image == \"${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_IMAGE}:${2}\") | key")

            # 在yaml中找不到配置的情况，直接放弃
            if [ -z "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}" ]; then
                echo "${TMP_SPLITER2}"
                echo_style_text "<Error>: Cannot found 'key' from 'image'(<${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_IMAGE}:${2}>) in compose.yml, execute step return"
                return
            fi
            
            # 当前yaml节点信息
            local TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_NODE=$(echo "${TMP_DC_CPL_$soft_upper_short_name_COMPOSE_YML}" | yq ".services.${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}")
            # 当前yaml节点索引
            local TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_INDEX=$(diff -e <(echo "${TMP_DC_CPL_$soft_upper_short_name_COMPOSE_YML}" | yq '.services | keys') <(echo "${TMP_DC_CPL_$soft_upper_short_name_COMPOSE_YML}" | yq ".services | keys | del(.[] | select(.==\"${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_KEY}\"))") | grep -oE "[0-9]+" | xargs -I {} echo {}-1 | bc)

            # # 有DB初始化操作，等待60秒
            # if [[ "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_IMAGE}" == "postgres" || "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_IMAGE}" == "mysql" || "${TMP_DC_$soft_upper_short_name_SETUP_RELY_SERVICE_IMAGE}" == "mariadb" ]]; then
            #     exec_sleep 60 "Waitting <database> 'initial', pls checking <database> 'change', this will stay [60 secs] to exit"
            # fi
            
            # 执行操作
            exec_step_dc_rely_$soft_setup_name
        }
                
        # 执行部署
        function _exec_deploy_compose_dc_$soft_setup_name()
        {
            # 执行compose安装
            echo_style_wrap_text "Starting 'execute' <${TMP_DC_$soft_upper_short_name_SETUP_REPO}> [compose] 'deploy', hold on please"
            

            # 移除并合并多余的docker-compose-*.yml，后者覆盖前者
            ## 参考：https://mikefarah.gitbook.io/yq/commands/evaluate-all
            mv docker-compose.nginx.yml docker-compose.nginx.yml.bak
            mv docker-compose.without-nginx.yml docker-compose.without-nginx.yml.bak
            cp docker-compose.yml docker-compose.main.yml.bak

            yq eval-all --inplace 'select(fileIndex == 0) * select(fileIndex == 1)' docker-compose.yml docker-compose.without-nginx.yml.bak
            
            ## 1：有脚本的场景 
            # bash install.sh
            ## 2：无脚本的场景 
            ### 编译时，通过 -p 指定容器命名前缀，不然会弹出警告(it must contain only characters from [a-z0-9_-] and start with [a-z0-9]、WARN[0009] Found orphan containers )
            docker-compose -p ${TMP_DC_$soft_upper_short_name_SETUP_REPO%%/*} up -d

            # 有DB初始化操作，等待120秒
            echo && exec_sleep 120 "Waitting <${TMP_DC_$soft_upper_short_name_DISPLAY_TITLE}> 'initial', pls checking <database & config> 'change', this will stay [120 secs] to exit"
        }

        # 1：无环境文件的场景 
        # local TMP_DC_CPL_$soft_upper_short_name_COMPOSE_YML=$(cat docker-compose.yml)
        # local TMP_DC_CPL_$soft_upper_short_name_MAIN_VER="$(echo "${TMP_DC_CPL_$soft_upper_short_name_COMPOSE_YML}" | yq '.services.$repo_main_svr_key.image'" | cut -d':' -f2)"
        # 2：有环境文件的场景
        local TMP_DC_CPL_$soft_upper_short_name_COMPOSE_YML=$(env_file_format_echo ".env" "docker-compose.yml")
        local TMP_DC_CPL_$soft_upper_short_name_MAIN_VER="$(echo "${TMP_DC_CPL_$soft_upper_short_name_COMPOSE_YML}" | yq '.services.$repo_main_svr_key.image' | cut -d':' -f2)"

        soft_docker_compose_check_upgrade_action "${TMP_DC_$soft_upper_short_name_SETUP_REPO}*" "${TMP_DC_CPL_$soft_upper_short_name_MAIN_VER}" "_exec_deploy_compose_dc_$soft_setup_name" "_exec_resolve_compose_dc_$soft_setup_name"
        return $?
    fi
}

##########################################################################################################

# x2-2：迁移compose
function formal_cpl_dc_$soft_setup_name() {
    echo_style_wrap_text "Starting 'formal' <${TMP_DC_$soft_upper_short_name_SETUP_REPO}> [compile], hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移    
    function _formal_cpl_dc_$soft_setup_name_cp_source() {
        echo_style_text "Starting 'compile migrate'↓:"
        # 拷贝应用目录
        cp -r ${TMP_DC_CPL_$soft_upper_short_name_EXTRA_DIR} ${1}

        # mkdir -pv ${1}/{plugins,bleve-indexes,client/plugins}

        echo_style_text "[View] the 'compile migrate'↓:"
        
        # 修改权限 & 查看列表
        ls -lia ${1}
        echo
    }

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_pcreate ${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR} "_formal_cpl_dc_$soft_setup_name_cp_source"
    
    # 进入compose目录
    cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}
        
    ### 日志(日志初始尚未能创建，compose之后才会创建)
    #### /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver
    soft_path_restore_confirm_create "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"
    ### 数据(数据初始尚未能创建，compose之后才会创建)
    #### /mountdisk/data/docker_apps/$repo_mark_name/v$down_ver
    soft_path_restore_confirm_create "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"
    ### CONF(仅判断还原)
    #### /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver
    soft_path_restore_confirm_create "${TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_CONF_DIR}"
    
    return $?
}

# x2-3：修改编译配置，参考harbor.sh
function conf_cpl_dc_$soft_setup_name() {
    echo_style_wrap_text "Starting 'configuration' <${TMP_DC_$soft_upper_short_name_SETUP_REPO}> [compile] 'attrs', hold on please"

	# 修改配置文件
    cd ${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}
    
    ## 注释不需要的节点配置
    # comment_yaml_file_node_item "$soft_setup_name.yml" ".https"

    return $?
}

# x2-1：部署操作
# 参数1：软件安装名称
# 参数2：软件安装路径
# 参数3：软件解压路径
# 参数4：软件版本（取决于是否存在release版本号）
function deploy_compose_dc_$soft_setup_name() {
	# 变量覆盖特性，其它方法均可读取
	## 执行传入参数
	local TMP_DC_CPL_$soft_upper_short_name_SETUP_NAME=${1}
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_MARK_REPO=${TMP_DC_$soft_upper_short_name_SETUP_REPO/\//_}
	# local TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR=${2}
    local TMP_DC_CPL_$soft_upper_short_name_EXTRA_DIR=${3}
    
    ## 统一标记名称(存在于安装目录的真实名称)
    ### 已被全局 DEPLOY_XXX_MARK 替代
        
    # 安装依赖
    set_env_dc_$soft_setup_name
    
    # 开始编译
    cd ${TMP_DC_CPL_$soft_upper_short_name_EXTRA_DIR}

    # !!! 创建编译文件，如果编译规则存在
    # if [[ -a $soft_setup_name.yml.tmpl && ! -a $soft_setup_name.yml ]]; then
    #     cp $soft_setup_name.yml.tmpl $soft_setup_name.yml
    # fi
    
    ## 版本获取
    local TMP_DC_CPL_$soft_upper_short_name_COMPOSE_VER="$(yq '.version' docker-compose.yml)"
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_VER="v${TMP_DC_CPL_$soft_upper_short_name_COMPOSE_VER:-${4:-${TMP_DC_$soft_upper_short_name_DOWN_VER}}}"
        
    ## 安装后的规范路径（此处依据实际路径名称修改）
    ### 1：链接与根版本对的上需注释此处，放开传参
    ### /opt/docker_apps/$repo_mark_name/v$down_ver/
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR=${2}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}
    ### 2：链接与根版本对不上需自定义路径
    # local TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_CPL_HB_SETUP_MARK_REPO}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}
    ### /opt/docker_apps/$repo_mark_name/v$down_ver/compose
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR=${TMP_DC_CPL_$soft_upper_short_name_SETUP_DIR}/${DEPLOY_COMPOSE_MARK}
    
    ## 统一编排到的路径（此处定义真实存在的根目录）
    ### /mountdisk/logs/docker_apps/$repo_mark_name/v$down_ver
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_MARK_REPO}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}
    ### /mountdisk/data/docker_apps/$repo_mark_name/v$down_ver
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_MARK_REPO}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}
    ### /mountdisk/conf/docker_apps/$repo_mark_name/v$down_ver
    local TMP_DC_CPL_$soft_upper_short_name_SETUP_LNK_CONF_DIR=${DOCKER_APP_CONF_DIR}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_MARK_REPO}/${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}

    # x2-2：目录迁移
    formal_cpl_dc_$soft_setup_name

    # x2-3：修改配置
    conf_cpl_dc_$soft_setup_name
    
    # 检测安装，生成docker-compose.yml
    ## 1：有预编译，且存在预制容器
    # echo_style_wrap_text "Starting 'execute' <${TMP_DC_$soft_upper_short_name_SETUP_REPO}> [compile] & 'build' [compose] 'yaml', hold on please"
    # soft_docker_compile_check_upgrade_action "$compose_from_repo/prepare" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}" "bash prepare --with-clair --with-chartmuseum" "exec_resolve_compose_dc_$soft_setup_name_loop"
    # soft_docker_compile_check_upgrade_action "$compose_from_repo/prepare" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}" "bash prepare --with-trivy" "exec_resolve_compose_dc_$soft_setup_name_loop"
    
    ## 2：无预编译(默认使用主镜像版本做参考)
    echo_style_wrap_text "Starting 'conf' <${TMP_DC_$soft_upper_short_name_SETUP_REPO}> [compose] 'yaml' & 'execute' [rely loop], hold on please"
    exec_resolve_compose_dc_$soft_setup_name_loop

    # x2-4/x4-4 检测浏览
    boot_check_dc_$soft_setup_name "${TMP_DC_$soft_upper_short_name_SETUP_REPO}" "${TMP_DC_$soft_upper_short_name_SETUP_OPN_HTTP_PORT}"
    
    # 授权开机启动
    echo_style_wrap_text "Starting 'echo' <${TMP_DC_$soft_upper_short_name_SETUP_REPO}> [supervisor] 'startup conf', hold on please"
    # echo_startup_supervisor_config "${TMP_DC_CPL_$soft_upper_short_name_SETUP_MARK_REPO}_${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}" "docker-compose up -d" "" 999 "" "docker" "false" "0"
    echo_startup_supervisor_config "${TMP_DC_CPL_$soft_upper_short_name_SETUP_MARK_REPO}_${TMP_DC_CPL_$soft_upper_short_name_SETUP_VER}" "${TMP_DC_CPL_$soft_upper_short_name_SETUP_COMPOSE_DIR}" "docker-compose -p ${TMP_DC_$soft_upper_short_name_SETUP_REPO%%/*} up -d" "" 999 "" "docker" "false" "0"
    
    # 结束
    exec_sleep 30 "Deploy <${TMP_DC_$soft_upper_short_name_SETUP_REPO}> over, please checking the deploy log, this will stay %s secs to exit"

    return $?
}

# x1：下载/安装/更新软件
# 参数1：软件安装仓库
function download_package_dc_$soft_setup_name() {
	# 当前路径（仅记录）
	local TMP_DC_$soft_upper_short_name_CURRENT_DIR=$(pwd)
    
    echo_style_wrap_text "Download 'deploy package' <${TMP_DC_$soft_upper_short_name_SETUP_REPO}>, hold on please"

    # 选择及下载安装版本
    ## 1：离线下载方式
    # soft_setup_docker_git_wget "${1}" "${TMP_DC_$soft_upper_short_name_SETUP_REPO}" "https://github.com/${TMP_DC_$soft_upper_short_name_SETUP_REPO}/releases/download/v%s/harbor-offline-installer-v%s.tgz" "${TMP_DC_$soft_upper_short_name_DOWN_VER}" "deploy_compose_dc_$soft_setup_name"
    ## 2：Git下载方式
    soft_setup_docker_git "${TMP_DC_$soft_upper_short_name_SETUP_REPO}" "https://github.com/${TMP_DC_$soft_upper_short_name_SETUP_REPO}" "deploy_compose_dc_$soft_setup_name" "echo_style_text 'Deploy package <${TMP_DC_$soft_upper_short_name_SETUP_REPO}> already installed'"
    return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "${TMP_DC_$soft_upper_short_name_DISPLAY_TITLE}" "download_package_dc_$soft_setup_name"