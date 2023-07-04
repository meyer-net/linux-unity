# 数据导出
# # 针对事务性引擎
# mysqldump -uroot -ptiger --all-database -e --single-transaction --flush-logs --max_allowed_packet=1048576 --net_buffer_length=16384 > /data/all_db.sql
# # 针对 MyISAM 引擎，或多引擎混合的数据库
# mysqldump -uroot --all-database -e -l --flush-logs --max_allowed_packet=1048576 --net_buffer_length=16384 > /data/all_db.sql

# 数据导入
# # mysql -h 127.0.0.1 -u root -p < all_db.sql

# 4-2-1：设置主库
function conf_dc_mysql_etc_master()
{
    _conf_dc_mysql_etc_bind

    if [ -z "${TMP_DC_MSQ_CONF_LNK_CONF_PATH}" ]; then
        echo_style_text "Cannot define conf path"
        return
    fi

    if [[ ! -f ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} ]]; then
        echo_style_text "Cannot found conf path <${TMP_DC_MSQ_CONF_LNK_CONF_PATH}>"
        return
    fi

	echo_style_wrap_text "Starting 'configuration' <${TMP_DC_MSQ_CONF_CTN_IMG_NAME}> [master]"
    
    # 修改文件配置
	echo_style_text "Starting 'change cnf'(<${TMP_DC_MSQ_CONF_LNK_CONF_PATH}>)"
	## 不加binlog-do-db和binlog_ignore_db，那就表示备份全部数据库。
	## echo_style_text "'MySQL': Please Ender MySQL-Master All DB To Bak And Use Character ',' To Split Like 'db_a,db_b' In Network"
	## read -e DBS

    # file_content_part_not_exists_mquote_echo "^long_query_time=" ${1} "mysqld" "long_query_time=3"
    ## 指定主库的 server id
	sed -i "s@^server-id.*@server-id = ${LOCAL_ID}@g" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH}

	file_content_part_not_exists_mquote_echo "^relay-log-index.*" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "relay-log-index = relay-bin-index"
	file_content_part_not_exists_mquote_echo "^relay-log = .*" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "relay-log = relay-bin"
    ## 可以指定需要记录的库
    ## 需要记录多个库，只需要重复配置 binlog-do-db
    ### binlog-do-db=test_db
    ## 也可以指定不需要记录的库
	file_content_part_not_exists_mquote_echo "^binlog-ignore-db.*" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "binlog-ignore-db = mysql"

    # Last_IO_Error: Got fatal error 1236 from master when reading data from binary log: 'Binary log is not open'
    file_content_part_not_exists_mquote_echo "^innodb_flush_log_at_trx_commit.*" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "innodb_flush_log_at_trx_commit = 1"
    file_content_part_not_exists_mquote_echo "^sync_binlog.*" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "sync_binlog = 1"
    ## 指定 Binlog 的位置
    file_content_part_not_exists_mquote_echo "^log-bin.*" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "log-bin=mysql-bin.log"

	## 表示只备份
	## file_content_part_not_exists_mquote_echo "^binlog-do-db.*" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "binlog-do-db=$DBS"
	file_content_part_not_exists_mquote_echo "^# Defind for" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "# Defind for master set by meyer.cheng, at ${LOCAL_TIME}"

    ## 修改配置完重启
	docker container restart ${TMP_DC_MSQ_CONF_CTN_ID}
    
    # 修改DB内配置
	echo_style_text "Starting 'grant permission' to [slave]"
    local TMP_DC_MSQ_CONF_DB_PASSWD=$(console_input "TMP_DC_MSQ_CONF_TEMPORARY_PWD" "Please ender your '${TMP_DC_MSQ_CONF_CTN_IMG_NAME}' <database password> of [localhost]" "y")
    local TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD=$(rand_passwd 'mysql-slave' 'db' "${TMP_DC_MSQ_CONF_CTN_SOFT_VER}")
    TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD=$(console_input "TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD" "Please sure your '${TMP_DC_MSQ_CONF_CTN_IMG_NAME}' <database password> for [slave]" "y" "TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD")
    local TMP_DC_MSQ_CONF_DB_MASTER_SLAVE=$(console_input "${LOCAL_HOST%.*}." "'MySQL': Please ender your '${TMP_DC_MSQ_CONF_CTN_IMG_NAME}' <mysql slave address>")
	
    local TMP_DC_MSQ_CONF_SET_MASTER_SQL=$(cat <<EOF
# GRANT FILE ON *.* TO 'slave'@'${TMP_DC_MSQ_CONF_DB_MASTER_SLAVE}' IDENTIFIED BY '${TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD}';
# GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* to 'slave'@'${TMP_DC_MSQ_CONF_DB_MASTER_SLAVE}' IDENTIFIED BY '${TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD}';
${TMP_DC_MSQ_CONF_CMD_MARK} -uroot -p'${TMP_DC_MSQ_CONF_DB_PASSWD}' -e"
CREATE USER 'slave'@'${TMP_DC_MSQ_CONF_DB_MASTER_SLAVE}' IDENTIFIED BY '${TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD}';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* to 'slave'@'${TMP_DC_MSQ_CONF_DB_MASTER_SLAVE}' WITH GRANT OPTION;
FLUSH PRIVILEGES;
show variables like '%server_id%';
select host,user,authentication_string from mysql.user;
show master status;
exit"
    echo "${TMP_DC_MSQ_CONF_CTN_IMG_NAME}: Master set success"
    echo "${TMP_DC_MSQ_CONF_CTN_IMG_NAME}: Password(${green}${TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD}${reset}) for ${red}slave${reset} set success"
EOF
)

    docker_bash_channel_echo_exec "${TMP_DC_MSQ_CONF_CTN_ID}" "${TMP_DC_MSQ_CONF_SET_MASTER_SQL}" "/tmp/set_db_master.sh" "."
    
    # 结束
    exec_sleep 10 "Conf <library/mysql> master over, please checking the setup log, this will stay [%s] secs to exit"

	return $?
}

