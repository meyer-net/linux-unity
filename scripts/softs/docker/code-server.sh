#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  Arm参考：https://hub.docker.com/r/linuxserver/code-server
#------------------------------------------------
# 安装版本：4.14.1
#------------------------------------------------
# source scripts/softs/docker/code-server.sh
#------------------------------------------------
# Debug：
# docker ps -a --no-trunc | awk '{if($2~"codercom"){print $1}}' | xargs docker stop
# docker ps -a --no-trunc | awk '{if($2~"codercom"){print $1}}' | xargs docker rm
# docker images | awk '{if($1~"codercom"){print $3}}' | xargs docker rmi
# rm -rf /opt/docker_apps/codercom_code-server* && rm -rf /mountdisk/conf/docker_apps/codercom_code-server* && rm -rf /mountdisk/logs/docker_apps/codercom_code-server* && rm -rf /mountdisk/data/docker_apps/codercom_code-server* && rm -rf /opt/docker/data/apps/codercom_code-server* && rm -rf /opt/docker/conf/codercom_code-server* && rm -rf /opt/docker/logs/codercom_code-server* && rm -rf /mountdisk/repo/migrate/clean/codercom_code-server* && rm -rf /mountdisk/svr_sync/coder
# rm -rf /mountdisk/repo/backup/opt/docker_apps/codercom_code-server* && rm -rf /mountdisk/repo/backup/mountdisk/conf/docker_apps/codercom_code-server* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/codercom_code-server* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/codercom_code-server* && rm -rf /mountdisk/repo/backup/opt/docker/data/apps/codercom_code-server* && rm -rf /mountdisk/repo/backup/opt/docker/conf/codercom_code-server* && rm -rf /mountdisk/repo/backup/opt/docker/logs/codercom_code-server*
# docker volume ls | awk 'NR>1{print $2}' | xargs docker volume rm
#------------------------------------------------
local TMP_DC_CS_DISPLAY_TITLE="Code-Server"
local TMP_DC_CS_SETUP_IMG_FROM="codercom"
local TMP_DC_CS_SETUP_IMG_PRJT="code-server"
local TMP_DC_CS_SETUP_IMG_REPO="${TMP_DC_CS_SETUP_IMG_FROM}/${TMP_DC_CS_SETUP_IMG_PRJT}"
local TMP_DC_CS_SETUP_IMG_USER="coder"
local TMP_DC_CS_SETUP_INN_PORT=8080
local TMP_DC_CS_SETUP_OPN_PORT=1024

##########################################################################################################

# 1-配置环境
function set_env_dc_codercom_code-server() {
    echo_style_wrap_text "Starting 'configuare' <${TMP_DC_CS_SETUP_IMG_NAME}> 'install' [envs], hold on please"

    cd ${__DIR}

    return $?
}

##########################################################################################################

