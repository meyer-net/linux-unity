# 4-1：设置软件
function conf_dc_mysql_etc()
{
    file_content_part_not_exists_mquote_echo "^long_query_time.*" ${1} "mysqld" "long_query_time = 3"
    file_content_part_not_exists_mquote_echo "^slow-query-log.*" ${1} "mysqld" "slow-query-log = 0"

    file_content_part_not_exists_mquote_echo "^max_heap_table_size.*" ${1} "mysqld" "max_heap_table_size = 64M"
    file_content_part_not_exists_mquote_echo "^tmp_table_size.*" ${1} "mysqld" "tmp_table_size = 64M"

    file_content_part_not_exists_mquote_echo "^query_cache_size.*" ${1} "mysqld" "query_cache_size = 256M"
    file_content_part_not_exists_mquote_echo "^query_cache_min_res_unit.*" ${1} "mysqld" "query_cache_min_res_unit = 4K"
    file_content_part_not_exists_mquote_echo "^query_cache_limit.*" ${1} "mysqld" "query_cache_limit = 512K"
    file_content_part_not_exists_mquote_echo "^query_cache_type.*" ${1} "mysqld" "query_cache_type = 1"

    file_content_part_not_exists_mquote_echo "^thread_cache_size.*" ${1} "mysqld" "thread_cache_size = 512"
    file_content_part_not_exists_mquote_echo "^max_connect_errors.*" ${1} "mysqld" "max_connect_errors = 256"
    file_content_part_not_exists_mquote_echo "^max_connections.*" ${1} "mysqld" "max_connections = 1024"

    file_content_part_not_exists_mquote_echo "^skip-character-set-client-handshake" ${1} "mysqld" "skip-character-set-client-handshake"
    file_content_part_not_exists_mquote_echo "^skip-name-resolve" ${1} "mysqld" "skip-name-resolve"

    file_content_part_not_exists_mquote_echo "^collation-server.*" ${1} "mysqld" "collation-server = utf8_unicode_ci"
    file_content_part_not_exists_mquote_echo "^init_connect = \'SET collation_connection" ${1} "mysqld" "init_connect='SET collation_connection=utf8_unicode_ci'"
    file_content_part_not_exists_mquote_echo "^init_connect = \'SET NAMES" ${1} "mysqld" "init_connect='SET NAMES utf8'"
    file_content_part_not_exists_mquote_echo "^character-set-server.*" ${1} "mysqld" "character-set-server = utf8"

    file_content_part_not_exists_mquote_echo "^server-id.*" ${1} "mysqld" "server-id = ${LOCAL_ID}"
    file_content_part_not_exists_mquote_echo "^user.*" ${1} "mysqld" "user = mysql"

	file_content_part_not_exists_mquote_echo "^# Defind" ${1} "mysqld" "# Defind basic set by meyer.cheng, at ${LOCAL_TIME}"

	return $?
}

##########################################################################################################
__CURR_DIR="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"
__CURR_FILE="${__CURR_DIR}/$(basename ${BASH_SOURCE[0]})"
cd ${__CURR_DIR}

# 安装主体
exec_if_choice "TMP_MSQL_SETUP_CHOICE" "Please choice which mysql type you want to setup" "...,MySQL,MariaDB,Conf,Exit" "${TMP_SPLITER}" "mysql"