# 4-2-2：设置备库
function conf_dc_mysql_etc_slave()
{
    _conf_dc_mysql_etc_bind

    if [ -z "${TMP_DC_MSQ_CONF_LNK_CONF_PATH}" ]; then
        echo_style_text "Cannot define conf path"
        return
    fi

    if [[ ! -f ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} ]]; then
        echo_style_text "Cannot found conf path <${TMP_DC_MSQ_CONF_LNK_CONF_PATH}>"
        return
    fi

	echo_style_wrap_text "Starting 'configuration' <slave>"

	#不加binlog-do-db和binlog_ignore_db，那就表示备份全部数据库。
	#echo_style_text "'MySQL': Please Ender MySQL-Slave All DB To Bak And Use Character ',' To Split Like 'db_a,db_b' In Network"
	#read -e DBS

    # 修改文件配置
	echo_style_text "Starting 'change cnf'(<${TMP_DC_MSQ_CONF_LNK_CONF_PATH}>)"
	sed -i "s@^server-id.*@server-id = ${LOCAL_ID}@g" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH}
	sed -i "s@^innodb_thread_concurrency.*@innodb_thread_concurrency = 0@g" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH}

	file_content_part_not_exists_mquote_echo "^skip-slave-start" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "skip-slave-start"
	file_content_part_not_exists_mquote_echo "^replicate-ignore-db.*" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "replicate-ignore-db = mysql"
	#表示只备份
	#file_content_part_not_exists_mquote_echo "^replicate-do-db.*" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "replicate-do-db = $DBS"
	file_content_part_not_exists_mquote_echo "^# Defind for" ${TMP_DC_MSQ_CONF_LNK_CONF_PATH} "mysqld" "# Defind for slave set by meyer.cheng, at ${LOCAL_TIME}"

	docker container restart ${TMP_DC_MSQ_CONF_CTN_ID}
        
    # 修改DB内配置
	echo_style_text "Starting 'change master' for [slave]"
	local TMP_DC_MSQ_CONF_DB_PASSWD=$(console_input "TMP_DC_MSQ_CONF_TEMPORARY_PWD" "'MySQL': Please ender '${TMP_DC_MSQ_CONF_CTN_IMG_NAME}' <localhost password> of [root]" "y")
	local TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_HOST=$(console_input "${LOCAL_HOST%.*}." "'MySQL': Please ender 'mysql master host' in internal")
	local TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_PORT=$(console_input "${TMP_DC_MSQ_CONF_SOFT_OPN_PORT}" "'MySQL': Please sure 'mysql master port' of host(<${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_HOST}>)")
    local TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD=$(rand_passwd 'mysql-slave' 'db' "${TMP_DC_MSQ_CONF_CTN_SOFT_VER}")
    TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD=$(console_input "TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD" "Please ender your '${TMP_DC_MSQ_CONF_CTN_IMG_NAME}' master@<${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_HOST}>:[${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_PORT}] account <password> for 'slave'" "y" "TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD")

    # 获取主库状态
    local TMP_DC_MSQ_CONF_DB_MASTER_STATUS=$(docker_bash_channel_exec "${TMP_DC_MSQ_CONF_CTN_ID}" "echo 'show master status\G;' | ${TMP_DC_MSQ_CONF_CMD_MARK} -h${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_HOST} -uslave -p'${TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD}' -P${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_PORT}")
    local TMP_DC_MSQ_CONF_DB_MASTER_FILE=$(echo "${TMP_DC_MSQ_CONF_DB_MASTER_STATUS}" | awk -F':' '{if($1~"File"){print $2}}' | xargs echo)
    local TMP_DC_MSQ_CONF_DB_MASTER_POS=$(echo "${TMP_DC_MSQ_CONF_DB_MASTER_STATUS}" | awk -F':' '{if($1~"Position"){print $2}}' | xargs echo)

    if [[ -z "${TMP_DC_MSQ_CONF_DB_MASTER_FILE}" || -z "${TMP_DC_MSQ_CONF_DB_MASTER_POS}" ]]; then
        echo_style_text "Cannot found master@<${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_HOST}>:[${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_PORT}] status"
        return
    fi

	# 在主服务器新建一个用户赋予“REPLICATION SLAVE”的权限。
    local TMP_DC_MSQ_CONF_SET_SLAVE_SQL=$(cat <<EOF
# change master to master_host='${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_HOST}', master_port=${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_PORT}, master_user='slave', master_password='${TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD}', master_auto_position=1;
# change master to master_host='${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_HOST}', master_port=${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_PORT}, master_user='slave', master_password='${TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD}', master_log_file='${TMP_DC_MSQ_CONF_DB_MASTER_FILE}', master_log_pos=${TMP_DC_MSQ_CONF_DB_MASTER_POS};
# set @@GLOBAL.GTID_MODE = OFF;
${TMP_DC_MSQ_CONF_CMD_MARK} -uroot -p'${TMP_DC_MSQ_CONF_DB_PASSWD}' -e"
stop slave;
reset slave;
FLUSH PRIVILEGES;
CHANGE MASTER TO master_host='${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_HOST}', master_port=${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_PORT}, master_user='slave', master_password='${TMP_DC_MSQ_CONF_DB_SLAVE_PASSWD}';
start slave;
show slave status\G;
FLUSH PRIVILEGES;
show variables like '%server_id%';
select host,user,authentication_string from mysql.user;
exit"
echo "${TMP_DC_MSQ_CONF_CTN_IMG_NAME}: Slave set success"
echo "${TMP_DC_MSQ_CONF_CTN_IMG_NAME}: Current master changed(${green}slave${reset}@${red}${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_HOST}:${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_PORT}${reset})"
echo "${TMP_SPLITER2}"
echo "If u got problems, pls via 'https://yq.aliyun.com/articles/27792' to look some questions"
echo "${TMP_SPLITER2}"
EOF
)
    docker_bash_channel_echo_exec "${TMP_DC_MSQ_CONF_CTN_ID}" "${TMP_DC_MSQ_CONF_SET_SLAVE_SQL}" "/tmp/set_db_slave.sh" "."
   
	# 添加系统启动命令(不sleep可能会遇到服务还没起来的情况)
    echo_startup_supervisor_config "mysql_slave_${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_HOST##*.}_${TMP_DC_MSQ_CONF_DB_SLAVE_MASTER_PORT}" "${SUPERVISOR_DATA_DIR}" "docker exec -i ${TMP_DC_MSQ_CONF_CTN_ID} sh -c \"sleep 30 && echo 'start slave; show slave status\\\G;' | ${TMP_DC_MSQ_CONF_CMD_MARK} -uroot -p'${TMP_DC_MSQ_CONF_DB_PASSWD}' -P${TMP_DC_MSQ_CONF_SOFT_INN_PORT}\"" "" 999 "" "docker" "false" "0"
    
    # 结束
    exec_sleep 10 "Conf <library/mysql> slave over, please checking the setup log, this will stay [%s] secs to exit"

	return $?
}