# 2-安装软件
function setup_dc_codercom_code-server() {
    echo_style_wrap_text "Starting 'install' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"

    function _setup_dc_codercom_code-server_cp_source() {
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'workingdir copy'↓:"

        # 拷贝应用目录
        docker cp -a ${TMP_DC_CS_SETUP_CTN_ID}:/usr/lib/${TMP_DC_CS_SETUP_APP_MARK} ${1} >& /dev/null
        
        # 授权
        sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${1}
        
        # 查看拷贝列表
        ls -lia ${1}
    }

    # 创建安装目录(纯属为了规范)
    ## 1：存在working dir
    soft_path_restore_confirm_pcreate "${TMP_DC_CS_SETUP_WORK_DIR}" "_setup_dc_codercom_code-server_cp_source"

    cd ${TMP_DC_CS_SETUP_DIR}

    # 开始安装

    return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal' <${TMP_DC_CS_SETUP_IMG_NAME}> 'dirs', hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移
    ### 日志
    #### /mountdisk/logs/docker_apps/codercom_code-server/imgver111111
    function _formal_dc_codercom_code-server_cp_logs() {
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'logs copy'↓:"

        # 拷贝日志目录
        ## /mountdisk/logs/docker_apps/codercom_code-server/imgver111111/app
        docker cp -a ${TMP_DC_CS_SETUP_CTN_ID}:/root/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}/coder-logs ${1}/app >& /dev/null

        ## /mountdisk/logs/docker_apps/codercom_code-server/imgver111111/app
        docker cp -a ${TMP_DC_CS_SETUP_CTN_ID}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}/coder-logs ${1}/workspace >& /dev/null
        
        # 授权
        sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${1}/app
        sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${1}/workspace
            
        # 查看拷贝列表
        echo_style_text "'|'[app]↓:"
        ls -lia ${1}/app
        echo_style_text "'|'[workspace]↓:"
        ls -lia ${1}/workspace
    }
    soft_path_restore_confirm_create "${TMP_DC_CS_SETUP_LNK_LOGS_DIR}" "_formal_dc_codercom_code-server_cp_logs"

    ### 数据
    #### /mountdisk/data/docker_apps/codercom_code-server/imgver111111
    function _formal_dc_codercom_code-server_cp_data() {
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'data copy'↓:"

        # 拷贝日志目录
        # mkdir -pv ${1}
        docker cp -a ${TMP_DC_CS_SETUP_CTN_ID}:${TMP_DC_CS_SETUP_CTN_WORK_DIR} ${SYNC_DIR} >& /dev/null
        
        # 指定一个workdir
        # /mountdisk/data/docker_apps/codercom_code-server/4.14.1 -> /mountdisk/svr_sync/coder
        path_not_exists_link "${1}" "" "${SYNC_DIR}/${TMP_DC_CS_SETUP_IMG_USER}"

        ################################################################################################
        # 应用网站项目目录
        local TMP_DC_CS_SETUP_PRJ_WWW_DIR=${1}/projects/www
        # 应用网站自启动目录
        local TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_DIR}/boots
        # 应用网站自启动服务器目录
        local TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_NGX_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DIR}/nginx
        local TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_ORT_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DIR}/openresty
        local TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_CDY_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DIR}/caddy
        local TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DOC_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DIR}/docker
        # 应用网站初始化目录
        local TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_DIR}/init
        local TMP_DC_CS_SETUP_PRJ_WWW_INIT_MYSQL_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}/mysql
        local TMP_DC_CS_SETUP_PRJ_WWW_INIT_MARIADB_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}/mariadb
        local TMP_DC_CS_SETUP_PRJ_WWW_INIT_POSTGRESQL_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}/postgresql
        local TMP_DC_CS_SETUP_PRJ_WWW_INIT_MONGODB_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}/mongodb
        # 应用网站项目语种对应目录
        local TMP_DC_CS_SETUP_PRJ_WWW_LUA_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_DIR}/lang/lua
        local TMP_DC_CS_SETUP_PRJ_WWW_PY_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_DIR}/lang/py
        local TMP_DC_CS_SETUP_PRJ_WWW_JV_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_DIR}/lang/java
        local TMP_DC_CS_SETUP_PRJ_WWW_HTML_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_DIR}/lang/html

        # 应用项目目录
        local TMP_DC_CS_SETUP_PRJ_APP_DIR=${1}/projects/app
        # 应用项目自启动目录
        local TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DIR=${TMP_DC_CS_SETUP_PRJ_APP_DIR}/boots
        # 应用项目自启动服务器目录
        local TMP_DC_CS_SETUP_PRJ_APP_BOOTS_CDA_DIR=${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DIR}/conda
        local TMP_DC_CS_SETUP_PRJ_APP_BOOTS_SUP_DIR=${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DIR}/supervisor
        local TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DOC_DIR=${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DIR}/docker
        # 应用项目自启动目录
        local TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR=${TMP_DC_CS_SETUP_PRJ_APP_DIR}/init
        local TMP_DC_CS_SETUP_PRJ_APP_INIT_MYSQL_DIR=${TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR}/mysql
        local TMP_DC_CS_SETUP_PRJ_APP_INIT_MARIADB_DIR=${TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR}/mariadb
        local TMP_DC_CS_SETUP_PRJ_APP_INIT_POSTGRESQL_DIR=${TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR}/postgresql
        local TMP_DC_CS_SETUP_PRJ_APP_INIT_MONGODB_DIR=${TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR}/mongodb
        # 应用项目语种对应目录
        local TMP_DC_CS_SETUP_PRJ_APP_PY_DIR=${TMP_DC_CS_SETUP_PRJ_APP_DIR}/lang/py
        ################################################################################################
        # 应用网站自启动服务器目录
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_NGX_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_ORT_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_CDY_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DOC_DIR}"

        # 应用网站初始化目录
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_MYSQL_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_MARIADB_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_POSTGRESQL_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_MONGODB_DIR}"

        # 应用网站项目语种对应目录
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_LUA_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_PY_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_JV_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_HTML_DIR}"

        # 应用项目自启动服务器目录
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_CDA_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_SUP_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DOC_DIR}"

        # 应用项目自启动目录
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_INIT_MYSQL_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_INIT_MARIADB_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_INIT_POSTGRESQL_DIR}"
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_INIT_MONGODB_DIR}"

        # 应用项目语种对应目录
        path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_PY_DIR}"
        ################################################################################################
        
        # 授权
        sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${SYNC_DIR}/${TMP_DC_CS_SETUP_IMG_USER}

        # 查看拷贝列表
        ls -lia ${1}/
    }
    soft_path_restore_confirm_pcreate "${TMP_DC_CS_SETUP_LNK_DATA_DIR}" "_formal_dc_codercom_code-server_cp_data"
    
    ### CONF - ①-1Y：存在配置文件：原路径文件放给真实路径
    #### /mountdisk/data/docker/containers/${CTN_ID}
    local TMP_DC_CS_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_DC_CS_SETUP_CTN_ID}"
    #### /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/container
    local TMP_DC_CS_SETUP_LNK_CONF_CTN_DIR="${TMP_DC_CS_SETUP_LNK_CONF_DIR}/container"
    #### /mountdisk/conf/docker_apps/codercom_code-server/imgver111111
    function _formal_dc_codercom_code-server_cp_conf() {
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'conf copy'↓:"

        # !!! 有可能未提前生成，故手动创建补足流程
        # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "test -d ${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.config || mkdir -pv ${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.config"

        # 1：拷贝配置目录
        ## /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/app
        docker cp -a ${TMP_DC_CS_SETUP_CTN_ID}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.config ${1}/app >& /dev/null

        # 2：添加python环境
        ## /home/coder/env

        # 授权
        sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${1}/app
        
        # 查看拷贝列表
        ls -lia ${1}/app
        
        ## /mountdisk/data/docker/containers/${CTN_ID} ©&<- /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/container
        soft_path_restore_confirm_swap "${TMP_DC_CS_SETUP_LNK_CONF_CTN_DIR}" "${TMP_DC_CS_SETUP_CTN_DIR}"
    }
    soft_path_restore_confirm_create "${TMP_DC_CS_SETUP_LNK_CONF_DIR}" "_formal_dc_codercom_code-server_cp_conf"
   
    ### 迁移CONF下LOGS归位
    #### [ 废弃，logs路径会被强制修改未docker root dir对应的数据目录，一旦软连接会被套出多层路径，如下（且修改无效）：
    ##### "LogPath": "/mountdisk/data/docker/containers/4f8b1ca03fe001037e3d701079f094bb5f2a65da089305825546df486c082c22/mountdisk/logs/docker_apps/codercom_code-server/imgver111111/container/4f8b1ca03fe001037e3d701079f094bb5f2a65da089305825546df486c082c22-json.log"
    #### /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/container/${CTN_ID}-json.log ©&<- /mountdisk/logs/docker_apps/codercom_code-server/imgver111111/container/${CTN_ID}-json.log
    # soft_path_restore_confirm_move "${TMP_DC_CS_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_CS_SETUP_CTN_ID}-json.log" "${TMP_DC_CS_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_CS_SETUP_CTN_ID}-json.log"
    #### ]

    ## 创建链接规则
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'symlink create':↓"
    ### 日志
    #### /opt/docker_apps/codercom_code-server/imgver111111/logs -> /mountdisk/logs/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${TMP_DC_CS_SETUP_LOGS_DIR}" "" "${TMP_DC_CS_SETUP_LNK_LOGS_DIR}"
    #### /opt/docker/logs/codercom_code-server/imgver111111 -> /mountdisk/logs/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}" "" "${TMP_DC_CS_SETUP_LNK_LOGS_DIR}"
    #### /mountdisk/logs/docker_apps/codercom_code-server/imgver111111/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/container/${CTN_ID}-json.log
    path_not_exists_link "${TMP_DC_CS_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_CS_SETUP_CTN_ID}-json.log" "" "${TMP_DC_CS_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_CS_SETUP_CTN_ID}-json.log"
    ### 数据
    #### /opt/docker_apps/codercom_code-server/imgver111111/data -> /mountdisk/data/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${TMP_DC_CS_SETUP_DATA_DIR}" "" "${TMP_DC_CS_SETUP_LNK_DATA_DIR}"
    #### /opt/docker/data/apps/codercom_code-server/imgver111111 -> /mountdisk/data/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_DATA_MARK}/apps/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}" "" "${TMP_DC_CS_SETUP_LNK_DATA_DIR}"
    ### CONF
    #### /opt/docker_apps/codercom_code-server/imgver111111/conf -> /mountdisk/conf/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${TMP_DC_CS_SETUP_CONF_DIR}" "" "${TMP_DC_CS_SETUP_LNK_CONF_DIR}"
    #### /opt/docker/conf/codercom_code-server/imgver111111 -> /mountdisk/conf/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_CONF_MARK}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}" "" "${TMP_DC_CS_SETUP_LNK_CONF_DIR}"
    #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/container
    path_not_exists_link "${TMP_DC_CS_SETUP_CTN_DIR}" "" "${TMP_DC_CS_SETUP_LNK_CONF_CTN_DIR}"

    # 预实验部分        
    ## 目录调整完修改启动参数
    echo "${TMP_SPLITER2}"
    echo_style_text "Starting 'inspect change' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"

    # 挂载目录(必须停止服务才能修改，否则会无效)
    docker_change_container_volume_migrate "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_WORK_DIR}:/usr/lib/${TMP_DC_CS_SETUP_APP_MARK} ${TMP_DC_CS_SETUP_LNK_LOGS_DIR}/app:/root/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}/coder-logs:rw,z ${TMP_DC_CS_SETUP_LNK_LOGS_DIR}/workspace:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}/coder-logs:rw,z ${TMP_DC_CS_SETUP_LNK_DATA_DIR}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}:rw,z ${TMP_DC_CS_SETUP_LNK_CONF_DIR}/app:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.config" "" $([[ -z "${TMP_DC_CS_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    
    return $?
}

##########################################################################################################

# 4-设置软件
function conf_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"

    # 开始配置
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "sed -i \"s@os.tmpdir()@\'\/usr\/src\/app\'@g\" src/utils.js" "t" "root" "$work_dir"

    return $?
}

##########################################################################################################

# 5-测试软件
function test_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}
    
    echo_style_wrap_text "Starting 'test' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"

    # 实验部分
    ## 1：检测启停
    docker container stop ${TMP_DC_CS_SETUP_CTN_ID}
    docker container start ${TMP_DC_CS_SETUP_CTN_ID}

    return $?
}

