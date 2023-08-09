# 4-1：设置软件
# 参数1：软件名称，例 mysql mariadb
# 参数2：配置文件路径
# 参数3：软件版本
function conf_dc_mysql_etc()
{
    local _TMP_CONF_DC_MYSQL_ETC_SED_NODE="mysqld"
    
    if [ -z "$(cat ${2} | egrep "^\[mysqld\]$")"]; then
        _TMP_CONF_DC_MYSQL_ETC_SED_NODE="mariadbd"
    fi

    file_content_part_not_exists_mquote_echo "^long_query_time.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "long_query_time = 3"
    file_content_part_not_exists_mquote_echo "^slow-query-log.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "slow-query-log = 0"

    file_content_part_not_exists_mquote_echo "^max_heap_table_size.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "max_heap_table_size = 64M"
    file_content_part_not_exists_mquote_echo "^tmp_table_size.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "tmp_table_size = 64M"
    
    # mysql 8的版本不识别
    if [[ "${2}" == "mariadb" || ("${2}" == "mysql" && ($(echo "${3%.*} < 8" | bc) == 1)) ]]; then
        file_content_part_not_exists_mquote_echo "^query_cache_size.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "query_cache_size = 256M"
        file_content_part_not_exists_mquote_echo "^query_cache_min_res_unit.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "query_cache_min_res_unit = 4K"
        file_content_part_not_exists_mquote_echo "^query_cache_limit.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "query_cache_limit = 512K"
        file_content_part_not_exists_mquote_echo "^query_cache_type.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "query_cache_type = 1"
    else
        if [[ "${2}" == "mysql" && ($(echo "${3%.*} >= 8" | bc) == 1) ]]; then
            file_content_part_not_exists_mquote_echo "^default_authentication_plugin.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "default_authentication_plugin = mysql_native_password"
        fi
    fi

    file_content_part_not_exists_mquote_echo "^thread_cache_size.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "thread_cache_size = 512"
    file_content_part_not_exists_mquote_echo "^max_connect_errors.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "max_connect_errors = 256"
    file_content_part_not_exists_mquote_echo "^max_connections.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "max_connections = 1024"

    file_content_part_not_exists_mquote_echo "^skip-character-set-client-handshake" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "skip-character-set-client-handshake"
    file_content_part_not_exists_mquote_echo "^skip-name-resolve" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "skip-name-resolve"

    file_content_part_not_exists_mquote_echo "^collation-server.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "collation-server = utf8_unicode_ci"
    file_content_part_not_exists_mquote_echo "^init_connect = \'SET collation_connection" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "init_connect='SET collation_connection=utf8_unicode_ci'"
    file_content_part_not_exists_mquote_echo "^init_connect = \'SET NAMES" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "init_connect='SET NAMES utf8'"
    file_content_part_not_exists_mquote_echo "^character-set-server.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "character-set-server = utf8"

    file_content_part_not_exists_mquote_echo "^server-id.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "server-id = ${LOCAL_ID}"
    file_content_part_not_exists_mquote_echo "^user.*" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "user = mysql"

	file_content_part_not_exists_mquote_echo "^# Defind" ${2} "${_TMP_CONF_DC_MYSQL_ETC_SED_NODE}" "# Defind basic set by meyer.cheng, at ${LOCAL_TIME}"

	return $?
}

# 获取主配置文件路径
# 参数1：容器ID或名称
function docker_container_mysql_etc_mysqld_node_file_path_echo()
{
    function _docker_container_mysql_etc_mysqld_node_file_path_echo_judge() {
        local TMP_DOCKER_CONTAINER_MYSQL_CONF_MYSQLD_NODE_FILE_PATH_ECHO=${DOCKER_APP_SETUP_DIR}/${3/\//_}/${4}/${DEPLOY_CONF_MARK}
        bind_symlink_link_path "TMP_DOCKER_CONTAINER_MYSQL_CONF_MYSQLD_NODE_FILE_PATH_ECHO"

        # 配置文件路径    
        case "${3}" in
        "library/mysql")
            echo "${TMP_DOCKER_CONTAINER_MYSQL_CONF_MYSQLD_NODE_FILE_PATH_ECHO}/${DEPLOY_CONF_MARK}/app/my.cnf"
            ;;
        "library/mariadb")
            if [ -n "$(docker_bash_channel_exec "${2}" "ls /etc | grep 'my.cnf'")" ]; then
                echo "${TMP_DOCKER_CONTAINER_MYSQL_CONF_MYSQLD_NODE_FILE_PATH_ECHO}/app/my.cnf"
            else
                if [ -f ${TMP_DOCKER_CONTAINER_MYSQL_CONF_MYSQLD_NODE_FILE_PATH_ECHO}/app/mariadb.conf.d/50-server.cnf ]; then
                    echo "${TMP_DOCKER_CONTAINER_MYSQL_CONF_MYSQLD_NODE_FILE_PATH_ECHO}/app/mariadb.conf.d/50-server.cnf"
                else
                    if [ -f ${TMP_DOCKER_CONTAINER_MYSQL_CONF_MYSQLD_NODE_FILE_PATH_ECHO}/app/mariadb.cnf ]; then
                        echo "${TMP_DOCKER_CONTAINER_MYSQL_CONF_MYSQLD_NODE_FILE_PATH_ECHO}/app/mariadb.cnf"
                    else
                        if [ -f ${TMP_DOCKER_CONTAINER_MYSQL_CONF_MYSQLD_NODE_FILE_PATH_ECHO}/app/my.cnf.d/server.cnf ]; then
                            echo "${TMP_DOCKER_CONTAINER_MYSQL_CONF_MYSQLD_NODE_FILE_PATH_ECHO}/app/my.cnf.d/server.cnf"
                        fi
                    fi
                fi
            fi
            ;;
        *)
            # echo "OTHER"
            ;;
        esac
    }

    docker_container_param_check_action "${1}" "_docker_container_mysql_etc_mysqld_node_file_path_echo_judge"
	return $?
}

##########################################################################################################
__CURR_DIR="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"
__CURR_FILE="${__CURR_DIR}/$(basename ${BASH_SOURCE[0]})"
cd ${__CURR_DIR}

# 安装主体
exec_if_choice "TMP_MSQL_SETUP_CHOICE" "Please choice which <mysql> [type] you want to setup" "...,MySQL,MariaDB,Conf,Exit" "${TMP_SPLITER}" "mysql"