# 4-2-x：绑定db连接变量
function _conf_dc_mysql_etc_bind()
{    
    # 检索mysql容器集合
    local TMP_DC_MSQ_CONF_CTNS=$(docker ps -a --no-trunc | awk "{if(\$2~\"mysql\"||\$2~\"mariadb\"){ print \$2\":\"\$1}}")
    if [ -z "${TMP_DC_MSQ_CONF_CTNS}" ]; then
        echo_style_text "Cannot found 'containers' for any mysql db types"
        return
    fi

    # 选择修改的容器
    local TMP_DC_MSQ_CONF_CTN_CHOICE=
    bind_if_choice "TMP_DC_MSQ_CONF_CTN_CHOICE" "Please choice which 'container' u want to conf <${TMP_DC_MSQ_CONF_CHOICE_MODE}>" "${TMP_DC_MSQ_CONF_CTNS}"

    # 容器配置修改
    if [ -n "${TMP_DC_MSQ_CONF_CTN_CHOICE}" ]; then
        TMP_DC_MSQ_CONF_CTN_IMG_NAME=$(echo "${TMP_DC_MSQ_CONF_CTN_CHOICE}" | cut -d':' -f1)
        TMP_DC_MSQ_CONF_CTN_IMG_MARK_NAME="${TMP_DC_MSQ_CONF_CTN_IMG_NAME/\//_}"
        TMP_DC_MSQ_CONF_CTN_IMG_VER=$(echo "${TMP_DC_MSQ_CONF_CTN_CHOICE}" | cut -d':' -f2)
        TMP_DC_MSQ_CONF_CTN_ID=$(echo "${TMP_DC_MSQ_CONF_CTN_CHOICE}" | cut -d':' -f3)
        # 软件内部标识命令（大于等于11的版本被标记为mariadb）
        if [ -z "$(docker_bash_channel_exec "${TMP_DC_MSQ_CONF_CTN_ID}" 'which mysql')" ]; then
            TMP_DC_MSQ_CONF_CMD_MARK="mariadb"
        fi

        TMP_DC_MSQ_CONF_CTN_SOFT_VER=$(docker_bash_channel_exec "${TMP_DC_MSQ_CONF_CTN_ID}" '${TMP_DC_MSQ_CONF_CMD_MARK} -V | grep -oP "(?<=Distrib ).+(?=,)"')
        if [ -z "${TMP_DC_MSQ_CONF_CTN_SOFT_VER}" ]; then
            ## mysql  Ver 8.0.33 for Linux on x86_64 (MySQL Community Server - GPL)
            TMP_DC_MSQ_CONF_CTN_SOFT_VER=$(docker_bash_channel_exec "${TMP_DC_MSQ_CONF_CTN_ID}" '${TMP_DC_MSQ_CONF_CMD_MARK} -V | grep -oP "(?<=Ver ).+(?= for)"')
        fi
        
        local TMP_DC_MSQ_CONF_CTN_RUNLIKE=$(su_bash_env_conda_channel_exec "runlike ${TMP_DC_MSQ_CONF_CTN_ID}")
        if [ -z "${TMP_DC_MSQ_CONF_CTN_RUNLIKE}" ]; then
            echo_style_text "Cannot print 'runlike' from 'container' <${TMP_DC_MSQ_CONF_CTN_ID}>"
            return
        fi
        
        local TMP_DC_MSQ_CONF_SOFT_PORT_PAIR=$(echo "${TMP_DC_MSQ_CONF_CTN_RUNLIKE}"  | grep -oP "(?<=-p )[0-9|:]+(?=\s*)")
        TMP_DC_MSQ_CONF_SOFT_OPN_PORT=$(echo "${TMP_DC_MSQ_CONF_SOFT_PORT_PAIR}" | cut -d':' -f1)
        TMP_DC_MSQ_CONF_SOFT_INN_PORT=$(echo "${TMP_DC_MSQ_CONF_SOFT_PORT_PAIR}" | cut -d':' -f2)
        TMP_DC_MSQ_CONF_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_MSQ_CONF_CTN_IMG_MARK_NAME}/${TMP_DC_MSQ_CONF_CTN_IMG_VER}

        # 临时密码
        TMP_DC_MSQ_CONF_TEMPORARY_PWD=$(cat ${TMP_DC_MSQ_CONF_SETUP_DIR}/${DEPLOY_LOGS_MARK}/container/${TMP_DC_MSQ_CONF_CTN_ID}-json.log | grep "GENERATED ROOT PASSWORD: " | jq ".log" | awk 'END{print}' | grep -oP "(?<=GENERATED ROOT PASSWORD: ).+(?=\\\n\")")
        TMP_DC_MSQ_CONF_TEMPORARY_PWD="${TMP_DC_MSQ_CONF_TEMPORARY_PWD//\'/\\\'/}"

        # 配置文件路径
        TMP_DC_MSQ_CONF_LNK_CONF_PATH=$(docker_container_mysql_etc_mysqld_node_file_path_echo "${TMP_DC_MSQ_CONF_CTN_ID}")
    fi
	return $?
}

##########################################################################################################

# 基础参数
local TMP_DC_MSQ_CONF_SETUP_DIR=
local TMP_DC_MSQ_CONF_CTN_IMG_NAME=
local TMP_DC_MSQ_CONF_CTN_IMG_VER=
local TMP_DC_MSQ_CONF_CTN_SOFT_VER=
local TMP_DC_MSQ_CONF_CTN_ID=
local TMP_DC_MSQ_CONF_SOFT_OPN_PORT=
local TMP_DC_MSQ_CONF_SOFT_INN_PORT=
local TMP_DC_MSQ_CONF_LNK_CONF_PATH=
local TMP_DC_MSQ_CONF_TEMPORARY_PWD=
local TMP_DC_MSQ_CONF_CMD_MARK="mysql"

# 主备选择
local TMP_DC_MSQ_CONF_CHOICE_MODE=
typeset -l TMP_DC_MSQ_CONF_CHOICE_MODE
exec_if_choice "TMP_DC_MSQ_CONF_CHOICE_MODE" "Please choice which 'mode' you want conf" "...,Master,Slave,Exit" "${TMP_SPLITER}" "conf_dc_mysql_etc_"