##########################################################################################################

# 6-启动后检测脚本
function boot_check_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}

    # 实验部分
    echo_style_wrap_text "Starting 'boot check' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"

    if [ -n "${TMP_DC_CS_SETUP_CTN_PORT}" ]; then
        echo_style_text "[View] the 'container visit'↓:"
        curl -s http://localhost:${TMP_DC_CS_SETUP_CTN_PORT}
        echo

        # 授权iptables端口访问
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] echo the 'port'(<${TMP_DC_CS_SETUP_CTN_PORT}>) to iptables:↓"
        echo_soft_port "TMP_DC_CS_SETUP_OPN_PORT"
        
        # 生成web授权访问脚本
        # echo_web_service_init_scripts "codercom_code-server${LOCAL_ID}" "codercom_code-server${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_DC_CS_SETUP_OPN_PORT} "${LOCAL_HOST}"
    fi
    
    # 授权开机启动
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] echo the 'supervisor startup conf'↓:"
    # echo_startup_supervisor_config "${TMP_DC_CS_SETUP_IMG_MARK_NAME}" "${TMP_DC_CS_SETUP_DIR}" "systemctl start ${TMP_DC_CS_SETUP_IMG_MARK_NAME}.service" "" "999" "" "" false 0
    echo_startup_supervisor_config "${TMP_DC_CS_SETUP_IMG_MARK_NAME}" "${TMP_DC_CS_SETUP_DIR}" "bin/${TMP_DC_CS_SETUP_IMG_MARK_NAME} start"
    
    # 结束
    exec_sleep 10 "Boot <${TMP_DC_CS_SETUP_IMG_NAME}> over, please checking the setup log, this will stay [%s] secs to exit"
}

