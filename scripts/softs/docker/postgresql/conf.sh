
# 4-2-1：设置主库
function conf_dc_postgresql_etc_master()
{
    _conf_dc_postgresql_etc_bind

    if [ -z "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}" ]; then
        echo_style_text "Cannot define conf dir"
        return
    fi

    if [[ ! -d ${TMP_DC_PSQ_CONF_LNK_ETC_DIR} ]]; then
        echo_style_text "Cannot found conf dir <${TMP_DC_PSQ_CONF_LNK_ETC_DIR}>"
        return
    fi

	echo_style_wrap_text "Starting 'configuration' <${TMP_DC_PSQ_CONF_CTN_IMG_NAME}> [master]"
    
    # 修改文件配置
	echo_style_text "Starting 'change cnf'(<${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf>)"
    if [[ ! -f ${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf ]]; then
        echo_style_text "Cannot found conf path <${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf>"
        return
    fi

    # 参数配置，详见：https://blog.csdn.net/yeqinghanwu/article/details/130388106
    file_content_not_exists_echo "^# Defind for" ${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf "# Defind for master set by meyer.cheng, at ${LOCAL_TIME}"
    file_content_not_exists_echo "^max_wal_senders =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf" "max_wal_senders = 10"
    file_content_not_exists_echo "^max_connections =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf" "max_connections = 1000"
    file_content_not_exists_echo "^wal_level =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf" "wal_level = replica"
    file_content_not_exists_echo "^archive_mode =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf" "archive_mode = on"
    file_content_not_exists_echo "^archive_command =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf" "archive_command = '/bin/date'"
    file_content_not_exists_echo "^hot_standby =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf" "hot_standby = on"
    # file_content_not_exists_echo "^wal_keep_segments =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf" "wal_keep_segments = 64"
    file_content_not_exists_echo "^wal_sender_timeout =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf" "wal_sender_timeout = 60s"
    file_content_not_exists_echo "^full_page_writes =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf" "full_page_writes = on"
    file_content_not_exists_echo "^wal_log_hints =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf" "wal_log_hints = on"

    # 开启同步备份
	file_content_not_exists_echo "^synchronous_standby_names =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf" "synchronous_standby_names = '*'"

    # 重载配置文件
    docker_bash_channel_exec "${TMP_DC_PSQ_CONF_CTN_ID}" "pg_ctl reload" "" "postgres"
       
    # 修改DB内配置
	echo_style_text "Starting 'grant permission' to [slave]"
    local TMP_DC_PSQ_CONF_DB_PASSWD=$(console_input "TMP_DC_PSQ_CONF_TEMPORARY_PWD" "Please ender your '${TMP_DC_PSQ_CONF_CTN_IMG_NAME}' <database password> of [localhost]" "y")
    local TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD=$(rand_passwd 'psql-slave' 'db' "${TMP_DC_PSQ_CONF_CTN_IMG_VER}")
    TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD=$(console_input "TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD" "Please sure your '${TMP_DC_PSQ_CONF_CTN_IMG_NAME}' <database password> for [slave]" "y" "TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD")
    local TMP_DC_PSQ_CONF_DB_MASTER_SLAVE_HOST=$(console_input "${LOCAL_HOST%.*}." "'PSql': Please ender your '${TMP_DC_PSQ_CONF_CTN_IMG_NAME}' <psql slave address>")
	
    file_content_not_exists_echo "^host replication rep_user ${TMP_DC_PSQ_CONF_DB_MASTER_SLAVE_HOST}/.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/pg_hba.conf" "host replication rep_user ${TMP_DC_PSQ_CONF_DB_MASTER_SLAVE_HOST}/32 md5"

    # 修改配置完重启
	docker container restart ${TMP_DC_PSQ_CONF_CTN_ID}

    local TMP_DC_PSQ_CONF_SET_MASTER_SH=$(cat <<EOF
echo "CREATE USER rep_user replication LOGIN CONNECTION LIMIT 3 ENCRYPTED PASSWORD '${TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD}'; select * from pg_user;" | psql -U postgres -h localhost -d postgres
echo "${TMP_DC_PSQ_CONF_CTN_IMG_NAME}: Master set success"
echo "${TMP_DC_PSQ_CONF_CTN_IMG_NAME}: Password(${green}${TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD}${reset}) for ${red}slave${reset} set success"
EOF
)

    docker_bash_channel_echo_exec "${TMP_DC_PSQ_CONF_CTN_ID}" "${TMP_DC_PSQ_CONF_SET_MASTER_SH}" "/tmp/set_db_master.sh" "."
    
    # 结束
    exec_sleep 10 "Conf <${TMP_DC_PSQ_CONF_CTN_IMG_NAME}> master over, please checking the setup log, this will stay 10 secs to exit"

	return $?
}

# 4-2-2：设置备库
function conf_dc_postgresql_etc_slave()
{
    _conf_dc_postgresql_etc_bind

    if [ -z "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}" ]; then
        echo_style_text "Cannot define conf dir"
        return
    fi

    if [[ ! -d ${TMP_DC_PSQ_CONF_LNK_ETC_DIR} ]]; then
        echo_style_text "Cannot found conf dir <${TMP_DC_PSQ_CONF_LNK_ETC_DIR}>"
        return
    fi

	echo_style_wrap_text "Starting 'configuration' <${TMP_DC_PSQ_CONF_CTN_IMG_NAME}> [slave]"

    # 修改文件配置
	echo_style_text "Starting 'change cnf'(<${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf>)"
    if [[ ! -f ${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf ]]; then
        echo_style_text "Cannot found conf path <${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/postgresql.conf>"
        return
    fi

    # 备份主库
    echo_style_text "Starting 'backup master' for [slave]"
	# local TMP_DC_PSQ_CONF_DB_PASSWD=$(console_input "TMP_DC_PSQ_CONF_TEMPORARY_PWD" "'PSql': Please ender '${TMP_DC_PSQ_CONF_CTN_IMG_NAME}' <localhost password> of [root]" "y")
	local TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_HOST=$(console_input "${LOCAL_HOST%.*}." "'PSql': Please ender 'postgresql master host' in internal")
	local TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_PORT=$(console_input "${TMP_DC_PSQ_CONF_SOFT_OPN_PORT}" "'PSql': Please sure 'postgresql master port' of host(<${TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_HOST}>)")
    local TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD=$(rand_passwd 'psql-slave' 'db' "${TMP_DC_PSQ_CONF_CTN_IMG_VER}")
    TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD=$(console_input "TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD" "Please ender your '${TMP_DC_PSQ_CONF_CTN_IMG_NAME}' master@<${TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_HOST}>:[${TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_PORT}] account <password> for 'slave'" "y" "TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD")

    file_content_not_exists_echo "^host replication rep_user ${TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_HOST}/.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/pg_hba.conf" "host replication rep_user ${TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_HOST}/32 md5"

    local TMP_DC_PSQ_CONF_BACKUP_MASTER_SH=$(cat <<EOF
apt-get -y install rsync
PGPASSWORD="${TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD}" pg_basebackup -h ${TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_HOST} -p ${TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_PORT} -D /var/lib/postgresql_replicate -U rep_user -Fp -Xs -P -v
echo "*.txt" > /var/lib/postgresql_replicate/rsync-exclude.txt
echo "*.conf" >> /var/lib/postgresql_replicate/rsync-exclude.txt
echo "*.done" >> /var/lib/postgresql_replicate/rsync-exclude.txt
echo "*.pots" >> /var/lib/postgresql_replicate/rsync-exclude.txt
rsync -av /var/lib/postgresql_replicate/ /var/lib/postgresql/data --exclude-from /var/lib/postgresql_replicate/rsync-exclude.txt
chown -R postgres:postgres /var/lib/postgresql
rm -rf /var/lib/postgresql_replicate

test -f /usr/share/postgresql/recovery.conf.sample && cp /usr/share/postgresql/recovery.conf.sample /var/lib/postgresql/data/recovery.done
EOF
)

    docker_bash_channel_echo_exec "${TMP_DC_PSQ_CONF_CTN_ID}" "${TMP_DC_PSQ_CONF_BACKUP_MASTER_SH}" "/tmp/sync_db_master.sh" "."
    
    # 重新同步到本地
    docker cp -a ${TMP_DC_PSQ_CONF_CTN_ID}:/var/lib/postgresql/data ${TMP_DC_PSQ_CONF_SETUP_DIR}/data_replicate
    # 清理容器内存储，谨防写入不产生同步
    docker_bash_channel_exec "${TMP_DC_PSQ_CONF_CTN_ID}" "pg_ctl stop -D /var/lib/postgresql/data -s -m fast && rm -rf /var/lib/postgresql/data" "" "postgres"

    docker container stop ${TMP_DC_PSQ_CONF_CTN_ID}
    
    local TMP_DC_PSQ_CONF_DATA_DIR=${TMP_DC_PSQ_CONF_SETUP_DIR}/data
    bind_symlink_link_path "TMP_DC_PSQ_CONF_DATA_DIR"

    rsync -av ${TMP_DC_PSQ_CONF_SETUP_DIR}/data_replicate/ ${TMP_DC_PSQ_CONF_DATA_DIR} 
    
    rm -rf ${TMP_DC_PSQ_CONF_SETUP_DIR}/data_replicate

    # 注意：PostgreSQL 12 的一个重要变化是 recovery.conf 配置文件中的参数合并到 postgresql.conf，recovery.conf 不再使用。
    ## 详细参考 https://developer.aliyun.com/article/714975 | https://www.cybertec-postgresql.com/en/recovery-conf-is-gone-in-postgresql-v12/
    local TMP_DC_PSQ_CONF_LNK_ETC_RECV_PATH="postgresql.conf"
    if [ $(echo "${TMP_DC_PSQ_CONF_CTN_SOFT_VER%.*} < 12" | bc) == 1 ]; then
        TMP_DC_PSQ_CONF_LNK_ETC_RECV_PATH="recovery.done"
        file_content_not_exists_echo "^standby_mode =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/${TMP_DC_PSQ_CONF_LNK_ETC_RECV_PATH}" "standby_mode = on"
    else
        echo > ${TMP_DC_PSQ_CONF_DATA_DIR}/standby.signal
    fi

    file_content_not_exists_echo "^# Defind for" ${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/${TMP_DC_PSQ_CONF_LNK_ETC_RECV_PATH} "# Defind for slave set by meyer.cheng, at ${LOCAL_TIME}"
    file_content_not_exists_echo "^recovery_target_timeline =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/${TMP_DC_PSQ_CONF_LNK_ETC_RECV_PATH}" "recovery_target_timeline = 'latest'"
    file_content_not_exists_echo "^hot_standby =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/${TMP_DC_PSQ_CONF_LNK_ETC_RECV_PATH}" "hot_standby = on"
    file_content_not_exists_echo "^primary_conninfo =.*" "${TMP_DC_PSQ_CONF_LNK_ETC_DIR}/${TMP_DC_PSQ_CONF_LNK_ETC_RECV_PATH}" "primary_conninfo = 'host=${TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_HOST} port=${TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_PORT} user=rep_user password=${TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD}'"

	docker container start ${TMP_DC_PSQ_CONF_CTN_ID}
    
    local TMP_DC_PSQ_CONF_BACKUP_MASTER_SH=$(cat <<EOF
echo "${TMP_DC_PSQ_CONF_CTN_IMG_NAME}: Mark -> f(master)、 t(slave)"
echo "${TMP_DC_PSQ_CONF_CTN_IMG_NAME}: Checking master status"
echo "select usename,application_name,client_addr,sync_state from pg_stat_replication; select pg_is_in_recovery();\l;" | PGPASSWORD="${TMP_DC_PSQ_CONF_DB_SLAVE_PASSWD}" psql -U rep_user -d postgres -h ${TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_HOST} -p ${TMP_DC_PSQ_CONF_DB_SLAVE_MASTER_PORT}

echo "${TMP_DC_PSQ_CONF_CTN_IMG_NAME}: Checking slave status"
echo "select pg_is_in_recovery();\l;" | PGPASSWORD="${TMP_DC_PSQ_CONF_TEMPORARY_PWD}" psql -U rep_user -d postgres -h localhost
pg_controldata
EOF
)

    docker_bash_channel_echo_exec "${TMP_DC_PSQ_CONF_CTN_ID}" "${TMP_DC_PSQ_CONF_BACKUP_MASTER_SH}" "/tmp/check_replicate.sh" "."
   
    # 结束
    exec_sleep 10 "Conf <${TMP_DC_PSQ_CONF_CTN_IMG_NAME}> slave over, please checking the setup log, this will stay 10 secs to exit"

	return $?
}

# 4-2-x：绑定db连接变量
function _conf_dc_postgresql_etc_bind()
{    
    # 检索postgresql容器集合
    local TMP_DC_PSQ_CONF_CTNS=$(docker ps -a --no-trunc | awk "{if(\$2~\"postgres\"){ print \$2\":\"\$1}}")
    if [ -z "${TMP_DC_PSQ_CONF_CTNS}" ]; then
        echo_style_text "Cannot found 'containers' for any postgresql db types"
        return
    fi

    # 选择修改的容器
    local TMP_DC_PSQ_CONF_CTN_CHOICE=
    bind_if_choice "TMP_DC_PSQ_CONF_CTN_CHOICE" "Please choice which 'container' u want to conf <${TMP_DC_PSQ_CONF_CHOICE_MODE}>" "${TMP_DC_PSQ_CONF_CTNS}"

    # 容器配置修改
    if [ -n "${TMP_DC_PSQ_CONF_CTN_CHOICE}" ]; then
        TMP_DC_PSQ_CONF_CTN_IMG_NAME=$(echo "${TMP_DC_PSQ_CONF_CTN_CHOICE}" | cut -d':' -f1)
        TMP_DC_PSQ_CONF_CTN_IMG_MARK_NAME="${TMP_DC_PSQ_CONF_CTN_IMG_NAME/\//_}"
        TMP_DC_PSQ_CONF_CTN_IMG_VER=$(echo "${TMP_DC_PSQ_CONF_CTN_CHOICE}" | cut -d':' -f2)
        TMP_DC_PSQ_CONF_CTN_ID=$(echo "${TMP_DC_PSQ_CONF_CTN_CHOICE}" | cut -d':' -f3)
        TMP_DC_PSQ_CONF_CTN_SOFT_VER=$(docker_bash_channel_exec "${TMP_DC_PSQ_CONF_CTN_ID}" 'psql --version | grep -oP "(?<=\) ).+(?=\(Debian)"')
        
        local TMP_DC_PSQ_CONF_CTN_RUNLIKE=$(su_bash_env_conda_channel_exec "runlike ${TMP_DC_PSQ_CONF_CTN_ID}")
        if [ -z "${TMP_DC_PSQ_CONF_CTN_RUNLIKE}" ]; then
            echo_style_text "Cannot print 'runlike' from 'container' <${TMP_DC_PSQ_CONF_CTN_ID}>"
            return
        fi
        
        local TMP_DC_PSQ_CONF_SOFT_PORT_PAIR=$(echo "${TMP_DC_PSQ_CONF_CTN_RUNLIKE}"  | grep -oP "(?<=-p )[0-9|:]+(?=\s*)")
        TMP_DC_PSQ_CONF_SOFT_OPN_PORT=$(echo "${TMP_DC_PSQ_CONF_SOFT_PORT_PAIR}" | cut -d':' -f1)
        TMP_DC_PSQ_CONF_SOFT_INN_PORT=$(echo "${TMP_DC_PSQ_CONF_SOFT_PORT_PAIR}" | cut -d':' -f2)
        TMP_DC_PSQ_CONF_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_PSQ_CONF_CTN_IMG_MARK_NAME}/${TMP_DC_PSQ_CONF_CTN_IMG_VER}

        # 临时密码
        TMP_DC_PSQ_CONF_TEMPORARY_PWD=$(echo "${TMP_DC_PSQ_CONF_CTN_RUNLIKE}" | grep -oP "(?<=--env=POSTGRES_PASSWORD=)\S+")

        # 配置文件路径
        function _conf_dc_postgresql_etc_bind_etc_dir()
        {
            TMP_DC_PSQ_CONF_LNK_ETC_DIR=${DOCKER_APP_SETUP_DIR}/${3/\//_}/${4}/etc/data
            bind_symlink_link_path "TMP_DC_PSQ_CONF_LNK_ETC_DIR"
        }

        docker_container_param_check_action "${TMP_DC_PSQ_CONF_CTN_ID}" "_conf_dc_postgresql_etc_bind_etc_dir"
    fi
	return $?
}

##########################################################################################################

# 基础参数
local TMP_DC_PSQ_CONF_SETUP_DIR=
local TMP_DC_PSQ_CONF_CTN_IMG_NAME=
local TMP_DC_PSQ_CONF_CTN_IMG_VER=
local TMP_DC_PSQ_CONF_CTN_SOFT_VER=
local TMP_DC_PSQ_CONF_CTN_ID=
local TMP_DC_PSQ_CONF_SOFT_OPN_PORT=
local TMP_DC_PSQ_CONF_SOFT_INN_PORT=
local TMP_DC_PSQ_CONF_LNK_ETC_DIR=
local TMP_DC_PSQ_CONF_TEMPORARY_PWD=
local TMP_DC_PSQ_CONF_CMD_MARK="psql"

# 主备选择
local TMP_DC_PSQ_CONF_CHOICE_MODE=
typeset -l TMP_DC_PSQ_CONF_CHOICE_MODE
exec_if_choice "TMP_DC_PSQ_CONF_CHOICE_MODE" "Please choice which 'mode' you want conf" "...,Master,Slave,Exit" "${TMP_SPLITER}" "conf_dc_postgresql_etc_"