##########################################################################################################

# 7-1 下载扩展/驱动/插件
function down_ext_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}

    echo_style_wrap_text "Starting 'download' <${TMP_DC_CS_SETUP_IMG_NAME}> 'exts', hold on please"

    return $?
}

# 7-2 安装与配置扩展/驱动/插件
function setup_ext_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}

    echo_style_wrap_text "Starting 'install' <${TMP_DC_CS_SETUP_IMG_NAME}> 'exts', hold on please"

    return $?
}

##########################################################################################################

# 8-重新配置（有些软件安装完后需要重新配置）
function reconf_dc_codercom_code-server()
{
    cd ${TMP_DC_CS_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'reconf' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"

	return $?
}

##########################################################################################################

# x3-执行步骤
#    参数1：启动后的进程ID
#    参数2：最终启动端口
#    参数3：最终启动版本
#    参数4：最终启动命令
#    参数5：最终启动参数
function exec_step_dc_codercom_code-server() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_DC_CS_SETUP_CTN_ID="${1}"
    # local TMP_DC_CS_SETUP_PS_SID="${TMP_DC_CS_SETUP_CTN_ID:0:12}"
    local TMP_DC_CS_SETUP_CTN_PORT="${2}"
    # imgver111111/imgver111111_v1670000000
    local TMP_DC_CS_SETUP_CTN_VER="${3}"
    local TMP_DC_CS_SETUP_CTN_CMD="${4}"
    local TMP_DC_CS_SETUP_CTN_ARGS="${5}"
    local TMP_DC_CS_SETUP_CTN_WORK_DIR="$(echo "${5}" | grep -oP "(?<=--workdir\=)[^\s]+")"
    if [ -z "${TMP_DC_CS_SETUP_CTN_WORK_DIR}" ]; then
        TMP_DC_CS_SETUP_CTN_WORK_DIR=$(docker container inspect --format '{{.Config.WorkingDir}}' ${1})
    fi

    # 默认取进入时的目录
    if [ -z "${TMP_DC_CS_SETUP_CTN_WORK_DIR}" ]; then
        TMP_DC_CS_SETUP_CTN_WORK_DIR=$(docker_bash_channel_exec "${1}" "pwd")
    fi

    # 获取授权用户的UID/GID
    local TMP_DC_CS_SETUP_CTN_UID=$(docker_bash_channel_exec "${1}" "id -u ${TMP_DC_CS_SETUP_IMG_USER}")
    local TMP_DC_CS_SETUP_CTN_GID=$(docker_bash_channel_exec "${1}" "id -g ${TMP_DC_CS_SETUP_IMG_USER}")
    
    # 软件内部标识版本（$3已返回该版本号，仅测试选择5.7.42的场景）
    local TMP_DC_CS_SETUP_SOFT_VER=$(docker_bash_channel_exec "${1}" "code-server -v | awk '{print \$NF}'")

    ## 统一编排到的路径
    local TMP_DC_CS_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}
    local TMP_DC_CS_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}
    local TMP_DC_CS_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}
    local TMP_DC_CS_SETUP_LNK_CONF_DIR=${DOCKER_APP_CONF_DIR}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}

    ## 统一标记名称(存在于安装目录的真实名称)
    local TMP_DC_CS_SETUP_APP_MARK="code-server"

    ## 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_DC_CS_SETUP_WORK_DIR=${TMP_DC_CS_SETUP_DIR}/${DEPLOY_WORK_MARK}
    local TMP_DC_CS_SETUP_LOGS_DIR=${TMP_DC_CS_SETUP_DIR}/${DEPLOY_LOGS_MARK}
    local TMP_DC_CS_SETUP_DATA_DIR=${TMP_DC_CS_SETUP_DIR}/${DEPLOY_DATA_MARK}
    local TMP_DC_CS_SETUP_CONF_DIR=${TMP_DC_CS_SETUP_DIR}/${DEPLOY_CONF_MARK}
    
    echo_style_wrap_text "Starting 'execute step' <${TMP_DC_CS_SETUP_IMG_NAME}>:[${TMP_DC_CS_SETUP_CTN_VER}]('${TMP_DC_CS_SETUP_CTN_ID}'), hold on please"

    set_env_dc_codercom_code-server

    setup_dc_codercom_code-server

    formal_dc_codercom_code-server

    conf_dc_codercom_code-server

    test_dc_codercom_code-server

    # down_ext_dc_codercom_code-server
    # setup_ext_dc_codercom_code-server

    boot_check_dc_codercom_code-server

    reconf_dc_codercom_code-server
    
    # 结束
    exec_sleep 30 "Install <${TMP_DC_CS_SETUP_IMG_NAME}> over, please checking the setup log, this will stay [%s] secs to exit"

    return $?
}

##########################################################################################################

# x2-简略启动，获取初始化软件（形成启动后才可抽取目录信息）
#    参数1：镜像名称，例 codercom/code-server
#    参数2：镜像版本，例 latest
#    参数3：启动命令，例 /bin/sh
#    参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#    参数5：快照类型(还原时有效)，例 image/container/dockerfile
#    参数6：快照来源，例 snapshot/clean/hub/commit，默认snapshot
function boot_build_dc_codercom_code-server() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_DC_CS_SETUP_IMG_NAME="${1}"
    local TMP_DC_CS_SETUP_IMG_MARK_NAME="${1/\//_}"
    local TMP_DC_CS_SETUP_IMG_VER="${2}"
    local TMP_DC_CS_SETUP_CTN_ARG_CMD="${3}"
    local TMP_DC_CS_SETUP_CTN_ARGS="${4}"
    local TMP_DC_CS_SETUP_IMG_SNAP_TYPE="${5}"
    local TMP_DC_CS_SETUP_IMG_STORE="${6}"

    echo_style_wrap_text "Starting 'build container' <${TMP_DC_CS_SETUP_IMG_NAME}>:[${TMP_DC_CS_SETUP_IMG_VER}], hold on please"

    # 设置密码
    ## 面板密码
    local TMP_DC_CS_SETUP_GUI_PASSWD=$(console_input "$(rand_simple_passwd 'cs.gui' 'db' "${TMP_DC_CS_SETUP_IMG_VER}")" "Please sure your 'gui' <access password>" "y")
    ## SUDO密码
    local TMP_DC_CS_SETUP_SUDO_PASSWD=$(console_input "$(rand_passwd 'cs.sudo' 'db' "${TMP_DC_CS_SETUP_IMG_VER}")" "Please sure your 'sudo' <terminal password>" "y")
    
    ## 标准启动参数
    # local TMP_DC_CS_SETUP_PRE_ARG_USER="--user $(id -u):$(id -g)"
    local TMP_DC_CS_SETUP_PRE_ARG_PORTS="-p ${TMP_DC_CS_SETUP_OPN_PORT}:${TMP_DC_CS_SETUP_INN_PORT}"
    local TMP_DC_CS_SETUP_PRE_ARG_NETWORKS="--network=${DOCKER_NETWORK}"
    local TMP_DC_CS_SETUP_PRE_ARG_ENVS="--env=TZ=Asia/Shanghai --privileged=true --expose ${TMP_DC_CS_SETUP_OPN_PORT} --env=PASSWORD=${TMP_DC_CS_SETUP_GUI_PASSWD} --env=SUDO_PASSWORD=${TMP_DC_CS_SETUP_SUDO_PASSWD}"
    local TMP_DC_CS_SETUP_PRE_ARG_MOUNTS="--volume=/etc/localtime:/etc/localtime:ro"
    local TMP_DC_CS_SETUP_PRE_ARGS="--name=${TMP_DC_CS_SETUP_IMG_MARK_NAME}_${TMP_DC_CS_SETUP_IMG_VER} ${TMP_DC_CS_SETUP_PRE_ARG_USER} ${TMP_DC_CS_SETUP_PRE_ARG_PORTS} ${TMP_DC_CS_SETUP_PRE_ARG_NETWORKS} --restart=always ${TMP_DC_CS_SETUP_PRE_ARG_ENVS} ${TMP_DC_CS_SETUP_PRE_ARG_MOUNTS}"

    # !!! 默认包含用户（可能内部相关文件夹未指定该用户，从而引发permission错误）
    # --env=USER=coder

    # 参数覆盖, 镜像参数覆盖启动设定
    echo_style_text "<Container> 'pre' args && cmd↓:"
    echo "Args：${TMP_DC_CS_SETUP_PRE_ARGS:-None}"
    echo "Cmd：${TMP_DC_CS_SETUP_CTN_ARG_CMD:-None}"
    
    echo "${TMP_SPLITER3}"
    echo_style_text "<Container> 'ctn' args && cmd↓:"
    echo "Args：${TMP_DC_CS_SETUP_CTN_ARGS:-None}"
    echo "Cmd：${TMP_DC_CS_SETUP_CTN_ARG_CMD:-None}"
    
    echo "${TMP_SPLITER3}"
    echo_style_text "Starting 'combine container' <${TMP_DC_CS_SETUP_IMG_NAME}>:[${TMP_DC_CS_SETUP_IMG_VER}] boot args, hold on please"
    docker_image_args_combine_bind "TMP_DC_CS_SETUP_PRE_ARGS" "TMP_DC_CS_SETUP_CTN_ARGS"
    echo_style_text "<Container> 'combine' args && cmd↓:"
    echo "Args：${TMP_DC_CS_SETUP_PRE_ARGS:-None}"
    echo "Cmd：${TMP_DC_CS_SETUP_CTN_ARG_CMD:-None}"

    # 开始启动
    docker_image_boot_print "${TMP_DC_CS_SETUP_IMG_NAME}" "${TMP_DC_CS_SETUP_IMG_VER}" "${TMP_DC_CS_SETUP_CTN_ARG_CMD}" "${TMP_DC_CS_SETUP_PRE_ARGS}" "" "exec_step_dc_codercom_code-server"
    
    return $?
}

##########################################################################################################

# x1-下载/安装/更新软件
function check_setup_dc_codercom_code-server() {
	# 当前路径（仅记录）
    local TMP_DC_CS_CURRENT_DIR=$(pwd)

    echo_style_wrap_text "Checking 'install' <${1}>, hold on please"

    # 重装/更新/安装
    soft_docker_check_choice_upgrade_action "${TMP_DC_CS_SETUP_IMG_REPO}" "boot_build_dc_codercom_code-server"

    return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "${TMP_DC_CS_DISPLAY_TITLE}" "check_setup_dc_codercom_code-server"