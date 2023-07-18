#!/bin/sh
#------------------------------------------------
#      Linux softs install scripts by env
#      copyright https://oshit.thiszw.com/
#      author: meyer.cheng
#------------------------------------------------
# Mark：公共函数
#------------------------------------------------
# http://blog.csdn.net/u010861514/article/details/51028220
# 命令参考：https://www.jianshu.com/p/1bbdbf1aa1bd

# $? :上一个命令的执行状态返回值
# $#：:参数的个数
# $*：参数列表，所有的变量作为一个字符串
# $@：参数列表，每个变量作为单个字符串
# ${1}-9,${10}：位置参数
# $$：脚本的进程号
# $_：之前命令的最后一个参数
# $0：脚本的名称
# $！：运行在后台的最后一个进程ID

# 清理系统缓存后执行
echo 3 > /proc/sys/vm/drop_caches

##########################################################################################################
# 辅助操作类
##########################################################################################################
function underline() 
{ 
	printf "${underline}${bold}%s${reset}\n" "$@"
}

function h1() 
{ 
	printf "\n${underline}${bold}${blue}%s${reset}\n" "$@"
}

function h2() 
{ 
	printf "\n${underline}${bold}${white}%s${reset}\n" "$@"
}

function debug() 
{ 
	printf "${white}%s${reset}\n" "$@"
}

function info() 
{ 
	printf "${white}➜ %s${reset}\n" "$@"
}

function success() 
{ 
	printf "${green}✔ %s${reset}\n" "$@"
}

function error() 
{ 
	printf "${red}✖ %s${reset}\n" "$@"
}

function warn() 
{ 
	printf "${tan}➜ %s${reset}\n" "$@"
}

function bold() 
{ 
	printf "${bold}%s${reset}\n" "$@"
}

function note() 
{ 
	printf "\n${underline}${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$@"
}


# 绑定系统域名设定
# 参数1：需要设置的变量名
function bind_sysdomain() {
	function _bind_sysdomain()
	{
		local _TMP_BIND_SYS_DOMAIN_VAL="mydomain.com"
		if [ -f "${SETUP_DIR}/.sys_domain" ]; then
			_TMP_BIND_SYS_DOMAIN_VAL=$(cat ${SETUP_DIR}/.sys_domain)
		fi

		eval ${1}='${_TMP_BIND_SYS_DOMAIN_VAL}'
	}

	discern_exchange_var_action "${1}" "_bind_sysdomain" "${@}"
	return $?
}

#填充右处
# 参数1：需要设置的变量名
# 参数2：填充字符
# 参数3：总长度
# 参数4：格式化字符
function fill_right()
{
	function _fill_right()
	{
		local _TMP_FILL_RIGHT_VAR_VAL=$(eval echo '${'"${1}"'}')
		local _TMP_FILL_RIGHT_FILL_CHR=${2}
		local _TMP_FILL_RIGHT_TOTAL_LEN=${3}

		local _TMP_FILL_RIGHT_ITEM_LEN=${#_TMP_FILL_RIGHT_VAR_VAL}
		local _TMP_FILL_RIGHT_OUTPUT_SPACE_COUNT=$((_TMP_FILL_RIGHT_TOTAL_LEN-_TMP_FILL_RIGHT_ITEM_LEN))	
		local _TMP_FILL_RIGHT_SPACE_STR=$(eval printf %.s'${_TMP_FILL_RIGHT_FILL_CHR}' {1..${_TMP_FILL_RIGHT_OUTPUT_SPACE_COUNT}})
		
		local _TMP_FILL_RIGHT_FINAL_STR="${_TMP_FILL_RIGHT_VAR_VAL}${_TMP_FILL_RIGHT_SPACE_STR}"
		
		if [ -n "${4}" ]; then
			_TMP_FILL_RIGHT_FINAL_STR=$(echo "${4}" | sed s@%@"${_TMP_FILL_RIGHT_FINAL_STR}"@g)
		fi
		
		eval ${1}='${_TMP_FILL_RIGHT_FINAL_STR}'
	}

	discern_exchange_var_action "${1}" "_fill_right" "${@}"
	return $?
}

# 生成启动配置文件
# 参数1：程序命名
# 参数2：程序启动的目录
# 参数3：程序启动的命令
# 参数4：程序启动的环境
# 参数5：优先级序号
# 参数6：运行环境，默认/etc/profile
# 参数7：运行所需的用户，默认root
# 参数8：是否自动重启，默认true
# 参数9：自动重启次数，默认10
function echo_startup_supervisor_config()
{
	set_if_empty "SUPERVISOR_CONF_DIR" "${CONDA_APP_CONF_DIR}/supervisor"

	local _TMP_ECHO_STARTUP_SUP_CONF_NAME=${1}
	local _TMP_ECHO_STARTUP_SUP_CONF_FILENAME=${_TMP_ECHO_STARTUP_SUP_CONF_NAME}.conf
	local _TMP_ECHO_STARTUP_SUP_CONF_BOOT_DIR=${2}
	local _TMP_ECHO_STARTUP_SUP_CONF_COMMAND=${3}
	local _TMP_ECHO_STARTUP_SUP_CONF_ENV_PATH=${4}
	local _TMP_ECHO_STARTUP_SUP_CONF_PRIORITY=${5:-99}
	local _TMP_ECHO_STARTUP_SUP_CONF_SOURCE=${6}
	local _TMP_ECHO_STARTUP_SUP_CONF_USER=${7:-root}
	local _TMP_ECHO_STARTUP_SUP_CONF_AUTO_RESTART=${8:-true}
	local _TMP_ECHO_STARTUP_SUP_CONF_RETRY_COUNT=${9:-10}

	local _TMP_ECHO_STARTUP_SUP_CONF_DFT_ENV="/usr/bin:/usr/local/bin:"
    # 设置默认的源环境，并检测是否为NPM启动方式
	if [ -z "${_TMP_ECHO_STARTUP_SUP_CONF_SOURCE}" ]; then
		_TMP_ECHO_STARTUP_SUP_CONF_SOURCE="/etc/profile"

		# 因konga的关系，此处启动暂时注释自动修改环境的操作（建议可自动修改环境变量至当前的npm版本，并取消原始bin环境）
		# local _TMP_STARTUP_BY_NPM_CHECK=$(echo "${_TMP_ECHO_STARTUP_SUP_CONF_COMMAND}" | sed "s@^sudo@@g" | awk '{sub("^ *","");sub(" *$","");print}' | grep -o "^npm")
		# if [ "${_TMP_STARTUP_BY_NPM_CHECK}" == "npm" ]; then
		# 	_TMP_ECHO_STARTUP_SUP_CONF_SOURCE=$(dirname ${NVM_PATH})
		# fi

		# 上述调整后，解决环境冲突问题
		local _TMP_STARTUP_BY_NPM_CHECK=$(echo "${_TMP_ECHO_STARTUP_SUP_CONF_COMMAND}" | sed "s@^sudo@@g" | awk '{sub("^ *","");sub(" *$","");print}' | grep -o "^npm")
		if [ "${_TMP_STARTUP_BY_NPM_CHECK}" == "npm" ]; then
			_TMP_ECHO_STARTUP_SUP_CONF_DFT_ENV=""
		fi
	fi

	if [ -n "${_TMP_ECHO_STARTUP_SUP_CONF_BOOT_DIR}" ]; then
		_TMP_ECHO_STARTUP_SUP_CONF_BOOT_DIR="directory = ${_TMP_ECHO_STARTUP_SUP_CONF_BOOT_DIR}  ; 程序的启动目录"
	fi
	if [ -n "${_TMP_ECHO_STARTUP_SUP_CONF_ENV_PATH}" ]; then
		_TMP_ECHO_STARTUP_SUP_CONF_ENV_PATH="${_TMP_ECHO_STARTUP_SUP_CONF_ENV_PATH}:"
	fi

	# 类似的：environment = ANDROID_HOME="/opt/android-sdk-linux",PATH="/usr/bin:/usr/local/bin:%(ENV_ANDROID_HOME)s/tools:%(ENV_ANDROID_HOME)s/tools/bin:%(ENV_ANDROID_HOME)s/platform-tools:%(ENV_PATH)s"
	_TMP_ECHO_STARTUP_SUP_CONF_ENV_PATH="environment = PATH=\"${_TMP_ECHO_STARTUP_SUP_CONF_DFT_ENV}${_TMP_ECHO_STARTUP_SUP_CONF_ENV_PATH}:%(ENV_PATH)s\"  ; 程序启动的环境变量信息"

	_TMP_ECHO_STARTUP_SUP_CONF_PRIORITY="priority = ${_TMP_ECHO_STARTUP_SUP_CONF_PRIORITY}"
	
	local _TMP_ECHO_STARTUP_SUP_CONF_CONF_DIR=${SUPERVISOR_CONF_DIR}/boots
	local _TMP_ECHO_STARTUP_SUP_CONF_CONF_CURRENT_OUTPUT_PATH=${_TMP_ECHO_STARTUP_SUP_CONF_CONF_DIR}/${_TMP_ECHO_STARTUP_SUP_CONF_FILENAME}
    local _TMP_ECHO_STARTUP_SUP_CONF_LNK_LOGS_DIR=${SUPERVISOR_LOGS_DIR}
	
	path_not_exists_create $(dirname ${_TMP_ECHO_STARTUP_SUP_CONF_CONF_CURRENT_OUTPUT_PATH})
	path_not_exists_create "${_TMP_ECHO_STARTUP_SUP_CONF_LNK_LOGS_DIR}"

	if [ ! -f "${_TMP_ECHO_STARTUP_SUP_CONF_CONF_CURRENT_OUTPUT_PATH}" ]; then
		echo_style_wrap_text "Supervisor：Gen startup config of <${_TMP_ECHO_STARTUP_SUP_CONF_CONF_CURRENT_OUTPUT_PATH}>"
		tee ${_TMP_ECHO_STARTUP_SUP_CONF_CONF_CURRENT_OUTPUT_PATH} <<-EOF
[program:${_TMP_ECHO_STARTUP_SUP_CONF_NAME}]
command = /bin/bash -c 'source "\$0" && exec "\$@"' ${_TMP_ECHO_STARTUP_SUP_CONF_SOURCE} ${_TMP_ECHO_STARTUP_SUP_CONF_COMMAND} ; 启动命令，可以看出与手动在命令行启动的命令是一样的
autostart = true                                                                     ; 在 supervisord 启动的时候也自动启动
startsecs = 240                                                                      ; 启动 240 秒后没有异常退出，就当作已经正常启动了
autorestart = ${_TMP_ECHO_STARTUP_SUP_CONF_AUTO_RESTART}                             ; 程序异常退出后自动重启
startretries = ${_TMP_ECHO_STARTUP_SUP_CONF_RETRY_COUNT}                             ; 启动失败自动重试次数，默认是 10
user = ${_TMP_ECHO_STARTUP_SUP_CONF_USER}                                            ; 用哪个用户启动
redirect_stderr = true                                                               ; 把 stderr 重定向到 stdout，默认 false
stdout_logfile_maxbytes = 20MB                                                       ; stdout 日志文件大小，默认 50MB
stdout_logfile_backups = 20                                                          ; stdout 日志文件备份数

${_TMP_ECHO_STARTUP_SUP_CONF_PRIORITY}                                                     ; 启动优先级，默认999
${_TMP_ECHO_STARTUP_SUP_CONF_BOOT_DIR}                                                        

${_TMP_ECHO_STARTUP_SUP_CONF_ENV_PATH}                                                        

stdout_logfile = ${_TMP_ECHO_STARTUP_SUP_CONF_LNK_LOGS_DIR}/${_TMP_ECHO_STARTUP_SUP_CONF_NAME}_stdout.log  ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动创建目录（supervisord 会自动创建日志文件）
numprocs = 1                                                                           ;
EOF
	else
		echo ${TMP_SPLITER}
		echo_style_text "'Supervisor'：The startup config of <${_TMP_ECHO_STARTUP_SUP_CONF_CONF_CURRENT_OUTPUT_PATH}> created at↓:"
		ls -lia ${_TMP_ECHO_STARTUP_SUP_CONF_CONF_CURRENT_OUTPUT_PATH}
		echo "${TMP_SPLITER2}"
		cat ${_TMP_ECHO_STARTUP_SUP_CONF_CONF_CURRENT_OUTPUT_PATH}
	fi

	return $?
}

# 生成conda启动配置文件
# 参数1：程序命名
# 参数2：程序启动的命令
# 参数3：优先级序号
# 参数4：CONDA环境
# 参数5：是否自动重启，默认true
# 参数6：自动重启次数，默认10
function echo_conda_startup_supervisor_config()
{
	local _TMP_ECHO_CONDA_STARTUP_SUP_CONF_ENV="${4:-${PY_ENV}}"
	local _TMP_ECHO_CONDA_STARTUP_SUP_CONF_SETUP_PATH=$(su_bash_env_conda_channel_exec "pip show ${1} 2>/dev/null | grep -oP '(?<=^Location: ).+' | xargs -I {} echo '{}/${1}'" "${_TMP_ECHO_CONDA_STARTUP_SUP_CONF_ENV}")
	local _TMP_ECHO_CONDA_STARTUP_SUP_CONF_ENV_PATH=$(su_bash_conda_channel_exec 'echo $PATH' "${_TMP_ECHO_CONDA_STARTUP_SUP_CONF_ENV}")
	local _TMP_ECHO_CONDA_STARTUP_SUP_CONF_SOURCE="$(su_bash_conda_channel_exec 'cd;pwd' "${_TMP_ECHO_CONDA_STARTUP_SUP_CONF_ENV}")/.bashrc"

	echo_conda_startup_supervisor_config "${1}" "${_TMP_ECHO_CONDA_STARTUP_SUP_CONF_SETUP_PATH}" "${2}" "${_TMP_ECHO_CONDA_STARTUP_SUP_CONF_ENV_PATH}" "${3}" "${_TMP_ECHO_CONDA_STARTUP_SUP_CONF_SOURCE}" "conda" ${5} ${6}
	return $?
}

# 输出WEB映射生成脚本（生成的脚本必须在KONG所在机器下运行）
# 参数1：WEB命名
# 参数2：WEB域名
# 参数3：WEB端口
# 参数4：WEB地址
# 参数5：Kong内网地址
# 参数6：Caddy内网地址
# 示例：
#       echo_web_service_init_scripts "supervisor${LOCAL_ID}" "supervisor${LOCAL_ID}-webui.myvnc.com" 19001 "${LOCAL_HOST}"
function echo_web_service_init_scripts()
{
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_NAME=${1}
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME=$(echo ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_NAME} | sed 's/[a-z]/\u&/g')
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN=${2}
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT=${3}
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST=${4:-"${LOCAL_HOST}"}
	
	local TMP_KNG_SETUP_CHAR_PORT_SPLIT=":"

	# 开放端口给kong所在服务器
	echo_soft_port ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT} "${5%:*}"
	
	# 开放端口给caddy所在服务器
	echo_soft_port ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT} "${6%:*}"

	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST=${5:-localhost}
	
	# 附加端口
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KNG_API_HTTP_PAIR=$([[ ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST} == *${TMP_KNG_SETUP_CHAR_PORT_SPLIT}* ]]  && echo ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST} || echo "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST}:${KNG_API_PORT}" )

	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_CDY_HOST=${6}

	path_not_exists_create "${WWW_INIT_DIR}"
	echo_style_wrap_text "Gen '${WWW_INIT_DIR}/init_web_service_for_${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME}_by_caddy_webhook.sh'"
	tee ${WWW_INIT_DIR}/init_web_service_for_${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME}_by_caddy_webhook.sh <<-EOF
#!/bin/sh
#----------------------------------------------------
#  Project init script - for web service or autohttps
#----------------------------------------------------
TMP_INIT_WEB_SERVICE_CDY_HOST="${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_CDY_HOST}"
TMP_INIT_WEB_SERVICE_LOCAL_HOST=\$(ip a | grep inet | grep -v inet6 | grep -v 127 | grep -v docker | awk '{print $2}' | awk -F'/' '{print $1}' | awk 'END {print}')
[[ -z "\${TMP_INIT_WEB_SERVICE_LOCAL_HOST}" ]] && (TMP_INIT_WEB_SERVICE_LOCAL_HOST=\$(ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1\))

TMP_INIT_WEB_SERVICE_LOCAL_PORT="${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT}"

# 本机未有kong_api直接退出执行
if [ ! -f "/usr/bin/kong_api" ]; then
	echo "Cannot find 'kong_api' command in '/usr/bin/kong_api'，please sure u exec at 'kong host'"
	return
fi

# 未定义caddy-host	
if [ -z "\${TMP_INIT_WEB_SERVICE_CDY_HOST}" ]; then	
	echo "Cannot find 'caddy host' in var defined，please sure which your caddy host"
	return
fi

# 先添加域名，避免被caddy-webhook的autohttps解析覆盖
kong_api "upstream" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KNG_API_HTTP_PAIR}" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME}" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST}:\${TMP_INIT_WEB_SERVICE_LOCAL_PORT}" "" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN}"

# 添加防火墙授权许可
echo "${TMP_SPLITER}"
echo "Please allow your iptables or cloud firewall for port '\${TMP_INIT_WEB_SERVICE_LOCAL_PORT}' on host '${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST}'"
echo "${TMP_SPLITER}"
echo "iptables："
echo "          sed -i "11a-A INPUT -s \${TMP_INIT_WEB_SERVICE_LOCAL_HOST} -p tcp -m state --state NEW -m tcp --dport \${TMP_INIT_WEB_SERVICE_LOCAL_PORT} -j ACCEPT" /etc/sysconfig/iptables"
echo "          sed -i "11a-A INPUT -s \${TMP_INIT_WEB_SERVICE_LOCAL_HOST} -p udp -m state --state NEW -m udp --dport \${TMP_INIT_WEB_SERVICE_LOCAL_PORT} -j ACCEPT" /etc/sysconfig/iptables"
echo "          systemctl restart iptables.service"
echo "firewall-cmd："
echo "              firewall-cmd --permanent --add-port=\${TMP_INIT_WEB_SERVICE_LOCAL_PORT}/tcp"
echo "              firewall-cmd --permanent --add-port=\${TMP_INIT_WEB_SERVICE_LOCAL_PORT}/udp"
echo "              firewall-cmd --reload"
echo "${TMP_SPLITER}"

# 添加autohttps维护
tee ${WWW_INIT_DIR}/Caddyroute_for_${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN}.json <<-\EOF
{
	"match": [
		{
			"host": ["${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN}"]
		}
	],
	"handle": [
		{
			"handler": "static_response",
			"body": "Welcome to my security site of '${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN}'!"
		}
	],
	"terminal": true
}
\EOF

	curl \${TMP_INIT_WEB_SERVICE_CDY_HOST}:${CDY_API_PORT}/config/apps/http/servers/autohttps/routes -X POST -H "Content-Type: application/json" -d @Caddyroute_for_${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN}.json
	curl \${TMP_INIT_WEB_SERVICE_CDY_HOST}:${CDY_API_PORT}/config/apps/http/servers/autohttps/logs/logger_names -X POST -H "Content-Type: application/json" -d '{"${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN}": "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN}"}'
EOF

	echo_style_wrap_text "Gen '${WWW_INIT_DIR}/init_web_service_for_${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME}_by_acme_plugin.sh'"
	tee ${WWW_INIT_DIR}/init_web_service_for_${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME}_by_acme_plugin.sh <<-EOF
#!/bin/sh
#----------------------------------------------------
#  Project init script - for web service or autohttps
#----------------------------------------------------
TMP_INIT_WEB_SERVICE_LOCAL_HOST=\$(ip a | grep inet | grep -v inet6 | grep -v 127 | grep -v docker | awk '{print \$2}' | awk -F'/' '{print \$1}' | awk 'END {print}')
[ -z \${TMP_INIT_WEB_SERVICE_LOCAL_HOST} ] && TMP_INIT_WEB_SERVICE_LOCAL_HOST=\$(ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1)

TMP_INIT_WEB_SERVICE_LOCAL_PORT="${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT}"

# 本机未有kong_api直接退出执行
if [ ! -f "/usr/bin/kong_api" ]; then
	echo "Cannot find 'kong_api' command in '/usr/bin/kong_api'，please sure u exec at 'kong host'"
	return
fi

# 先添加域名
kong_api "upstream" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KNG_API_HTTP_PAIR}" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME}" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST}:\${TMP_INIT_WEB_SERVICE_LOCAL_PORT}" "" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN}"

# 添加防火墙授权许可
echo "${TMP_SPLITER}"
echo "Please allow your iptables or cloud firewall for port '\${TMP_INIT_WEB_SERVICE_LOCAL_PORT}' on host '${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST}'"
echo "${TMP_SPLITER}"
echo "iptables："
echo "          sed -i "11a-A INPUT -s \${TMP_INIT_WEB_SERVICE_LOCAL_HOST} -p tcp -m state --state NEW -m tcp --dport \${TMP_INIT_WEB_SERVICE_LOCAL_PORT} -j ACCEPT" /etc/sysconfig/iptables"
echo "          sed -i "11a-A INPUT -s \${TMP_INIT_WEB_SERVICE_LOCAL_HOST} -p udp -m state --state NEW -m udp --dport \${TMP_INIT_WEB_SERVICE_LOCAL_PORT} -j ACCEPT" /etc/sysconfig/iptables"
echo "          systemctl restart iptables.service"
echo "firewall-cmd："
echo "              firewall-cmd --permanent --add-port=\${TMP_INIT_WEB_SERVICE_LOCAL_PORT}/tcp"
echo "              firewall-cmd --permanent --add-port=\${TMP_INIT_WEB_SERVICE_LOCAL_PORT}/udp"
echo "              firewall-cmd --reload"
echo "${TMP_SPLITER}"
EOF
	echo
	
	chmod +x ${WWW_INIT_DIR}/*.sh

	return $?
}

# 复制nginx启动器
# 参数1：程序命名
# 参数2：程序启动的目录
# 参数3：程序启动的端口
function cp_nginx_starter()
{
	local _TMP_CP_NGX_STT_NAME=${1}
	local _TMP_CP_NGX_STT_RUNNING_DIR=${2}
	local _TMP_CP_NGX_STT_RUNNING_PORT=${3}

	local _TMP_CP_NGX_STT_CONTAINER_DIR=${WWW_BOOT_NGX_DIR}/${1}_${3}

	mkdir -pv ${WWW_BOOT_NGX_DIR}

	echo "Copy '${__DIR}/templates/nginx/server' To '${_TMP_CP_NGX_STT_CONTAINER_DIR}'"
	cp -r ${__DIR}/templates/nginx/server ${_TMP_CP_NGX_STT_CONTAINER_DIR}
	
	if [ ! -d "${_TMP_CP_NGX_STT_RUNNING_DIR}" ]; then
		echo "Copy '${__DIR}/templates/nginx/template' To '${_TMP_CP_NGX_STT_RUNNING_DIR}'"
		cp -r ${__DIR}/templates/nginx/template ${_TMP_CP_NGX_STT_RUNNING_DIR}
	fi

	cd ${_TMP_CP_NGX_STT_CONTAINER_DIR}

	sed -i "s@\%prj_port\%@${_TMP_CP_NGX_STT_RUNNING_PORT}@g" conf/vhosts/project.conf
	sed -i "s@\%prj_name\%@${_TMP_CP_NGX_STT_NAME}@g" conf/vhosts/project.conf
	sed -i "s@\%prj_dir\%@${_TMP_CP_NGX_STT_RUNNING_DIR}@g" conf/vhosts/project.conf

	mv conf/vhosts/project.conf conf/vhosts/${_TMP_CP_NGX_STT_NAME}.conf
	bash start.sh master

    echo_soft_port ${_TMP_CP_NGX_STT_RUNNING_PORT}
    echo_startup_supervisor_config "${_TMP_CP_NGX_STT_NAME}" "${_TMP_CP_NGX_STT_CONTAINER_DIR}" "bash start.sh master" "" "99"

	return $?
}

# 生成nginx启动器
function gen_nginx_starter()
{
    local _TMP_GEN_NGX_STT_DATE=$(date +%Y%m%d%H%M%S)

    local _TMP_GEN_NGX_STT_BOOT_NAME="tmp"
    local _TMP_GEN_NGX_STT_BOOT_PORT=""
	rand_val "_TMP_GEN_NGX_STT_BOOT_PORT" 1024 2048
    
    bind_if_input "_TMP_GEN_NGX_STT_BOOT_NAME" "NGX_CONF: Please ender application name"
	set_if_empty "_TMP_GEN_NGX_STT_BOOT_NAME" "prj_${_TMP_GEN_NGX_STT_DATE}"
    
    local _TMP_GEN_NGX_STT_NGX_BOOT_PATH="${WWW_BOOT_NGX_DIR}/${_TMP_GEN_NGX_STT_BOOT_NAME}"
    bind_if_input "_TMP_GEN_NGX_STT_NGX_BOOT_PATH" "NGX_CONF: Please ender application path"
	set_if_empty "_TMP_GEN_NGX_STT_NGX_BOOT_PATH" "${WWW_BOOT_NGX_DIR}"
    
    bind_if_input "_TMP_GEN_NGX_STT_BOOT_PORT" "Please ender application port Like '8080'"
	set_if_empty "_TMP_GEN_NGX_STT_BOOT_PORT" "${_TMP_GEN_NGX_STT_NGX_CONF_PORT}"

	cp_nginx_starter "${_TMP_GEN_NGX_STT_BOOT_NAME}" "${_TMP_GEN_NGX_STT_NGX_BOOT_PATH}" "${_TMP_GEN_NGX_STT_BOOT_PORT}"
	
	# 添加系统启动命令
    echo_startup_supervisor_config "ngx_${_TMP_GEN_NGX_STT_BOOT_NAME}" "${_TMP_GEN_NGX_STT_NGX_BOOT_PATH}" "bash start.sh" "" "999"

    # 生成web授权访问脚本
    echo_web_service_init_scripts "${_TMP_GEN_NGX_STT_BOOT_NAME}${LOCAL_ID}" "${_TMP_GEN_NGX_STT_BOOT_NAME}${LOCAL_ID}.${SYS_DOMAIN}" ${_TMP_GEN_NGX_STT_BOOT_PORT} "${LOCAL_HOST}"

	return $?
}

#构建shadowsocks服务
# 参数1：构建模式（默认自检）
function proxy_by_ss()
{
	local _TMP_PROXY_BY_SS_MODE="${1}"

    #加载脚本
    source ${__DIR}/scripts/tools/shadowsocks.sh

	# 判断境外网络，决定为客户端或服务端
    echo "---------------------------------------------------------------------"
    echo "Shadowsocks: System start check your internet to switch your run mode"
    echo "---------------------------------------------------------------------"
	local _TMP_PROXY_BY_SS_IS_WANT_CROSS_FIREWALL=$(curl -I -m 10 -o /dev/null -s -w %{http_code} https://www.facebook.com)
    echo "Shadowsocks: The remote returns '${_TMP_PROXY_BY_SS_IS_WANT_CROSS_FIREWALL}'"
    echo "---------------------------------------------------------------------"

    # 选择启动模式
    # exec_if_choice "_TMP_PROXY_BY_SS_MODE" "Please choice your shadowsocks run mode on this computer" "Server,Client,Exit" "${TMP_SPLITER}" "boot_shadowsocks_"
	local _TMP_PROXY_BY_SS_MODE_NECESSARY_CHECK=""
	if [ "${_TMP_PROXY_BY_SS_IS_WANT_CROSS_FIREWALL}" == "000" ]; then
		_TMP_PROXY_BY_SS_MODE_NECESSARY_CHECK="client"
    else
        if [ ${#all_proxy} -gt 0 ]; then
			_TMP_PROXY_BY_SS_MODE_NECESSARY_CHECK="client"
        else
			_TMP_PROXY_BY_SS_MODE_NECESSARY_CHECK="server"
        fi
	fi

	if [ ${#_TMP_PROXY_BY_SS_MODE} -eq 0 ] || [ "${_TMP_PROXY_BY_SS_MODE}" == "${_TMP_PROXY_BY_SS_MODE_NECESSARY_CHECK}" ]; then
		boot_shadowsocks_${_TMP_PROXY_BY_SS_MODE_NECESSARY_CHECK}
	fi

	return $?
}

##########################################################################################################
# 变量操作类
##########################################################################################################
# 检查变量类型(单个数组函数会被判定为字符串，如下_VAR5)
# 参数1：需要判断的变量名/值
# 示例：
#       _VAR1=1 && echo_var_type "${_VAR1}" && echo_var_type "_VAR1" && echo "-> integer:integer" && echo
#       _VAR2="321" && echo_var_type "${_VAR2}" && echo_var_type "_VAR2" && echo "-> integer:integer" && echo
#       _VAR3="a1234" && echo_var_type "${_VAR3}" && echo_var_type "_VAR3" && echo "-> string:string" && echo
#       _VAR4="epel-release" && echo_var_type "${_VAR4}" && echo_var_type "_VAR4" && echo "-> string:string" && echo
#       _VAR5="str space str" && echo_var_type "${_VAR5}" && echo_var_type "_VAR5" && echo "-> string:string" && echo
#       _VAR6="" && echo_var_type "${_VAR6}" && echo_var_type "_VAR6" && echo "-> nil:nil" && echo
#       _VAR7=(1 2 3) && echo_var_type "${_VAR7[*]}" && echo_var_type "_VAR7" && echo "-> string:array" && echo
#       _VAR8=(abc) && echo_var_type "${_VAR8[*]}" && echo_var_type "_VAR8" && echo "-> string:array" && echo
#       _VAR9=() && echo_var_type "${_VAR9[*]}" && echo_var_type "_VAR9" && echo "-> nil:array" && echo
#       _VAR10=(a123 b321) && echo_var_type "${_VAR10[*]}" && echo_var_type "_VAR10" && echo "-> string:array" && echo
#       _VAR11=($(ls -l /tmp/ | awk -F' ' '{print $9}' | awk '$1=$1')) && echo_var_type "${_VAR11[*]}" && echo_var_type "_VAR11" && echo "-> string:array" && echo
#       _VAR12="$(ls -l /tmp/ | awk -F' ' '{print $9}' | awk '$1=$1')" && echo_var_type "${_VAR12[*]}" && echo_var_type "_VAR12" && echo "-> string:string" && echo
function echo_var_type() {
	if [ $(echo "${1}" | wc -l) -gt 1 ]; then
		echo "string"
		return $?
	fi

	local _TMP_ECHO_VAR_TYPE_VAR_PAIR=()
	bind_discern_exchange_var_pair "_TMP_ECHO_VAR_TYPE_VAR_PAIR" "${1}"
	local _TMP_ECHO_VAR_TYPE_CHECK_VAR_NAME=${_TMP_ECHO_VAR_TYPE_VAR_PAIR[0]}
	local _TMP_ECHO_VAR_TYPE_CHECK_VAR_VAL=${_TMP_ECHO_VAR_TYPE_VAR_PAIR[1]}

	local _TMP_ECHO_VAR_TYPE_CHECK_VAR_DECLARE=$(declare -p ${_TMP_ECHO_VAR_TYPE_CHECK_VAR_NAME} 2>/dev/null)
	local _TMP_ECHO_VAR_TYPE_CHECK_VAR_REGEX='^declare -n [^=]+=\"([^\"]+)\"$'
	while [[ $_TMP_ECHO_VAR_TYPE_CHECK_VAR_DECLARE =~ ${_TMP_ECHO_VAR_TYPE_CHECK_VAR_REGEX} ]]; do
		_TMP_ECHO_VAR_TYPE_CHECK_VAR_DECLARE=$(declare -p ${BASH_REMATCH[1]})
	done

	case "${_TMP_ECHO_VAR_TYPE_CHECK_VAR_DECLARE#declare -}" in
	a*)
		echo "array"
		return $?
		;;
	A*)
		echo "hash"
		return $?
		;;
	i*)
		echo "int"
		return $?
		;;
	x*)
		echo "export"
		return $?
		;;
	*)
		# echo "OTHER"
		;;
	esac

	[ -z "${_TMP_ECHO_VAR_TYPE_CHECK_VAR_VAL}" ] && echo "nil" && return $?
	# [[ "${_TMP_ECHO_VAR_TYPE_VAR_ARR_VAL}" =~ ${_TMP_ECHO_VAR_TYPE_CHECK_VAR_VAL} ]] && [[ "${_TMP_ECHO_VAR_TYPE_CHECK_VAR_VAL}" != "${_TMP_ECHO_VAR_TYPE_VAR_ARR_VAL}" ]] && [[ ${_TMP_ECHO_VAR_TYPE_VAR_ARR_LEN} -ne ${#_TMP_ECHO_VAR_TYPE_CHECK_VAR_VAL} ]] && echo "array" && return $?
	printf "%d" "${_TMP_ECHO_VAR_TYPE_CHECK_VAR_VAL}" &>/dev/null && echo "integer" && return $?
	printf "%d" "$(echo ${_TMP_ECHO_VAR_TYPE_CHECK_VAR_VAL}|sed 's/^[+-]\?0\+//')" &>/dev/null && echo "integer" && return
	printf "%d" "$(echo ${_TMP_ECHO_VAR_TYPE_CHECK_VAR_VAL} | sed 's/^[+-]\?0\+//')" &>/dev/null && echo "integer" && return $?
	printf "%f" "${_TMP_ECHO_VAR_TYPE_CHECK_VAR_VAL}" &>/dev/null && echo "number" && return $?
	[ ${#_TMP_ECHO_VAR_TYPE_CHECK_VAR_VAL} -eq 1 ] && echo "char" && return $?
	echo "string" && return $?
	
	return $?
}

# 设置变量值函数如果为空
# 参数1：需要设置/判断的变量名
# 参数2：需要设置的变量值
# 示例：
#       _VAR= && set_if_empty "_VAR" "1"
function set_if_empty()
{
	function _set_if_empty()
	{
		local _TMP_SET_IF_EMPTY_VAR_VAL=$(eval echo '${'"${1}"'}')
		if [ -z "${_TMP_SET_IF_EMPTY_VAR_VAL}" ] && [ -n "${2}" ]; then
			eval ${1}='${2}'
		fi
	}

	discern_exchange_var_action "${1}" "_set_if_empty" "${@}"
	return $?
}

# 设置变量值函数如果相同
# 参数1：相同时，设置的变量的 名/值
# 参数2：需要对比的原始变量名1
# 参数3：需要对比的原始变量名2/值2
# 示例：
#       _BIND_HOST= && set_if_equals "_BIND_HOST" "127.0.0.1" "192.168.0.1" && echo "${_BIND_HOST}"
#       _BIND_HOST= && _COMPARE_HOST="192.168.0.1" && set_if_equals "_BIND_HOST" "_COMPARE_HOST" "192.168.0.1" && echo "${_BIND_HOST}"
#       _BIND_HOST="127.0.0.1" && _COMPARE_HOST="192.168.0.1" && set_if_equals "_BIND_HOST" "_COMPARE_HOST" "LOCAL_HOST" && echo "${_BIND_HOST}"
function set_if_equals()
{
	local _TMP_SET_IF_EQS_COMPARE_VAR_NAME=$(echo_discern_exchange_var_name "${1}")

	function _set_if_equals()
	{
		eval ${_TMP_SET_IF_EQS_COMPARE_VAR_NAME}='${1}'
		return $?
	}

	equals_action "${2}" "${3}" "_set_if_equals"
	return $?
}

# 执行指定函数如果变量对比相同
# 参数1：需要对比的原始变量名1
# 参数2：需要对比的原始变量名2/值2
# 参数3：相同时，执行的变量的 名/值
# 示例：
#       equals_action "127.0.0.1" "192.168.0.1" "echo 1"
function equals_action()
{
	local _TMP_ACTION_IF_EQS_SOURCE_VAR_VAL=$(echo_discern_exchange_var_val "${1}")
	local _TMP_ACTION_IF_EQS_COMPARE_VAR_VAL=$(echo_discern_exchange_var_val "${2}")

	if [ "${_TMP_ACTION_IF_EQS_SOURCE_VAR_VAL}" == "${_TMP_ACTION_IF_EQS_COMPARE_VAR_VAL}" ]; then
		script_check_action "${3}" "${_TMP_ACTION_IF_EQS_SOURCE_VAR_VAL}"
		return $?
	fi

	return $?
}

# 识别并返回变量的KV值（V值始终作为数组字符串返回）!!!超出引用数组范围外，变量会失效 ??? 传递空数组时，会变成变量名。有地方被引用
# 参数1：需要绑定到的变量名
# 参数2：需要识别的变量名/值
# 示例：
#      bind_discern_exchange_var_pair "_PAIR1" 123 && echo ${_PAIR1[*]}
#      _VAR=123 && bind_discern_exchange_var_pair "_PAIR2" "_VAR" && echo ${_PAIR2[*]}
#      bind_discern_exchange_var_pair "_PAIR3" "abc" && echo ${_PAIR3[*]}
#      _VAR="abc" && bind_discern_exchange_var_pair "_PAIR4" "_VAR" && echo ${_PAIR4[*]}
function bind_discern_exchange_var_pair() {
	# 变量名
	local _TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_NAME="${2}"
	# 默认当作值处理
	local _TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_VAL="${2}"

	# 匿名变量绑定
	function bind_discern_exchange_var_pair_bind_anymouse()
	{
		_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_NAME="_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_EXCHANGE_VAL_$(cat /proc/sys/kernel/random/uuid | sed 's@-@_@g')"

		# 预先转变变量赋值
		eval ${_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_NAME}='${_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_VAL}'
	}

	# 必须满足变量定义规范
	if [ -n "$(echo "${2}" | egrep '^\w+$')" ]; then
		# 排除数字开始
		if [ -z "$(echo "${2}" | egrep '^[0-9]+')" ]; then
			# 数组输出：declare -a _ARR='()'
			# 字符串输出：declare -- _ARR_STR="/mountdisk /data"
			# 未定义输出：-bash: declare: _ARR: 未找到
			local _TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_DECLARE="$(declare -p ${2} 2>/dev/null)"
			if [[ "${_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_DECLARE}" =~ "declare -a" ]]; then
				_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_VAL=$(eval echo '${'"${2}[@]"'}')
			elif [[ "${_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_DECLARE}" =~ "declare --" || "${_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_DECLARE}" =~ "declare -l" ]]; then
				_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_VAL=$(eval echo '${'"${2}"'}')
			else
				# 判断是否是数组定义，非0则被定义了别的变量或（不是有效标识符/不是数组变量）
				# eval "unset ${2}[0]" >& /dev/null && [ $? -eq 0 ]
					# 多行的情况 或 判断是否是其它变量定义
					# 参考：https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
				local _TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_ELSE_DEFINE=$(eval echo '${'"${2}"+x'}' 2>/dev/null)
				if [ $(echo "${2}" | wc -l) -gt 1 ] || [ -z "${_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_ELSE_DEFINE}" ]; then
					# 未定义变量则使用变量本身
					_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_VAL=${2}
				fi

				bind_discern_exchange_var_pair_bind_anymouse
			fi
		else
			bind_discern_exchange_var_pair_bind_anymouse
		fi
	else
		# 值里包含空格，铁定不是变量
		# if [ $( echo "${2}" | grep -o "[[:space:]]" | wc -l) -gt 0 ]; then
			bind_discern_exchange_var_pair_bind_anymouse
		# fi
	fi

	eval ${1}='("${_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_NAME}" "${_TMP_BIND_DISCERN_EXCHANGE_VAR_PAIR_VAR_VAL}")'

	return $?
}

# 识别并返回变量的KTV值（数组字符串）!!!超出引用数组范围外，变量会失效
# 参数1：需要绑定到的变量名
# 参数2：需要识别的变量名/值
# 示例：
#      bind_discern_exchange_var_arr "_PAIR" 123 && echo ${_PAIR[*]}
#      _VAR=123 && bind_discern_exchange_var_arr "_PAIR" "_VAR" && echo ${_PAIR[*]}
#      bind_discern_exchange_var_arr "_PAIR" "abc" && echo ${_PAIR[*]}
#      _VAR="abc" && bind_discern_exchange_var_arr "_PAIR" "_VAR" && echo ${_PAIR[*]}
function bind_discern_exchange_var_arr() {
	local _TMP_BIND_DISCERN_EXCHANGE_VAR_ARR_PAIR_ARR=()
	bind_discern_exchange_var_pair "_TMP_BIND_DISCERN_EXCHANGE_VAR_ARR_PAIR_ARR" "${2}"
	local _TMP_BIND_DISCERN_EXCHANGE_VAR_ARR_VAR_NAME="${_TMP_BIND_DISCERN_EXCHANGE_VAR_ARR_PAIR_ARR[0]}"
	local _TMP_BIND_DISCERN_EXCHANGE_VAR_ARR_VAR_VAL=${_TMP_BIND_DISCERN_EXCHANGE_VAR_ARR_PAIR_ARR[1]}

	local _TMP_BIND_DISCERN_EXCHANGE_VAR_ARR_VAR_TYPE=$(echo_var_type "${2}")
	
	eval ${1}='("${_TMP_BIND_DISCERN_EXCHANGE_VAR_ARR_VAR_NAME}" "${_TMP_BIND_DISCERN_EXCHANGE_VAR_ARR_VAR_TYPE}" "${_TMP_BIND_DISCERN_EXCHANGE_VAR_ARR_VAR_VAL}")'

	return $?
}

# 识别并交换var值
# 参数1：需要识别的变量名/值
# 参数2：识别后执行函数
# 参数3-N：动态传参
# 示例：
#      discern_exchange_var_action 123
#      _VAR=123 && discern_exchange_var_action "_VAR" "_child_func"
#      discern_exchange_var_action "abc"
#      _VAR="abc" && discern_exchange_var_action "_VAR"
#      discern_exchange_var_action "${1}" "_child_func" "${@}"
function discern_exchange_var_action() {
	# 使用该方式，匿名变量名会读取失效。
	# local _TMP_DISCERN_EXCHANGE_VAR_ACTION_VAR_NAME="$(echo_discern_exchange_var_name "${1}")"
	local _TMP_DISCERN_EXCHANGE_VAR_ACTION_PAIR_ARR=()
	bind_discern_exchange_var_pair "_TMP_DISCERN_EXCHANGE_VAR_ACTION_PAIR_ARR" "${1}"
	local _TMP_DISCERN_EXCHANGE_VAR_ACTION_VAR_NAME=${_TMP_DISCERN_EXCHANGE_VAR_ACTION_PAIR_ARR[0]}

	local _TMP_DISCERN_EXCHANGE_VAR_ACTION_PARAMS=("${@:4}")

	if [ -n "${2}" ]; then
		# 传参必须用[@]
		${2} "${_TMP_DISCERN_EXCHANGE_VAR_ACTION_VAR_NAME}" "${_TMP_DISCERN_EXCHANGE_VAR_ACTION_PARAMS[@]}"
		return $?
	fi

	return $?
}

# 识别输出提交的变量名
# 参数1：需要识别的变量名、变量值
# 示例：
#      echo_discern_exchange_var_name 123
#      _VAR=123 && echo_discern_exchange_var_name "_VAR"
#      echo_discern_exchange_var_name "abc"
#      _VAR="abc" && echo_discern_exchange_var_name "_VAR"
#      echo_discern_exchange_var_name "abc"
function echo_discern_exchange_var_name() {
	local _TMP_ECHO_DISCERN_EXCHANGE_VAR_NAME_PAIR_ARR=()
	bind_discern_exchange_var_pair "_TMP_ECHO_DISCERN_EXCHANGE_VAR_NAME_PAIR_ARR" "${1}"
	echo "${_TMP_ECHO_DISCERN_EXCHANGE_VAR_NAME_PAIR_ARR[0]}"

	return $?
}

# 识别输出提交的变量实际值
# 参数1：需要识别的变量名、变量值
# 示例：
#      echo_discern_exchange_var_val 123
#      _VAR=123 && echo_discern_exchange_var_val "_VAR"
#      echo_discern_exchange_var_val "abc"
#      _VAR="abc" && echo_discern_exchange_var_val "_VAR"
#      echo_discern_exchange_var_val "abc"
function echo_discern_exchange_var_val() {
	
	local _TMP_ECHO_DISCERN_EXCHANGE_VAR_VAL_PAIR_ARR=()
	bind_discern_exchange_var_pair "_TMP_ECHO_DISCERN_EXCHANGE_VAR_VAL_PAIR_ARR" "${1}"
	echo "${_TMP_ECHO_DISCERN_EXCHANGE_VAR_VAL_PAIR_ARR[1]}"

	return $?
}

# 绑定交换YN项(Yy,YESyes,TRUE,true)，意图取反获得统一YN值
# 参数1：需要设置的变量名，自带YN值
function bind_exchange_yn_val()
{
	function _bind_exchange_yn_val()
	{
		local _TMP_BIND_EXCHANGE_YN_VAL_VAR_VAL=$(eval echo '${'"${1}"'}')
		
		typeset -u _TMP_BIND_EXCHANGE_YN_VAL_VAR_VAL

		case ${_TMP_BIND_EXCHANGE_YN_VAL_VAR_VAL} in
			"Y")
				_TMP_BIND_EXCHANGE_YN_VAL_VAR_VAL="N"
			;;
			"YES")
				_TMP_BIND_EXCHANGE_YN_VAL_VAR_VAL="N"
			;;
			"TRUE")
				_TMP_BIND_EXCHANGE_YN_VAL_VAR_VAL="N"
			;;
			*)
				_TMP_BIND_EXCHANGE_YN_VAL_VAR_VAL="Y"
		esac

		eval ${1}='${_TMP_BIND_EXCHANGE_YN_VAL_VAR_VAL}'
	}

	discern_exchange_var_action "${1}" "_bind_exchange_yn_val" "${@}"
	return $?
}

##########################################################################################################
# 数字操作类
##########################################################################################################
# 随机数
# 参数1：需要设置的变量名
# 参数2：最小值
# 参数3：最大值
# 示例：
#       rand_val "_RAND_NUM" 1000 2000
function rand_val() {
	function _rand_val()
	{
		local _TMP_RAND_VAL_MIN=${2}
		local _TMP_RAND_VAL_MID=$((${3}-${_TMP_RAND_VAL_MIN}+1))  
		# local _TMP_RAND_VAL_CURR=$(cat /proc/sys/kernel/random/uuid | cksum | awk -F ' ' '{print $1}')

		# eval ${1}=$((${_TMP_RAND_VAL_CURR}%${_TMP_RAND_VAL_MID}+${_TMP_RAND_VAL_MIN}))
		eval ${1}=$(shuf -i ${2}-${3} -n 1)
	}

	discern_exchange_var_action "${1}" "_rand_val" "${@}"
	return $?
}

##########################################################################################################
# 字符串操作类
##########################################################################################################
# 随机数
# 参数1：需要设置的变量名
# 参数2：指定长度
# 示例：
#       rand_str "_RAND_STR" 32
function rand_str() {
	function _rand_str()
	{
		local _TMP_RAND_STR_LEN_VAL=${2} 
		# random-string()
		# {
		# 	cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
		# }
		# $(random-string 32)
		local _TMP_RAND_STR_FINAL_VAL=$(cat /dev/urandom | head -n ${_TMP_RAND_STR_LEN_VAL} | md5sum | head -c ${_TMP_RAND_STR_LEN_VAL})

		eval ${1}='${_TMP_RAND_STR_FINAL_VAL}'
	}

	discern_exchange_var_action "${1}" "_rand_str" "${@}"
	return $?
}

# 清除首尾字符
# 参数1：需要存储清除后数据的变量名
# 参数2：指定清除的字符串，默认空
# 示例：
#       trim_str " abc "
#       trim_str "|abc|" "|"
function trim_str() {
	function _trim_str()
	{
		local _TMP_TRIM_STR_VAR_NAME="${1}"
		local _TMP_TRIM_STR_VAR_VAL=$(eval echo '${'"${1}"'}')
		local _TMP_TRIM_STR_CHAR=${2:-"[:space:]"}
		
		: "${_TMP_TRIM_STR_VAR_VAL#"${_TMP_TRIM_STR_VAR_VAL%%[!${_TMP_TRIM_STR_CHAR}]*}"}" 
		: "${_%"${_##*[!${_TMP_TRIM_STR_CHAR}]}"}"
		
		eval ${1}='$_'
	}

	discern_exchange_var_action "${1}" "_trim_str" "${@}"
	return $?
}

# 生成密码
# 参数1：软件名称
# 参数2：软件类型
# 参数3：安装节点或版本
# 示例：
#       rand_passwd "docker"
#       rand_passwd "docker" "svr"
function rand_passwd() {
	typeset -l _TMP_RAND_PASSWD_SOFT_NAME
	local _TMP_RAND_PASSWD_SOFT_NAME="${1}"

	typeset -u _TMP_RAND_PASSWD_SOFT_TYPE
	local _TMP_RAND_PASSWD_SOFT_TYPE="${2}"

	echo "${_TMP_RAND_PASSWD_SOFT_NAME}-${_TMP_RAND_PASSWD_SOFT_TYPE}!m${LOCAL_ID}.${3:-0}~"

	return $?
}

# 生成密码
# 参数1：软件名称
# 参数2：软件类型
# 参数3：安装节点或版本
# 示例：
#       rand_simple_passwd "docker"
#       rand_simple_passwd "docker" "svr"
function rand_simple_passwd() {
	typeset -l _TMP_RAND_PASSWD_SOFT_NAME
	local _TMP_RAND_PASSWD_SOFT_NAME="${1}"

	typeset -u _TMP_RAND_PASSWD_SOFT_TYPE
	local _TMP_RAND_PASSWD_SOFT_TYPE="${2}"

	echo "${_TMP_RAND_PASSWD_SOFT_NAME}${_TMP_RAND_PASSWD_SOFT_TYPE}m${LOCAL_ID}${3:-0}"

	return $?
}

# URL编码
# 参数1：需要编码的字符串
function echo_url_encode() {
	local _TMP_URL_ENCODE_STR="${#1}"
	local _TMP_URL_ENCODE_INDEX=0
	while :
	do
		[ ${_TMP_URL_ENCODE_STR} -gt ${_TMP_URL_ENCODE_INDEX} ] && {
			local _TMP_URL_ENCODE_CHR="${1:${_TMP_URL_ENCODE_INDEX}:1}"
			case ${_TMP_URL_ENCODE_CHR} in [a-zA-Z0-9.~_-]) 
				printf "${_TMP_URL_ENCODE_CHR}" ;;
			*) 
				printf '%%%02X' "'${_TMP_URL_ENCODE_CHR}" ;; 
			esac
		} || break
		let _TMP_URL_ENCODE_INDEX++
	done
}

# URL解码
# 参数2：需要解码的字符串
function echo_url_decode(){
	local _TMP_URL_DECODE_STR="${1//+/ }"
	echo -e "${_TMP_URL_DECODE_STR//%/\\x}"
}

# 修改JSON参数单项并输出
# 参数1：JSON内容变量名
# 参数2：修改的参数节点，例 .Config.WorkingDir
# 参数3：修改的参数节点内容，例 "/usr/src/app"
function change_json_node_item()
{
	function _change_json_node_item()
	{
		local _TMP_CHANGE_JSON_ARG_ITEM_VAR_VAL=$(eval echo '${'"${1}"'}')

		_TMP_CHANGE_JSON_ARG_ITEM_VAR_VAL=$(echo "${_TMP_CHANGE_JSON_ARG_ITEM_VAR_VAL}" | jq "${2}=${3}")
		
		eval ${1}='${_TMP_CHANGE_JSON_ARG_ITEM_VAR_VAL}'
	}

	discern_exchange_var_action "${1}" "_change_json_node_item" "${@}"
    return $?
}

# 修改JSON参数数组并输出
# 参数1：JSON内容变量名
# 参数2：修改的参数节点，例如 .Config.Env
# 参数3：内容项匹配规则，例如 ^${2}=.*$
# 参数4：内容项目最终修改值
function change_json_node_arr()
{
	function _change_json_node_arr()
	{
		local _TMP_CHANGE_JSON_ARG_ARR_VAR_VAL=$(eval echo '${'"${1}"'}')

		local _TMP_CHANGE_JSON_ARG_ARR_CHANGE_ARR=($(echo "${_TMP_CHANGE_JSON_ARG_ARR_VAR_VAL}" | jq "${2}" | grep -oP "(?<=^  \").*(?=\",*$)"))

		local _TMP_CHANGE_JSON_ARG_ARR_REG="${2}"
		local _TMP_CHANGE_JSON_ARG_ARR_REG_ITEM="${3}"
		local _TMP_CHANGE_JSON_ARG_ARR_CHANGE_VAL="${4}"
		function _change_json_node_arr_change()
		{
			_TMP_CHANGE_JSON_ARG_ARR_VAR_VAL=$(echo "${_TMP_CHANGE_JSON_ARG_ARR_VAR_VAL}" | jq "${_TMP_CHANGE_JSON_ARG_ARR_REG}[${2}]=${_TMP_CHANGE_JSON_ARG_ARR_CHANGE_VAL}")
		}

		item_check_action "${_TMP_CHANGE_JSON_ARG_ARR_REG_ITEM}" "${_TMP_CHANGE_JSON_ARG_ARR_CHANGE_ARR[*]}" "_change_json_node_arr_change"
			
		eval ${1}='${_TMP_CHANGE_JSON_ARG_ARR_VAR_VAL}'
	}

	discern_exchange_var_action "${1}" "_change_json_node_arr" "${@}"
    return $?
}

# 注释yaml文件节点内容（由于yq本身不支持，所以手动实现）
# 参数1：YAML文件路径变量名/值
# 参数2：注释的节点，例 .https
# 示例：
#       comment_yaml_file_node_item "harbor/harbor.yml" ".https"
function comment_yaml_file_node_item()
{
	local _TMP_COMMENT_YAML_NODE_ITEM_FILE_PATH=$(echo_discern_exchange_var_val "${1}")

	# 预先统一格式，不然输出格式会存在问题
	(cat ${_TMP_COMMENT_YAML_NODE_ITEM_FILE_PATH} | yq) > ${_TMP_COMMENT_YAML_NODE_ITEM_FILE_PATH}.temp
	local _TMP_COMMENT_YAML_NODE_ITEM_DIFF_VAL=$(diff -e <(yq "del(${2})" ${_TMP_COMMENT_YAML_NODE_ITEM_FILE_PATH}.temp) ${_TMP_COMMENT_YAML_NODE_ITEM_FILE_PATH}.temp)

	if [ -n "${_TMP_COMMENT_YAML_NODE_ITEM_DIFF_VAL}" ]; then
		# 删除节点
		yq -i "del(${2})" ${_TMP_COMMENT_YAML_NODE_ITEM_FILE_PATH}.temp

		local _TMP_COMMENT_YAML_NODE_ITEM_LINE=$(echo "${_TMP_COMMENT_YAML_NODE_ITEM_DIFF_VAL}" | awk 'NR==1')
		local _TMP_COMMENT_YAML_NODE_ITEM_LINE_NUM=$(echo "${_TMP_COMMENT_YAML_NODE_ITEM_LINE}" | egrep -o '^[0-9]+')
		local _TMP_COMMENT_YAML_NODE_ITEM_LINE_ATTR=$(echo "${_TMP_COMMENT_YAML_NODE_ITEM_LINE}" | grep -oP "(?<=^${_TMP_COMMENT_YAML_NODE_ITEM_LINE_NUM})\w+")

		# 逐行插入注释后的节点
		function _comment_yaml_file_node_item_append()
		{
			sed -i "${_TMP_COMMENT_YAML_NODE_ITEM_LINE_NUM}${_TMP_COMMENT_YAML_NODE_ITEM_LINE_ATTR:-a} ${1}" ${_TMP_COMMENT_YAML_NODE_ITEM_FILE_PATH}.temp

			# 行号后移
			_TMP_COMMENT_YAML_NODE_ITEM_LINE_NUM=$((${_TMP_COMMENT_YAML_NODE_ITEM_LINE_NUM}+1))
		}
		
		# 忽略空行，最后一行
		echo "${_TMP_COMMENT_YAML_NODE_ITEM_DIFF_VAL}" | awk 'NR>1{if(line!=""){print line}{line="#"$0}}' | eval "script_channel_action '_comment_yaml_file_node_item_append'"

		# 还原文件
		cat ${_TMP_COMMENT_YAML_NODE_ITEM_FILE_PATH}.temp > ${_TMP_COMMENT_YAML_NODE_ITEM_FILE_PATH}
		rm -rf ${_TMP_COMMENT_YAML_NODE_ITEM_FILE_PATH}.temp
	fi
	
    return $?
}

# 传入卷信息，分多卷与单点
# 参数1：yml内容变量名/值
# 参数2：要读取的节点信息 例 .services.core.volumes[0]/.services.core.volumes.[]
function echo_yaml_formal_volumes()
{
	local _TMP_ECHO_YML_FORMAL_VOLS_YML_VAR_VAL=$(echo_discern_exchange_var_val "${1}")
	local _TMP_ECHO_YML_FORMAL_VOLS_PATH_VAR_VAL=$(echo_discern_exchange_var_val "${2}")

	function _echo_yaml_formal_volumes() {
		if [ "${1}" != "null" ]; then
			# 匹配节点模型，始终包含(type source dest)
			if [[ $(echo "${1}" | wc -l) -eq 1 ]]; then
				# 匹配KV模型
				echo "${1}"
			else
				local _TMP_ECHO_YML_FORMAL_VOLS_VOL_MODE=$(echo "${1}" | yq '.mode')
				if [[ "${_TMP_ECHO_YML_FORMAL_VOLS_VOL_MODE}" == "null" || -z "${_TMP_ECHO_YML_FORMAL_VOLS_VOL_MODE}" ]]; then
					echo "${1}" | yq '.source + ":" + .target'
				else
					echo "${1}" | yq '.source + ":" + .target + ":" + .mode'
				fi
			fi
		fi
	}
	
	yaml_split_action "$(echo "${_TMP_ECHO_YML_FORMAL_VOLS_YML_VAR_VAL}" | yq "${_TMP_ECHO_YML_FORMAL_VOLS_PATH_VAR_VAL}")" "_echo_yaml_formal_volumes"	
	return $?
}

# 执行文本格式化
# 参数1：需要格式化的变量名
# 参数2：格式化字符串规格
# 示例：
#	TMP_TEST_STYLED_TEXT="[Hello] world"
#	bind_style_text "TMP_TEST_STYLED_TEXT" "red"
#	echo "The styled text is ‘$TMP_TEST_STYLED_TEXT’"
function bind_style_text()
{
	function _bind_style_text()
	{
		local _TMP_BIND_STYLE_TEXT_VAR_STYLE=${2} #${2:-"${red}"}
		# local _TMP_BIND_STYLE_TEXT_VAR_VAL=$(eval echo '${'${_TMP_BIND_STYLE_TEXT_VAR_NAME}'/ /}')
		local _TMP_BIND_STYLE_TEXT_VAR_VAL=$(eval echo '${'"${1}"'}')

		function _TMP_BIND_STYLE_TEXT_WRAP_FUNC() {
			local _TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_LEFT=${1}
			local _TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_RIGHT=${1}
			local _TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_ESCAPE='\'
			local _TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_STYLE="${_TMP_BIND_STYLE_TEXT_VAR_STYLE}"

			function _TMP_BIND_STYLE_TEXT_NORMAL_FUNC() {
				if [ -z "$(echo ${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_STYLE} | grep -vE '[0-9]+')" ]; then
					_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_STYLE=""
				fi

				_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM="${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_STYLE:-"${green}"}${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM}${reset}"

				return $?
			}
			
			function _TMP_BIND_STYLE_TEXT_GUM_FUNC() {
				# Gum模式存在默认样式，普通模式不存在
				# 加个空格，不然不识别--，会与自身命令冲突
				if [[ "${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM}" =~ ^- ]]; then
					_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM=" ${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM}"
				fi
				_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM=$(gum style --foreground ${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_STYLE:-"${GUM_INPUT_PROMPT_FOREGROUND}"} "${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM}")
				if [[ "${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM}" =~ ^- ]]; then
					local _TMP_BIND_STYLE_TEXT_MATCH_STYLE_PREFIX_ITEM=$(echo "${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM}" | awk '{print $1}')
					local _TMP_BIND_STYLE_TEXT_MATCH_STYLE_NONE_PREFIX_ITEM=$(echo "${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM}" | awk '{$1="\b";print $0}')
					_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM="${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_PREFIX_ITEM}${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_NONE_PREFIX_ITEM}"
				fi

				return $?
			}

			case ${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_LEFT} in
			'[')
				# 加入转义符
				_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_LEFT='['
				_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_RIGHT=']'
				# 紫红
				_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_STYLE=${_TMP_BIND_STYLE_TEXT_VAR_STYLE:-"200"}
			;;
			# '{')
			# 	_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_LEFT='{'
			# 	_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_RIGHT='}'
			# ;;
			'<')
				_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_LEFT='<'
				_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_RIGHT='>'
				_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_ESCAPE=''
				# 土黄
				_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_STYLE=${_TMP_BIND_STYLE_TEXT_VAR_STYLE:-"220"}
			;;
			'"')
				_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_RIGHT='"'
				_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_STYLE=${_TMP_BIND_STYLE_TEXT_VAR_STYLE:-"230"}
			;;
			*)
				_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_ESCAPE=''
			esac

			local _TMP_BIND_STYLE_TEXT_WRAP_FUNC_SAVEIFS=$IFS   # Save current IFS
			IFS=$'\n'      # Change IFS to new line

			local _TMP_BIND_STYLE_TEXT_WRAP_FUNC_ITEM_LEFT="${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_ESCAPE}${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_LEFT}"
			local _TMP_BIND_STYLE_TEXT_WRAP_FUNC_ITEM_RIGHT="${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_ESCAPE}${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_RIGHT}"
			local _TMP_BIND_STYLE_TEXT_WRAP_FUNC_ITEM_REGEX="${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_ITEM_LEFT}[^${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_ITEM_LEFT}]+${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_ITEM_RIGHT}"
			# local _TMP_BIND_STYLE_TEXT_MATCH_PREFIX=$(echo "${_TMP_BIND_STYLE_TEXT_VAR_VAL}" | egrep -o '^\[[^]]+\]')
			# wrap类型 [] <>
			local _TMP_BIND_STYLE_TEXT_MATCH_ITEM_ARR=($(echo "${_TMP_BIND_STYLE_TEXT_VAR_VAL}" | egrep -o "${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_ITEM_REGEX}"))
			for _TMP_BIND_STYLE_TEXT_MATCH_ITEM in ${_TMP_BIND_STYLE_TEXT_MATCH_ITEM_ARR[@]}; do
				local _TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM="${_TMP_BIND_STYLE_TEXT_MATCH_ITEM}"
				if [ -n "${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM}" ]; then
					# 清除第一个]及其左边字符串
					# echo "${A/\[reset_os\]/}" 
					trim_str "_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM" "${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_ITEM_LEFT}"
					if [ "${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_LEFT}" != "${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_CHAR_RIGHT}" ]; then
						trim_str "_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM" "${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_ITEM_RIGHT}"
					fi
					
					local _TMP_BIND_STYLE_TEXT_MATCH_TRIMED_ITEM="${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_ITEM_LEFT}${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM}${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_ITEM_RIGHT}"
					path_exists_yn_action "${GUM_PATH}" "_TMP_BIND_STYLE_TEXT_GUM_FUNC" "_TMP_BIND_STYLE_TEXT_NORMAL_FUNC"	

					_TMP_BIND_STYLE_TEXT_VAR_VAL=$(echo ${_TMP_BIND_STYLE_TEXT_VAR_VAL/${_TMP_BIND_STYLE_TEXT_MATCH_TRIMED_ITEM}/${_TMP_BIND_STYLE_TEXT_MATCH_STYLE_ITEM}})
				fi
			done

			IFS=${_TMP_BIND_STYLE_TEXT_WRAP_FUNC_SAVEIFS}   # Restore IFS

			return $?
		}

		# 自动样式化消息
		_TMP_BIND_STYLE_TEXT_WRAP_FUNC "["
		_TMP_BIND_STYLE_TEXT_WRAP_FUNC "<"
		_TMP_BIND_STYLE_TEXT_WRAP_FUNC "'"
		_TMP_BIND_STYLE_TEXT_WRAP_FUNC '"'
		# _TMP_BIND_STYLE_TEXT_WRAP_FUNC "{"

		eval ${1}='${_TMP_BIND_STYLE_TEXT_VAR_VAL}'
	}

	discern_exchange_var_action "${1}" "_bind_style_text" "${@}"
	return $?
}

# 输出文本格式化
# 参数1：需要格式化的变量名/值
# 参数2：格式化字符串规格，指定颜色
# 示例：
#	TMP_ECHO_TEXT_STYLED_TEXT="[Hello] 'World'"
#	echo_style_text "TMP_ECHO_TEXT_STYLED_TEXT"
function echo_style_text() {
	local _TMP_ECHO_STYLE_TEXT_VAL=$(echo_discern_exchange_var_val "${1}")
	bind_style_text "_TMP_ECHO_STYLE_TEXT_VAL" "${2}"
	echo ${_TMP_ECHO_STYLE_TEXT_VAL}
	
	return $?
}

# 输出文本格式化，包裹
# 参数1：需要格式化的变量名/值
# 参数2：格式化字符串规格，指定颜色
# 参数3：输出包裹字符，默认-
# 示例：
#	    echo_style_wrap_text "[Hello] 'World'"
function echo_style_wrap_text() {
	local _TMP_EXEC_TEXT_WRAP_STYLE_VAL="'|'$(echo_discern_exchange_var_val "${1}")'|'"
	local _TMP_EXEC_TEXT_WRAP_STYLE_SPLITER=""

	local _TMP_EXEC_TEXT_WRAP_STYLE_START_SPECIAL_CHAR_COUNT=$(echo "${_TMP_EXEC_TEXT_WRAP_STYLE_VAL}" | grep -oE "]|[\\\"\'\<\>\[]" | wc -l)
	fill_right "_TMP_EXEC_TEXT_WRAP_STYLE_SPLITER" "${3:--}" $((${#_TMP_EXEC_TEXT_WRAP_STYLE_VAL}-${_TMP_EXEC_TEXT_WRAP_STYLE_START_SPECIAL_CHAR_COUNT}-2))

	echo_style_text "'+${_TMP_EXEC_TEXT_WRAP_STYLE_SPLITER}+'"
	bind_style_text "_TMP_EXEC_TEXT_WRAP_STYLE_VAL" "${2}"
	echo "${_TMP_EXEC_TEXT_WRAP_STYLE_VAL}"
	echo_style_text "'+${_TMP_EXEC_TEXT_WRAP_STYLE_SPLITER}+'"
	
	return $?
}

# 执行文本格式化(仅支持单参数，匹配一个变量内的多个%)
# 参数1：需要格式化的变量名/值
# 参数2：格式化字符串模板变量名/值
# 示例：
#	    TMP_TEST_FORMATED_TEXT="World"
#	    exec_text_printf "TMP_TEST_FORMATED_TEXT" "Hello %s，%s"
#	    echo "The formated text is ‘$TMP_TEST_FORMATED_TEXT’"
function exec_text_printf()
{
	local _TMP_EXEC_TEXT_PRINTF_VAR_PAIR=()
	bind_discern_exchange_var_pair "_TMP_EXEC_TEXT_PRINTF_VAR_PAIR" "${1}"
	local _TMP_EXEC_TEXT_PRINTF_VAR_NAME=${_TMP_EXEC_TEXT_PRINTF_VAR_PAIR[0]}
	local _TMP_EXEC_TEXT_PRINTF_VAR_VAL=${_TMP_EXEC_TEXT_PRINTF_VAR_PAIR[1]}
	local _TMP_EXEC_TEXT_PRINTF_VAR_FORMAT=$(echo_discern_exchange_var_val "${2}")

	# 判断格式化模板是否为空，为空不继续执行
	if [ -z "${_TMP_EXEC_TEXT_PRINTF_VAR_FORMAT}" ]; then
		return $?
	fi

	# 附加动态参数
	local _TMP_EXEC_TEXT_PRINTF_COUNT=$(echo "${_TMP_EXEC_TEXT_PRINTF_VAR_FORMAT}" | grep -o "%" | wc -l)
	local _TMP_EXEC_TEXT_PRINTF_QUOTE="{}"
	local _TMP_EXEC_TEXT_PRINTF_VAR_QUOTE=$(seq -s "${_TMP_EXEC_TEXT_PRINTF_QUOTE}" $((_TMP_EXEC_TEXT_PRINTF_COUNT+1)) | sed 's@[0-9]@ @g')
	# local _TMP_EXEC_TEXT_PRINTF_VAR_VAL_ARR=()
	
	# if [ -n "$(echo "${_TMP_EXEC_TEXT_PRINTF_VAR_VAL}" | grep -o "'")" ]; then
	# 	_TMP_EXEC_TEXT_PRINTF_VAR_VAL_ARR=($(echo "${_TMP_EXEC_TEXT_PRINTF_VAR_QUOTE}" | sed "s@{}@\"${_TMP_EXEC_TEXT_PRINTF_VAR_VAL}\"@g"))
	# else
	# 	if [ -n "$(echo "${_TMP_EXEC_TEXT_PRINTF_VAR_VAL}" | grep -o '"')" ]; then
	# 		_TMP_EXEC_TEXT_PRINTF_VAR_VAL_ARR=($(echo "${_TMP_EXEC_TEXT_PRINTF_VAR_QUOTE}" | sed "s@{}@'${_TMP_EXEC_TEXT_PRINTF_VAR_VAL}'@g"))
	# 	else
	# 		_TMP_EXEC_TEXT_PRINTF_VAR_VAL_ARR=($(echo "${_TMP_EXEC_TEXT_PRINTF_VAR_QUOTE}" | sed "s@{}@${_TMP_EXEC_TEXT_PRINTF_VAR_VAL}@g"))
	# 	fi		 
	# fi
		
	# 废弃，因会有字符识别问题
	## local _TMP_EXEC_TEXT_PRINTF_SCRIPT="printf \"${_TMP_EXEC_TEXT_PRINTF_VAR_FORMAT}\" ${_TMP_EXEC_TEXT_PRINTF_VAR_VAL_ARR[*]}"
	## local _TMP_EXEC_TEXT_PRINTF_FORMATED_VAL=$(script_check_action "${_TMP_EXEC_TEXT_PRINTF_SCRIPT}")
	# 再次废弃，因单双引号问题
	# local _TMP_EXEC_TEXT_PRINTF_FORMATED_VAL=$(printf "${_TMP_EXEC_TEXT_PRINTF_VAR_FORMAT}" ${_TMP_EXEC_TEXT_PRINTF_VAR_VAL_ARR[*]})
	local _TMP_EXEC_TEXT_PRINTF_FORMATED_VAL=$(printf "${_TMP_EXEC_TEXT_PRINTF_VAR_FORMAT}" ${_TMP_EXEC_TEXT_PRINTF_VAR_QUOTE//${_TMP_EXEC_TEXT_PRINTF_QUOTE}/${_TMP_EXEC_TEXT_PRINTF_VAR_VAL}})
	
	eval ${_TMP_EXEC_TEXT_PRINTF_VAR_NAME}='${_TMP_EXEC_TEXT_PRINTF_FORMATED_VAL}'
	
	return $?
}

# 执行文本格式化(仅支持1:1的参数，匹配一个变量内的多个%)
# 参数1：需要格式化的模板变量名/值
# 参数2：格式化字符串规格动态参数列表
# 示例：
#	    TMP_TEST_FORMATED_TEXT="Hello %s %s"
#	    exec_multy_printf "TMP_TEST_FORMATED_TEXT" "Java" "World"
#	    echo "The formated text is ‘$TMP_TEST_FORMATED_TEXT’"
function exec_multy_printf()
{
	local _TMP_EXEC_MULTY_PRINTF_VAR_PAIR=()
	bind_discern_exchange_var_pair "_TMP_EXEC_MULTY_PRINTF_VAR_PAIR" "${1}"
	local _TMP_EXEC_MULTY_PRINTF_VAR_NAME=${_TMP_EXEC_MULTY_PRINTF_VAR_PAIR[0]}
	local _TMP_EXEC_MULTY_PRINTF_VAR_VAL=${_TMP_EXEC_MULTY_PRINTF_VAR_PAIR[1]}
	
	# 判断格式化模板是否为空，为空不继续执行
	shift
	if [ ${#@} -eq 0 ]; then
		return $?
	fi
	
	local _TMP_EXEC_MULTY_PRINTF_LESS_COUNT=$(echo "${_TMP_EXEC_MULTY_PRINTF_VAR_VAL}" | grep -o "%" | wc -l)
	if [ ${_TMP_EXEC_MULTY_PRINTF_LESS_COUNT} -gt 0 ]; then
		_TMP_EXEC_MULTY_PRINTF_VAR_VAL=$(printf "${_TMP_EXEC_MULTY_PRINTF_VAR_VAL}" "${@:1:${_TMP_EXEC_MULTY_PRINTF_LESS_COUNT}}")
		eval ${_TMP_EXEC_MULTY_PRINTF_VAR_NAME}='${_TMP_EXEC_MULTY_PRINTF_VAR_VAL}'
	fi
	
	return $?
}

# 循环读取值
# 参数1：需要设置的变量名（即是默认值，也是逗号分隔的数组字符串）
# 参数2：提示信息
# 参数3：格式化字符串
# 参数4：需执行的脚本
function exec_while_read() 
{
	function _exec_while_read()
	{
		local _TMP_EXEC_WHILE_READ_ECHO=${2}
		local _TMP_EXEC_WHILE_READ_FORMAT=${3}
		local _TMP_EXEC_WHILE_READ_SCRIPTS=${4}
		local _TMP_EXEC_WHILE_READ_VAR_VAL=$(eval echo '${'"${1}"'}')

		local I=1
		for I in $(seq 99);
		do
			local _TMP_EXEC_WHILE_READ_CURRENT_ECHO=$(eval echo "${_TMP_EXEC_WHILE_READ_ECHO}")
			echo_style_text "${_TMP_EXEC_WHILE_READ_CURRENT_ECHO} Or 'enter key' To Quit"
			read -e _TMP_EXEC_WHILE_READ_CURRENT

			echo_style_text "Item of <${_TMP_EXEC_WHILE_READ_CURRENT}> inputed"
			
			if [ -z "${_TMP_EXEC_WHILE_READ_CURRENT}" ]; then
				if [ $I -eq 1 ] && [ -n "${_TMP_EXEC_WHILE_READ_VAR_VAL}" ]; then
					echo_style_text "No input, set value to default '${_TMP_EXEC_WHILE_READ_VAR_VAL}'"
					_TMP_EXEC_WHILE_READ_CURRENT="${_TMP_EXEC_WHILE_READ_VAR_VAL}"
				else
					_TMP_EXEC_WHILE_READ_BREAK_ACTION=true
				fi
			fi

			local _TMP_EXEC_WHILE_READ_FORMAT_CURRENT="${_TMP_EXEC_WHILE_READ_CURRENT}"
		
			exec_text_printf "_TMP_EXEC_WHILE_READ_FORMAT_CURRENT" "${_TMP_EXEC_WHILE_READ_FORMAT}"

			if [ -n "${_TMP_EXEC_WHILE_READ_CURRENT}" ]; then
				if [ $I -gt 1 ]; then
					eval ${1}=$(eval echo '$'${1},${_TMP_EXEC_WHILE_READ_FORMAT_CURRENT})
				else
					eval ${1}="${_TMP_EXEC_WHILE_READ_FORMAT_CURRENT}"
				fi
				
				script_check_action "${_TMP_EXEC_WHILE_READ_SCRIPTS}"
				echo
			fi

			if [ ${_TMP_EXEC_WHILE_READ_BREAK_ACTION} == true ]; then
				break
			fi
		done

		# TMP_FORMAT_VAL="$TMP_WRAP_CHAR${_TMP_EXEC_WHILE_READ_CURRENT}$TMP_WRAP_CHAR"
		local _TMP_EXEC_WHILE_READ_NEW_VAL=$(echo_discern_exchange_var_val "${1}")
		_TMP_EXEC_WHILE_READ_NEW_VAL=$(echo "${_TMP_EXEC_WHILE_READ_NEW_VAL}" | sed "s/^[,]\{1,\}//g;s/[,]\{1,\}$//g")
		eval ${1}='${_TMP_EXEC_WHILE_READ_NEW_VAL}'
		
		if [ -z "${_TMP_EXEC_WHILE_READ_NEW_VAL}" ]; then
			echo_style_text "<Items not set>"
			# exit 1
		fi

		# eval ${1}=$(echo "${1}" | sed "s/^[,]\{1,\}//g;s/[,]\{1,\}$//g")
		echo_style_text "Final 'value' is <${_TMP_EXEC_WHILE_READ_NEW_VAL}>"
	}

	discern_exchange_var_action "${1}" "_exec_while_read" "${@}"
	return $?
}

#循环读取JSON值
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：选项参数
function exec_while_read_json() 
{
	function _exec_while_read_json()
	{
		local _TMP_EXEC_WHILE_READ_JSON_ECHO=${2}
		local _TMP_EXEC_WHILE_READ_JSON_ITEMS=${3}

		local _TMP_EXEC_WHILE_READ_JSON_ITEMS_ARR=(${_TMP_EXEC_WHILE_READ_JSON_ITEMS//,/ })
		local _TMP_EXEC_WHILE_READ_JSON_ITEMS_LEN=${#_TMP_EXEC_WHILE_READ_JSON_ITEMS_ARR[@]}
		
		for i in $(seq 99);
		do
			local _TMP_EXEC_WHILE_READ_JSON_Y_N="N"
			confirm_yn_action "_TMP_EXEC_WHILE_READ_JSON_Y_N" "Please sure you will input items"
			
			if [ "${_TMP_EXEC_WHILE_READ_JSON_Y_N}" != "y" ] || [ "${_TMP_EXEC_WHILE_READ_JSON_Y_N}" != "Y" ]; then
				break
			fi

			local _TMP_EXEC_WHILE_READ_JSON_ITEM="${_TMP_EXEC_WHILE_READ_JSON_ITEM}{ "
			for I in ${!_TMP_EXEC_WHILE_READ_JSON_ITEMS_ARR[@]}; do
				_TMP_EXEC_WHILE_READ_JSON_KEY=${_TMP_EXEC_WHILE_READ_JSON_ITEMS_ARR[$I]}
				echo ${_TMP_EXEC_WHILE_READ_JSON_ECHO} | sed 's@\$i@'$i'@g' | sed 's@\$@'\'${_TMP_EXEC_WHILE_READ_JSON_KEY}\''@g'
				read -e _TMP_EXEC_WHILE_READ_JSON_CURRENT

				_TMP_EXEC_WHILE_READ_JSON_ITEM="${_TMP_EXEC_WHILE_READ_JSON_ITEM}\"${_TMP_EXEC_WHILE_READ_JSON_KEY}\": \"${_TMP_EXEC_WHILE_READ_JSON_CURRENT}\""
				if [ $((I+1)) -ne ${_TMP_EXEC_WHILE_READ_JSON_ITEM}S_LEN ]; then
					_TMP_EXEC_WHILE_READ_JSON_ITEM="${_TMP_EXEC_WHILE_READ_JSON_ITEM}, "
				fi
			done
			_TMP_EXEC_WHILE_READ_JSON_ITEM="${_TMP_EXEC_WHILE_READ_JSON_ITEM} }"

			eval ${1}='${_TMP_EXEC_WHILE_READ_JSON_ITEM}'
			echo_style_text "Item of <${_TMP_EXEC_WHILE_READ_JSON_ITEM}> inputed"
		done

		local _TMP_EXEC_WHILE_READ_JSON_NEW_VAL=$(echo "${_TMP_EXEC_WHILE_READ_JSON_ITEM}" | sed 's@}{@}, {@g')
		eval ${1}='${_TMP_EXEC_WHILE_READ_JSON_NEW_VAL}'
		
		if [ -z "${_TMP_EXEC_WHILE_READ_JSON_NEW_VAL}" ]; then
			echo_style_text "<Items not set, script exit>"
			exit 1
		fi

		# eval ${1}=$(echo "${1}" | sed "s/^[,]\{1,\}//g;s/[,]\{1,\}$//g")
		echo "Final value is: "
		echo "${_TMP_EXEC_WHILE_READ_JSON_NEW_VAL}" | jq
	}

	discern_exchange_var_action "${1}" "_exec_while_read_json" "${@}"
	return $?
}

# # 查找列表中，获取关键字首行
# # 参数1：需要设置的变量名
# # 参数2：需要查找的内容
# # 参数3：查找关键字
# function find_content_list_first_line()
# {
# 	function _find_content_list_first_line()
# 	{
# 		local _TMP_FIND_CONTENT_LIST_FIRST_LINE_VAR_NAME=${1}
# 		local _TMP_FIND_CONTENT_LIST_FIRST_LINE_VAR_FIND_CONTENT=${2}
# 		local _TMP_FIND_CONTENT_LIST_FIRST_LINE_VAR_KEY_WORDS=${3}

# 		local _TMP_FIND_CONTENT_LIST_FIRST_LINE_MATCH_CONTENT_FIRST_LINE=$(echo ${_TMP_FIND_CONTENT_LIST_FIRST_LINE_VAR_FIND_CONTENT} | grep "${_TMP_FIND_CONTENT_LIST_FIRST_LINE_VAR_KEY_WORDS}" | awk 'NR==1')

# 		if [ -n "${_TMP_FIND_CONTENT_LIST_FIRST_LINE_MATCH_CONTENT_FIRST_LINE}" ]; then
# 			eval ${1}='${_TMP_FIND_CONTENT_LIST_FIRST_LINE_MATCH_CONTENT_FIRST_LINE}'
# 		fi
# 	}

# 	discern_exchange_var_action "${1}" "_find_content_list_first_line" "${@}"
# 	return $?
# }

##########################################################################################################
# 数组操作类
##########################################################################################################
# 执行脚本，选项存在或不存在
# 参数1：内容正则变量名/值
# 参数2：内容判断数组
# 参数3：存在执行脚本
#       参数1：匹配到内容
#       参数1：匹配到内容所在数组字符串下标
# 参数4：不存在执行脚本
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_exists_yn_action "_CHECK_ITEM" "${_ARR[*]}" "echo 'exists'" "echo 'not exists'"
#      item_exists_yn_action "^/etc/docker$" "${_ARR[*]}" "echo 'exists'" "echo 'not exists'"
function item_exists_yn_action() 
{
	local _TMP_ITEM_EXISTS_YN_ACTION_VAR_REGEX=$(echo_discern_exchange_var_val "${1}")
	if [ "\$${1}" == "${_TMP_ITEM_EXISTS_YN_ACTION_VAR_REGEX}" ]; then
		_TMP_ITEM_EXISTS_YN_ACTION_VAR_REGEX="${1}"
	fi

	local _TMP_ITEM_EXISTS_YN_ACTION_CON_E_ACTION=${3}
	local _TMP_ITEM_EXISTS_YN_ACTION_CON_NE_ACTION=${4}

	#create group if not exists
	local _TMP_ITEM_EXISTS_YN_ACTION_ITEM_MATCHED=""
	function _item_exists_yn_action_check()
	{
		echo "${1}" | egrep "${_TMP_ITEM_EXISTS_YN_ACTION_VAR_REGEX}" >& /dev/null
		if [ $? -eq 0 ]; then
			_TMP_ITEM_EXISTS_YN_ACTION_ITEM_MATCHED=${1}
			script_check_action "_TMP_ITEM_EXISTS_YN_ACTION_CON_E_ACTION" "${1}" ${2}
		fi
	}
	
	items_split_action "${2}" "_item_exists_yn_action_check"
	
	if [ -z "${_TMP_ITEM_EXISTS_YN_ACTION_ITEM_MATCHED}" ]; then
		script_check_action "_TMP_ITEM_EXISTS_YN_ACTION_CON_NE_ACTION"
	fi

	return $?
}

# 执行脚本,如果选项不存在
# 参数1：内容正则变量
# 参数2：内容判断数组
# 参数3：不存在执行脚本
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_not_exists_action "_CHECK_ITEM" "${_ARR[*]}" "echo 'not exists'"
#      item_not_exists_action "^/etc/docker$" "${_ARR[*]}" "echo 'not exists'"
function item_not_exists_action() 
{
	item_exists_yn_action "${1}" "${2}" "" "${3}"
	return $?
}

# 执行脚本,如果选项存在
# 参数1：内容正则变量
# 参数2：内容判断数组
# 参数3：存在执行脚本
#       参数1：匹配到内容
#       参数1：匹配到内容所在数组字符串下标
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_exists_action "_CHECK_ITEM" "${_ARR[*]}" "echo 'exists'"
#      item_exists_action "^/etc/docker$" "${_ARR[*]}" "echo 'exists'"
function item_exists_action() 
{
	item_exists_yn_action "${1}" "${2}" "${3}"
	return $?
}

# 执行脚本，并获取匹配到的值，及在数组下标（仅匹配第一个）
# 参数1：内容正则变量名/值
# 参数2：内容判断数组字符串变量名/值
# 参数3：始终执行脚本
#       参数1：匹配到内容/或空
#       参数1：匹配到内容所在数组字符串下标/或最新下标
# 示例：
#       local _ARR=()
#       _ARR[0]="/opt/docker"
#       _ARR[1]="/var/lib/docker"
#       _ARR[2]="/var/log/docker"
#       _ARR[3]="/etc/docker"
#       local _CHECK_ITEM="^/var/log/docker$"
#       function _item_check_action()
#       {
#       	if [ -n "${1}" ]; then
#       		_ARR[${2}]="match-item"
#       	else
#       		_ARR[${2}]="new-item"
#       	fi
#       }
#       item_check_action "_CHECK_ITEM" "${_ARR[*]}" "_item_check_action"
#		item_check_action "^/etc/docker$" "${_ARR[*]}" "_item_check_action"
#		item_check_action "^/tmp/docker$" "${_ARR[*]}" "_item_check_action"
function item_check_action() 
{    
	local _TMP_ITEM_CHECK_ACTION_CHANGE_ARR=($(echo_discern_exchange_var_val "${2}"))
	bind_fix_arr "_TMP_ITEM_CHECK_ACTION_CHANGE_ARR"
	local _TMP_ITEM_CHECK_ACTION_ARR_CHANGE_INDEX=${#_TMP_ITEM_CHECK_ACTION_CHANGE_ARR[@]}
	local _TMP_ITEM_CHECK_ACTION_CHANGE_MATCH_ITEM=""

    function _item_check_action_change()
    {
		_TMP_ITEM_CHECK_ACTION_CHANGE_MATCH_ITEM=${1}
        _TMP_ITEM_CHECK_ACTION_ARR_CHANGE_INDEX=${2}
    }
	
	item_exists_action "${1}" "_TMP_ITEM_CHECK_ACTION_CHANGE_ARR" "_item_check_action_change"
	
	script_check_action "${3}" "${_TMP_ITEM_CHECK_ACTION_CHANGE_MATCH_ITEM}" "${_TMP_ITEM_CHECK_ACTION_ARR_CHANGE_INDEX}"
	return $?
}

# 执行脚本，内容存在则匹配
# 参数1：内容正则变量名/值
# 参数2：内容判断数组名/值
# 参数3：匹配后执行脚本
#       参数1：被匹配的字符串
#       参数2：被匹配的字符串下标
#       参数3：匹配后的数组字符串
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_change_match_action "_CHECK_ITEM" "${_ARR[*]}" 'echo "after match arr str：${1}"'
#      item_change_match_action "^/etc/docker$" "${_ARR[*]}" 'echo "after match arr str：${1}"'
function item_change_match_action()
{
	local _TMP_ITEM_CHANGE_MATCH_ACTION_ITEMS=$(echo_discern_exchange_var_val "${2}")
	local _TMP_ITEM_CHANGE_MATCH_ACTION_AFTER_MATCH_SCRIPTS=${3}
	
	function _item_change_match_action()
	{
		if [ -n "${1}" ]; then
			local _TMP_ITEM_CHANGE_MATCH_ACTION_ITEM_ARR=(${_TMP_ITEM_CHANGE_MATCH_ACTION_ITEMS})
			bind_fix_arr "_TMP_ITEM_CHANGE_MATCH_ACTION_ITEM_ARR"

			# 匹配后，移除。避免影响后续操作
			unset _TMP_ITEM_CHANGE_MATCH_ACTION_ITEM_ARR[${2}]
			
			_TMP_ITEM_CHANGE_MATCH_ACTION_ITEMS="${_TMP_ITEM_CHANGE_MATCH_ACTION_ITEM_ARR[*]}"
			script_check_action "_TMP_ITEM_CHANGE_MATCH_ACTION_AFTER_MATCH_SCRIPTS" "${1}" "${2}" "${_TMP_ITEM_CHANGE_MATCH_ACTION_ITEMS}"
		else
			break
		fi
	}

	while [ 1=1 ]; do 
		item_check_action "${1}" "_TMP_ITEM_CHANGE_MATCH_ACTION_ITEMS" "_item_change_match_action"
	done

	return $?
}

# 执行脚本，内容存在则替换，不存在则新增
# 参数1：内容正则变量名/值
# 参数2：覆写内容变量名/值
# 参数3：内容判断数组变量名/值
# 参数4：覆写后执行脚本
#       参数1：被覆写的字符串
#       参数2：被覆写的字符串下标
#       参数3：覆写后的数组字符串
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_change_cover_action "_CHECK_ITEM" "/etc/docker_cover" "${_ARR[*]}" 'echo "has cover arr str：${1}"'
#      item_change_cover_action "^/etc/docker$" "/etc/docker_cover" "${_ARR[*]}" 'echo "has cover arr str：${1}"'
function item_change_cover_action()
{
	local _TMP_ITEM_CHANGE_COVER_ACTION_ITEM="$(echo_discern_exchange_var_val ${2})"
	local _TMP_ITEM_CHANGE_COVER_ACTION_VAR_VAL=$(echo_discern_exchange_var_val "${3}")

	local _TMP_ITEM_CHANGE_COVER_ACTION_AFTER_COVER_SCRIPTS=${4}
	function _item_change_cover_action()
	{
		local _TMP_ITEM_CHANGE_COVER_ACTION_ITEM_ARR=(${_TMP_ITEM_CHANGE_COVER_ACTION_VAR_VAL})
		bind_fix_arr "_TMP_ITEM_CHANGE_COVER_ACTION_ITEM_ARR"
		_TMP_ITEM_CHANGE_COVER_ACTION_ITEM_ARR[${2}]=${_TMP_ITEM_CHANGE_COVER_ACTION_ITEM}

		script_check_action "${_TMP_ITEM_CHANGE_COVER_ACTION_AFTER_COVER_SCRIPTS}" "${1}" "${2}" "${_TMP_ITEM_CHANGE_COVER_ACTION_ITEM_ARR[*]}"
		return $?
	}

	item_check_action "${1}" "_TMP_ITEM_CHANGE_COVER_ACTION_VAR_VAL" "_item_change_cover_action"
	return $?
}

# 执行脚本，内容存在则替换，不存在则新增
# 参数1：需要绑定的数组字符串变量名/值
# 参数2：内容正则变量
# 参数3：覆写内容
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_change_cover_bind "_ARR" "_CHECK_ITEM" "/etc/docker_cover" && echo "${_ARR[*]}"
#      item_change_cover_bind "${_ARR[*]}" "^/etc/docker$" "/etc/docker_cover"
function item_change_cover_bind()
{
	local _TMP_ITEM_CHANGE_COVER_BIND_VAR_ARR=()
	bind_discern_exchange_var_arr "_TMP_ITEM_CHANGE_COVER_BIND_VAR_ARR" "${1}"
	local _TMP_ITEM_CHANGE_COVER_BIND_VAR_NAME=${_TMP_ITEM_CHANGE_COVER_BIND_VAR_ARR[0]}
	local _TMP_ITEM_CHANGE_COVER_BIND_VAR_TYPE=${_TMP_ITEM_CHANGE_COVER_BIND_VAR_ARR[1]}
	local _TMP_ITEM_CHANGE_COVER_BIND_VAR_VAL=${_TMP_ITEM_CHANGE_COVER_BIND_VAR_ARR[2]}
		
	function _item_change_cover_bind_re()
	{
		# _TMP_ITEM_CHANGE_COVER_BIND_VAR_VAL="${3}"
		if [ "${_TMP_ITEM_CHANGE_COVER_BIND_VAR_TYPE}" == "array" ]; then
			if [ -z "${_TMP_ITEM_CHANGE_COVER_BIND_VAR_VAL}" ]; then
				eval ${_TMP_ITEM_CHANGE_COVER_BIND_VAR_NAME}='(${1})'
			else
				eval ${_TMP_ITEM_CHANGE_COVER_BIND_VAR_NAME}='(${3})'
			fi
		else
			eval ${_TMP_ITEM_CHANGE_COVER_BIND_VAR_NAME}='${3}'
		fi
	}

	item_change_cover_action "${2}" "${3}" "_TMP_ITEM_CHANGE_COVER_BIND_VAR_VAL" "_item_change_cover_bind_re"
	return $?
}

# 执行脚本，并做合并覆写，内容存在则替换，不存在则新增
# 参数1：内容正则变量，用于遍历时做判断匹配
# 参数2：内容判断数组，用于遍历判断
# 参数3：内容判断数组，用于对比并输出结果
# 参数4：合并覆写后执行脚本
#       参数1：被覆写的字符串
#       参数2：被覆写的字符串下标
#       参数3：覆写后的数组字符串
# 示例：
#      local _CHECK_ARR=()
#      _CHECK_ARR[0]="/opt/docker"
#      _CHECK_ARR[1]="/opt/docker/logs"
#      _CHECK_ARR[2]="/var/log/docker"
#      _CHECK_ARR[3]="/etc/docker"
#      local _OUTPUT_ARR=()
#      _OUTPUT_ARR[0]="/opt/docker"
#      _OUTPUT_ARR[1]="/opt/docker/logs"
#      _OUTPUT_ARR[2]="/opt/docker/data"
#      _OUTPUT_ARR[3]="/opt/docker/conf"
#      _OUTPUT_ARR[4]="/var/lib/docker"
#      _OUTPUT_ARR[5]="/var/log/docker"
#      #items_change_combine_cover_action '^%s$' "${_CHECK_ARR[*]}" "${_OUTPUT_ARR[*]}" '_OUTPUT_ARR=(${3}) && echo "after cover arr str：${@:1:2}" && echo "${_OUTPUT_ARR[*]}"'
#      items_change_combine_cover_action '' "${_CHECK_ARR[*]}" "${_OUTPUT_ARR[*]}" '_OUTPUT_ARR_STR="${3}" && echo "after cover arr str：${@:1:2}" && echo "${_OUTPUT_ARR_STR}"'
function items_change_combine_cover_action()
{
	local _TMP_ITEMS_CHANGE_COMBINE_COVER_ACTION_ITEM_REGEX=$(echo_discern_exchange_var_val "${1}")
	local _TMP_ITEMS_CHANGE_COMBINE_COVER_ACTION_OUTPUT_VAL=$(echo_discern_exchange_var_val "${3}")
	local _TMP_ITEMS_CHANGE_COMBINE_COVER_ACTION_AFTER_COVER_SCRIPTS=${4}

	function _items_change_combine_cover_action_split() 
	{
		function _items_change_combine_cover_action_combine()
		{
			# 处于循环体中，不能覆写，否则引用会失效
			_TMP_ITEMS_CHANGE_COMBINE_COVER_ACTION_OUTPUT_VAL="${3}"
			script_check_action "_TMP_ITEMS_CHANGE_COMBINE_COVER_ACTION_AFTER_COVER_SCRIPTS" "${1}" "${2}" "${3}"
		}

		local _TMP_ITEMS_CHANGE_COMBINE_COVER_ACTION_ITEM_FORMAT_REGEX="${1}"
		exec_text_printf "_TMP_ITEMS_CHANGE_COMBINE_COVER_ACTION_ITEM_FORMAT_REGEX" "${_TMP_ITEMS_CHANGE_COMBINE_COVER_ACTION_ITEM_REGEX}"
		
		item_change_cover_action "${_TMP_ITEMS_CHANGE_COMBINE_COVER_ACTION_ITEM_FORMAT_REGEX:-"^${1}$"}" "${1}" "${_TMP_ITEMS_CHANGE_COMBINE_COVER_ACTION_OUTPUT_VAL}" "_items_change_combine_cover_action_combine"
	}

	items_split_action "$(echo_discern_exchange_var_val "${2}")" "_items_change_combine_cover_action_split"		
	return $?
}


# 执行脚本，并做合并覆写，内容存在则替换，不存在则新增
# 参数1：需要绑定的数组字符串变量名/值 （内容判断数组，用于对比并输出结果）
# 参数2：内容正则变量，用于遍历时做判断匹配
# 参数3：内容判断数组，用于遍历判断
# 示例：
#      local _CHECK_ARR=()
#      _CHECK_ARR[0]="/opt/docker"
#      _CHECK_ARR[1]="/opt/docker/logs"
#      _CHECK_ARR[2]="/var/log/docker"
#      _CHECK_ARR[3]="/etc/docker"
#      local _OUTPUT_ARR=()
#      _OUTPUT_ARR[0]="/opt/docker"
#      _OUTPUT_ARR[1]="/opt/docker/logs"
#      _OUTPUT_ARR[2]="/opt/docker/data"
#      _OUTPUT_ARR[3]="/opt/docker/conf"
#      _OUTPUT_ARR[4]="/var/lib/docker"
#      _OUTPUT_ARR[5]="/var/log/docker"
#      items_change_combine_cover_bind '_OUTPUT_ARR' '^%s$' "${_CHECK_ARR[*]}" && echo "${_OUTPUT_ARR[*]}"
#      items_change_combine_cover_bind '_OUTPUT_ARR' '^%s$' "_CHECK_ARR" && echo "${_OUTPUT_ARR[*]}"  ## ??? 存在bug，不支持读变量名
#      items_change_combine_cover_bind '_OUTPUT_ARR[*]' '' "${_CHECK_ARR[*]}"
function items_change_combine_cover_bind()
{
	local _TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_ARR=()
	bind_discern_exchange_var_arr "_TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_ARR" "${1}"
	local _TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_NAME=${_TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_ARR[0]}
	local _TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_TYPE=${_TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_ARR[1]}
	local _TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_VAL=${_TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_ARR[2]}
		
	function _items_change_combine_cover_bind_re()
	{
		if [ "${_TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_TYPE}" == "array" ]; then
			if [ -z "${_TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_VAL}" ]; then
				eval ${_TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_NAME}='(${1})'
			else
				eval ${_TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_NAME}='(${3})'
			fi
		else
			eval ${_TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_NAME}='${3}'
		fi
	}

	items_change_combine_cover_action "${1}" "${3}" "_TMP_ITEMS_CHANGE_COMBINE_COVER_BIND_VAR_VAL" "_items_change_combine_cover_bind_re"
	return $?
}

# 执行脚本，内容存在则删除
# 参数1：内容正则变量名/值
# 参数2：内容判断数组名/值
# 参数3：删除后执行脚本
#       参数1：被删除的字符串
#       参数2：被删除的字符串下标
#       参数3：删除后的数组字符串
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_change_remove_action "_CHECK_ITEM" "${_ARR[*]}" 'echo "after remove arr str：${1}"'
#      item_change_remove_action "^/etc/docker$" "${_ARR[*]}" 'echo "after remove arr str：${1}"'
function item_change_remove_action()
{
	item_change_match_action "${@}"

	return $?
}

# 执行脚本，内容存在则删除
# 参数1：需要绑定的数组字符串变量名/值
# 参数2：内容正则变量
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_change_remove_bind "_ARR" "_CHECK_ITEM"
#      item_change_remove_bind "_ARR" "^/etc/docker$"
function item_change_remove_bind()
{	
	local _TMP_ITEM_CHANGE_REMOVE_BIND_VAR_ARR=()
	bind_discern_exchange_var_arr "_TMP_ITEM_CHANGE_REMOVE_BIND_VAR_ARR" "${1}"
	local _TMP_ITEM_CHANGE_REMOVE_BIND_VAR_NAME=${_TMP_ITEM_CHANGE_REMOVE_BIND_VAR_ARR[0]}
	local _TMP_ITEM_CHANGE_REMOVE_BIND_VAR_TYPE=${_TMP_ITEM_CHANGE_REMOVE_BIND_VAR_ARR[1]}
	local _TMP_ITEM_CHANGE_REMOVE_BIND_VAR_VAL=${_TMP_ITEM_CHANGE_REMOVE_BIND_VAR_ARR[2]}
	
	function _item_change_remove_bind_re()
	{
		if [ "${_TMP_ITEM_CHANGE_REMOVE_BIND_VAR_TYPE}" == "array" ]; then
			eval ${_TMP_ITEM_CHANGE_REMOVE_BIND_VAR_NAME}='(${3})'
		else
			eval ${_TMP_ITEM_CHANGE_REMOVE_BIND_VAR_NAME}='${3}'
		fi
	}

	item_change_remove_action "${2}" "_TMP_ITEM_CHANGE_REMOVE_BIND_VAR_VAL" '_item_change_remove_bind_re'
	return $?
}

# 执行脚本，并做合并删除
# 参数1：内容判断数组，用于遍历判断
# 参数2：内容判断数组，用于对比并输出结果
# 参数3：合并删除后执行脚本
#       参数1：被删除的字符串
#       参数2：被删除的字符串下标
#       参数3：删除后的数组字符串
# 示例：
#      local _CHECK_ARR=()
#      _CHECK_ARR[0]="/opt/docker"
#      _CHECK_ARR[1]="/opt/docker/logs"
#      _CHECK_ARR[2]="/var/log/docker"
#      local _OUTPUT_ARR=()
#      _OUTPUT_ARR[0]="/opt/docker"
#      _OUTPUT_ARR[1]="/opt/docker/logs"
#      _OUTPUT_ARR[2]="/opt/docker/data"
#      _OUTPUT_ARR[3]="/opt/docker/conf"
#      _OUTPUT_ARR[4]="/var/lib/docker"
#      _OUTPUT_ARR[5]="/var/log/docker"
#      _OUTPUT_ARR[6]="/etc/docker"
#      items_change_combine_remove_action "${_CHECK_ARR[*]}" "${_OUTPUT_ARR[*]}" '_OUTPUT_ARR=(${3}) && echo "after remove arr str：${@:1:2}" && echo "${_OUTPUT_ARR[*]}"'
#      items_change_combine_remove_action "${_CHECK_ARR[*]}" "${_OUTPUT_ARR[*]}" '_OUTPUT_ARR_STR="${3}" && echo "after remove arr str：${@:1:2}" && echo "${_OUTPUT_ARR_STR}"'
function items_change_combine_remove_action()
{
	local _TMP_ITEMS_CHANGE_COMBINE_REMOVE_OUTPUT_VAL=$(echo_discern_exchange_var_val "${2}")
	local _TMP_ITEMS_CHANGE_COMBINE_REMOVE_AFTER_REMOVE_SCRIPTS=${3}

	function _items_change_combine_remove_action_split() 
	{
		function _items_change_combine_remove_action_combine()
		{
			# 处于循环体中，不能删除，否则引用会失效
			_TMP_ITEMS_CHANGE_COMBINE_REMOVE_OUTPUT_VAL="${3}"
			script_check_action "_TMP_ITEMS_CHANGE_COMBINE_REMOVE_AFTER_REMOVE_SCRIPTS" "${1}" "${2}" "${3}"
		}

		item_change_remove_action "^${1}$" "${_TMP_ITEMS_CHANGE_COMBINE_REMOVE_OUTPUT_VAL}" "_items_change_combine_remove_action_combine"
	}

	items_split_action "${1}" "_items_change_combine_remove_action_split"		
	return $?
}

# 执行脚本，内容存在则保留
# 参数1：内容正则变量名/值
# 参数2：内容判断数组变量名/值
# 参数3：保留后执行脚本
#       参数1：被保留的字符串
#       参数2：被保留的字符串下标
#       参数3：保留后的数组字符串
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_change_select_action "_CHECK_ITEM" "${_ARR[*]}" 'echo "after select arr str：${1}"'
#      item_change_select_action "^/etc/docker$" "${_ARR[*]}" 'echo "after select arr str：${1}"'
function item_change_select_action()
{
	local _TMP_ITEM_CHANGE_SELECT_ACTION_AFTER_SELECT_SCRIPTS=${3}
	local _TMP_ITEM_CHANGE_SELECT_ACTION_SELECT_ITEMS=()
	
	function _item_change_select_action()
	{
		_TMP_ITEM_CHANGE_SELECT_ACTION_SELECT_ITEMS[${#_TMP_ITEM_CHANGE_SELECT_ACTION_SELECT_ITEMS[@]}]="${1}"
		script_check_action "_TMP_ITEM_CHANGE_SELECT_ACTION_AFTER_SELECT_SCRIPTS" "${1}" "${2}" "${_TMP_ITEM_CHANGE_SELECT_ACTION_SELECT_ITEMS[*]}"
	}

	# 有可能没运行
	if [ ${#_TMP_ITEM_CHANGE_SELECT_ACTION_SELECT_ITEMS[@]} -eq 0 ]; then
		script_check_action "_TMP_ITEM_CHANGE_SELECT_ACTION_AFTER_SELECT_SCRIPTS" "${1}" "${2}" "${_TMP_ITEM_CHANGE_SELECT_ACTION_SELECT_ITEMS[*]}"
	fi

	item_change_remove_action "${1}" "${2}" "_item_change_select_action"
	return $?
}

# 执行脚本，内容存在则保留
# 参数1：需要绑定的数组字符串变量名/值
# 参数2：内容正则变量名/值
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_change_select_bind "_ARR" "_CHECK_ITEM"
#      item_change_select_bind "_ARR" "^/etc/docker$"
function item_change_select_bind()
{
	local _TMP_ITEM_CHANGE_SELECT_BIND_VAR_ARR=()
	bind_discern_exchange_var_arr "_TMP_ITEM_CHANGE_SELECT_BIND_VAR_ARR" "${1}"
	local _TMP_ITEM_CHANGE_SELECT_BIND_VAR_NAME="${_TMP_ITEM_CHANGE_SELECT_BIND_VAR_ARR[0]}"
	local _TMP_ITEM_CHANGE_SELECT_BIND_VAR_TYPE="${_TMP_ITEM_CHANGE_SELECT_BIND_VAR_ARR[1]}"
	local _TMP_ITEM_CHANGE_SELECT_BIND_VAR_VAL="${_TMP_ITEM_CHANGE_SELECT_BIND_VAR_ARR[2]}"

	function _item_change_select_bind_re()
	{
		if [ "${_TMP_ITEM_CHANGE_SELECT_BIND_VAR_TYPE}" == "array" ]; then
			eval ${_TMP_ITEM_CHANGE_SELECT_BIND_VAR_NAME}='(${3})'
		else
			eval ${_TMP_ITEM_CHANGE_SELECT_BIND_VAR_NAME}='${3}'
		fi
	}

	item_change_select_action "${2}" "_TMP_ITEM_CHANGE_SELECT_BIND_VAR_VAL" '_item_change_select_bind_re'
	return $?
}

# 执行脚本，内容存在则替换
# 参数1：内容正则变量
# 参数2：替换内容变量名/值
# 参数3：内容判断数组
# 参数4：替换后执行脚本
#       参数1：被替换的字符串
#       参数2：被替换的字符串下标
#       参数3：替换后的数组字符串
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_change_replace_action "_CHECK_ITEM" "/etc/docker" "${_ARR[*]}" 'echo "has replace arr str：${1}"'
#      item_change_replace_action "^/etc/docker$" "/etc/docker" "${_ARR[*]}" 'echo "has replace arr str：${1}"'
function item_change_replace_action()
{
	local _TMP_ITEM_CHANGE_REPLACE_ACTION_ITEM=$(echo_discern_exchange_var_val "${2}")
	local _TMP_ITEM_CHANGE_REPLACE_ACTION_ITEMS="${3}"
	local _TMP_ITEM_CHANGE_REPLACE_ACTION_AFTER_REPLACE_SCRIPTS=${4}
	function _item_change_replace_action()
	{
		if [ -n "${1}" ]; then
			local _TMP_ITEM_CHANGE_REPLACE_ACTION_ITEM_ARR=(${_TMP_ITEM_CHANGE_REPLACE_ACTION_ITEMS})
			bind_fix_arr "_TMP_ITEM_CHANGE_REPLACE_ACTION_ITEM_ARR"
			_TMP_ITEM_CHANGE_REPLACE_ACTION_ITEM_ARR[${2}]=${_TMP_ITEM_CHANGE_REPLACE_ACTION_ITEM}

			script_check_action "${_TMP_ITEM_CHANGE_REPLACE_ACTION_AFTER_REPLACE_SCRIPTS}" "${1}" "${2}" "${_TMP_ITEM_CHANGE_REPLACE_ACTION_ITEM_ARR[*]}"
			return $?
		fi
	}

	item_check_action "${1}" "${3}" "_item_change_replace_action"
	return $?
}

# 执行脚本，内容不存在则替换
# 参数1：需要绑定的数组字符串变量名/值
# 参数2：内容正则变量名/值
# 参数3：替换内容变量名/值
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_change_replace_bind "_ARR" "_CHECK_ITEM" "/etc/docker" && echo "${_ARR[*]}"
#      item_change_replace_bind "${_ARR[*]}" "^/etc/docker$" "/etc/docker"
function item_change_replace_bind()
{	
	local _TMP_ITEM_CHANGE_REPLACE_BIND_VAR_ARR=()
	bind_discern_exchange_var_arr "_TMP_ITEM_CHANGE_REPLACE_BIND_VAR_ARR" "${1}"
	local _TMP_ITEM_CHANGE_REPLACE_BIND_VAR_NAME=${_TMP_ITEM_CHANGE_REPLACE_BIND_VAR_ARR[0]}
	local _TMP_ITEM_CHANGE_REPLACE_BIND_VAR_TYPE=${_TMP_ITEM_CHANGE_REPLACE_BIND_VAR_ARR[1]}
	local _TMP_ITEM_CHANGE_REPLACE_BIND_VAR_VAL=${_TMP_ITEM_CHANGE_REPLACE_BIND_VAR_ARR[2]}

	function _item_change_replace_bind_re()
	{
		# _TMP_ITEM_CHANGE_REPLACE_BIND_VAR_VAL="${3}"
		if [ "${_TMP_ITEM_CHANGE_REPLACE_BIND_VAR_TYPE}" == "array" ]; then
			if [ -z "${_TMP_ITEM_CHANGE_REPLACE_BIND_VAR_VAL}" ]; then
				eval ${_TMP_ITEM_CHANGE_REPLACE_BIND_VAR_NAME}='(${1})'
			else
				eval ${_TMP_ITEM_CHANGE_REPLACE_BIND_VAR_NAME}='(${3})'
			fi
		else
			eval ${_TMP_ITEM_CHANGE_REPLACE_BIND_VAR_NAME}='${3}'
		fi
	}

	item_change_replace_action "${2}" "${3}" "_TMP_ITEM_CHANGE_REPLACE_BIND_VAR_VAL" "_item_change_replace_bind_re"
	return $?
}

# 执行脚本，内容不存在则新增
# 参数1：内容正则变量名/值
# 参数2：新增内容变量名/值
# 参数3：内容判断数组变量名/值
# 参数4：新增后执行脚本
#       参数1：被新增的字符串
#       参数2：被新增的字符串下标
#       参数3：新增后的数组字符串
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_change_append_action "_CHECK_ITEM" "/etc/docker" "${_ARR[*]}" 'echo "after append arr str：${1}"'
#      item_change_append_action "^/etc/docker$" "/etc/docker" "${_ARR[*]}" 'echo "after append arr str：${1}"'
function item_change_append_action()
{
	local _TMP_ITEM_CHANGE_APPEND_ACTION_ITEM=$(echo_discern_exchange_var_val "${2}")
	local _TMP_ITEM_CHANGE_APPEND_ACTION_ITEMS=$(echo_discern_exchange_var_val "${3}")
	local _TMP_ITEM_CHANGE_APPEND_ACTION_AFTER_APPEND_SCRIPTS=${4}
	function _item_change_append_action()
	{
		if [ -z "${1}" ]; then
			local _TMP_ITEM_CHANGE_APPEND_ACTION_ITEM_ARR=(${_TMP_ITEM_CHANGE_APPEND_ACTION_ITEMS})
			bind_fix_arr "_TMP_ITEM_CHANGE_APPEND_ACTION_ITEM_ARR"
			_TMP_ITEM_CHANGE_APPEND_ACTION_ITEM_ARR[${2}]=${_TMP_ITEM_CHANGE_APPEND_ACTION_ITEM}

			script_check_action "${_TMP_ITEM_CHANGE_APPEND_ACTION_AFTER_APPEND_SCRIPTS}" "${_TMP_ITEM_CHANGE_APPEND_ACTION_ITEM}" "${2}" "${_TMP_ITEM_CHANGE_APPEND_ACTION_ITEM_ARR[*]}"
			return $?
		fi
	}

	item_check_action "${1}" "${3}" "_item_change_append_action"
	return $?
}

# 执行脚本，内容不存在则新增
# 参数1：需要绑定的数组字符串变量名/值
# 参数2：内容正则变量名/值
# 参数3：新增内容变量名/值
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      item_change_append_bind "_ARR" "_CHECK_ITEM" "/etc/docker" && echo "${_ARR[*]}"
#      item_change_append_bind "${_ARR[*]}" "^/etc/docker$" "/etc/docker"
function item_change_append_bind()
{
	local _TMP_ITEM_CHANGE_APPEND_BIND_VAR_ARR=()
	bind_discern_exchange_var_arr "_TMP_ITEM_CHANGE_APPEND_BIND_VAR_ARR" "${1}"
	local _TMP_ITEM_CHANGE_APPEND_BIND_VAR_NAME=${_TMP_ITEM_CHANGE_APPEND_BIND_VAR_ARR[0]}
	local _TMP_ITEM_CHANGE_APPEND_BIND_VAR_TYPE=${_TMP_ITEM_CHANGE_APPEND_BIND_VAR_ARR[1]}
	local _TMP_ITEM_CHANGE_APPEND_BIND_VAR_VAL=${_TMP_ITEM_CHANGE_APPEND_BIND_VAR_ARR[2]}
	
	function _item_change_append_bind_re()
	{
		# _TMP_ITEM_CHANGE_APPEND_BIND_VAR_VAL="${3}"
		if [ "${_TMP_ITEM_CHANGE_APPEND_BIND_VAR_TYPE}" == "array" ]; then
			if [ -z "${_TMP_ITEM_CHANGE_APPEND_BIND_VAR_VAL}" ]; then
				eval ${_TMP_ITEM_CHANGE_APPEND_BIND_VAR_NAME}='(${1})'
			else
				eval ${_TMP_ITEM_CHANGE_APPEND_BIND_VAR_NAME}='(${3})'
			fi
		else
			eval ${_TMP_ITEM_CHANGE_APPEND_BIND_VAR_NAME}='${3}'
		fi
	}

	item_change_append_action "${2}" "${3}" "_TMP_ITEM_CHANGE_APPEND_BIND_VAR_VAL" "_item_change_append_bind_re"
	return $?
}

# 执行脚本，内容不存在且数组中的前置字符串对比内容不存在则新增
# 例如:
# 前置字符串存在的情况则不添加，已知前置字符串：/opt/docker，则类似/opt/docker/logs不添加，软连接需自行提前识别
# 参数1：需要绑定的数组字符串变量名/值
# 参数2：新增内容变量名/值
# 参数3：间隔符号，默认空（路径时需要，否则会无法绑定）
# 示例：
#       local _ARR=()
#       _ARR[0]="/opt/docker"
#       _ARR[1]="/var/lib/docker"
#       _ARR[2]="/var/log/docker"
#       _ARR[3]="/etc/docker"
#       item_change_append_ignore_prefix_bind "_ARR" "/opt/docker/logs" && echo "(${_ARR[*]}):${#_ARR[@]}"
#       item_change_append_ignore_prefix_bind "_ARR" "/opt/docker1/logs" && echo "(${_ARR[*]}):${#_ARR[@]}"
#       item_change_append_ignore_prefix_bind "_ARR" "/opt/docker2/logs" "/" && echo "(${_ARR[*]}):${#_ARR[@]}"
#       item_change_append_ignore_prefix_bind "_ARR" "/opt/newer" && echo "(${_ARR[*]}):${#_ARR[@]}"
#       item_change_append_ignore_prefix_bind "${_ARR[*]}" "/etc/docker"  ??? 不兼容
function item_change_append_ignore_prefix_bind()
{
	local _TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_VAR_PAIR=()
	bind_discern_exchange_var_pair "_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_VAR_PAIR" "${1}"
	local _TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_VAR_NAME=${_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_VAR_PAIR[0]}
	local _TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_VAR_VAL=${_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_VAR_PAIR[1]}

	local _TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_APPEND_ITEM=$(echo_discern_exchange_var_val "${2}")
	local _TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_SPLITER="${3}"

	local _TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_CHECK_RET=""
	function _item_change_append_ignore_prefix_bind_filter()
	{
		# 前置不存在
		echo "${_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_APPEND_ITEM}" | egrep "^${1}${_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_SPLITER}" >& /dev/null
		if [ $? -eq 0 ]; then
			_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_CHECK_RET=0
			break
		fi
	}
	
	items_split_action "_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_VAR_VAL" "_item_change_append_ignore_prefix_bind_filter"

	if [ -z "${_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_CHECK_RET}" ]; then
		item_change_append_bind "${_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_VAR_NAME}" "^${_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_APPEND_ITEM}$" "${_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_APPEND_ITEM}"
		return $?
	fi
	
	return ${_TMP_ITEM_CHANGE_APPEND_IGNORE_PREFIX_BIND_CHECK_RET}
}

# 用于修复错误的数组分割
# 参数1：用于分割的数组字符串变量名/值
# 参数2：用于分割数组字符变量名/值，默认空格
# 示例：
#       local _ARR=(--env=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin --env=LANG=en_US.UTF-8 --label='build-date=20221224' --label='name=Photon OS 2.0 Base Image' --label='vendor=VMware')
#       bind_fix_arr "_ARR" && echo "${#_ARR[@]}"
function bind_fix_arr()
{
	local _TMP_BIND_FIX_ARR_VAR_ARR=()
	bind_discern_exchange_var_arr "_TMP_BIND_FIX_ARR_VAR_ARR" "${1}"
	local _TMP_BIND_FIX_ARR_VAR_NAME=${_TMP_BIND_FIX_ARR_VAR_ARR[0]}
	local _TMP_BIND_FIX_ARR_VAR_TYPE=${_TMP_BIND_FIX_ARR_VAR_ARR[1]}
	local _TMP_BIND_FIX_ARR_VAR_VAL=${_TMP_BIND_FIX_ARR_VAR_ARR[2]}

	local _TMP_BIND_FIX_ARR_IFS=$(echo_discern_exchange_var_val "${2}")

	# ???删除逗号了，暂时无法判断是否有影响
	if [ "${_TMP_BIND_FIX_ARR_VAR_TYPE}" != "array" ]; then
		_TMP_BIND_FIX_ARR_VAR_VAL=(${_TMP_BIND_FIX_ARR_VAR_VAL//${_TMP_BIND_FIX_ARR_IFS:- }/ })
	else
		_TMP_BIND_FIX_ARR_VAR_VAL=(${_TMP_BIND_FIX_ARR_VAR_VAL})
	fi

	# 清空原数组
	eval ${_TMP_BIND_FIX_ARR_VAR_NAME}='()'

	# 整理切割的字符串，谨防变量被切割，例如：--env=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin --env=LANG=en_US.UTF-8 --label='build-date=20221224' --label='name=Photon OS 2.0 Base Image' --label='vendor=VMware'
	local _TMP_BIND_FIX_ARR_CURR_INDEX=0
	local _TMP_BIND_FIX_ARR_CURR_SPLING=0
	for _TMP_BIND_FIX_ARR_CURR_ITEM in ${_TMP_BIND_FIX_ARR_VAR_VAL[@]}; do
		# 当前内容存在特殊字符做分割
		local _TMP_BIND_FIX_ARR_CHAR_COUNT=$(echo "${_TMP_BIND_FIX_ARR_CURR_ITEM}" | grep -o "'" | wc -l)		
		if [ $((${_TMP_BIND_FIX_ARR_CHAR_COUNT}%2)) -gt 0 ]; then
			_TMP_BIND_FIX_ARR_CURR_SPLING=1
		fi
		
		local _TMP_BIND_FIX_ARR_ARR_POINT=${_TMP_BIND_FIX_ARR_VAR_NAME}'['${_TMP_BIND_FIX_ARR_CURR_INDEX}']'

		# 未被分割，直接赋值，索引+1
		if [ ${_TMP_BIND_FIX_ARR_CURR_SPLING} -eq 0 ]; then
			eval ${_TMP_BIND_FIX_ARR_ARR_POINT}='${_TMP_BIND_FIX_ARR_CURR_ITEM}'
			_TMP_BIND_FIX_ARR_CURR_INDEX=$((_TMP_BIND_FIX_ARR_CURR_INDEX+1))
		else
			# 已处于分割中
			local _TMP_BIND_FIX_ARR_CURR_PREV_ITEM=$(eval echo '${'${_TMP_BIND_FIX_ARR_ARR_POINT}'}')
			if [ -n "${_TMP_BIND_FIX_ARR_CURR_PREV_ITEM}" ]; then
				_TMP_BIND_FIX_ARR_CURR_ITEM="${_TMP_BIND_FIX_ARR_CURR_PREV_ITEM} ${_TMP_BIND_FIX_ARR_CURR_ITEM}"
				eval ${_TMP_BIND_FIX_ARR_ARR_POINT}='${_TMP_BIND_FIX_ARR_CURR_ITEM}'
				if [ $((${_TMP_BIND_FIX_ARR_CHAR_COUNT}%2)) -gt 0 ]; then
					_TMP_BIND_FIX_ARR_CURR_SPLING=0
					_TMP_BIND_FIX_ARR_CURR_INDEX=$((_TMP_BIND_FIX_ARR_CURR_INDEX+1))
				fi
			else
				eval ${_TMP_BIND_FIX_ARR_ARR_POINT}='${_TMP_BIND_FIX_ARR_CURR_ITEM}'
			fi
		fi
	done
	
	return $?
}

# 分割并执行动作
# 参数1：用于分割的数组字符串变量名/值
# 参数2：对分割字符串执行脚本
#       参数1：内容下正文
#       参数2：内容所在索引
# 参数3：用于分割数组字符变量名/值，默认空格
# 参数x-N：动态参数
# 示例：
#       TMP=1 && while_exec "TMP=\$((TMP+1))" "[ \$TMP -eq 10 ] && echo 1" "echo \$TMP"
function items_split_action()
{
	local _TMP_ITEMS_SPLIT_ACTION_VAR_VAL=$(echo_discern_exchange_var_val "${1}") 
	bind_fix_arr "_TMP_ITEMS_SPLIT_ACTION_VAR_VAL" "${3}"

	# local _TMP_ITEMS_SPLIT_ACTION_SPLIT_ARR=(${1//,/ })
	local _TMP_ITEMS_SPLIT_ACTION_EXEC_SCRIPT=${2}
	if [ -n "${_TMP_ITEMS_SPLIT_ACTION_EXEC_SCRIPT}" ]; then
		_TMP_ITEMS_SPLIT_ACTION_CURR_INDEX=0
		for _TMP_ITEMS_SPLIT_ACTION_CURR_INDEX in ${!_TMP_ITEMS_SPLIT_ACTION_VAR_VAL[@]}; do
			local _TMP_ITEMS_SPLIT_ACTION_SPLIT_ITEM=${_TMP_ITEMS_SPLIT_ACTION_VAR_VAL[_TMP_ITEMS_SPLIT_ACTION_CURR_INDEX]}

			# 附加动态参数
			local _TMP_ITEMS_SPLIT_ACTION_EXEC_SCRIPT_FINAL="${_TMP_ITEMS_SPLIT_ACTION_SPLIT_ITEM}"
			exec_text_printf "_TMP_ITEMS_SPLIT_ACTION_EXEC_SCRIPT_FINAL" "${_TMP_ITEMS_SPLIT_ACTION_EXEC_SCRIPT}"

			# 格式化运行动态脚本
			script_check_action "_TMP_ITEMS_SPLIT_ACTION_EXEC_SCRIPT_FINAL" "${_TMP_ITEMS_SPLIT_ACTION_SPLIT_ITEM}" "${_TMP_ITEMS_SPLIT_ACTION_CURR_INDEX}" "${@:3}"
		done
	fi

	return $?
}

# 分割并执行动作
# 参数1：用于分割的JSON字符串变量名/值
# 参数2：对分割字符串执行脚本
#       参数1：内容下正文
#       参数2：内容所在索引
# 参数x-N：动态参数
# 示例：
#       TMP=1 && while_exec "TMP=\$((TMP+1))" "[ \$TMP -eq 10 ] && echo 1" "echo \$TMP"
function json_split_action()
{
	local _TMP_JSON_SPLIT_ACTION_VAR_PAIR=()
	bind_discern_exchange_var_pair "_TMP_JSON_SPLIT_ACTION_VAR_PAIR" "${1}"
	local _TMP_JSON_SPLIT_ACTION_VAR_NAME=${_TMP_JSON_SPLIT_ACTION_VAR_PAIR[0]}
	local _TMP_JSON_SPLIT_ACTION_VAR_VAL=${_TMP_JSON_SPLIT_ACTION_VAR_PAIR[1]}
	
	local _TMP_JSON_SPLIT_ACTION_EXEC_SCRIPT=${2}
	if [ -n "${_TMP_JSON_SPLIT_ACTION_EXEC_SCRIPT}" ]; then
		local _TMP_JSON_SPLIT_ACTION_VAR_VAL_LENGTH=$(echo "${_TMP_JSON_SPLIT_ACTION_VAR_VAL:-[]}" | jq "length-1")
		if [ ${_TMP_JSON_SPLIT_ACTION_VAR_VAL_LENGTH} -ge 0 ]; then
			for _TMP_JSON_SPLIT_ACTION_CURR_INDEX in $(seq 0 ${_TMP_JSON_SPLIT_ACTION_VAR_VAL_LENGTH}); do
				local _TMP_JSON_SPLIT_ACTION_SPLIT_ITEM=$(echo "${_TMP_JSON_SPLIT_ACTION_VAR_VAL}" | jq ".[${_TMP_JSON_SPLIT_ACTION_CURR_INDEX}]")

				# 附加动态参数
				local _TMP_JSON_SPLIT_ACTION_EXEC_SCRIPT_FINAL="${_TMP_JSON_SPLIT_ACTION_SPLIT_ITEM}"
				exec_text_printf "_TMP_JSON_SPLIT_ACTION_EXEC_SCRIPT_FINAL" "${_TMP_JSON_SPLIT_ACTION_EXEC_SCRIPT}"

				# 格式化运行动态脚本
				script_check_action "_TMP_JSON_SPLIT_ACTION_EXEC_SCRIPT_FINAL" "${_TMP_JSON_SPLIT_ACTION_SPLIT_ITEM}" "${_TMP_JSON_SPLIT_ACTION_CURR_INDEX}" "${@:3}"
			done
		fi
	fi

	return $?
}

# 分割并执行动作
# 参数1：用于分割的yaml字符串变量名/值
# 参数2：对分割字符串执行脚本
#       参数1：内容下正文
#       参数2：内容所在索引
#       参数3：内容对应KEY
# 参数x-N：动态参数
# 示例：
#		function _print_yaml()
#    	{
#        	echo "${1}"
#        	echo "${TMP_SPLITER3}"
#    	}
#    	yaml_split_action "$(cat /root/harbor/docker-compose.yml | yq '.services')" "_print_yaml"

function yaml_split_action()
{
	local _TMP_YAML_SPLIT_ACTION_VAR_PAIR=()
	bind_discern_exchange_var_pair "_TMP_YAML_SPLIT_ACTION_VAR_PAIR" "${1}"
	local _TMP_YAML_SPLIT_ACTION_VAR_NAME=${_TMP_YAML_SPLIT_ACTION_VAR_PAIR[0]}
	local _TMP_YAML_SPLIT_ACTION_VAR_VAL=${_TMP_YAML_SPLIT_ACTION_VAR_PAIR[1]}
	
	local _TMP_YAML_SPLIT_ACTION_EXEC_SCRIPT=${2}
	if [ -n "${_TMP_YAML_SPLIT_ACTION_EXEC_SCRIPT}" ] && [ -n "${_TMP_YAML_SPLIT_ACTION_VAR_VAL}" ] && [ "${_TMP_YAML_SPLIT_ACTION_VAR_VAL}" != "null" ]; then
		# 等于 yq '.services | keys' /root/harbor/docker-compose.yml
		local _TMP_YAML_SPLIT_ACTION_YAML_KEYS=$(echo "${_TMP_YAML_SPLIT_ACTION_VAR_VAL}" | yq "keys")
		if [ -n "${_TMP_YAML_SPLIT_ACTION_YAML_KEYS}" ] && [ "${_TMP_YAML_SPLIT_ACTION_YAML_KEYS}" != "null" ]; then
			local _TMP_YAML_SPLIT_ACTION_YAML_KEYS_LENGTH=$(echo "${_TMP_YAML_SPLIT_ACTION_YAML_KEYS}" | wc -l)
			for _TMP_YAML_SPLIT_ACTION_CURR_INDEX in $(seq 0 $((${_TMP_YAML_SPLIT_ACTION_YAML_KEYS_LENGTH}-1))); do
				# 等于yq '.services | keys | .[4]' /root/harbor/docker-compose.yml
				local _TMP_YAML_SPLIT_ACTION_SPLIT_KEY=$(echo "${_TMP_YAML_SPLIT_ACTION_YAML_KEYS}" | yq ".[${_TMP_YAML_SPLIT_ACTION_CURR_INDEX}]")
				local _TMP_YAML_SPLIT_ACTION_SPLIT_ITEM=$(echo "${_TMP_YAML_SPLIT_ACTION_VAR_VAL}" | yq ".${_TMP_YAML_SPLIT_ACTION_SPLIT_KEY}")

				# 附加动态参数
				local _TMP_YAML_SPLIT_ACTION_EXEC_SCRIPT_FINAL="${_TMP_YAML_SPLIT_ACTION_SPLIT_ITEM}"
				exec_text_printf "_TMP_YAML_SPLIT_ACTION_EXEC_SCRIPT_FINAL" "${_TMP_YAML_SPLIT_ACTION_EXEC_SCRIPT}"
				
				# 格式化运行动态脚本
				script_check_action "_TMP_YAML_SPLIT_ACTION_EXEC_SCRIPT_FINAL" "${_TMP_YAML_SPLIT_ACTION_SPLIT_ITEM}" "${_TMP_YAML_SPLIT_ACTION_CURR_INDEX}" "${_TMP_YAML_SPLIT_ACTION_SPLIT_KEY}" "${@:3}"
			done
		fi
	fi

	return $?
}
##########################################################################################################
# 路径操作类
##########################################################################################################
# 转换路径
# 参数1：原始路径变量名/值
# 示例：
#       _PATH="~/" && convert_path "_PATH"
function convert_path () {
	function _convert_path()
	{
		local _TMP_CONVERT_PATH_SOURCE=$(eval echo '${'"${1}"'}')
		local _TMP_CONVERT_PATH_CONVERT_VAL="${_TMP_CONVERT_PATH_SOURCE}"

		# 文件存在的情况
		if [ -a "${_TMP_CONVERT_PATH_SOURCE}" ]; then
			# Linux中第一个字符代表这个文件是目录、文件或链接文件等等。
			# 当为[ d ]则是目录
			# 当为[ - ]则是文件；
			# 若是[ l ]则表示为链接文档(link file)；
			# 若是[ b ]则表示为装置文件里面的可供储存的接口设备(可随机存取装置)；
			# 若是[ c ]则表示为装置文件里面的串行端口设备，例如键盘、鼠标(一次性读取装置)。
			local _TMP_CONVERT_PATH_SOURCE_ATTR=$(ls -l ${_TMP_CONVERT_PATH_SOURCE} | cut -d' ' -f1)
			case "${_TMP_CONVERT_PATH_SOURCE_ATTR:0:1}" in
			'd')
				_TMP_CONVERT_PATH_CONVERT_VAL=$(su -c "cd ${_TMP_CONVERT_PATH_SOURCE} && pwd -P")
			;;
			*)
				local _TMP_CONVERT_PATH_SOURCE_DIR=$(dirname ${_TMP_CONVERT_PATH_SOURCE})
				# 等于当前目录的文件情况，例如.env、env.exe
				if [ "${_TMP_CONVERT_PATH_SOURCE_DIR}" == "." ]; then
					_TMP_CONVERT_PATH_SOURCE_DIR=$(pwd)
					_TMP_CONVERT_PATH_SOURCE=$(pwd)/${_TMP_CONVERT_PATH_SOURCE}
				fi
				
				local _TMP_CONVERT_PATH_SOURCE_FILE=${_TMP_CONVERT_PATH_SOURCE:${#_TMP_CONVERT_PATH_SOURCE_DIR}}
				local _TMP_CONVERT_PATH_REALLY_DIR=$(su -c "cd ${_TMP_CONVERT_PATH_SOURCE_DIR} && pwd -P")
				_TMP_CONVERT_PATH_CONVERT_VAL="${_TMP_CONVERT_PATH_REALLY_DIR}${_TMP_CONVERT_PATH_SOURCE_FILE}"
			esac
		else
			local _TMP_CONVERT_PATH_WHOAMI=$(whoami)
			_TMP_CONVERT_PATH_CONVERT_VAL=$(echo "${_TMP_CONVERT_PATH_SOURCE}" | sed "s@^~@/${_TMP_CONVERT_PATH_WHOAMI}@g")
		fi

		eval ${1}='${_TMP_CONVERT_PATH_CONVERT_VAL}'
	}

	discern_exchange_var_action "${1}" "_convert_path" "${@}"
	return $?
}

# 查找软链接真实路径
# 参数1：用于查找的变量名/值
# 示例：
#       _PATH="/opt/docker/logs" && bind_symlink_link_path "_PATH"
function bind_symlink_link_path()
{
	function _bind_symlink_link_path()
	{
		local _TMP_SYMLINK_TRUE_PATH_SOURCE=$(eval echo '${'"${1}"'}')
		convert_path "_TMP_SYMLINK_TRUE_PATH_SOURCE"

		local _TMP_SYMLINK_TRUE_PATH_CONVERT_VAL=$(echo "${_TMP_SYMLINK_TRUE_PATH_SOURCE}" | sed "s@^~@/root@g")

		# 记录链接层数，有可能是死链
		local _TMP_SYMLINK_TRUE_PATH_INDEX=0
		local _TMP_SYMLINK_TRUE_PATH_TMP="${_TMP_SYMLINK_TRUE_PATH_CONVERT_VAL}"
		
		# 判断是否是绝对路径
		if [[ ${_TMP_SYMLINK_TRUE_PATH_CONVERT_VAL} =~ ^/ ]]; then
			_TMP_SYMLINK_TRUE_PATH_TMP=${_TMP_SYMLINK_TRUE_PATH_CONVERT_VAL}
		else
			# 相对路径，以.开始
			local _TMP_SYMLINK_TRUE_REL_PATH_TMP=$(echo "${_TMP_SYMLINK_TRUE_PATH_TMP}" | grep -oP '(?<=\./).+')
			if [ -n "${_TMP_SYMLINK_TRUE_REL_PATH_TMP}" ]; then
				_TMP_SYMLINK_TRUE_PATH_TMP=$(pwd)/${_TMP_SYMLINK_TRUE_REL_PATH_TMP}
			else
				_TMP_SYMLINK_TRUE_PATH_TMP=$(pwd)/${_TMP_SYMLINK_TRUE_PATH_CONVERT_VAL}
			fi
		fi
		
		while [ -h ${_TMP_SYMLINK_TRUE_PATH_TMP} ];
		do
			local _TMP_SYMLINK_TRUE_PATH_TMP_1=$(ls -ld ${_TMP_SYMLINK_TRUE_PATH_TMP} | awk '{print $NF}')
			local _TMP_SYMLINK_TRUE_PATH_TMP_2=$(ls -ld ${_TMP_SYMLINK_TRUE_PATH_TMP} | awk '{print $(NF-2)}')

			[[ ${_TMP_SYMLINK_TRUE_PATH_TMP_1} =~ ^/ ]] && _TMP_SYMLINK_TRUE_PATH_TMP=${_TMP_SYMLINK_TRUE_PATH_TMP_1} || _TMP_SYMLINK_TRUE_PATH_TMP=$(dirname ${_TMP_SYMLINK_TRUE_PATH_TMP_2})/${_TMP_SYMLINK_TRUE_PATH_TMP_1}
			
			_TMP_SYMLINK_TRUE_PATH_INDEX=$((_TMP_SYMLINK_TRUE_PATH_INDEX+1))
			if [ ${_TMP_SYMLINK_TRUE_PATH_INDEX} -gt 9 ]; then
				echo_style_text "The symlink of '${_TMP_SYMLINK_TRUE_PATH_TMP}' linked too much more depth, cannot resolve, please check, system exit."
				exit
			fi
		done

		eval ${1}='${_TMP_SYMLINK_TRUE_PATH_TMP}'
	}

	discern_exchange_var_action "${1}" "_bind_symlink_link_path" "${@}"
	return $?
}

# 交换路径，将来源迁移到指定路径，并创建软连接
# 参数1：指定路径
# 参数2：来源路径(为空则默认取还原路径)
# 示例：
#      path_swap_link "/mountdisk/data/docker" "/var/lib/docker"
#      path_swap_link "/mountdisk/conf/docker_apps/browserless_chrome/04d7d58d0a96/container" "/mountdisk/data/docker/containers/ffcf89d0c7a907ff7dd7d232f8d448e22b422364e9b28a4cb7678ed0ccb6fb18"
#      path_swap_link "/mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/container/core" "/mountdisk/data/docker/containers/d2c785c861d4dd9a93d03e1bf9dc6e7156e5495f5648dce66137c3ad5d03d881"
function path_swap_link()
{
	local _TMP_PATH_SWAP_LINK_DEST_PATH=${1}
	local _TMP_PATH_SWAP_LINK_FROM_PATH=${2}
	convert_path "_TMP_PATH_SWAP_LINK_FROM_PATH"
	bind_symlink_link_path "_TMP_PATH_SWAP_LINK_FROM_PATH"

	# 转换后路径不相同的情况
	if [[ "${_TMP_PATH_SWAP_LINK_FROM_PATH}" != "${_TMP_PATH_SWAP_LINK_DEST_PATH}" ]]; then
		# mv ${2} ${_TMP_PATH_SWAP_LINK_DEST_PATH}_clean_${LOCAL_TIMESTAMP} && ln -sf ${_TMP_PATH_SWAP_LINK_DEST_PATH} ${2}
		if [[ -a ${_TMP_PATH_SWAP_LINK_DEST_PATH} ]]; then
			mv ${_TMP_PATH_SWAP_LINK_FROM_PATH} ${_TMP_PATH_SWAP_LINK_DEST_PATH}_clean_${LOCAL_TIMESTAMP} && ln -sf ${_TMP_PATH_SWAP_LINK_DEST_PATH} ${_TMP_PATH_SWAP_LINK_FROM_PATH}
		else
			mkdir -pv $(dirname ${_TMP_PATH_SWAP_LINK_DEST_PATH}) && ([[ -a ${_TMP_PATH_SWAP_LINK_FROM_PATH} ]] && (cp -Rp ${_TMP_PATH_SWAP_LINK_FROM_PATH} ${_TMP_PATH_SWAP_LINK_DEST_PATH} && mv ${_TMP_PATH_SWAP_LINK_FROM_PATH} ${_TMP_PATH_SWAP_LINK_DEST_PATH}_clean_${LOCAL_TIMESTAMP}) || mkdir -pv $(dirname ${_TMP_PATH_SWAP_LINK_FROM_PATH}) ${_TMP_PATH_SWAP_LINK_DEST_PATH}) && ln -sf ${_TMP_PATH_SWAP_LINK_DEST_PATH} ${_TMP_PATH_SWAP_LINK_FROM_PATH}
		fi
	fi

	ls -lia ${_TMP_PATH_SWAP_LINK_FROM_PATH}
	return $?
}

# 交换软连接(不是软连接的情况下执行)
# 参数1：检测的路径
# 参数2：真实的路径 
# 参数3：交换前的动作
function exchange_softlink()
{
	local _TMP_EXCHANGE_SOFT_LINK_CHECK_PATH=${1}
	local _TMP_EXCHANGE_SOFT_LINK_TRUE_PATH=${2}
	local _TMP_EXCHANGE_SOFT_LINK_ACTION_BEFORE=${3}

	if [ -f ${_TMP_EXCHANGE_SOFT_LINK_CHECK_PATH} ]; then
		local _TMP_EXCHANGE_SOFT_LINK_CHECK_IS_LINK=$(ls -il ${_TMP_EXCHANGE_SOFT_LINK_CHECK_PATH} | grep '\->')
		if [ -z "${_TMP_EXCHANGE_SOFT_LINK_CHECK_IS_LINK}" ]; then
			script_check_action "_TMP_EXCHANGE_SOFT_LINK_ACTION_BEFORE"

			cp ${_TMP_EXCHANGE_SOFT_LINK_CHECK_PATH} ${_TMP_EXCHANGE_SOFT_LINK_TRUE_PATH} -Rp
			rm -rf ${_TMP_EXCHANGE_SOFT_LINK_CHECK_PATH}
        	ln -sf ${_TMP_EXCHANGE_SOFT_LINK_TRUE_PATH} ${_TMP_EXCHANGE_SOFT_LINK_CHECK_PATH}

			echo "Link Changed：${_TMP_EXCHANGE_SOFT_LINK_CHECK_PATH} -> ${_TMP_EXCHANGE_SOFT_LINK_TRUE_PATH}"
		fi
	else
		ln -sf ${_TMP_EXCHANGE_SOFT_LINK_TRUE_PATH} ${_TMP_EXCHANGE_SOFT_LINK_CHECK_PATH}

		echo "Linked：${_TMP_EXCHANGE_SOFT_LINK_CHECK_PATH} -> ${_TMP_EXCHANGE_SOFT_LINK_TRUE_PATH}"
    fi

	return $?
}

# 将DIRS转换为实际目录
# 参数1：结果绑定变量名，输出数组字符串
# 参数2：非真实链接时执行脚本，例如 rm -rf %s
# 示例：
#       _REALLY_DIRS=""
#       _SOURCE_DIR_ARR=()
#       _SOURCE_DIR_ARR[0]="/opt/docker/logs"
#       _SOURCE_DIR_ARR[1]="/opt/docker/data"
#       _SOURCE_DIR_ARR[2]="/opt/docker/conf"
#       _SOURCE_DIR_ARR[2]="/opt/docker"
#       bind_dirs_convert_truthful_action "_REALLY_DIRS" "${_SOURCE_DIR_ARR[*]}" "rm -rf %s"
function bind_dirs_convert_truthful_action()
{
	# 绑定变量的类型
	local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_VAR_ARR=()
	bind_discern_exchange_var_arr "_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_VAR_ARR" "${1}"
	local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_VAR_NAME=${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_VAR_ARR[0]}
	local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_VAR_TYPE=${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_VAR_ARR[1]}
	local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_VAR_VAL=${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_VAR_ARR[2]}
	local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_NT_SCRIPTS=${2}

	local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_DIR_ARR=()
	function _bind_dirs_convert_truthful_action_record()
	{
		# 指定链接
		local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_SYM_DIR="${1}"

		# 真实链接
		local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_LNK_DIR="${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_SYM_DIR}"
		bind_symlink_link_path "_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_LNK_DIR"
		
		# 如果是软链接，直接删除
		local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_MARK_TEXT=""
		if [ "${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_SYM_DIR}" != "${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_LNK_DIR}" ]; then
			_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_MARK_TEXT=", marked '${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_SYM_DIR}' → '${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_LNK_DIR}'"
			script_check_action "${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_NT_SCRIPTS}" "${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_SYM_DIR}" "${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_LNK_DIR}"
		fi
		
		# 如果数组中不存在指定链接，则添加
		# local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_PREFIX=""
		function _bind_dirs_convert_truthful_action_record_rel_arr()
		{
			if [ -a ${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_LNK_DIR} ]; then
				# 插入前长度
				local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_REALLY_DIR_ARR_LEN=${#_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_DIR_ARR[@]}

				# 绝对链接
				local _TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_ABS_DIR=${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_LNK_DIR}
				convert_path "_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_ABS_DIR"

				# 因 item_change_append_ignore_prefix_bind 不支持空数组，所以固定写一个/???
				if [ ${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_REALLY_DIR_ARR_LEN} -eq 0 ]; then
					_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_DIR_ARR[0]="${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_ABS_DIR}"
				else
					item_change_append_ignore_prefix_bind "_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_DIR_ARR" "${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_ABS_DIR}" "/"
				fi

				if [ ${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_REALLY_DIR_ARR_LEN} -ne ${#_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_DIR_ARR[@]} ]; then
					echo_style_text "Record <really> dir('${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_ABS_DIR}'${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_MARK_TEXT})"
				else
					echo_style_text "':'Ignore [really] dir('${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_ABS_DIR}'${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_MARK_TEXT})"
				fi
			else
				echo_style_text "':'Ignore [not exists] dir('${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_SYM_DIR}' → [${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_LNK_DIR}])"
			fi
		}
		
		item_not_exists_action "^${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_LNK_DIR}$" "${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_DIR_ARR[*]}" "_bind_dirs_convert_truthful_action_record_rel_arr"
	}

	items_split_action "_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_VAR_VAL" "_bind_dirs_convert_truthful_action_record"
	
	echo "${TMP_SPLITER3}"
	echo_style_text "'Finally' truthful <really> dirs got 'follows'↓:"
	echo "${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_DIR_ARR[*]}" | sed 's@ @\n@g' | sort

	if [ "${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_VAR_TYPE}" == "array" ]; then
		eval ${1}='(${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_DIR_ARR[*]})'
	else
		eval ${1}='${_TMP_BIND_DIRS_CONVERT_TRUTHFUL_ACTION_DIR_ARR[*]}'
	fi

	return $?
}

# 路径不存在执行
# 参数1：检测路径
# 参数2：执行函数或脚本
# 参数3：路径存在时输出信息
function path_not_exists_action() 
{
	local _TMP_PATH_NOT_EXISTS_ACTION_PATH=${1}
	local _TMP_PATH_NOT_EXISTS_ACTION_NE_SCRIPT=${2}
	local _TMP_PATH_NOT_EXISTS_ACTION_E_ECHO=${3}

	local _TMP_PATH_NOT_EXISTS_ACTION_E_SCRIPT=""
	if [ -n "${_TMP_PATH_NOT_EXISTS_ACTION_E_ECHO}" ]; then
		_TMP_PATH_NOT_EXISTS_ACTION_E_SCRIPT="echo_style_text '${_TMP_PATH_NOT_EXISTS_ACTION_E_ECHO}'"
	fi

	path_exists_yn_action "${1}" "${_TMP_PATH_NOT_EXISTS_ACTION_E_SCRIPT}" "${_TMP_PATH_NOT_EXISTS_ACTION_NE_SCRIPT}"
	return $?
}

# 路径存在与不存在手动确认执行函数，路径不存在时不执行任何脚本
# 参数1：检测路径
# 参数2：路径存在时的输出文本，path_exists_yn_action调用时为空则后台默认执行
# 参数3：存在时执行函数或脚本
# 参数4：路径存在时的, 选择N执行的脚本
# 参数5：不存在时执行函数或脚本
# 参数6：确认时默认的Y/N值
function path_exists_confirm_action() 
{
	local _TMP_PATH_EXISTS_CONFIRM_ACTION_PATH="${1}"
	local _TMP_PATH_EXISTS_CONFIRM_ACTION_ECHO="${2}"
	local _TMP_PATH_EXISTS_CONFIRM_ACTION_PATH_Y_SCRIPT="${3}"
	local _TMP_PATH_EXISTS_CONFIRM_ACTION_PATH_Y_N_SCRIPT="${4}"
	local _TMP_PATH_EXISTS_CONFIRM_ACTION_PATH_N_SCRIPT="${5}"
	local _TMP_PATH_EXISTS_CONFIRM_ACTION_YN_VAL="${6:-"N"}"
	
	convert_path "_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH"

	# 缺失了对文件夹的判断，修复20-12.25
	local _TMP_PATH_EXISTS_CONFIRM_ACTION_VAL=$([ -a "${_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH}" ] && echo 1 || echo 0)

	if [ ${_TMP_PATH_EXISTS_CONFIRM_ACTION_VAL} -eq 1 ]; then
		function _path_exists_confirm_action_exec()
		{
			script_check_action "_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH_Y_SCRIPT" ${_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH}
		}

		# 非path_exists_yn_action调用时才执行，这里保持函数复用
		if [ "${FUNCNAME[1]}" != "path_exists_yn_action" ]; then
			function _path_exists_confirm_action_exec_yn()
			{
				_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH_Y_SCRIPT=''
				
				script_check_action "_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH_Y_N_SCRIPT" ${_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH}
			}

			confirm_yn_action "_TMP_PATH_EXISTS_CONFIRM_ACTION_YN_VAL" "${_TMP_PATH_EXISTS_CONFIRM_ACTION_ECHO:-"The path of '${_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH}' exists, please 'sure' u will <action> 'still or not'"}" "" "_path_exists_confirm_action_exec_yn"
		fi

		_path_exists_confirm_action_exec
	else
		script_check_action "_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH_N_SCRIPT" ${_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH}

		return 0;
	fi

	return $?
}

# 路径存在执行
# 参数1：检测路径
# 参数2：执行函数或脚本
# 参数3：路径不存在时输出信息
function path_exists_action() 
{
	local _TMP_PATH_EXISTS_ACTION_PATH=${1}
	local _TMP_PATH_EXISTS_ACTION_E_SCRIPT=${2}
	local _TMP_PATH_EXISTS_ACTION_NE_ECHO=${3}

	local _TMP_PATH_EXISTS_ACTION_PATH_NOT_EXISTS_SCRIPT=""
	if [ -n "${_TMP_PATH_EXISTS_ACTION_NE_ECHO}" ]; then
		_TMP_PATH_EXISTS_ACTION_PATH_NOT_EXISTS_SCRIPT="echo '${_TMP_PATH_EXISTS_ACTION_NE_ECHO}'"
	fi

	path_exists_yn_action "${1}" "${_TMP_PATH_EXISTS_ACTION_E_SCRIPT}" "${_TMP_PATH_EXISTS_ACTION_PATH_NOT_EXISTS_SCRIPT}"
	return $?
}

# 路径存在与不存在执行函数
# 参数1：检测路径
# 参数2：存在时执行函数或脚本
# 参数3：不存在时执行函数或脚本
function path_exists_yn_action() 
{
	path_exists_confirm_action "${1}" "" "${2}" "" "${3}"
	return $?
}

# 路径不存在则创建
# 参数1：检测路径
# 参数2：路径存在时输出信息
# 参数3：创建完目录后执行函数或脚本
function path_not_exists_create() 
{
	local _TMP_PATH_NOT_EXISTS_CREATE_PATH="${1}"
	local _TMP_PATH_NOT_EXISTS_CREATE_ECHO="${2}"
	local _TMP_PATH_NOT_EXISTS_CREATE_SCRIPT="${3}"

	function _path_not_exists_create()
	{
		script_check_action "_TMP_PATH_NOT_EXISTS_CREATE_SCRIPT" "${_TMP_PATH_NOT_EXISTS_CREATE_PATH}"
	}

    path_not_exists_action "${_TMP_PATH_NOT_EXISTS_CREATE_PATH}" "mkdir -pv ${_TMP_PATH_NOT_EXISTS_CREATE_PATH} && _path_not_exists_create" "${_TMP_PATH_NOT_EXISTS_CREATE_ECHO}"
	return $?
}

# 路径不存在则链接
# 参数1：检测路径
# 参数2：路径存在时输出信息
# 参数3：源(真实)路径
# 参数4：链接完目录后执行函数或脚本
# 示例：
#      path_not_exists_link "/var/lib/docker" "" "/mountdisk/data/docker"
#      -> ln -sf /mountdisk/data/docker /var/lib/docker
function path_not_exists_link() 
{
	local _TMP_PATH_NOT_EXISTS_LINK_PATH=${1}
	local _TMP_PATH_NOT_EXISTS_LINK_ECHO=${2:-"The 'link' of <${1}> 'exists'."}
	local _TMP_PATH_NOT_EXISTS_LINK_SOUR=${3}
	local _TMP_PATH_NOT_EXISTS_LINK_SCRIPT=${4}

	function _path_not_exists_link_echo()
	{
		script_check_action "_TMP_PATH_NOT_EXISTS_LINK_SCRIPT" "${_TMP_PATH_NOT_EXISTS_LINK_SOUR}" "${_TMP_PATH_NOT_EXISTS_LINK_PATH}"
	}
	
    path_not_exists_action "${_TMP_PATH_NOT_EXISTS_LINK_PATH}" "[[ -a ${_TMP_PATH_NOT_EXISTS_LINK_SOUR} ]] && (mkdir -pv $(dirname ${_TMP_PATH_NOT_EXISTS_LINK_PATH}) && ln -sf ${_TMP_PATH_NOT_EXISTS_LINK_SOUR} ${_TMP_PATH_NOT_EXISTS_LINK_PATH} && ls -lia ${_TMP_PATH_NOT_EXISTS_LINK_PATH} && _path_not_exists_link_echo) || echo_style_text 'Source path <${_TMP_PATH_NOT_EXISTS_LINK_SOUR}> not exists, link stoped'" "${_TMP_PATH_NOT_EXISTS_LINK_ECHO}"
	return $?
}

##########################################################################################################
# 数据录入类
##########################################################################################################
# 弹出动态设置变量值函数(变量读取时，应该取最后一行)
# 参数1：默认变量名/值
# 参数2：提示信息
# 参数3：是否内容加密（默认：不显示，y/Y：密文）
# 参数4：为空时的变量名/值
function console_input()
{
	local _TMP_CONSULE_INPUT_VAR_VAL=$(echo_discern_exchange_var_val "${1}")
	local _TMP_CONSULE_INPUT_ECHO="'|'${2}"
	local _TMP_CONSULE_INPUT_VAR_SEC=${3}
	local _TMP_CONSULE_INPUT_VAR_EMPTY_VAL=$(echo_discern_exchange_var_val "${4}")
	
	# 自动样式化消息前缀 
	bind_style_text "_TMP_CONSULE_INPUT_ECHO"
	
	local _TMP_CONSULE_INPUT_INPUT_CURRENT=""
	function _TMP_CONSULE_INPUT_NORMAL_FUNC() {
		_TMP_CONSULE_INPUT_ECHO=$(printf "%s, default '%s'" "${_TMP_CONSULE_INPUT_ECHO}" "${_TMP_CONSULE_INPUT_VAR_VAL}")
		echo ${_TMP_CONSULE_INPUT_ECHO}
		read -e _TMP_CONSULE_INPUT_INPUT_CURRENT
	}
	
	function _TMP_CONSULE_INPUT_GUM_FUNC()	{
		# gum input --prompt "Please sure your country code，default：" --placeholder "HK"
		# 必须转义，否则带样式的前提下会解析冲突
		_TMP_CONSULE_INPUT_ECHO=${_TMP_CONSULE_INPUT_ECHO//\"/\\\"}
		local _TMP_CONSULE_INPUT_GUM_ARGS="--placeholder '${_TMP_CONSULE_INPUT_VAR_EMPTY_VAL:-${_TMP_CONSULE_INPUT_VAR_VAL}}' --value '${_TMP_CONSULE_INPUT_VAR_VAL}'"
		
		case ${_TMP_CONSULE_INPUT_VAR_SEC} in
			"y" | "Y")
			_TMP_CONSULE_INPUT_GUM_ARGS="${_TMP_CONSULE_INPUT_GUM_ARGS} --prompt '${reset}${_TMP_CONSULE_INPUT_ECHO}: ' --password"
			;;
		*)
			local _TMP_CONSULE_INPUT_GUM_DFT_TXT_ECHO=
			if [ -n "${_TMP_CONSULE_INPUT_VAR_VAL}" ]; then
				_TMP_CONSULE_INPUT_GUM_DFT_TXT_ECHO=", default"
			fi
			_TMP_CONSULE_INPUT_GUM_ARGS="${_TMP_CONSULE_INPUT_GUM_ARGS} --prompt '${reset}${_TMP_CONSULE_INPUT_ECHO}${_TMP_CONSULE_INPUT_GUM_DFT_TXT_ECHO}: '"
		esac

		_TMP_CONSULE_INPUT_INPUT_CURRENT=$(eval gum input ${_TMP_CONSULE_INPUT_GUM_ARGS})
		
		return $?
	}
	
	# path_exists_yn_action "${GUM_PATH}" "_${FUNCNAME[0]}_gum \"${1}\" \"${2}\"" "_TMP_CONSULE_INPUT_NORMAL_FUNC"
	path_exists_yn_action "${GUM_PATH}" "_TMP_CONSULE_INPUT_GUM_FUNC" "_TMP_CONSULE_INPUT_NORMAL_FUNC"
	
	if [[ -z "${_TMP_CONSULE_INPUT_INPUT_CURRENT}" && -n "${_TMP_CONSULE_INPUT_VAR_EMPTY_VAL}" ]]; then
		_TMP_CONSULE_INPUT_INPUT_CURRENT=${_TMP_CONSULE_INPUT_VAR_EMPTY_VAL}
	fi
	
	echo "${_TMP_CONSULE_INPUT_INPUT_CURRENT}"

	return $?
}

# 弹出动态设置变量值函数
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：是否内容加密（默认：不显示，y/Y：密文）
# 参数4：为空时的变量名/值
function bind_if_input()
{
	local _TMP_BIND_IF_INPUT_INPUT_CURRENT=$(console_input "${1}" "${2}" "${3}" "${4}")
	# 多行的情况下，只打印最后一行
	if [ $(echo "${_TMP_BIND_IF_INPUT_INPUT_CURRENT}" | wc -l) -gt 1 ]; then
		_TMP_BIND_IF_INPUT_INPUT_CURRENT=$(echo "${_TMP_BIND_IF_INPUT_INPUT_CURRENT}" | awk 'END{print}')
	fi
	
	eval ${1}='${_TMP_BIND_IF_INPUT_INPUT_CURRENT}'

	return $?
}

# 弹出动态设置变量值函数，如果为空
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：是否内容加密（默认：不显示，y/Y：密文）
# 参数4：为空时的变量名/值
function bind_empty_if_input()
{
	local _TMP_BIND_EMPTY_IF_INPUT_VAR_VAL=$(echo_discern_exchange_var_val "${1}")
	if [ -z "${_TMP_BIND_EMPTY_IF_INPUT_VAR_VAL}" ]; then
		bind_if_input "${@}"
	fi

	return $?
}

# 按键选择类型的弹出动态设置变量值函数
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：选项参数
# 参数4：自定义的Spliter
function bind_if_choice()
{
	local _TMP_BIND_IF_CHOICE_ECHO=${2}
	local _TMP_BIND_IF_CHOICE_CHOICE=${3}
	
	bind_style_text "_TMP_BIND_IF_CHOICE_ECHO"

	local _TMP_CHOICE_SPLITER=$([ -n "${TMP_SPLITER}" ] && echo "${TMP_SPLITER}" || echo "------------------------------------------------------")
	set_if_empty "_TMP_CHOICE_SPLITER" "${4}"
	local _TMP_CHOICE_SPLITER_LEN=${#_TMP_CHOICE_SPLITER}
	
	local _TMP_BIND_IF_CHOICE_ARR=(${_TMP_BIND_IF_CHOICE_CHOICE//,/ })
	local _TMP_BIND_IF_CHOICE_ARR_LEN=${#_TMP_BIND_IF_CHOICE_ARR[@]}
	
	# 编号前坠
	local _TMP_BIND_IF_CHOICE_TMP_SQ_PREFIX=""

	# X退出字符前缀
	local _TMP_BIND_IF_CHOICE_TMP_SQ_EXIT_SIGN="X"
	
	if [ ${_TMP_BIND_IF_CHOICE_ARR_LEN} -gt 10 ]; then
		_TMP_BIND_IF_CHOICE_TMP_SQ_PREFIX=$(eval printf %.s'' {1..$((${#_TMP_BIND_IF_CHOICE_ARR_LEN}-1))})
		_TMP_BIND_IF_CHOICE_TMP_SQ_EXIT_SIGN=$(eval printf %.s'X' {1..${#_TMP_BIND_IF_CHOICE_ARR_LEN}})
	fi

	function _TMP_BIND_IF_CHOICE_NORMAL_FUNC() {
		echo ${_TMP_CHOICE_SPLITER}

		for I in ${!_TMP_BIND_IF_CHOICE_ARR[@]};  
		do
			local _TMP_BIND_IF_CHOICE_NORMAL_FUNC_TMP_COLOR="${red}"
			if [ $(($I%2)) -eq 0 ]; then
				_TMP_BIND_IF_CHOICE_NORMAL_FUNC_TMP_COLOR="${green}"
			fi

			local _TMP_BIND_IF_CHOICE_NORMAL_FUNC_SIGN=$((I+1))
			local _TMP_BIND_IF_CHOICE_ITEM=${_TMP_BIND_IF_CHOICE_ARR[$I]}
			if [ $(echo "${_TMP_BIND_IF_CHOICE_ITEM}" | tr 'A-Z' 'a-z') == "exit" ]; then
				echo ${_TMP_CHOICE_SPLITER}
				_TMP_BIND_IF_CHOICE_NORMAL_FUNC_SIGN=${_TMP_BIND_IF_CHOICE_TMP_SQ_EXIT_SIGN}
			else
				if [ ${I} -ge 9 ]; then
					_TMP_BIND_IF_CHOICE_TMP_SQ_PREFIX=""
				fi
			fi
			
			fill_right "_TMP_BIND_IF_CHOICE_ITEM" "" $((${_TMP_CHOICE_SPLITER_LEN}-${#_TMP_BIND_IF_CHOICE_TMP_SQ_EXIT_SIGN}-10)) "|     [${_TMP_BIND_IF_CHOICE_NORMAL_FUNC_SIGN}]${_TMP_BIND_IF_CHOICE_TMP_SQ_PREFIX}${_TMP_BIND_IF_CHOICE_NORMAL_FUNC_TMP_COLOR}%${reset}|"
			
			echo "${_TMP_BIND_IF_CHOICE_ITEM}"
		done
		
		echo ${_TMP_CHOICE_SPLITER}

		if [ -n "${_TMP_BIND_IF_CHOICE_ECHO}" ]; then
			echo_style_text "${_TMP_BIND_IF_CHOICE_ECHO}, by 'above keys', then <enter> it"
		fi
		
		if [ ${_TMP_BIND_IF_CHOICE_ARR_LEN} -le 10 ]; then
			read -n 1 KEY
		else
			read KEY
		fi

		_TMP_BIND_IF_CHOICE_NEW_VAL=${_TMP_BIND_IF_CHOICE_ARR[$((KEY-1))]}

		echo

		return $?
	}
	
	function _TMP_BIND_IF_CHOICE_GUM_FUNC() {		
		for I in ${!_TMP_BIND_IF_CHOICE_ARR[@]};  
		do
			local _TMP_BIND_IF_CHOICE_NORMAL_FUNC_TMP_COLOR=170
			if [ $(($I%2)) -eq 0 ]; then
				_TMP_BIND_IF_CHOICE_NORMAL_FUNC_TMP_COLOR=180
			fi

			local _TMP_BIND_IF_CHOICE_GUM_FUNC_SIGN=$((I+1))
						
			local _TMP_BIND_IF_CHOICE_ITEM=${_TMP_BIND_IF_CHOICE_ARR[$I]}
			if [ $(echo "${_TMP_BIND_IF_CHOICE_ITEM}" | tr 'A-Z' 'a-z') == "exit" ]; then
				_TMP_BIND_IF_CHOICE_GUM_FUNC_SIGN=${_TMP_BIND_IF_CHOICE_TMP_SQ_EXIT_SIGN}
			else
				if [ ${I} -ge 9 ]; then
					_TMP_BIND_IF_CHOICE_TMP_SQ_PREFIX=""
				fi
			fi

			fill_right "_TMP_BIND_IF_CHOICE_ITEM" "" $((_TMP_CHOICE_SPLITER_LEN-11)) "[${_TMP_BIND_IF_CHOICE_GUM_FUNC_SIGN}]${_TMP_BIND_IF_CHOICE_TMP_SQ_PREFIX}$(gum style --foreground ${_TMP_BIND_IF_CHOICE_NORMAL_FUNC_TMP_COLOR} \"%\")"
			_TMP_BIND_IF_CHOICE_ARR[$I]="\"${_TMP_BIND_IF_CHOICE_ITEM}\""
		done

		local _TMP_BIND_IF_CHOICE_ARR_STR=$(IFS=' '; echo "${_TMP_BIND_IF_CHOICE_ARR[*]}")
		if [ -z "${_TMP_BIND_IF_CHOICE_ARR_STR}" ]; then
			echo
			echo_style_text "'No choice' set, please check your 'str arr'"

			return 0
		fi

		local _TMP_BIND_IF_CHOICE_GUM_CHOICE_SCRIPT="gum choose --cursor='|>' --selected-prefix '[✓] ' ${_TMP_BIND_IF_CHOICE_ARR_STR} | tr -d '' | cut -d ']' -f2"
		if [ -n "${_TMP_BIND_IF_CHOICE_ECHO}" ]; then
			echo_style_text "${_TMP_BIND_IF_CHOICE_ECHO}, by 'follow keys', then <enter> it"
		fi
		
		_TMP_BIND_IF_CHOICE_NEW_VAL=$(eval ${_TMP_BIND_IF_CHOICE_GUM_CHOICE_SCRIPT})

		return $?
	}

	local _TMP_BIND_IF_CHOICE_NEW_VAL=""
	
	path_exists_yn_action "${GUM_PATH}" "_TMP_BIND_IF_CHOICE_GUM_FUNC" "_TMP_BIND_IF_CHOICE_NORMAL_FUNC"	
	
	echo "Choice of '${_TMP_BIND_IF_CHOICE_NEW_VAL//√/}' checked"

	# eval ${1}=$(echo "${_TMP_BIND_IF_CHOICE_NEW_VAL}" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")
	eval ${1}=$(echo "${_TMP_BIND_IF_CHOICE_NEW_VAL}" | sed -r "s/\x1B\[(([0-9]+)(;[0-9]+)*)?[m,K,H,f,J]//g")
	
	return $?
}

# 选中列表再执行
# 参数1：选中数组字符串，标记√的选中
# 参数2：选择所弹出的提示文本
# 参数3：选择后执行
#       参数1：标记的选中值
#       参数2：标记选中是否选中，为空则为未选中值
# 示例：
#       mark_if_choice_action "_CHOICE_BIND" "please sure which item u want to choice" "_funca"
function mark_if_choice_action()
{
	local _TMP_MARK_IF_CHOICE_ACTION_ITEMS_COUNT=$(echo "${1}" | grep -oP "(?<=^)[^]+" | wc -w)
	local _TMP_MARK_IF_CHOICE_ACTION_ITEM=$(echo "${1}" | grep -v '√' | awk 'NR==1')

	# 有多个版本时，才提供选择操作
	if [ ${_TMP_MARK_IF_CHOICE_ACTION_ITEMS_COUNT} -gt 1 ]; then
		echo "${TMP_SPLITER2}"
		bind_if_choice "_TMP_MARK_IF_CHOICE_ACTION_ITEM" "${2}" "${1}"
	else
		_TMP_MARK_IF_CHOICE_ACTION_ITEM="${1}"
	fi
	
	local _TMP_MARK_IF_CHOICE_ACTION_NONE_MARK_ITEM=$(echo "${_TMP_MARK_IF_CHOICE_ACTION_ITEM}" | grep -oP "(?<=^)[^]+")
	local _TMP_MARK_IF_CHOICE_ACTION_INSTALL_OUTPUT=$([[ "${_TMP_MARK_IF_CHOICE_ACTION_NONE_MARK_ITEM}" != "${_TMP_MARK_IF_CHOICE_ACTION_ITEM}" ]] && echo 1)

	script_check_action "${3}" "${_TMP_MARK_IF_CHOICE_ACTION_NONE_MARK_ITEM}" "${_TMP_MARK_IF_CHOICE_ACTION_INSTALL_OUTPUT}"
    return $?
}

# 按键选择类型的弹出动态设置变量值函数
# 参数1：需要设置的变量名/值
# 参数2：提示信息
# 参数3：选项参数
# 参数4：自定义的Spliter
# 参数5：脚本路径/前缀
# 参数6：执行脚本后的操作
function exec_if_choice_custom()
{
	typeset -l _TMP_EXEC_IF_CHOICE_CUSTOM_VAR_VAL

	local _TMP_EXEC_IF_CHOICE_CUSTOM_VAR_PAIR=()
	bind_discern_exchange_var_pair "_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_PAIR" "${1}"
	local _TMP_EXEC_IF_CHOICE_CUSTOM_VAR_NAME=${_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_PAIR[0]}
	local _TMP_EXEC_IF_CHOICE_CUSTOM_VAR_VAL=${_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_PAIR[1]}

	# 非首次运行时，清理命令台
	if [ "${_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_VAL}" != "tmp_choice_ctx" ]; then
		clear
	fi

	function _exec_if_choice_custom()
	{
		bind_if_choice "${@:1:4}"

		_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_VAL=$(eval echo '${'"${1}"'}')
	}

	discern_exchange_var_action "${1}" "_exec_if_choice_custom" "${@}"

	if [ -n "${_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_VAL}" ]; then
		if [ "${_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_VAL}" = "exit" ]; then
			exit 1
		fi

		if [ "${_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_VAL}" = "..." ]; then
			return $?
		fi
		
		if [ -n "$5" ]; then
			local _TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH="${5}/${_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_VAL}"
			local _TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH_ARR=(${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH})
			_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH_ARR[1]=$(echo "${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}" | sed "s@-@.@g")
			_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH_ARR[2]=$(echo "${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}" | sed "s@-@_@g")
			_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH_ARR[3]=$(echo "${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}" | sed "s@_@-@g")
			_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH_ARR[4]=$(echo "${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}" | sed "s@_@.@g")
			_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH_ARR[5]=$(echo "${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}" | sed "s@\.@-@g")
			_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH_ARR[6]=$(echo "${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}" | sed "s@\.@_@g")
			_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH_ARR[7]=$(echo "${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}" | sed "s@ @-@g")
			_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH_ARR[8]=$(echo "${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}" | sed "s@ @_@g")
			_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH_ARR[9]=$(echo "${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}" | sed "s@ @.@g")

			# 识别文件转换
			for _TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH in ${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH_ARR[@]}; do
				if [ -f "${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}.sh" ]; then
					_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH="${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}.sh"
					break
				fi
			done

			if [ ! -f "${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}" ];then
				script_check_action "${5}${_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_VAL}"
			else
				source ${_TMP_EXEC_IF_CHOICE_CUSTOM_SCRIPT_PATH}
			fi
		else
			script_check_action "${_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_VAL}"
		fi
		
		local _TMP_EXEC_IF_CHOICE_CUSTOM_TMP_RETURN=$?
		#返回非0，跳出循环，指导后续请求不再进行
		if [ ${_TMP_EXEC_IF_CHOICE_CUSTOM_TMP_RETURN} != 0 ]; then
			return ${_TMP_EXEC_IF_CHOICE_CUSTOM_TMP_RETURN}
		fi

		# if [ "${_TMP_EXEC_IF_CHOICE_CUSTOM_VAR_VAL}" != "..." ]; then
		# 	read -n 1 -p "Press <Enter> go on..."
		# fi

		if [ -n "${6}" ]; then
			eval "${6}"
		fi
	fi

	return $?
}

# 按键选择类型的弹出动态设置变量值函数
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：选项参数
# 参数4：自定义的Spliter
# 参数5：脚本路径/前缀
function exec_if_choice()
{
	exec_if_choice_custom "${1}" "${2}" ${3} "${4}" "${5}" 'exec_if_choice "${1}" "${2}" ${3} "${4}" "${5}"'
	return $?
}

# 按键选择类型的弹出动态设置变量值函数
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：选项参数
# 参数4：自定义的Spliter
# 参数5：脚本路径/前缀
function exec_if_choice_onece()
{
	exec_if_choice_custom "${1}" "${2}" ${3} "${4}" "${5}"
	return $?
}

# 参照某类软件安装流程化（自定义或默认执行）操作，例：mysql/redis/postgres
# 参数1：软件名称
# 参数2：自定义时执行
# 参数3：默认时执行
function confirm_soft_setup_step_action()
{
    local _TMP_CONFIRM_SOFT_SETUP_STEP_ACTION_USE_CUSTOM="Y"
    confirm_yn_action "_TMP_CONFIRM_SOFT_SETUP_STEP_ACTION_USE_CUSTOM" "Please 'sure' u will use <${1}> [custom] 'still or not'" "${2}" "${3}"
	return $?
}

# 参照某类软件安装流程化（自定义或默认执行）操作，例：mysql/redis/postgres
# 参数1：PSQL 默认主机地址
# 参数2：PSQL 默认主机端口
# 参数3：PSQL 新建用户登录名
# 参数4：PSQL 新建用户登录密码
# 参数5：PSQL 新建用户授权Database
# 参数6：自定义时执行
# 参数7：默认时执行
function confirm_postgresql_setup_step_action()
{
    local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST=${1}
    local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT=${2}
    local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME=${3}
    local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_PASSWORD=${4}
    local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB=${5}

    local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CUSTOM_SCRIPT="${6}"
    local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_DEPENDS_SCRIPT="${7}"
	function _confirm_postgresql_setup_step_action_custom()
	{
		    local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LCL_CTNS=$(docker ps -a --no-trunc | awk "{if(\$2~\"postgres\"){ print \$2\":\"\$1}}")
        # local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LCL_CTNS=$(docker ps -a --no-trunc | awk "{ print \$2\":\"\$1}")

        # 选择修改的容器
        local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_CHOICE="${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LCL_CTNS}"
        ## 大于一条，则开启选择是否使用 自定义的本地容器
        local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LCL_CTN_COUNTS=$(echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LCL_CTNS}" | wc -l)
        if [ $(echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LCL_CTN_COUNTS}-1" | bc) -gt 0 ]; then
            # local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_USE_LOCAL="Y"
            # confirm_yn_action "_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_USE_LOCAL" "Checked 'depends' <postgresql> on [local] was exists, please 'sure' u will use 'still or not'" "__soft_cmd_check_confirm_git_action '${1}'" "echo_style_text \"Checked 'command'(<${1}>-'git') was ${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC}ed\""
            bind_if_choice "_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_CHOICE" "Please choice which 'container' u want to execute on" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LCL_CTNS}"
        fi

        _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST="${LOCAL_HOST}"
        _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT=15432
        local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER="postgres"
        local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD=

        local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID=$(echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_CHOICE}" | cut -d':' -f3)
        if [ -n "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" ]; then
            local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_RUNLIKE=$(su_bash_env_conda_channel_exec "runlike ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}")    
            if [ -z "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_RUNLIKE}" ]; then
                echo_style_text "Cannot print 'runlike' from 'container' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}>"
                exit -1
            fi
            
            local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT_PAIR=$(echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_RUNLIKE}" | grep -oP "(?<=-p )[0-9|:]+(?=\s*)")

            _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT=$(echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT_PAIR}" | cut -d':' -f1)
            _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD=$(echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_RUNLIKE}" | grep -oP "(?<=--env=POSTGRES_PASSWORD=)\S+")
        fi
        
        _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST=$(console_input "_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST" "Please ender your 'postgres' <root host>")
        if [ "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}" == "${LOCAL_HOST}" ]; then
            _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST="127.0.0.1"
        fi

        _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT=$(console_input "_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT" "Please ender your 'postgres' <root host port> of [${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}]")

        if [[ "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}" != "127.0.0.1" && "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}" != "localhost" ]]; then
            _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER=$(console_input "_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER" "Please ender your 'postgres' <root user> of [${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}]:[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT}]")
        fi

        if [[ "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}" != "127.0.0.1" && "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}" != "localhost" ]]; then
            _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD=$(console_input "_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD" "Please ender your 'postgres' <password> of [${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER}]@[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}]:[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT}]" "y")
        fi

        # _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_PASSWORD=$(rand_simple_passwd 'mattermost' 'db' "${TMP_DC_CPL_MTTM_SETUP_VER}")

        # !!!此处之所以分为多段，且用-d后台执行&重启进程，纯属因DEBUG过程中，每次执行脚本时用户或DB创建了，但是进程被阻塞所致。
        local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CREATE_DB_SH=$(cat <<EOF
# CREATE DATABASE ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB} OWNER '${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}' WITH ENCODING 'UTF8';
PGPASSWORD='${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD}' psql -h ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST} -p ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT} -U ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER} -d postgres << ${EOF_TAG} 
CREATE DATABASE ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB} WITH ENCODING 'UTF8';
${EOF_TAG}
EOF
)
        
        local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_SET_MASTER_USR_SH=$(cat <<EOF
# CREATE USER ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME} WITH PASSWORD '${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_PASSWORD}';
# ALTER ROLE "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}" WITH LOGIN;
# PGPASSWORD="${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD}" psql -h ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST} -p ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT} -U ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER} -d postgres -c "CREATE ROLE ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME} LOGIN ENCRYPTED PASSWORD '${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_PASSWORD}';"
PGPASSWORD='${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD}' psql -h ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST} -p ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT} -U ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER} -d postgres << ${EOF_TAG} 
CREATE USER ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME} LOGIN CONNECTION LIMIT -1 ENCRYPTED PASSWORD '${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_PASSWORD}';
${EOF_TAG}
EOF
)

        local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_SCHEMA_SH=$(cat <<EOF
PGPASSWORD="${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD}" psql -h ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST} -p ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT} -U ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER} -d postgres << ${EOF_TAG}
\c ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB};
\c - postgres;
GRANT ALL ON SCHEMA public TO ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME};
${EOF_TAG}
EOF
)

        local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_PRIVILEGES_SH=$(cat <<EOF
PGPASSWORD="${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD}" psql -h ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST} -p ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT} -U ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER} -d postgres << ${EOF_TAG}
\c ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB};
\c - postgres;
GRANT ALL PRIVILEGES ON DATABASE ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB} TO ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME};
${EOF_TAG}
EOF
)
     
        local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_OWNER_SH=$(cat <<EOF
PGPASSWORD="${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD}" psql -h ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST} -p ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT} -U ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER} -d postgres -c "ALTER DATABASE ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB} OWNER TO ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME};"
EOF
)

        # 如果在本地存在docker环境的postgres
        # ??? 如果在本地存在 postgres 客户端
        if [ -n "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" ]; then
            # 插入并执行SQL脚本
            echo_style_text "Starting 'create' <database> [${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}] backend..."
            docker_bash_channel_echo_exec "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CREATE_DB_SH}" "/tmp/init_${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}_${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}_${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}_db.sh" "." 'td' 'postgres'     
            
            echo_style_text "Starting 'create' <user> [${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}] backend..."
            docker_bash_channel_echo_exec "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_SET_MASTER_USR_SH}" "/tmp/init_${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}_${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}_${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}_usr.sh" "." 'td' 'postgres'

            # 修改配置完重启（第一次）
            if [[ "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}" == "127.0.0.1" || "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}" == "localhost" ]]; then  
                docker_bash_channel_exec "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" "pg_ctl restart && echo" "" "postgres"
            else
                echo_style_text "If u cannot create 'database' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}> or 'user' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}> on host [${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}], pls check manual or kill thread('pg_ctl restart') on command"
            fi

            # !!! 阻塞TAG检测，即已经创建了对应的DB的情况下，不会再进行流程阻塞验证
            # local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CREATE_BLOCK_TAG=$(docker_bash_channel_exec "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" "psql -lqt | cut -d \| -f1 | grep -oP \"(?<= )\w+\" | grep -w \"${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}\"" "t" "postgres")
            local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CREATE_BLOCK_TAG=$(docker_bash_channel_exec "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" "PGPASSWORD='${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD}' psql -h ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST} -p ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT} -U ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER} -lqt | cut -d \| -f1 | grep -oP '(?<= )\w+' | grep -w '${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}'" "t" "postgres")
            if [ -z "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CREATE_BLOCK_TAG}" ]; then
                echo_style_text "Pls check 'database' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}> and 'user' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}> [exists] on [${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER}]@[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}]:[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT}], then <ender> 'any key' to go on..."
                read -e _
            fi

            echo_style_text "Starting 'grant' <database>:[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}] to <user>:[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}] backend..."
            docker_bash_channel_exec "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_OWNER_SH}" "td" "postgres"
            docker_bash_channel_exec "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_SCHEMA_SH}" "td" "postgres"
            docker_bash_channel_exec "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_PRIVILEGES_SH}" "td" "postgres"
            
            # 修改配置完重启（第二次）
            if [[ "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}" == "127.0.0.1" || "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}" == "localhost" ]]; then  
                docker_bash_channel_exec "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" "pg_ctl restart && echo" "" "postgres"
            else
                echo_style_text "If u cannot grant 'database' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}> or 'user' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}> permission on host [${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}], pls check manual or kill thread('pg_ctl restart') on command"
            fi

            if [ -z "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CREATE_BLOCK_TAG}" ]; then
                echo_style_text "Pls check 'database' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}> and 'user' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}> [permission] on [${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER}]@[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}]:[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT}], then <ender> 'any key' to go on..."
                read -e _
            fi

            local _TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_DISPLAY_SH=$(cat <<EOF
echo
# REVOKE CONNECT ON DATABASE ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB} FROM ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME};
# REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME};
# REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME};
# REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME};
# REVOKE ALL ON SCHEMA public FROM ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME};
# DROP USER ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME};
PGPASSWORD="${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_PASSWORD}" psql -h ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST} -p ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT} -U ${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER} -d postgres << ${EOF_TAG}
\l
\du
SELECT * FROM pg_user;
${EOF_TAG}
EOF
)
            
            echo_style_text "Starting 'display grant' <database>:[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}] to <user>:[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}]..."
            docker_bash_channel_echo_exec "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CTN_ID}" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_DISPLAY_SH}" "/tmp/grant_${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}_${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}_${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}_permission.sh" "." "t"
        else
            echo_style_text "Pls 'execute follow scripts manual' on <remote postgres> [service]："
            echo "${TMP_SPLITER}"
            echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CREATE_DB_SH}"
            echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_SET_MASTER_USR_SH}"
            echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_OWNER_SH}"
            echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_SCHEMA_SH}"
            echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_PRIVILEGES_SH}"
            echo "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_GRANT_DISPLAY_SH}"
            echo "${TMP_SPLITER}"
            echo_style_text "If u cannot create 'database' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}> or 'user' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}>, pls check manual or kill thread('pg_ctl restart') on command"
            echo_style_text "Pls check 'database' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}> and 'user' <${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}> exists on [${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_ROOT_USER}]@[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}]:[${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT}], then <ender> 'any key' to go on..."
            read -e _
        fi

		script_check_action "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_CUSTOM_SCRIPT}" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_HOST}" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_PORT}" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_NAME}" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_LOGIN_PASSWORD}" "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_MAIN_DB}"
	}

	function _confirm_postgresql_setup_step_action_depens()
	{
		script_check_action "${_TMP_CONFIRM_POSTGRESQL_SETUP_STEP_ACTION_DEPENDS_SCRIPT}"
	}

	confirm_soft_setup_step_action "postgresql" "_confirm_postgresql_setup_step_action_custom" "_confirm_postgresql_setup_step_action_depens"
	return $?
}

##########################################################################################################
# 文件操作类
##########################################################################################################
# 查询内容所在行
# 参数1：文件路径
# 参数2：关键字
# 示例：
#      echo_line "_LINE_ROW_CONTENT" "/usr/lib/systemd/system/docker.service" "User="
#      -> 10:User=docker -> 10
function echo_line()
{
	cat ${1} | grep -nE "${2}" | sort | awk 'NR==1' | cut -d':' -f1

	return $?
}

# 查询内容所在行
# 参数1：需要设置的变量名
# 参数2：文件路径
# 参数3：关键字
# 示例：
#      bind_line "_LINE_ROW_CONTENT" "/usr/lib/systemd/system/docker.service" "User="
#      -> 10:User=docker -> 10
function bind_line()
{
	function _bind_line()
	{
		local TMP_KEY_WORDS_LINE=$(echo_line "${2}" "${3}")

		eval ${1}='$TMP_KEY_WORDS_LINE'
	}

	discern_exchange_var_action "${1}" "_bind_line" "${@}"
	return $?
}

# 关键行插入
# 参数1：文件路径
# 参数2：关键字
# 参数3：插入内容
# 示例：
#      curx_line_insert "/etc/sudoer" "^## Allows people in group wheel" "docker    ALL=(ALL)       ALL"
function curx_line_insert()
{
	local _TMP_CURX_LINE_INSERT_CURX_LINE=$(echo_line "${1}" "${2}")

	if [ ${_TMP_CURX_LINE_INSERT_CURX_LINE:-0} -gt 0 ]; then
		# 插入行内容相同则不插入
		local _TMP_CURX_LINE_INSERT_LINE=$((_TMP_CURX_LINE_INSERT_CURX_LINE+1))
		local _TMP_CURX_LINE_INSERT_TEXT=$(cat ${1} | awk "NR==${_TMP_CURX_LINE_INSERT_LINE}")
		if [ "${_TMP_CURX_LINE_INSERT_TEXT}" != "${3}" ]; then
			sed -i "${_TMP_CURX_LINE_INSERT_LINE}i ${3}" ${1}
		fi
	fi
	
	return $?
}

##########################################################################################################
# 环境操作类
##########################################################################################################
# 通过指定用户，通过管道执行脚本
# 参数1：环境内容
# 参数2：格式化内容
# 示例：
#   env_format_echo 'A=123' '${A}'
function env_format_echo()
{
	# local _TMP_ENV_FORMAT_ECHO_ENV="${1}"
	# local _TMP_ENV_FORMAT_ECHO_TEMPLATE="${2}"

	sh -c "${1}

cat <<EOF
${2}
EOF"
	return $?
}

# 通过指定用户，通过管道执行脚本
# 参数1：环境内容路径
# 参数2：格式化内容路径
# 示例：
#       env_file_format_echo '.env' 'docker-compose.yml'
function env_file_format_echo()
{
	env_format_echo "$(cat ${1})" "$(cat ${2})"
	return $?
}

##########################################################################################################
# 管道操作类
##########################################################################################################
# 通过指定用户，通过管道执行脚本
# 参数1：执行脚本
# 参数2：执行用户，默认$(whoami)
# 示例：
#   su_bash_channel_exec "source /etc/profile && source ~/.bashrc && conda update -y conda"
function su_bash_channel_exec()
{
	local _TMP_SU_BASH_CHANNEL_EXEC_SCRIPTS=${1:-"echo"}
    local _TMP_SU_BASH_CHANNEL_EXEC_USER=${2:-$(whoami)}
	local _TMP_SU_BASH_CHANNEL_EXEC_DEFAULT_DIR=$(pwd)

	# 用户默认目录
	local _TMP_SU_BASH_CHANNEL_EXEC_USER_HOME=$(su - ${_TMP_SU_BASH_CHANNEL_EXEC_USER} -c "pwd")

	# 尝试进入
	su - ${_TMP_SU_BASH_CHANNEL_EXEC_USER} -c "cd ${_TMP_SU_BASH_CHANNEL_EXEC_DEFAULT_DIR}" 2&>/dev/null || _TMP_SU_BASH_CHANNEL_EXEC_DEFAULT_DIR="${_TMP_SU_BASH_CHANNEL_EXEC_USER_HOME}"
	su - ${_TMP_SU_BASH_CHANNEL_EXEC_USER} -c "cd ${_TMP_SU_BASH_CHANNEL_EXEC_DEFAULT_DIR}" 2&>/dev/null || _TMP_SU_BASH_CHANNEL_EXEC_DEFAULT_DIR=""

	local _TMP_SU_BASH_CHANNEL_EXEC_BASIC_SCRIPT="cd ${_TMP_SU_BASH_CHANNEL_EXEC_DEFAULT_DIR}"
	su - ${_TMP_SU_BASH_CHANNEL_EXEC_USER} -c "${_TMP_SU_BASH_CHANNEL_EXEC_BASIC_SCRIPT} && (${_TMP_SU_BASH_CHANNEL_EXEC_SCRIPTS})"

	return $?
}

# 通过指定用户，通过管道执行脚本
# 参数1：执行脚本
# 参数2：执行用户，默认$(whoami)
# 示例：
#   su_bash_env_channel_exec "conda update conda"
function su_bash_env_channel_exec()
{
	local _TMP_SU_BASH_ENV_CHANNEL_EXEC_USER=${2:-$(whoami)}
	local _TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT="source /etc/profile && source /etc/bashrc"

	# 用户默认目录
	local _TMP_SU_BASH_ENV_CHANNEL_EXEC_USER_HOME=$(su - ${_TMP_SU_BASH_ENV_CHANNEL_EXEC_USER} -c "pwd")

	if [[ -a ${_TMP_SU_BASH_ENV_CHANNEL_EXEC_USER_HOME}/.bashrc ]]; then
		_TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT="${_TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT} && source ${_TMP_SU_BASH_ENV_CHANNEL_EXEC_USER_HOME}/.bashrc"
	fi

	if [ "${_TMP_SU_BASH_ENV_CHANNEL_EXEC_USER}" == "root" ]; then
		if [[ -a /${_TMP_SU_BASH_ENV_CHANNEL_EXEC_USER}/.bashrc ]]; then
			_TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT="${_TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT} && source /${_TMP_SU_BASH_ENV_CHANNEL_EXEC_USER}/.bashrc"
		fi
	fi

	su_bash_channel_exec "${_TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT} && (${1})" "${_TMP_SU_BASH_ENV_CHANNEL_EXEC_USER}"

	return $?
}

# 通过指定用户，通过管道执行脚本
# 参数1：执行脚本
# 参数2：执行用户，默认$(whoami)
# 示例：
#   su_bash_nvm_channel_exec "conda update conda"
function su_bash_nvm_channel_exec()
{
	local _TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT="[[ -a '${NVM_PATH}' ]] && source ${NVM_PATH}"
	su_bash_channel_exec "${_TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT} && (${1})" "${2}"

	return $?
}

# 通过指定用户，指定conda环境下，通过管道执行脚本
# 参数1：执行脚本
# 示例：
#   su_bash_conda_channel_exec 'condabin/conda info'
#	su_bash_conda_channel_exec "cd ${PLAYWRIGHT_SCRIPTS_DIR} && python py/pw_sync_fetch_docker_hub_vers.py 'labring/sealos'"
function su_bash_conda_channel_exec()
{
	local _TMP_SU_BASH_CONDA_CHANNEL_EXEC_SCRIPTS=${1:-"echo"}

	local _TMP_SU_BASH_CONDA_CHANNEL_EXEC_CONDA_HOME="${CONDA_HOME}"
	if [ -z "${_TMP_SU_BASH_CONDA_CHANNEL_EXEC_CONDA_HOME}" ]; then
		# _TMP_SU_BASH_CONDA_CHANNEL_EXEC_CONDA_HOME=$(whereis conda | awk '{print $2}' | awk -F'/' '{print "/"$2"/"$3}')
		_TMP_SU_BASH_CONDA_CHANNEL_EXEC_CONDA_HOME=$(whereis conda | awk '{print $2}' | xargs dirname | xargs dirname)
	fi
	
	local _TMP_SU_BASH_CONDA_CHANNEL_EXEC_BASIC_SCRIPT="CONDA_HOME=\${CONDA_HOME:-${_TMP_SU_BASH_CONDA_CHANNEL_EXEC_CONDA_HOME}} && PATH=\$CONDA_HOME/bin:\$PATH && export CONDA_HOME PATH"
	su_bash_env_channel_exec "${_TMP_SU_BASH_CONDA_CHANNEL_EXEC_BASIC_SCRIPT} && (${_TMP_SU_BASH_CONDA_CHANNEL_EXEC_SCRIPTS})" "conda"

	return $?
}

# 通过指定用户，指定conda环境下，通过管道执行脚本
# 参数1：执行脚本
# 参数2：pyenv环境，默认${PY_ENV}
# 示例：
#	su_bash_env_conda_channel_exec "cd ${PLAYWRIGHT_SCRIPTS_DIR} && python py/pw_sync_fetch_docker_hub_vers.py 'labring/sealos'"
function su_bash_env_conda_channel_exec()
{
    local _TMP_SU_BASH_CHANNEL_CONDA_ENV_EXEC_ENV=${2:-"${PY_ENV}"}

	su_bash_env_channel_exec "conda activate ${_TMP_SU_BASH_CHANNEL_CONDA_ENV_EXEC_ENV} && (${1})" "conda"
	# su_bash_conda_channel_exec "conda activate ${_TMP_SU_BASH_CHANNEL_CONDA_ENV_EXEC_ENV} && (${1})"

	return $?
}

# 通过指定用户，指定conda环境下，通过管道执行脚本
# 参数1：pyenv环境名称
# 参数2：pyenv环境对应python版本
# 示例：
#      su_bash_conda_create_env 'pyenv37' '3.7'
function su_bash_conda_create_env()
{
    echo_style_wrap_text "Starting 'create' <conda> env(<${1}> [python==${2}]), hold on please"
	local _TMP_SU_BASH_CONDA_CREATE_ENV_BASIC_SCRIPT="conda info -e | cut -d' ' -f1 | grep -v '#' | grep -v 'base' | grep -v '^$' | egrep '${1}'"
	su_bash_conda_channel_exec "(${_TMP_SU_BASH_CONDA_CREATE_ENV_BASIC_SCRIPT}) || conda create -n ${1} -y python=${2}"

	# 安装失败检测
	if [ -z "$(su_bash_conda_channel_exec "${_TMP_SU_BASH_CONDA_CREATE_ENV_BASIC_SCRIPT}")" ]; then
		echo_style_text "Cannot 'create' <conda> env(<${1}> [python==${2}]), retry"
		su_bash_conda_create_env "${@}"
	fi
	
	# 过期库更新
	local _TMP_SU_BASH_CONDA_CREATE_ENV_OUT_DATED=$(su_bash_env_conda_channel_exec "pip list --outdated | awk 'NR>2{print \$1}' && conda deactivate" "${1}")
	if [ -n "${_TMP_SU_BASH_CONDA_CREATE_ENV_OUT_DATED}" ]; then
		su_bash_env_conda_channel_exec "echo '${_TMP_SU_BASH_CONDA_CREATE_ENV_OUT_DATED}' | xargs pip install --ignore-installed --upgrade && conda deactivate" "${1}"
	fi
	
	return $?
}

# 通过指定用户，指定conda环境下，通过管道执行脚本
# 参数1：需要输出的内容
# 参数2：内容匹配正则
# 参数1：pyenv环境名称
# 示例：
#      su_bash_conda_echo_profile "export DISPLAY=:0" 
#      su_bash_conda_echo_profile "export DISPLAY=:0" "^export DISPLAY:=0$"
#      su_bash_conda_echo_profile "export DISPLAY=:0" "" 'pyenv37'
function su_bash_conda_echo_profile()
{
	local _TMP_SU_BASH_CONDA_ECHO_PROFILE_HOME_CONDA=$(su - conda -c "pwd")
	local _TMP_SU_BASH_CONDA_ECHO_PROFILE_BASIC_SCRIPT="egrep '${2:-^${1}$}' ${_TMP_SU_BASH_CONDA_ECHO_PROFILE_HOME_CONDA}/.bashrc >& /dev/null"
	su_bash_env_conda_channel_exec "(${_TMP_SU_BASH_CONDA_ECHO_PROFILE_BASIC_SCRIPT}) || echo '${1}' >> ${_TMP_SU_BASH_CONDA_ECHO_PROFILE_HOME_CONDA}/.bashrc && conda deactivate" "${3}"
	
	return $?
}

# 通过指定用户，通过管道执行脚本
# 参数1：容器ID
# 参数2：执行脚本
# 参数3：管道参数
# 参数4：执行用户，默认$(whoami)
# 参数5：工作目录
# 示例：
#       docker_bash_channel_exec "" "whoami" 
#       docker_bash_channel_exec "" "whoami" "t"
#       docker_bash_channel_exec "" "whoami" "td"
#       docker_bash_channel_exec "" "whoami" "" "root"
function docker_bash_channel_exec()
{
	local _TMP_DOCKER_BASH_CHANNEL_EXEC_CTN_ID=${1}
	local _TMP_DOCKER_BASH_CHANNEL_EXEC_SCRIPTS=${2:-"echo"}
    local _TMP_DOCKER_BASH_CHANNEL_EXEC_USER=${4:-$(whoami)}
	local _TMP_DOCKER_BASH_CHANNEL_EXEC_DEFAULT_DIR="${5}"
	if [ -n "${_TMP_DOCKER_BASH_CHANNEL_EXEC_DEFAULT_DIR}" ]; then
		_TMP_DOCKER_BASH_CHANNEL_EXEC_DEFAULT_DIR="-w ${_TMP_DOCKER_BASH_CHANNEL_EXEC_DEFAULT_DIR}"
	fi

	local _TMP_DOCKER_BASH_CHANNEL_EXEC_RUNLIKE=$(su_bash_env_conda_channel_exec "runlike ${_TMP_DOCKER_BASH_CHANNEL_EXEC_CTN_ID}" | grep -oP '(?<=--volume=)[^ ]+(?=\s)' | cut -d':' -f1 | egrep "^/var/run/docker.sock$")
	
	if [ -z "${_TMP_DOCKER_BASH_CHANNEL_EXEC_RUNLIKE}" ]; then
		local _TMP_DOCKER_BASH_CHANNEL_EXEC_USER_ARGS=
		# 尝试进入
		if [ "${_TMP_DOCKER_BASH_CHANNEL_EXEC_SCRIPTS}" != "whoami" ]; then
			_TMP_DOCKER_BASH_CHANNEL_EXEC_USER_ARGS="-u ${_TMP_DOCKER_BASH_CHANNEL_EXEC_USER}"
		fi

		docker exec ${_TMP_DOCKER_BASH_CHANNEL_EXEC_USER_ARGS} -i${3} ${_TMP_DOCKER_BASH_CHANNEL_EXEC_CTN_ID} sh -c "${_TMP_DOCKER_BASH_CHANNEL_EXEC_SCRIPTS}"
		return $?
	else
		echo_style_text "'|👉' Docker channel script(<${_TMP_DOCKER_BASH_CHANNEL_EXEC_SCRIPTS}>) exec stop, 'container'([${_TMP_DOCKER_BASH_CHANNEL_EXEC_CTN_ID:0:12}]) was connected to 'docker.sock'"
	fi

	return $?
}


# 通过指定用户，通过管道输出内容
# 参数1：容器ID
# 参数2：输出内容
# 参数3：输出容器路径
# 参数4：执行脚本
# 参数5：管道参数
# 参数6：执行用户，默认$(whoami)
# 参数7：工作目录
# 示例：
#       docker_bash_channel_echo_exec "" "whoami" 
#       docker_bash_channel_echo_exec "" "whoami" "t"
#       docker_bash_channel_echo_exec "" "whoami" "td"
#       docker_bash_channel_echo_exec "" "whoami" "" "root"
function docker_bash_channel_echo_exec()
{
	local _TMP_DOCKER_BASH_CHANNEL_ECHO_PATH="/tmp/docker_apps/${1}${3}.${LOCAL_TIMESTAMP}.echo.sh"
	local _TMP_DOCKER_BASH_CHANNEL_ECHO_SCRIPT="${4}"
	path_not_exists_create "$(dirname ${_TMP_DOCKER_BASH_CHANNEL_ECHO_PATH})"
	cat > ${_TMP_DOCKER_BASH_CHANNEL_ECHO_PATH} << EOF
	${2}
EOF
	docker cp -a ${_TMP_DOCKER_BASH_CHANNEL_ECHO_PATH} ${1}:${3} >& /dev/null

	if [ "${4}" == "." ]; then
		_TMP_DOCKER_BASH_CHANNEL_ECHO_SCRIPT="sh ${3}"
	fi

	if [ -n "${_TMP_DOCKER_BASH_CHANNEL_ECHO_SCRIPT}" ]; then
		docker_bash_channel_exec "${1}" "${_TMP_DOCKER_BASH_CHANNEL_ECHO_SCRIPT}" "${@:5}"
		return $?
	fi

	# rm -rf ${_TMP_DOCKER_BASH_CHANNEL_ECHO_PATH}

	return $?
}

# 在管道内运行函数执行此方法
# *1 无法读取多行内容的情况下需提前执行 tr -d '\r'，或改用items_split_action
# *2 eval script_channel_action 'funca' 该方式运行管道内的引用赋值，对外界操作无效
# 参数1：要执行的函数/脚本名称，或变量名称
# 示例：
#      该示例传递了管道内的数据给到内部变量
#		function funca()
#		{
#		    echo $1
#		    echo $2
#		    funcb
#		}
#		
#		function funcb()
#		{
#		    echo "b"
#		}
#      docker container ls -a | cut -d' ' -f1 | grep -v "CONTAINER" | grep -v "^$" | eval "script_channel_action funca 123"
#      docker container ls -a | cut -d' ' -f1 | grep -v "CONTAINER" | grep -v "^$" | eval script_channel_action 'funca' '123'
#      输出：
#			074c3737df15
#			123
#			b
function script_channel_action()
{
	# shift
	while read _TMP_EXEC_CHANNEL_TEXT_LINE
	do
		# local _TMP_EXEC_CHANNEL_ACTION_FUNC=${1}
		# ${_TMP_EXEC_CHANNEL_ACTION_FUNC} "${_TMP_EXEC_CHANNEL_TEXT_LINE}" ${@:2}
		script_check_action "${1}" "${_TMP_EXEC_CHANNEL_TEXT_LINE}" "${@:2}"
	done
}

##########################################################################################################
# 系统操作类
##########################################################################################################
# 获取IP
function echo_iplocal () {
	#  | grep noprefixroute，qcloud无此属性
	local _TMP_ECHO_IP_LOCAL_IP=$(ip addr | grep inet | grep brd | grep -v inet6 | grep -v 127 | grep -v docker | grep -v "br-" | awk '{print $2}' | awk -F'/' '{print $1}' | awk 'END {print}')
	[ -z ${_TMP_ECHO_IP_LOCAL_IP} ] && _TMP_ECHO_IP_LOCAL_IP=$(ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1)

	echo "${_TMP_ECHO_IP_LOCAL_IP}"
	
	return $?
}

# 获取IP范围，默认当前段
function echo_iplocal_area () {
	
	# echo_iplocal | awk -F'.' '{print $1"."$2"."$3".0"}'
	local _TMP_ECHO_IPLOCAL_AREA_IP=$(echo_iplocal)
	echo "${_TMP_ECHO_IPLOCAL_AREA_IP%.*}.0"

	return $?
}

# 获取IP
# 参数1：需要设置的变量名
# 参数2：绑定后执行的函数
function bind_iplocal_action () {
	function _bind_iplocal_action()
	{
		#  | grep noprefixroute，qcloud无此属性
		local _TMP_BIND_IPLOCAL_ACTION_IP=$(echo_iplocal)
		if [ -n "${_TMP_BIND_IPLOCAL_ACTION_IP}" ]; then
			eval ${1}='${_TMP_BIND_IPLOCAL_ACTION_IP}'

			script_check_action "${2}" "${_TMP_BIND_IPLOCAL_ACTION_IP}"
		fi
	}

	discern_exchange_var_action "${1}" "_bind_iplocal_action" "${@}"
	return $?
}

# 获取IP
# 参数1：需要设置的变量名
function bind_iplocal () {
	bind_iplocal_action "${1}"
	return $?
}

# 免密登录远程主机
# 参数1：需要免密登录的机器
# 参数2：需要免密登录的用户
function nopwd_login () {
    local _TMP_NOPWD_LOGIN_REMOTE_HOST="${1}"
    local _TMP_NOPWD_LOGIN_REMOTE_USER="${2:-"root"}"
    local _TMP_NOPWD_LOGIN_REMOTE_HOST_PORT=${1:-22}

	if [ -n "${_TMP_NOPWD_LOGIN_REMOTE_HOST}" ]; then
		local _TMP_NOPWD_LOGIN_ID_RSA_PATH="~/.ssh/id_rsa"

		path_not_exists_action "${_TMP_NOPWD_LOGIN_ID_RSA_PATH}" "ssh-keygen -t rsa"
		
		ssh-copy-id ${_TMP_NOPWD_LOGIN_REMOTE_USER}@${_TMP_NOPWD_LOGIN_REMOTE_HOST} -p ${_TMP_NOPWD_LOGIN_REMOTE_HOST_PORT}
	fi

	return $?
}

# 创建用户及组，如果不存在
# 参数1：组
# 参数2：用户
# 参数3：SUDOER
# 参数4：默认目录
function create_user_if_not_exists() 
{
	local _TMP_CREATE_USER_IF_NOT_EXISTS_GROUP="${1}"
	local _TMP_CREATE_USER_IF_NOT_EXISTS_USER="${2}"
	local _TMP_CREATE_USER_IF_NOT_EXISTS_SUDOER=${3}
	local _TMP_CREATE_USER_IF_NOT_EXISTS_DFT_DIR="${4:-/home/${2}}"

	# local _TMP_CREATE_USER_IF_NOT_EXISTS_USER_DATA=$(id ${_TMP_CREATE_USER_IF_NOT_EXISTS_USER})

	#create group if not exists
	egrep "^${_TMP_CREATE_USER_IF_NOT_EXISTS_GROUP}:" /etc/group >& /dev/null
	if [ $? -ne 0 ]; then
		groupadd ${_TMP_CREATE_USER_IF_NOT_EXISTS_GROUP}
	fi
	
	#create user if not exists
	egrep "^${_TMP_CREATE_USER_IF_NOT_EXISTS_USER}:" /etc/passwd >& /dev/null
	if [ $? -ne 0 ]; then
		local _TMP_CREATE_USER_IF_NOT_EXISTS_COMMAND_EXT=""
		if [ ! -d "${_TMP_CREATE_USER_IF_NOT_EXISTS_DFT_DIR}" ]; then
			_TMP_CREATE_USER_IF_NOT_EXISTS_COMMAND_EXT="-d ${_TMP_CREATE_USER_IF_NOT_EXISTS_DFT_DIR}"
		fi

		# 正在创建信箱文件: 文件已存在
		if [ -f /var/spool/mail/${_TMP_CREATE_USER_IF_NOT_EXISTS_USER} ]; then
			# -c：加上备注文字，备注文字保存在passwd的备注栏中。 
			# -d：指定用户登入时的启始目录。
			# -D：变更预设值。
			# -e：指定账号的有效期限，缺省表示永久有效。
			# -f：指定在密码过期后多少天即关闭该账号。
			# -g：指定用户所属的起始群组。
			# -G：指定用户所属的附加群组。
			# -m：自动建立用户的登入目录。
			# -M：不要自动建立用户的登入目录。
			# -n：取消建立以用户名称为名的群组。
			# -r：建立系统账号。
			# -s：指定用户登入后所使用的shell。
			# -u：指定用户ID号。
			rm -rf /var/spool/mail/${_TMP_CREATE_USER_IF_NOT_EXISTS_USER}
		fi

		# 如果用户组是root或者docker的情况，指定用户的UID
		if [ "${_TMP_CREATE_USER_IF_NOT_EXISTS_GROUP}" == "root" ] || [ "${_TMP_CREATE_USER_IF_NOT_EXISTS_GROUP}" == "docker" ]; then
			# 以当前用户修改docker、conda对应的用户UID
			# local _TMP_CREATE_USER_IF_NOT_EXISTS_USER_ID=$(id -u ${_TMP_CREATE_USER_IF_NOT_EXISTS_USER})
			local _TMP_CREATE_USER_IF_NOT_EXISTS_CURRENT_USER_ID=$(id -u $(whoami))
			# sed -i "s@^\(${_TMP_CREATE_USER_IF_NOT_EXISTS_USER}:x\):${_TMP_CREATE_USER_IF_NOT_EXISTS_USER_ID}@\1:${_TMP_CREATE_USER_IF_NOT_EXISTS_CURRENT_USER_ID}@g" /etc/passwd
			_TMP_CREATE_USER_IF_NOT_EXISTS_COMMAND_EXT="${_TMP_CREATE_USER_IF_NOT_EXISTS_COMMAND_EXT} -o -u ${_TMP_CREATE_USER_IF_NOT_EXISTS_CURRENT_USER_ID}"	
		fi

		useradd -g ${_TMP_CREATE_USER_IF_NOT_EXISTS_GROUP} ${_TMP_CREATE_USER_IF_NOT_EXISTS_USER} ${_TMP_CREATE_USER_IF_NOT_EXISTS_COMMAND_EXT}

	else
		# 1、设置某个用户所在组
		# 	 usermod -g 用户组 用户名
		# 注：
		#    -g|--gid，修改用户的gid，该组一定存在
		# 2、把用户添加进入某个组(s）
		# 	 usermod -a -G 用户组 用户名
		# 注：
		# 	 -a|--append，把用户追加到某些组中，仅与-G选项一起使用
		# 	 -G|--groups，把用户追加到某些组中，仅与-a选项一起使用
		usermod -a -G ${_TMP_CREATE_USER_IF_NOT_EXISTS_GROUP} ${_TMP_CREATE_USER_IF_NOT_EXISTS_USER}
	fi

	if [[ ${_TMP_CREATE_USER_IF_NOT_EXISTS_SUDOER} ]]; then
		function _create_user_if_not_exists_insert_sudoer()
		{
			chmod -v u+w /etc/sudoers
			curx_line_insert "/etc/sudoers" "^## Allows people in group wheel" "${_TMP_CREATE_USER_IF_NOT_EXISTS_USER}  ALL=(ALL)      NOPASSWD: ALL"
			chmod -v u-w /etc/sudoers
		}

		file_content_not_exists_action "^${_TMP_CREATE_USER_IF_NOT_EXISTS_USER}[[:space:]]+" "/etc/sudoers" "_create_user_if_not_exists_insert_sudoer"
	fi

	return $?
}

# 关闭删除文件占用进程
function kill_deleted()
{
	if [ ! -f "/usr/sbin/lsof" ]; then
		yum -y install lsof
	fi

	lsof -w | grep deleted | awk -F' ' '{print $2}' | awk '!a[$0]++' | xargs -I {} kill -9 {} >& /dev/null
	# lsof -w | grep deleted | awk -F' ' '{print $2}' | awk '!a[$0]++' | xargs -I {} ps aux | awk '{print $2}'| grep -w {} && kill -9 {}

	# !!! docker挂载卷删除方法
	## 1：找到overlay2种占用最多的文件
	### find /mountdisk -type f -size +100M -print0 | xargs -0 du -m | sort -nr 
	## 2：找到对应的文件解除挂载
	### 例如 code-server的find / -type f -size +100M -print0 | xargs -0 du -m | sort -nr | grep "kite" | cut  -d '/' -f6
	### umount /mountdisk/data/docker/overlay2/{}/merged && rm -rf /mountdisk/data/docker/overlay2/{}
	# docker部分资源占用参考：https://blog.csdn.net/Entity_G/article/details/112801239

	return $?
}

# 获取服务内容
# 参数1：服务名称
# 参数2：服务打印节点，例如 Loaded/Active/Docs/Main PID/CGroup，默认Active
# 示例：
#       echo_service_node_content "docker" "Active"
function echo_service_node_content()
{
	local _TMP_ECHO_SERVICE_NODE_CONTENT_PRINT_NODE="${2:-Active}"
	local _TMP_ECHO_SERVICE_NODE_CONTENT_SPACE_COUNT=0
	case ${_TMP_ECHO_SERVICE_NODE_CONTENT_PRINT_NODE} in
		"Docs")
			_TMP_ECHO_SERVICE_NODE_CONTENT_SPACE_COUNT=5
		;;
		"Main PID")
			_TMP_ECHO_SERVICE_NODE_CONTENT_SPACE_COUNT=1
		;;
		*)
			_TMP_ECHO_SERVICE_NODE_CONTENT_SPACE_COUNT=3
	esac
	# systemctl is-active supervisord.service  #（仅显示是否Active)
	# systemctl is-enabled supervisord.service   验证一下是否为开机启动
	systemctl status ${1} | grep -oP "(?<=^([[:space:]]{${_TMP_ECHO_SERVICE_NODE_CONTENT_SPACE_COUNT}})${_TMP_ECHO_SERVICE_NODE_CONTENT_PRINT_NODE}: )[^\s]+"
	return $?
}

# 修改服务运行时用户
# 参数1：需要修改的服务名称
# 参数2：服务运行时所用的用户
# 示例：
#      change_service_user "docker" "docker"
function change_service_user()
{
	# local _TMP_CHANGE_SERVICE_USER_SNAME="${1}"
	# local _TMP_CHANGE_SERVICE_USER_UNAME="${2}"

	local _TMP_CHANGE_SERVICE_USER_SERVICE_PATH="/usr/lib/systemd/system/${1}.service"
	local _TMP_CHANGE_SERVICE_USER_SOCKET_PATH="/usr/lib/systemd/system/${1}.socket"
	local _TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE=""
	# bind_line "_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE" "${_TMP_CHANGE_SERVICE_USER_SERVICE_PATH}" "^([#]*[[:space:]]*)User="
	bind_line "_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE" "${_TMP_CHANGE_SERVICE_USER_SERVICE_PATH}" '^([[:space:]]*)User='

	# 不存在用户设置
	if [ -z "${_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE}" ]; then
		bind_line "_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE" "${_TMP_CHANGE_SERVICE_USER_SERVICE_PATH}" '^\[Service\]$'
		_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE=$((_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE+1))
	else
		# 删除用户设置
		sed -i "${_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE}d" ${_TMP_CHANGE_SERVICE_USER_SERVICE_PATH}
		_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE=$((_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE-1))
	fi

	# 有socket的情况
	if [ -f ${_TMP_CHANGE_SERVICE_USER_SOCKET_PATH} ]; then
		local _TMP_CHANGE_SERVICE_USER_SOCKET_UGROUP=$(groups ${2} | cut -d' ' -f3)
		sed -i "s@\(SocketUser\)=.\+@\1=${2}@g" ${_TMP_CHANGE_SERVICE_USER_SOCKET_PATH}
		
		if [ -n "${_TMP_CHANGE_SERVICE_USER_SOCKET_UGROUP}" ]; then
			sed -i "s@\(SocketGroup\)=.\+@\1=${_TMP_CHANGE_SERVICE_USER_SOCKET_UGROUP}@g" ${_TMP_CHANGE_SERVICE_USER_SOCKET_PATH}
		fi
	fi

	# 插入用户设置
	sed -i "${_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE}a User=${2}" ${_TMP_CHANGE_SERVICE_USER_SERVICE_PATH}

	# 重新加载服务配置
    systemctl daemon-reload

	return $?
}

# 检测端口占用，并提示交换
# 参数1：需要设置的变量名，或变量
# 示例：
#      bind_exchange_port 13000
#      _PORT_VAR=13000 && bind_exchange_port "_PORT_VAR"
function bind_exchange_port() {
	function _bind_exchange_port_change()
	{
		local _TMP_BIND_EXCHANGE_PORT_VAR_VAL=$(eval echo '${'"${1}"'}')
		local _TMP_BIND_EXCHANGE_PORT_USING=$(lsof -i:${_TMP_BIND_EXCHANGE_PORT_VAR_VAL} | awk 'NR>1')
		
		local _TMP_BIND_EXCHANGE_PORT_NEWER_VAL=${_TMP_BIND_EXCHANGE_PORT_VAR_VAL}

		if [ -n "${_TMP_BIND_EXCHANGE_PORT_USING}" ]; then
			# 端口长度判断
			if [ ${#_TMP_BIND_EXCHANGE_PORT_NEWER_VAL} -lt 5 ]; then
				rand_val "_TMP_BIND_EXCHANGE_PORT_NEWER_VAL" 10000 65535
			else
				_TMP_BIND_EXCHANGE_PORT_NEWER_VAL=$((_TMP_BIND_EXCHANGE_PORT_NEWER_VAL+1))
			fi
			
			# 定义新变量并赋值
			local _TMP_BIND_EXCHANGE_PORT_VAR_NEWER_NAME="_TMP_BIND_EXCHANGE_PORT_VAR_NAME_$(cat /proc/sys/kernel/random/uuid | sed 's@-@_@g')"
			eval ${_TMP_BIND_EXCHANGE_PORT_VAR_NEWER_NAME}='${_TMP_BIND_EXCHANGE_PORT_NEWER_VAL}'

			# 重新确定变量
			local _TMP_BIND_EXCHANGE_PORT_USING_PRGS_ARR=($(echo "${_TMP_BIND_EXCHANGE_PORT_USING}" | cut -d' ' -f1 | uniq))
			bind_if_input "${_TMP_BIND_EXCHANGE_PORT_VAR_NEWER_NAME}" "Checked Port '${_TMP_BIND_EXCHANGE_PORT_VAR_VAL}' is using(<${_TMP_BIND_EXCHANGE_PORT_USING_PRGS_ARR[*]}>), please [change] newer one"
			
			# 内循环，端口再次占用时，继续
			_bind_exchange_port_change "${_TMP_BIND_EXCHANGE_PORT_VAR_NEWER_NAME}"

			# 将递归赋值拿到
			_TMP_BIND_EXCHANGE_PORT_NEWER_VAL=$(eval echo '${'"${_TMP_BIND_EXCHANGE_PORT_VAR_NEWER_NAME}"'}')
		fi
		
		# 操作完函数再赋值
		eval ${1}='${_TMP_BIND_EXCHANGE_PORT_NEWER_VAL}'

		# # 非绑定变量名时，直接输出结果
		# if [ "${1}" != "${_TMP_BIND_EXCHANGE_PORT_VAR_NAME}" ]; then
		# 	echo "${_TMP_BIND_EXCHANGE_PORT_EXCHANGE_VAL}"
		# fi
	}

	discern_exchange_var_action "${1}" "_bind_exchange_port_change" "${@}"
	return $?
}

# 执行休眠
# 参数1：休眠数值
# 参数2：休眠等待文字
function exec_sleep()
{
	local _TMP_EXEC_SLEEP_TIMES=${1}
	local _TMP_EXEC_SLEEP_ECHO=$(printf "${2}" "${1}")

	function _TMP_EXEC_SLEEP_NORMAL_FUNC() {
		echo_style_text "${_TMP_EXEC_SLEEP_ECHO}"
		sleep ${_TMP_EXEC_SLEEP_TIMES}
		return $?
	}
	
	function _TMP_EXEC_SLEEP_GUM_FUNC() {
		bind_style_text "_TMP_EXEC_SLEEP_ECHO"
		gum spin --spinner monkey --title "${_TMP_EXEC_SLEEP_ECHO}" -- sleep ${_TMP_EXEC_SLEEP_TIMES}

		return $?
	}

	path_exists_yn_action "${GUM_PATH}" "_TMP_EXEC_SLEEP_GUM_FUNC" "_TMP_EXEC_SLEEP_NORMAL_FUNC"
	return $?
}

# 执行休眠，直到不为空
# 参数1：休眠等待文字
# 参数2：等待输出不为空时的判断脚本
# 参数3：最长等待时长（秒）, 默认120
# 参数4：延迟时长（秒）, 默认0
# 示例：
#      exec_sleep_until_not_empty "test wait" "lsof -i:13000" 10 1
function exec_sleep_until_not_empty()
{
	local _TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CHECK_SCRIPTS=${2}
	local _TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_SLEEP_SECONDS=${3:-120}
	local _TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_DELAY_SECONDS=${4:-0}
	
	local _TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CURRENT_INDEX=1
	for _TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CURRENT_INDEX in $(seq ${_TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_SLEEP_SECONDS});  
	do
		# local _TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CURR_VAL=$(eval "${_TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CHECK_SCRIPTS}")
		local _TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CURR_VAL=$(script_check_action "${2}")
		if [ -z "${_TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CURR_VAL}" ]; then
			exec_sleep 1 "${1}, take <${_TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CURRENT_INDEX}>/[${_TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_SLEEP_SECONDS}]s"
		else
			break
		fi
	done

	if [ ${_TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_DELAY_SECONDS} -ne 0 ]; then
		exec_sleep ${_TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_DELAY_SECONDS} "${1}"
	fi

	return $?
}

# 获取挂载根路径，取第一个挂载的磁盘
function echo_mount_root() {
	lsblk | awk "{if(\$1!=\"${FDISK_L_SYS_DEFAULT}\" && \$6==\"disk\" && \$7!=\"\"){print \$7}}"

	return $?
}

# 识别磁盘挂载
# 参数1：磁盘挂载数组键/值 （当带入参数时，以带入的参数来决定脚本挂载几块硬盘）,为空时格式化所有硬盘
function resolve_unmount_disk () {
	local _TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE="MountDisk"
	local _TMP_RESOLVE_UNMOUNT_DISK_MOUNT_LOCAL_STR=${1:-}
	# http://wxnacy.com/2018/05/26/shell-split/
	local _TMP_RESOLVE_UNMOUNT_DISK_MOUNT_LOCAL_ARR=(${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_LOCAL_STR//,/ })
	
	# 获取当前磁盘的格式，例如sd,vd
	local _TMP_RESOLVE_UNMOUNT_DISK_LSBLK_DISKS_STR=$(lsblk | awk "{if(\$1!=\"${FDISK_L_SYS_DEFAULT}\" && \$6==\"disk\" && \$7==\"\"){print \$1}}")
	
	local _TMP_RESOLVE_UNMOUNT_DISK_ARR_DISK_POINT=(${_TMP_RESOLVE_UNMOUNT_DISK_LSBLK_DISKS_STR// / })
	
	function _resolve_unmount_disk_mount()
	{
		if [ ${#_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_LOCAL_ARR[@]} != 0 ] && [ ${2} -eq ${#_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_LOCAL_ARR[@]} ]; then
			break
		fi

		local _TMP_RESOLVE_UNMOUNT_DISK_POINT="/dev/${1}"

		# 判断未格式化
		local _TMP_RESOLVE_UNMOUNT_DISK_FORMATED_COUNT=$(fdisk -l | grep "^${_TMP_RESOLVE_UNMOUNT_DISK_POINT}" | wc -l)

		if [ ${_TMP_RESOLVE_UNMOUNT_DISK_FORMATED_COUNT} -eq 0 ]; then
			echo_style_text "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Checked there is one of disk(<$((${2}+1))>/[${#_TMP_RESOLVE_UNMOUNT_DISK_ARR_DISK_POINT[@]}]) '${_TMP_RESOLVE_UNMOUNT_DISK_POINT}' [not format]"
			echo_style_text "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Suggest step："
			echo_style_text "                                Type 'n', then <enter>"
			echo_style_text "                                Type 'p', then <enter>"
			echo_style_text "                                Type '1', then <enter>"
			echo_style_text "                                Type <enter>"
			echo_style_text "                                Type <enter>"
			echo_style_text "                                Type 'w', then <enter>"
			echo_style_text "                                Type 'y', then <enter>"
			echo "${TMP_SPLITER2}"
			fdisk ${_TMP_RESOLVE_UNMOUNT_DISK_POINT}
			echo "${TMP_SPLITER2}"

			# 格式化：
			mkfs.ext4 ${_TMP_RESOLVE_UNMOUNT_DISK_POINT}

			fdisk -l | grep "^${_TMP_RESOLVE_UNMOUNT_DISK_POINT}"
			echo_style_text "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Disk of <${_TMP_RESOLVE_UNMOUNT_DISK_POINT}> 'formated'"
			echo "${TMP_SPLITER2}"
		fi

		# 判断未挂载
		local _TMP_RESOLVE_UNMOUNT_DISK_MOUNTED_COUNT=$(df -h | grep "^${_TMP_RESOLVE_UNMOUNT_DISK_POINT}" | wc -l)
		if [ ${_TMP_RESOLVE_UNMOUNT_DISK_MOUNTED_COUNT} -eq 0 ]; then
			echo_style_text "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Checked there is one of disk(<$((${2}+1))>/[${#_TMP_RESOLVE_UNMOUNT_DISK_ARR_DISK_POINT[@]}]) '${_TMP_RESOLVE_UNMOUNT_DISK_POINT}' [no mount]"

			# 必要判断项
			# 1：数组为空，检测到所有项都提示
			# 2：数组不为空，多余的略过
			local _TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT=${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_LOCAL_ARR[${2}]}
			if [ -z "${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT}" ]; then
				bind_if_input "_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT" "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Please ender the disk of '${_TMP_RESOLVE_UNMOUNT_DISK_POINT}' mount path prefix like '/tmp/downloads'"
			fi

			while [ -a ${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT} ]; do
				bind_if_input "_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT" "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Checked path <${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT}> exists, please ender the disk of '${_TMP_RESOLVE_UNMOUNT_DISK_POINT}' mount path prefix like '/tmp/downloads' and sure it not exists"
			done

			if [ -n "${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT}" ]; then
				# 挂载
				mkdir -pv ${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT}
				echo "${_TMP_RESOLVE_UNMOUNT_DISK_POINT} ${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT} ext4 defaults 0 0" >> /etc/fstab
				mount -a
		
				df -h | grep "${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT}"
				echo_style_text "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Disk of <${_TMP_RESOLVE_UNMOUNT_DISK_POINT}> 'mounted'"
			else
				echo_style_text "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Path of <${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT}> error，the disk '${_TMP_RESOLVE_UNMOUNT_DISK_POINT}' [not mount]"
			fi

			echo "${TMP_SPLITER2}"
		fi
	}

	items_split_action "_TMP_RESOLVE_UNMOUNT_DISK_ARR_DISK_POINT" "_resolve_unmount_disk_mount"

	# 更新全局变量
	source ${__DIR}/common/common_vars.sh

	return $?
}

# 新增一个授权端口
# 参数1：需放开端口变量名/值
# 参数2：授权IP
# 参数3：ALL/TCP/UDP
function echo_soft_port()
{
	local _TMP_ECHO_SOFT_PORT=$(echo_discern_exchange_var_val "${1}")
	local _TMP_ECHO_SOFT_PORT_IP=${2}
	local _TMP_ECHO_SOFT_PORT_TYPE=${3:-tcp}

	# 为空或本机IP则修改成本机内网IP
	if [[ -z "${_TMP_ECHO_SOFT_PORT_IP}" || "${_TMP_ECHO_SOFT_PORT_IP}" == "localhost" || "${_TMP_ECHO_SOFT_PORT_IP}" == "127.0.0.1" ]]; then
		_TMP_ECHO_SOFT_PORT_IP="${LOCAL_HOST}"
	fi

	# 非VmWare产品的情况下，不安装iptables，给个假iptables文件
	if [ "${DMIDECODE_MANUFACTURER}" != "VMware, Inc." ] && [ "${DMIDECODE_MANUFACTURER}" != "QEMU" ]; then	
		if [ ! -f "/etc/sysconfig/iptables" ]; then
			cat >/etc/sysconfig/iptables<<EOF
# sample configuration for iptables service
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
# [[[[[[[[[[[A EMPTY FILE]]]]]]]]]]

# [[[[[[[[[[[A EMPTY FILE]]]]]]]]]]
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
		fi
	else
		if [ ! -f "/etc/sysconfig/iptables" ]; then
			soft_yum_check_setup "iptables-services"
			chkconfig --level 345 iptables on
			systemctl enable iptables.service

			echo_startup_supervisor_config "iptables" "/usr/bin" "systemctl restart iptables.service" "" "1" "" "" false 0
		fi
	fi

	# 判断是否加端口类型，
	# 注意 -s 一定要放在ALL	的上面（如果放在下面是不生效的！！！！）
	#cat /etc/sysconfig/iptables | grep "\-A INPUT -p" | awk -F' ' '{print $(NF-2)}' | awk '{for (i=1;i<=NF;i++) {if ($i=="801") {print i}}}'
	local _TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS_SCRIPT="cat /etc/sysconfig/iptables | grep -oE '^-A INPUT -p ${_TMP_ECHO_SOFT_PORT_TYPE} %s-m state --state NEW -m ${_TMP_ECHO_SOFT_PORT_TYPE} --dport ${_TMP_ECHO_SOFT_PORT} -j ACCEPT'"

	local _TMP_ECHO_SOFT_PORT_IP_RULE_ECHO=""
	# 非本机内网IP的情况
	if [[ -n "${_TMP_ECHO_SOFT_PORT_IP}" && "${_TMP_ECHO_SOFT_PORT_IP}" != "${LOCAL_HOST}" ]]; then
		_TMP_ECHO_SOFT_PORT_IP_RULE_ECHO="-s ${_TMP_ECHO_SOFT_PORT_IP} "
	else
		_TMP_ECHO_SOFT_PORT_IP_RULE_ECHO="-s ${LOCAL_HOST%.*}.0/24 "
	fi

	_TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS_SCRIPT=$(printf "${_TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS_SCRIPT}" "${_TMP_ECHO_SOFT_PORT_IP_RULE_ECHO}")
		
	local _TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS_GREP=$(script_check_action "_TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS_SCRIPT")
	if [ -n "${_TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS_GREP}" ]; then
		echo_style_text "'Port' <${_TMP_ECHO_SOFT_PORT_TYPE}:${_TMP_ECHO_SOFT_PORT}> accept [${_TMP_ECHO_SOFT_PORT_IP:-"ALL"}] exists"
		echo_style_text "Grep 'rule' follows↓:"
		echo "                   ${_TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS_GREP}"

		return $?
	fi

	# # 本机的情况下，不操作
	# if [[ "${_TMP_ECHO_SOFT_PORT_IP}" == "127.0.0.1" || "${_TMP_ECHO_SOFT_PORT_IP}" == "localhost" ]]; then
	# 	return
	# fi
	# firewall-cmd --zone=public --add-port=80/tcp --permanent  # nginx 端口
	# firewall-cmd --zone=public --add-port=2222/tcp --permanent  # 用户SSH登录端口 coco
	echo_style_text "'Port' <${_TMP_ECHO_SOFT_PORT_TYPE}:${_TMP_ECHO_SOFT_PORT}> accept [${_TMP_ECHO_SOFT_PORT_IP:-"ALL"}] echo"
	local _TMP_ECHO_SOFT_PORT_IPTABLES_RULE="-A INPUT -p ${_TMP_ECHO_SOFT_PORT_TYPE} ${_TMP_ECHO_SOFT_PORT_IP_RULE_ECHO}-m state --state NEW -m ${_TMP_ECHO_SOFT_PORT_TYPE} --dport ${_TMP_ECHO_SOFT_PORT} -j ACCEPT"
	echo "${_TMP_ECHO_SOFT_PORT_IPTABLES_RULE}"
	curx_line_insert "/etc/sysconfig/iptables" "^-A INPUT -p" "${_TMP_ECHO_SOFT_PORT_IPTABLES_RULE}"

	# firewall-cmd --reload  # 重新载入规则，
	if [[ "${DMIDECODE_MANUFACTURER}" == "VMware, Inc." && "${DMIDECODE_MANUFACTURER}" != "QEMU" ]]; then
		# *** 必须存储iptables规则，否则会与docker容器冲突
		iptables-save > /home/$(whoami)/iptables.rules
		exec_sleep 3 "Starting reboot firewall..."
		systemctl restart iptables.service
		exec_sleep 3 "Waitting firewall reboot..."
		iptables-restore < /home/$(whoami)/iptables.rules	
	fi

	# local TMP_FIREWALL_STATE=$(firewall-cmd --state)
	
	# firewall-cmd --permanent --add-port=${_TMP_ECHO_SOFT_PORT}/tcp
	# firewall-cmd --permanent --add-port=${_TMP_ECHO_SOFT_PORT}/udp
	# firewall-cmd --reload

	return $?
}

# 如果内容不存在则执行脚本
# 参数1：内容正则
# 参数2：内容路径
# 参数3：执行脚本
function file_content_not_exists_action() 
{
	local _TMP_FILE_CONTENT_NOT_EXISTS_ACTION_FILE_PATH="${2}"
	convert_path "_TMP_FILE_CONTENT_NOT_EXISTS_ACTION_FILE_PATH"
	
	egrep "${1}" ${_TMP_FILE_CONTENT_NOT_EXISTS_ACTION_FILE_PATH} >& /dev/null
	if [ $? -ne 0 ]; then
		script_check_action "${3}"
	fi

	return $?
}

# 如果内容不存在则输出信息
# 参数1：内容正则
# 参数2：内容路径
# 参数3：输出内容
function file_content_not_exists_echo() 
{
	file_content_not_exists_action "${1}" "${2}" "echo \"${3:-${1}}\" >> ${2}"

	return $?
}

# 输出文本至/etc/profile，避免重复项
# 参数1：需要输出的内容
# 参数2：内容匹配正则
function echo_etc_profile()
{
	file_content_not_exists_echo "${2:-^${1}$}" "/etc/profile" "${1}"

	return $?
}

# 输出文本至/etc/locale.conf，避免重复项
# 参数1：需要输出的内容
# 参数2：内容匹配正则
function echo_etc_locale()
{
	file_content_not_exists_echo "${2:-^${1}$}" "/etc/locale.conf" "${1}"

	return $?
}

# 输出文本至/etc/sysconfig/i18n，避免重复项
# 参数1：需要输出的内容
# 参数2：内容匹配正则
function echo_etc_i18n()
{
	file_content_not_exists_echo "${2:-^${1}$}" "/etc/sysconfig/i18n" "${1}"

	return $?
}

# 输出文本至/etc/rc.d/rc.local，避免重复项
# 参数1：需要输出的内容
# 参数2：内容匹配正则
function echo_etc_rcd_rclocal()
{
	file_content_not_exists_echo "${2:-^${1}$}" "/etc/rc.d/rc.local" "${1}"

	return $?
}

# 输出文本至/etc/rc.local，避免重复项
# 参数1：需要输出的内容
# 参数2：内容匹配正则
function echo_etc_rc_local()
{
	file_content_not_exists_echo "${2:-^${1}$}" "/etc/rc.local" "${1}"

	return $?
}

# 输出文本至/etc/security/limits.conf，避免重复项
# 参数1：需要输出的内容
# 参数2：内容匹配正则
function echo_etc_sec_limits()
{
	file_content_not_exists_echo "${2:-^${1}$}" "/etc/security/limits.conf" "${1}"

	return $?
}

# 如果内容不存在则插入
# 参数1：内容正则
# 参数2：内容路径
# 参数3：指定段落，例 mysqld
# 参数4：段落匹配正则（oP），例 (?<=\[)\w+(?=\])
# 参数5：执行脚本
# 示例：
#       file_content_part_not_exists_action "max_connections=1024" "/mountdisk/conf/docker_apps/library_mysql/5.7.42/app/my.cnf" "mysqld" "(?<=\[)\w+(?=\])" "echo '%s'"
function file_content_part_not_exists_action() 
{
	local _TMP_FILE_CONTENT_PART_NOT_EXISTS_MATCH_PATH=${2}
	local _TMP_FILE_CONTENT_PART_NOT_EXISTS_MATCH_PART=${3}
	local _TMP_FILE_CONTENT_PART_NOT_EXISTS_PART_REGEX=${4}

	local _TMP_FILE_CONTENT_PART_NOT_EXISTS_START_LINE=
	local _TMP_FILE_CONTENT_PART_NOT_EXISTS_END_LINE=$(cat ${2} | grep -n "" | awk -F':' 'END{print $1}')
	
	if [ -n "${4}" ]; then
		# _TMP_FILE_CONTENT_PART_NOT_EXISTS_ECHO=$(cat ${2} | grep -naE "${3}")
		
		# 4:mysqld
		# 66:client
		local _TMP_FILE_CONTENT_PART_NOT_EXISTS_PART_TAGS=$(cat ${2} | grep -oPn "${4}")
		
		local _TMP_FILE_CONTENT_PART_NOT_EXISTS_FOUND_PART=
		# 匹配指定段落的结束行号
		function file_content_part_not_exists_action_match_ends()
		{
			# 4
			local _TMP_FILE_CONTENT_PART_NOT_EXISTS_CURR_LINE=$(echo "${1}" | awk -F':' '{print $1}')
			# mysqld
			local _TMP_FILE_CONTENT_PART_NOT_EXISTS_CURR_TAG=$(echo "${1}" | grep -oP "(?<=${_TMP_FILE_CONTENT_PART_NOT_EXISTS_CURR_LINE}:).+")
			
			if [ -n "${_TMP_FILE_CONTENT_PART_NOT_EXISTS_START_LINE}" ]; then
				_TMP_FILE_CONTENT_PART_NOT_EXISTS_END_LINE=$(echo "${_TMP_FILE_CONTENT_PART_NOT_EXISTS_CURR_LINE}-1" | bc)
				break
			fi

			if [ "${_TMP_FILE_CONTENT_PART_NOT_EXISTS_MATCH_PART}" == "${_TMP_FILE_CONTENT_PART_NOT_EXISTS_CURR_TAG}" ]; then
				_TMP_FILE_CONTENT_PART_NOT_EXISTS_START_LINE=${_TMP_FILE_CONTENT_PART_NOT_EXISTS_CURR_LINE}
			fi
		}

		items_split_action "_TMP_FILE_CONTENT_PART_NOT_EXISTS_PART_TAGS" "file_content_part_not_exists_action_match_ends"
	fi

    cat ${2} | sed -n "${_TMP_FILE_CONTENT_PART_NOT_EXISTS_START_LINE},${_TMP_FILE_CONTENT_PART_NOT_EXISTS_END_LINE}p" | egrep "${1}" >& /dev/null
	if [ $? -ne 0 ]; then
		script_check_action "${5}" "${_TMP_FILE_CONTENT_PART_NOT_EXISTS_START_LINE}" "${_TMP_FILE_CONTENT_PART_NOT_EXISTS_END_LINE}"
	fi

	return $?
}

# 如果内容不存在则输出信息
# 参数1：内容正则
# 参数2：内容路径
# 参数3：指定段落，例 mysqld
# 参数4：段落匹配正则（oP），例 (?<=\[)\w+(?=\])
# 参数5：输出内容
# 示例：
#       file_content_part_not_exists_echo "^max_connections=1024" "/mountdisk/conf/docker_apps/library_mysql/5.7.42/app/my.cnf" "mysqld" "(?<=\[)\w+(?=\])" "test_echo"
function file_content_part_not_exists_echo() 
{
	local _TMP_FILE_CONTENT_PART_NOT_EXISTS_ECHO_PATH="${2}"
	local _TMP_FILE_CONTENT_PART_NOT_EXISTS_ECHO_TXT="${5}"
	function file_content_part_not_exists_echo_curx()
	{
		sed -i "$((${1}+1))i ${_TMP_FILE_CONTENT_PART_NOT_EXISTS_ECHO_TXT}" ${_TMP_FILE_CONTENT_PART_NOT_EXISTS_ECHO_PATH}
	}

	file_content_part_not_exists_action "${1}" "${2}" "${3}" "${4}" "file_content_part_not_exists_echo_curx"
	return $?
}

# 如果内容不存在则输出信息
# 参数1：内容正则
# 参数2：内容路径
# 参数3：指定段落，例 mysqld
# 参数4：输出内容
# 示例：
#       file_content_part_not_exists_mquote_echo "^max_connections=1024" "/mountdisk/conf/docker_apps/library_mysql/5.7.42/app/my.cnf" "mysqld"  "test_echo"
function file_content_part_not_exists_mquote_echo() 
{
	file_content_part_not_exists_echo "${1}" "${2}" "${3}" "(?<=\[)\w+(?=\])" "${4}"
	return $?
}

##########################################################################################################
# 网络操作类
##########################################################################################################
# 获取IPv4
function echo_ipv4 () {
	#wget -qO- -t1 -T2 ipv4.icanhazip.com
	local _TMP_GET_IPV4_LOCAL_IPV4=$(curl -s -A Mozilla ipv4.icanhazip.com | awk 'NR==1')
	[ -z ${_TMP_GET_IPV4_LOCAL_IPV4} ] && _TMP_GET_IPV4_LOCAL_IPV4=$(curl -s -A Mozilla ipinfo.io/ip | awk 'NR==1')
	[ -z ${_TMP_GET_IPV4_LOCAL_IPV4} ] && _TMP_GET_IPV4_LOCAL_IPV4=$(curl -s -A Mozilla ip.sb | awk 'NR==1')

	echo "${_TMP_GET_IPV4_LOCAL_IPV4}"

	return $?
}

# 获取IPv6
function echo_ipv6 () {
	curl -s -A Mozilla ipv6.icanhazip.com | awk 'NR==1'

	return $?
}

# 获取国家代码
# 参数1：需要设置的变量名
function get_country_code () {
	function _get_country_code()
	{
		local _TMP_GET_COUNTRY_CODE_VAR_VAL=$(eval echo '${'"${1}"'}')
		local _TMP_GET_COUNTRY_CODE_CODE=$(echo ${_TMP_GET_COUNTRY_CODE_VAR_VAL:-"CN"})
		
		local TMP_LOCAL_IPV4=$(curl -s ip.sb)

		# 项目开始判断服务器所在地，未初始化epel时无法安装JQ，故此处不使用JQ
		local _TMP_GET_COUNTRY_CODE_RESP=$(curl -s -A Mozilla https://api.ip.sb/geoip/${TMP_LOCAL_IPV4})

		if [ -f "/usr/bin/jq" ]; then
			_TMP_GET_COUNTRY_CODE_CODE=$(echo "${_TMP_GET_COUNTRY_CODE_RESP}" | jq '.country_code' | tr -d '"')
		else
			_TMP_GET_COUNTRY_CODE_CODE=$(echo "${_TMP_GET_COUNTRY_CODE_RESP}" | grep -oP "(?<=\"country_code\"\:\").*(?=\",)")
		fi
		
		eval ${1}='${_TMP_GET_COUNTRY_CODE_CODE}'
	}

	discern_exchange_var_action "${1}" "_get_country_code" "${@}"
	return $?
}

# 安装软件下载模式
# 参数1：软件下载地址
# 参数2：软件下载后，需移动的文件夹名
# 参数3：目标文件夹
# 参数4：解包后执行脚本
function wget_unpack_dist() 
{
	local _TMP_WGET_UNPACK_DIST_PWD=$(pwd)
	local _TMP_WGET_UNPACK_DIST_URL=${1}
	local _TMP_WGET_UNPACK_DIST_SOURCE=${2}
	local _TMP_WGET_UNPACK_DIST_PATH=${3}
	local _TMP_WGET_UNPACK_DIST_SCRIPT=${4}

	local _TMP_WGET_UNPACK_FILE_NAME=$(echo "${_TMP_WGET_UNPACK_DIST_URL}" | awk -F'/' '{print $NF}')

	mkdir -pv ${DOWN_DIR} && cd ${DOWN_DIR}

	if [ ! -f "${_TMP_WGET_UNPACK_FILE_NAME}" ]; then
		wget -c --tries=0 --timeout=60 ${_TMP_WGET_UNPACK_DIST_URL}
	fi

	local _TMP_WGET_UNPACK_DIST_FILE_EXT=$(echo ${_TMP_WGET_UNPACK_FILE_NAME##*.})
	if [ "${_TMP_WGET_UNPACK_DIST_FILE_EXT}" = "zip" ]; then
		local _TMP_WGET_UNPACK_DIST_PACK_DIR_LINE=$(unzip -v ${_TMP_WGET_UNPACK_FILE_NAME} | awk '/----/{print NR}' | awk 'NR==1{print}')
		local _TMP_WGET_UNPACK_FILE_NAME_NO_EXTS=$(unzip -v ${_TMP_WGET_UNPACK_FILE_NAME} | awk 'NR==LINE{print $NF}' LINE=$((_TMP_WGET_UNPACK_DIST_PACK_DIR_LINE+1)) | sed s@/@""@g)
		if [ ! -d "${_TMP_WGET_UNPACK_FILE_NAME_NO_EXTS}" ]; then
			unzip -o ${_TMP_WGET_UNPACK_FILE_NAME}
		fi
	else
		local _TMP_WGET_UNPACK_FILE_NAME_NO_EXTS=$(tar -tf ${_TMP_WGET_UNPACK_FILE_NAME} | awk 'NR==1{print}' | sed s@/@""@g)
		if [ ! -d "${_TMP_WGET_UNPACK_FILE_NAME_NO_EXTS}" ]; then
			tar -xvf ${_TMP_WGET_UNPACK_FILE_NAME}
		fi
	fi

	cd ${_TMP_WGET_UNPACK_FILE_NAME_NO_EXTS}

	script_check_action "${_TMP_WGET_UNPACK_DIST_SCRIPT}"

	cp -rf ${_TMP_WGET_UNPACK_DIST_SOURCE} ${_TMP_WGET_UNPACK_DIST_PATH}

	#rm -rf ${DOWN_DIR}/${_TMP_WGET_UNPACK_FILE_NAME}
	cd ${_TMP_WGET_UNPACK_DIST_PWD}

	return $?
}

# 无限循环重试下载
# 参数1：软件下载地址
# 参数2：软件下载后执行函数名称
function while_wget()
{
	local _TMP_WHILE_WGET_URL=${1}
	local _TMP_WHILE_WGET_CURRENT_DIR=$(pwd)

	#包含指定参数
	local _TMP_WHILE_WGET_FILE_DEST_NAME=$(echo "${_TMP_WHILE_WGET_URL}" | awk -F'-O' '{print $2}' | awk '{sub("^ *","");sub(" *$","");print}' | awk -F' ' '{print $1}')
	
	#原始链接名
	local _TMP_WHILE_WGET_FILE_SOUR_NAME=$(echo "${_TMP_WHILE_WGET_URL}" | awk -F'/' '{print $NF}' | awk -F' ' '{print $NR}')
	if [ "${_TMP_WHILE_WGET_FILE_SOUR_NAME}" == "download.rpm" ]; then
		_TMP_WHILE_WGET_FILE_SOUR_NAME=$(echo "${_TMP_WHILE_WGET_URL}" | awk -F'/' '{print $(NF-1)}')
	fi

	#提取真实URL链接
	local _TMP_WHILE_WGET_TRUE_URL=$(echo "${_TMP_WHILE_WGET_URL}" | grep -oh -E "https?://[a-zA-Z0-9\.\+\/_&=@$%?~#-]*")

	#最终名
	_TMP_WHILE_WGET_FILE_DEST_NAME=${_TMP_WHILE_WGET_FILE_DEST_NAME:-${_TMP_WHILE_WGET_FILE_SOUR_NAME}}
	# _TMP_WHILE_WGET_FILE_DEST_NAME=$([ -n "${_TMP_WHILE_WGET_FILE_DEST_NAME}" ] && echo "${_TMP_WHILE_WGET_FILE_DEST_NAME}" || echo ${_TMP_WHILE_WGET_FILE_SOUR_NAME})
	
	echo "-------------------------------------------------------------------------------------------------------------------"
	echo_style_text "Starting <get> file from [${_TMP_WHILE_WGET_TRUE_URL}] named '${_TMP_WHILE_WGET_FILE_DEST_NAME}'"
	echo "-------------------------------------------------------------------------------------------------------------------"
	echo_style_text "'Current Dir'：$(pwd)"
	local _TMP_WHILE_WGET_DIST_FILE_EXT=$(echo ${_TMP_WHILE_WGET_FILE_DEST_NAME##*.})
	case ${_TMP_WHILE_WGET_DIST_FILE_EXT} in
		"rpm")
			mkdir -pv ${RPMS_DIR} && cd ${RPMS_DIR}
		;;
		"repo")
			mkdir -pv ${REPO_DIR} && cd ${REPO_DIR}
		;;
		"sh")
			mkdir -pv ${SH_DIR} && cd ${SH_DIR}
		;;
		*)
		mkdir -pv ${DOWN_DIR} && cd ${DOWN_DIR}
	esac

	local _TMP_WHILE_WGET_COMMAND="wget -c --tries=0 --timeout=60 --no-check-certificate ${_TMP_WHILE_WGET_TRUE_URL} -O ${_TMP_WHILE_WGET_FILE_DEST_NAME}"
	echo_style_text "'Wget Command'：${_TMP_WHILE_WGET_COMMAND}"
	echo_style_text "'Wget/Current Dir'：$(pwd)"
	echo

	# ??? 未判断文件 ${_TMP_WHILE_WGET_FILE_DEST_NAME} 大小为0

	# 循环执行wget命令，直到成功
	while [ ! -f "${_TMP_WHILE_WGET_FILE_DEST_NAME}" ]; do
		#https://wenku.baidu.com/view/64f7d302b52acfc789ebc936.html
		${_TMP_WHILE_WGET_COMMAND}

		# 网络错误大小为0则清空文件
		local _TMP_WHILE_WGET_FILE_SIZE=$(ls -l ${_TMP_WHILE_WGET_FILE_DEST_NAME} | awk '{ print $5 }')
		if [ ${_TMP_WHILE_WGET_FILE_SIZE} -eq 0 ]; then
			rm -rf ${_TMP_WHILE_WGET_FILE_DEST_NAME}
		fi
	done

	# 执行wget后的脚本
	script_check_action "${2}"

	# 回到wget之前的目录
	cd ${_TMP_WHILE_WGET_CURRENT_DIR}

	return $?
}

# 无限循环重试下载
# 参数1：软件下载地址
# 参数2：软件下载后执行函数名称
function while_curl()
{
	local _TMP_WHILE_CURL_URL=${1}
	local _TMP_WHILE_CURL_CURRENT_DIR=$(pwd)

	#包含指定参数
	local _TMP_WHILE_CURL_FILE_DEST_NAME=$(echo "${_TMP_WHILE_CURL_URL}" | awk -F'-o' '{print $2}' | awk '{sub("^ *","");sub(" *$","");print}' | awk -F' ' '{print $1}')

	#原始链接名
	local _TMP_WHILE_CURL_FILE_NAME=$(echo "${_TMP_WHILE_CURL_URL}" | awk -F'/' '{print $NF}' | awk -F' ' '{print $NR}')

	#提取真实URL链接
	local _TMP_WHILE_CURL_TRUE_URL=$(echo "${_TMP_WHILE_CURL_URL}" | grep -oh -E "https?://[a-zA-Z0-9\.\+\/_&=@$%?~#-]*")

	#最终名
	_TMP_WHILE_CURL_FILE_DEST_NAME=${_TMP_WHILE_CURL_FILE_DEST_NAME:-${_TMP_WHILE_CURL_FILE_NAME}}
	# _TMP_WHILE_CURL_FILE_DEST_NAME=$([ -n "$_TMP_WHILE_CURL_FILE_DEST_NAME" ] && echo "$_TMP_WHILE_CURL_FILE_DEST_NAME" || echo $_TMP_WHILE_CURL_FILE_NAME)
	
	path_not_exists_create "${CURL_DIR}"
	echo "-------------------------------------------------------------------------------------------------------------------------"
	echo_style_text "Starting <curl> file from [${_TMP_WHILE_CURL_TRUE_URL}] named '${_TMP_WHILE_CURL_FILE_DEST_NAME}'"
	echo "-------------------------------------------------------------------------------------------------------------------------"
	echo_style_text "'Current Dir'：$(pwd)"

	cd ${CURL_DIR}
	local _TMP_WHILE_CURL_COMMAND="curl -4sSkL ${_TMP_WHILE_CURL_TRUE_URL} -o ${_TMP_WHILE_CURL_FILE_DEST_NAME}"
	echo_style_text "'Curl Command'：${_TMP_WHILE_CURL_COMMAND}"
	echo_style_text "'Curl/Current Dir'：$(pwd)"
	echo

	while [ ! -f "${_TMP_WHILE_CURL_FILE_DEST_NAME}" ]; do
		${_TMP_WHILE_CURL_COMMAND}
		
		# 网络错误大小为0则清空文件
		local _TMP_WHILE_CURL_FILE_SIZE=$(ls -l ${_TMP_WHILE_CURL_FILE_DEST_NAME} | awk '{ print $5 }')
		if [ ${_TMP_WHILE_CURL_FILE_SIZE} -eq 0 ]; then
			rm -rf ${_TMP_WHILE_CURL_FILE_DEST_NAME}
		fi
	done

	script_check_action "${2}"

	cd ${_TMP_WHILE_CURL_CURRENT_DIR}

	# rm -rf ${_TMP_WHILE_CURL_FILE_DEST_NAME}

	return $?
}

# 查找网页文件列表中，最新的文件名
# 描述：本函数先获取关键字最新的发布日期，再找对应行的文件名，最后提取href，适合比较通用型的文件列表
# 参数1：需要设置的变量名
# 参数2：需要找寻的URL路径
# 参数3：查找关键字
# 示例：
# 	set_newer_by_url_list_link_date "TMP_NEWER_LINK" "http://repo.yandex.ru/clickhouse/rpm/stable/x86_64/" "clickhouse-common-static-dbg-.*.x86_64.rpm"
function set_newer_by_url_list_link_date()
{
	function _set_newer_by_url_list_link_date()
	{
		local _TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL=${2}
		local _TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_KEY_WORDS=${3}

		local _TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_VERS_VAR_YET_VAL=$(eval echo '${'"${1}"'}')

		echo ${TMP_SPLITER}
		echo_style_text "Checking soft 'version' by 'link date' in <url>(${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL}), default 'val' is [${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_VERS_VAR_YET_VAL}]"
		#  | awk '{if (NR>2) {print}}' ，缺失无效行去除的判断
		local _TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE=$(curl -s -A Mozilla ${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL} | grep "${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_KEY_WORDS}" | awk -F'</a>' '{print $2}' | awk '{sub("^ *","");sub(" *$","");print}' | sed '/^$/d' | awk -F' ' '{print $1}' | awk 'function t_f(t){"date -d \""t"\" +%s" | getline ft; return ft}{print t_f(${1})}' | awk 'BEGIN {max = 0} {if (${1}+0 > max+0) {max=${1} ;content=$0} } END {print content}' | xargs -I {} env LC_ALL=en_US.en date -d@{} "+%d-%h-%Y")
		local _TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT=$(curl -s -A Mozilla ${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL} | grep "${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_KEY_WORDS}" | grep "${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE}" | sed 's/\(.*\)href="\([^"\n]*\)"\(.*\)/\2/g')

		if [ -n "${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT}" ]; then
			echo_style_text "Upgrade the soft 'version' by 'link date' in <url>(${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL}), release 'newer version' to [${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT}]"

			bind_if_input "_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT" "Please sure the checked soft 'version' by 'link date' <newer>('${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT}')，if u want to change"

			eval ${1}='${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT}'
		else
			echo_style_text "Cannot check the soft 'version' by 'link date' in <url>('${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL}'), some part info"
			echo "${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE}"
		fi
	}

	discern_exchange_var_action "${1}" "_set_newer_by_url_list_link_date" "${@}"
	return $?
}

#查找网页文件列表中，最新的文件名
#描述：本函数先获取href标签行，再提取href内容，最后提取文本关键字中最新的版本号，该方法合适比较简单的数字关键字版本信息
# 参数1：需要设置的变量名
# 参数2：需要找寻的URL路径
# 参数3：查找关键字（必须在关键字中将版本号括起‘()’，否则无法匹配具体的版本）
#示例：
# 	set_newer_by_url_list_link_text "TMP_NEWER_LINK" "http://repo.yandex.ru/clickhouse/rpm/stable/x86_64/" "clickhouse-common-static-dbg-().x86_64.rpm"
# 	set_newer_by_url_list_link_text "TMP_NEWER_LINK" "https://services.gradle.org/distributions/" "gradle-()-bin.zip"
function set_newer_by_url_list_link_text()
{
	function _set_newer_by_url_list_link_date()
	{
		local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL=${2}
		local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS=$(echo ${3} | sed 's@()@[0-9.-]*@g')  #‘gradle-()-bin.zip’ -> 'gradle-.*-bin.zip'
		
		# 零宽断言，参考两篇即明白：https://segmentfault.com/q/1010000009346369，https://blog.csdn.net/iteye_5616/article/details/81855906
		local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_LEFT=$(echo ${3} | grep -o ".*(" | sed 's@\(.*\)(@\1@g')
		local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_RIGHT=$(echo ${3} | grep -o ").*" | sed 's@)\(.*\)@\1@g')
		local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_ZREG="(?<=${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_LEFT:-^})\d.*(?=${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_RIGHT:-$})"
		
		local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS_VAR_YET_VAL=$(eval echo '${'"${1}"'}')

		echo ${TMP_SPLITER}
		echo_style_text "Checking soft 'version' by 'link text' in <url>('${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL}'), default 'val' is [${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS_VAR_YET_VAL}]"
		# 清除字母开头： | tr -d "a-zA-Z-"
		local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS=$(curl -s -A Mozilla ${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL} | grep "href=" | grep -v "Parent Directory" | sed 's@\(.*\)href="\([^"\n]*\)"\(.*\)@\2@g' | grep "${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS}" | grep -oP "${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_ZREG}" | sort -rV | awk 'NR==1')
		# local TMP_NEWER_FILENAME=$(echo ${3} | sed "s@()@${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS}.*@g")
		# local TMP_NEWER_HREF_LINK_FILENAME=$(curl -s -A Mozilla ${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL} | grep "href=" | grep -v "Parent Directory" | sed 's@\(.*\)href="\([^"\n]*\)"\(.*\)@\2@g' | grep "${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS}" | grep "${TMP_NEWER_FILENAME}\$" | awk 'NR==1' | sed 's@.*/@@g')

		if [ -n "${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS}" ]; then
			echo_style_text "Upgrade the soft 'version' by 'link text' in <url>('${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL}'), release newer 'version' to [${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS}]"
			
			bind_if_input "_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS" "Please sure the checked soft 'version' by 'link text' newer [${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS}], if u want to change"

			eval ${1}='${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS}'
		else
			echo_style_text "Cannot check the soft 'version' by 'link text' in <url>('${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL}'), some part info"
			echo "${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS}"
		fi
	}

	discern_exchange_var_action "${1}" "_set_newer_by_url_list_link_date" "${@}"
	return $?
}

#检测github最新版本
# 参数1：需要设置的变量名
# 参数2：Github仓储/项目，例如meyer.cheng/linux_scripts
#示例：
#	TMP_ELASTICSEARCH_NEWER_VERS="0.0.1"
#	set_github_soft_releases_newer_version "TMP_ELASTICSEARCH_NEWER_VERS" "elastic/elasticsearch"
#	echo "The github soft of 'elastic/elasticsearch' releases newer version is $TMP_ELASTICSEARCH_NEWER_VERS"
# ??? 兼容没有tag标签的情况，类似filebeat
function set_github_soft_releases_newer_version() 
{
	function _set_github_soft_releases_newer_version()
	{
		local _TMP_GITHUB_SOFT_NEWER_VERS_PATH=${2}

		local _TMP_GITHUB_SOFT_NEWER_VERS_HTTPS_PATH="https://github.com/${_TMP_GITHUB_SOFT_NEWER_VERS_PATH}/releases"
		local _TMP_GITHUB_SOFT_NEWER_VERS_TAG_PATH="${_TMP_GITHUB_SOFT_NEWER_VERS_PATH}/releases/tag/"
		# 提取href中值，如需提取标签内值，则使用： sed 's/="[^"]*[><][^"]*"//g;s/<[^>]*>//g' | awk '{sub("^ *","");sub(" *$","");print}' | awk NR==1
		
		local _TMP_GITHUB_SOFT_NEWER_VERS_VAR_YET_VAL=$(eval echo '${'"${1}"'}')

		echo_style_text "Checking 'github repos soft'(<${_TMP_GITHUB_SOFT_NEWER_VERS_PATH}>), default 'val' is '${_TMP_GITHUB_SOFT_NEWER_VERS_VAR_YET_VAL}'"
		# local _TMP_GITHUB_SOFT_NEWER_VERS=$(curl -s -A Mozilla ${_TMP_GITHUB_SOFT_NEWER_VERS_HTTPS_PATH} | grep "${_TMP_GITHUB_SOFT_NEWER_VERS_TAG_PATH}" | awk '{sub("^ *","");sub(" *$","");sub("<a href=\".*/tag/v", "");sub("<a href=\".*/tag/", "");sub("\">.*", "");print}' | awk NR==1)
		# <a href="/goharbor/harbor/releases/tag/v2.8.0-rc1" data-view-component="true" class="Link--primary">v2.8.0-rc1</a>
		# <a href="/goharbor/harbor/releases/tag/v1.10.17" data-view-component="true" class="Link--primary">v1.10.17</a>
		# <a href="/goharbor/harbor/releases/tag/v1.10.17-rc1" data-view-component="true" class="Link--primary">v1.10.17-rc1</a>
		# <a href="/goharbor/harbor/releases/tag/v2.5.6" data-view-component="true" class="Link--primary">v2.5.6</a>
		# <a href="/goharbor/harbor/releases/tag/v2.5.6-rc1" data-view-component="true" class="Link--primary">v2.5.6-rc1</a>
		# <a href="/goharbor/harbor/releases/tag/v2.7.1" data-view-component="true" class="Link--primary">v2.7.1</a>
		# <a href="/goharbor/harbor/releases/tag/v2.7.1-rc1" data-view-component="true" class="Link--primary">v2.7.1-rc1</a>
		# <a href="/goharbor/harbor/releases/tag/v2.6.4" data-view-component="true" class="Link--primary">v2.6.4</a>
		# <a href="/goharbor/harbor/releases/tag/v2.6.4-rc1" data-view-component="true" class="Link--primary">v2.6.4-rc1</a>
		# <a href="/goharbor/harbor/releases/tag/v1.10.16" data-view-component="true" class="Link--primary">v1.10.16</a>
		local _TMP_GITHUB_SOFT_NEWER_VERS=$(curl -s -A Mozilla "${_TMP_GITHUB_SOFT_NEWER_VERS_HTTPS_PATH}" | grep -o "<a href=\"/${_TMP_GITHUB_SOFT_NEWER_VERS_TAG_PATH}.*<\/a>" | awk '{sub("^ *","");sub(" *$","");sub("<a href=\".*/tag/v", "");sub("<a href=\".*/tag/", "");sub("\".*", "");print}' | grep -vE "\-rc[0-9]+$" | awk 'NR==1')

		if [ -n "${_TMP_GITHUB_SOFT_NEWER_VERS}" ]; then
			echo_style_text "Checking 'github repos soft'(<${_TMP_GITHUB_SOFT_NEWER_VERS_PATH}>), found released 'newer version': ([${_TMP_GITHUB_SOFT_NEWER_VERS}])"

			bind_if_input "_TMP_GITHUB_SOFT_NEWER_VERS" "Please sure 'github repos soft'(<${_TMP_GITHUB_SOFT_NEWER_VERS_PATH}>) version, if u want to [change]" "" "_TMP_GITHUB_SOFT_NEWER_VERS_VAR_YET_VAL"

			eval ${1}='${_TMP_GITHUB_SOFT_NEWER_VERS}'
		else
			echo_style_text "Cannot check the soft in github repos of <${_TMP_GITHUB_SOFT_NEWER_VERS_PATH}>, Some part info"
			echo "${_TMP_GITHUB_SOFT_NEWER_VERS}"
		fi
	}

	discern_exchange_var_action "${1}" "_set_github_soft_releases_newer_version" "${@}"
	return $?
}

# 获取指定URL选择器部分属性
# 参数1：获取URL的地址
# 参数2：内容选择器
# 参数3：获取属性，默认inner_text
# 示例：
#	fetch_url_selector_attr 'https://nodejs.org/en/' 'a[class=home-downloadbutton]:has-text("Recommended For Most Users")'
function fetch_url_selector_attr()
{
	local _TMP_FETCH_URL_SELECTOR_ATTR_URL="${1}"
	local _TMP_FETCH_URL_SELECTOR_ATTR_SELECTOR="${2}"
	local _TMP_FETCH_URL_SELECTOR_ATTR_ATTR="${3:-'inner_text'}"

	function _fetch_url_selector_attr_by_pw()
	{
		su_bash_env_conda_channel_exec "cd ${PLAYWRIGHT_SCRIPTS_DIR} && python py/pw_async_fetch_url_selector_attr.py '${_TMP_FETCH_URL_SELECTOR_ATTR_URL}' '${_TMP_FETCH_URL_SELECTOR_ATTR_SELECTOR}' '${_TMP_FETCH_URL_SELECTOR_ATTR_ATTR}'"
	}
	
	path_exists_yn_action "${PLAYWRIGHT_SCRIPTS_DIR}/py/pw_async_fetch_url_selector_attr.py" "_fetch_url_selector_attr_by_pw" "not implement"
}

# # 在yaml-list中执行
# # 参数1：加载的URL
# # 参数2：key的特征
# # 参数3：执行的脚本 
# # 示例：
# # exec_in_yml_list "http://${_TMP_GITLAB_ADDRESS}/network-security/office/-/raw/main/cust_filter/cust_filter_internal.list" "^- '" "_compare_ag_increase_cust_filter" "${_TMP_AG_API_PIPELINE_REGEX}" "_submit_ag_increase_cust_filter"
# function exec_in_yml_list()
# {
#     local _TMP_EXEC_IN_YML_LIST_LOAD_URL=${1}
#     local _TMP_EXEC_IN_YML_LIST_ITEM_FEATURE=${2}
#     local _TMP_EXEC_IN_YML_LIST_ACTION=${3}
#     local _TMP_EXEC_IN_YML_LIST_ITEM_PIPILINE=${4:-"awk -F':' '{print \$NF}'"}
#     local _TMP_EXEC_IN_YML_LIST_AFTER_ACTION=$5
    
#     local _TMP_EXEC_IN_YML_LIST_YML_CONTENT=$(curl -s -A Mozilla ${_TMP_EXEC_IN_YML_LIST_LOAD_URL})
#     while read line
#     do
#         local _TMP_EXEC_IN_YML_LIST_ITEM_MATCH_LINE=$(echo "${_TMP_EXEC_IN_YML_LIST_YML_CONTENT}" | grep "^${line}$" -n | awk -F':' '{print $1}' | awk 'NR==1')
#         local _TMP_EXEC_IN_YML_LIST_ITEM=$(eval "echo \"${_TMP_EXEC_IN_YML_LIST_YML_CONTENT}\" | sed -n \"${_TMP_EXEC_IN_YML_LIST_ITEM_MATCH_LINE}p\" | ${_TMP_EXEC_IN_YML_LIST_ITEM_PIPILINE} | awk '{sub(\"^ *\",\"\");sub(\" *$\",\"\");print}'")
        
#         script_check_action "${_TMP_EXEC_IN_YML_LIST_ACTION}"
#     done < <(echo "${_TMP_EXEC_IN_YML_LIST_YML_CONTENT}" | grep -E "${_TMP_EXEC_IN_YML_LIST_ITEM_FEATURE}")

#     if [ -n "${_TMP_EXEC_IN_YML_LIST_AFTER_ACTION}" ]; then
#         script_check_action "${_TMP_EXEC_IN_YML_LIST_AFTER_ACTION}"
#     fi

#     return $?
# }

##########################################################################################################
# 函数操作类
##########################################################################################################
# 检测并执行指令
# 参数1：要执行的函数/脚本名称，或变量名称
# 参数2-N：为函数时，要附加的参数
# 示例：
#     function test_func()
#     {
#         echo "${1}"
#         echo "${2}"
#         echo "${3}"
#     }
# 
#     script_check_action "test_func" "1" "2" "3"
#     local test_func_var="test_func"
#     script_check_action "test_func_var" "1" "2" "3"
#     script_check_action "echo 'hello test_func'"
function script_check_action() {
	# 为空不执行
	if [ -z "${1}" ]; then
		return 0
	fi

	local _TMP_EXEC_CHECK_ACTION_SCRIPT=$(echo_discern_exchange_var_val "${1}")
	
	# 空格数等于0的情况，可能是函数名或变量名。
	# 循环获取到最终的值，有可能是变量名嵌套传递。
	local _TMP_EXEC_CHECK_ACTION_PRE_SCRIPT=""
	## 没有空格，则是函数或者变量
	while [ $(echo "${_TMP_EXEC_CHECK_ACTION_SCRIPT}" | grep -o '[[:space:]]' | wc -l) -eq 0 ]; do
		# 非函数时（未定义的也会检测不到），开始检测
		if [ "$(type -t ${_TMP_EXEC_CHECK_ACTION_SCRIPT})" != "function" ] ; then	
			# 解析后结果还是相同，放弃解析，避免死循环
			if [ -n "${_TMP_EXEC_CHECK_ACTION_PRE_SCRIPT}" ] && [ "${_TMP_EXEC_CHECK_ACTION_PRE_SCRIPT}" == "${_TMP_EXEC_CHECK_ACTION_SCRIPT}" ]; then
				break
			fi

			_TMP_EXEC_CHECK_ACTION_SCRIPT=$(echo_discern_exchange_var_val "${_TMP_EXEC_CHECK_ACTION_SCRIPT}")
		
			# 变量解析后可能为空，为空则不执行(全部将在此跳出)
			if [ ${#_TMP_EXEC_CHECK_ACTION_SCRIPT} -eq 0 ]; then
				return 0
			fi

			_TMP_EXEC_CHECK_ACTION_PRE_SCRIPT="${_TMP_EXEC_CHECK_ACTION_SCRIPT}"
		else
			break
		fi
	done

	# 支持标记符 %s 传递参数，未验证，暂不操作
	# if [ -n "${2}" ]; then
	# 	local _TMP_EXEC_CHECK_ACTION_PRINTF_SCRIPT="${2}"
	# 	exec_text_printf "_TMP_EXEC_CHECK_ACTION_PRINTF_SCRIPT" "${_TMP_EXEC_CHECK_ACTION_SCRIPT}"
	# 	_TMP_EXEC_CHECK_ACTION_SCRIPT="${_TMP_EXEC_CHECK_ACTION_PRINTF_SCRIPT}"
	# fi

	# 变量传递脚本，有可能变量读取完以后，是执行脚本而非函数，所以此处再判断
	## 移除第一位选择器
	shift
	if [ "$(type -t ${_TMP_EXEC_CHECK_ACTION_SCRIPT})" == "function" ] ; then
		# path_not_exists_link "/opt/docker/bin/docker" "" "/usr/bin/docker" 这种也会被判别为function
		if [ $(echo "${_TMP_EXEC_CHECK_ACTION_SCRIPT}" | grep -o ' ' | wc -l) -eq 0 ]; then
			${_TMP_EXEC_CHECK_ACTION_SCRIPT} "${@}"
		else
			eval "${_TMP_EXEC_CHECK_ACTION_SCRIPT}"
		fi
	else
		exec_multy_printf "_TMP_EXEC_CHECK_ACTION_SCRIPT" "${@}"
		eval "${_TMP_EXEC_CHECK_ACTION_SCRIPT}"
	fi

	return $?
}

# 无限循环尝试启动程序
# 参数1：程序启动命令
# 参数2：程序检测命令（返回1）
# 参数3：失败后执行
# 例子：TMP=1 && while_exec "TMP=\$((TMP+1))" "[ \$TMP -eq 10 ] && echo 1" "echo \$TMP"
function while_exec()
{
	local _TMP_WHILE_EXEC_SCRIPT=${1}
	local _TMP_WHILE_EXEC_CHECK_SCRIPT=${2}
	local _TMP_WHILE_EXEC_FAILURE_SCRIPT=${3}

	echo "${TMP_SPLITER}"
	echo_style_text "Starting exec check script '${_TMP_WHILE_EXEC_CHECK_SCRIPT}'"
	local _TMP_WHILE_EXEC_CHECK_RESULT=$(eval "${_TMP_WHILE_EXEC_CHECK_SCRIPT}")
	if [ $I -eq 1 ] && [ "${_TMP_WHILE_EXEC_CHECK_RESULT}" == "1" ]; then
		echo_style_text "Script is 'running', exec exit"
		break
	fi

	echo_style_text "Starting exec script '${_TMP_WHILE_EXEC_SCRIPT}'"
	echo "${TMP_SPLITER}"

	for I in $(seq 99);
	do
		echo_style_text "Execute sequence：'${I}'"
		echo "${TMP_SPLITER2}"
		eval "$_TMP_WHILE_EXEC_SCRIPT"

		_TMP_WHILE_EXEC_CHECK_RESULT=$(eval "${_TMP_WHILE_EXEC_CHECK_SCRIPT}")

		if [ "${_TMP_WHILE_EXEC_CHECK_RESULT}" != "1" ]; then
			echo_style_text "Execute <failure>, the result response '<${_TMP_WHILE_EXEC_CHECK_RESULT}>', this will wait for 30s to try again"
			
			path_exists_yn_action "${GUM_PATH}" "gum spin --spinner monkey --title \"Waitting for try again...\" -- sleep 30" "sleep 30"	

			if [ ${#_TMP_WHILE_EXEC_FAILURE_SCRIPT} -gt 0 ]; then
				eval "${_TMP_WHILE_EXEC_FAILURE_SCRIPT}"
				echo "${TMP_SPLITER}"
			fi
		else
			echo "${TMP_SPLITER}"
			echo_style_text "Execute 'success'"
			echo "${TMP_SPLITER3}"
			break
		fi
	done

	return $?
}

# 命令存在时执行
# 参数1：需要判断的命令
# 参数2：要执行的函数/脚本名称，或变量名称
# 参数3-N：为函数时，要附加的参数
# 示例：
#     command_check_action "conda" "conda update -y conda"
#     local test_func_var="%s update -y %s"
#     command_check_action "conda" "test_func_var" "conda"
function command_check_action() {
	local _TMP_CMD_CHECK_ACTION_CMD=${1}
	local _TMP_CMD_CHECK_ACTION_FIRST_VAR_VAL=${2}

	local _TMP_CMD_CHECK_ACTION_CMD_WHERE=$(whereis ${_TMP_CMD_CHECK_ACTION_CMD})
	if [ "${_TMP_CMD_CHECK_ACTION_CMD}:" != "${_TMP_CMD_CHECK_ACTION_CMD_WHERE}" ]; then
		script_check_action "${@:2}"
		return 1
	fi

	return $?
}

# 执行需要判断的Y/N逻辑函数
# 参数1：需要针对存放的变量名/值，读取默认值
# 参数2：提示信息
# 参数3：执行Y时脚本
# 参数4：执行N时脚本
# 参数5：动态参数传递
function confirm_yn_action()
{
	function _confirm_yn_action()
	{
		typeset -u _TMP_CONFIRM_YN_ACTION_VAR_VAL
		local _TMP_CONFIRM_YN_ACTION_VAR_VAL=$(eval expr '$'${1})
		local _TMP_CONFIRM_YN_ACTION_ECHO=${2}
		local _TMP_CONFIRM_YN_ACTION_FUNCS_OR_SCRIPTS_Y=${3}
		local _TMP_CONFIRM_YN_ACTION_FUNCS_OR_SCRIPTS_N=${4}
		local _TMP_CONFIRM_YN_ACTION_RET=$?
		
		bind_style_text "_TMP_CONFIRM_YN_ACTION_ECHO"

		local _TMP_CONFIRM_YN_ACTION_Y_N=""
		function _TMP_CONFIRM_YN_ACTION_NORMAL_FUNC() {
			echo_style_text "${_TMP_CONFIRM_YN_ACTION_ECHO}, by follow key ('yes(y)' or enter key 'no(n)' or 'else')?"
			read -n 1 _TMP_CONFIRM_YN_ACTION_Y_N
			echo ""

			if [ -z "${_TMP_CONFIRM_YN_ACTION_Y_N}" ] && [ -n "${_TMP_CONFIRM_YN_ACTION_VAR_VAL}" ]; then
				echo_style_text "Cannot find 'sure val', set 'confirm val' to <${_TMP_CONFIRM_YN_ACTION_VAR_VAL}>"
				_TMP_CONFIRM_YN_ACTION_Y_N="${_TMP_CONFIRM_YN_ACTION_VAR_VAL}"
			fi

			return $?
		}
		
		function _TMP_CONFIRM_YN_ACTION_GUM_FUNC() {
			local _TMP_CONFIRM_YN_ACTION_VAR_GUM_DEFAULT=$([[ ${_TMP_CONFIRM_YN_ACTION_VAR_VAL} == "Y" ]] && echo "true" || echo "false")
			_TMP_CONFIRM_YN_ACTION_Y_N=$(gum confirm --default=${_TMP_CONFIRM_YN_ACTION_VAR_GUM_DEFAULT} "${_TMP_CONFIRM_YN_ACTION_ECHO}?" && echo 'Y' || echo 'N')

			return $?
		}
		
		path_exists_yn_action "${GUM_PATH}" "_TMP_CONFIRM_YN_ACTION_GUM_FUNC" "_TMP_CONFIRM_YN_ACTION_NORMAL_FUNC"

		# 移除前面4个参数 
		# shift 4

		case "${_TMP_CONFIRM_YN_ACTION_Y_N}" in
		"y" | "Y")
			script_check_action "${_TMP_CONFIRM_YN_ACTION_FUNCS_OR_SCRIPTS_Y}" "${@:5}"
		;;
		*)
			script_check_action "${_TMP_CONFIRM_YN_ACTION_FUNCS_OR_SCRIPTS_N}" "${@:5}"

			# 修复错误，否则选择N时，值无法赋上
			# return 1
			_TMP_CONFIRM_YN_ACTION_RET=1
		esac

		eval ${1}="${_TMP_CONFIRM_YN_ACTION_Y_N:-N}"
		
		# bind_style_text "Checked [${_TMP_CONFIRM_YN_ACTION_Y_N:-'N'}]"

		return ${_TMP_CONFIRM_YN_ACTION_RET}
	}

	discern_exchange_var_action "${1}" "_confirm_yn_action" "${@}"
	return $?
}

# 执行需要判断的Y/N逻辑函数
# 参数1：需要针对存放的变量名/值，读取默认值
# 参数2：提示信息
# 参数3：执行Y时脚本
# 参数4：动态参数传递
function confirm_y_action()
{
	confirm_yn_action "${1}" "${2}" "${3}" "" "${@:4}"
}

# 执行需要判断的Y/N逻辑函数
# 参数1：需要针对存放的变量名/值，读取默认值
# 参数2：提示信息
# 参数3：执行N时脚本
# 参数4：动态参数传递
function confirm_n_action()
{
	confirm_yn_action "${1}" "${2}" "" "${3}" "${@:4}"
}

# # [未使用]，函数名与逻辑不匹对]执行需要判断的Y/N逻辑函数
# # 参数1：并行逻辑执行参数/脚本
# # 参数2：提示信息
# function confirm_yn_continuous_action()
# {
# 	local _TMP_EXEC_YN_ACTION_Y_SCRIPTS=${1}
# 	local _TMP_EXEC_YN_ACTION_ECHO=${2}
		
# 	function _TMP_EXEC_YN_ACTION_EXEC_FUNC() {
# 		local _TMP_EXEC_YN_ACTION_ARR_FUNCS_OR_SCRIPTS=(${_TMP_EXEC_YN_ACTION_Y_SCRIPTS//,/ })
# 		#echo ${#_TMP_ARR_FUNCS_OR_SCRIPTS[@]} 
# 		for _TMP_EXEC_YN_ACTION_FUNC_ON_Y in ${_TMP_EXEC_YN_ACTION_ARR_FUNCS_OR_SCRIPTS[@]}; do
# 			script_check_action "${_TMP_EXEC_YN_ACTION_FUNC_ON_Y}"
# 			local _TMP_EXEC_YN_ACTION_RETURN=$?
# 			#返回非0，跳出循环，指导后续请求不再进行
# 			if [ ${_TMP_EXEC_YN_ACTION_RETURN} != 0 ]; then
# 				return ${_TMP_EXEC_YN_ACTION_RETURN}
# 			fi
# 		done

# 		return $?
# 	}

# 	confirm_yn_action "" "${_TMP_EXEC_YN_ACTION_ECHO}" "_TMP_EXEC_YN_ACTION_EXEC_FUNC"

# 	return $?
# }

# [未使用]检测是否值
# function check_yn_action() {
# 	local _TMP_CHECK_YN_ACTION_YN_VAL=$(echo_discern_exchange_var_val "${1}")
# 	typeset -l _TMP_CHECK_YN_ACTION_YN_VAL
	
# 	if [ "${_TMP_CHECK_YN_ACTION_YN_VAL_YN_VAL}" == false ] || [ "${_TMP_CHECK_YN_ACTION_YN_VAL_YN_VAL}" == "no" ] || [ "${_TMP_CHECK_YN_ACTION_YN_VAL_YN_VAL}" == "n" ] || [ -z "${_TMP_CHECK_YN_ACTION_YN_VAL_YN_VAL}" ] || [ "${_TMP_CHECK_YN_ACTION_YN_VAL_YN_VAL}" == 0 ]; then
# 		return $?
# 	fi

# 	return 1
# }

# 按数组循环执行函数
# 参数1：需要针对存放的变量名
# 参数2：循环数组
# 参数3：循环执行脚本函数
# 示例：
#       exec_repeat_funcs "TMP_EXEC_REPS_RESULT" "1000,2000" "num_sum"
function exec_repeat_funcs()
{
	function _exec_repeat_funcs()
	{
		local _TMP_EXEC_REPEAT_FUNCS_ARRAY_STR=${2}
		
		local _TMP_EXEC_REPEAT_FUNCS_ARR=(${_TMP_EXEC_REPEAT_FUNCS_ARRAY_STR//,/ })
		for I in ${!_TMP_EXEC_REPEAT_FUNCS_ARR[@]};  
		do
			local _TMP_EXEC_REPEAT_FUNCS_OUTPUT=$(${3} "${_TMP_EXEC_REPEAT_FUNCS_ARR[$I]}")

			if [ ${I} -gt 0 ]; then
				eval ${1}=$(eval expr '$'${1},${_TMP_EXEC_REPEAT_FUNCS_OUTPUT})
			else
				eval ${1}='${_TMP_EXEC_REPEAT_FUNCS_OUTPUT}'
			fi
		done
	}

	discern_exchange_var_action "${1}" "_exec_repeat_funcs" "${@}"
	return $?
}

#循环执行函数，执行true时终止(函数的入参列表必须一致)
# 参数1：需要针对存放的变量名
# 参数2：循环函数数组
# 参数3：函数入参(不定长)
# 示例：
#       exec_funcs_repeat_until_output "TMP_EXEC_FUNCS_REPS_UNTIL_OUTPUT_RESULT" "funa,funb" "_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_CURRENT_FUNCa" "paramc" ...
function exec_funcs_repeat_until_output()
{
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_VAR_NAME=${1}
	local _TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_ARR_FUNCS=${2}
	local _TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_FUNC_PARAMS=()

	local _I=0
	for _TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_CURRENT_FUNC in "$@";
	do
		if [ ${_I} -gt 1 ]; then
			_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_FUNC_PARAMS[${_I}-2]="\"${_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_CURRENT_FUNC}\""
		fi
		
	    let _I++
	done
	
	local _TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_ARR=(${_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_ARR_FUNCS//,/ })
	for I in ${!_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_ARR[@]};  
	do
		local _TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_EXEC="${_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_ARR[$I]} ${_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_FUNC_PARAMS[*]}"
		local _TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_OUTPUT=$(eval ${_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_EXEC})
		if [ -n "${_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_OUTPUT}" ]; then
			break
		fi
	done

	return $?
}

##########################################################################################################
# 备份还原操作类
##########################################################################################################
# 软件目录痕迹清理与备份
# 参数1：软件名称
# 参数2：需要清理的目录（数组字符串）
# 参数3：目录最终清理清理前执行脚本
# 参数4：是否强制删除（Y/N），强制删除则不提醒，默认N
# 示例：
#     dirs_trail_clear "docker" "_[*]" "echo 1" "N"
function dirs_trail_clear() 
{
	local _TMP_DIRS_TRAIL_CLEAR_NAME="${1}"	
	local _TMP_DIRS_TRAIL_CLEAR_MARK_NAME="${_TMP_DIRS_TRAIL_CLEAR_NAME/\//_}"	
	local _TMP_DIRS_TRAIL_CLEAR_TRUTHFUL_DIR_ARR=(${2})
	typeset -u _TMP_DIRS_TRAIL_CLEAR_FORCE
	local _TMP_DIRS_TRAIL_CLEAR_FORCE=${4:-"N"}
	
	# 备份文件
	## 获取软链接后的真实路径
	### Record really dir of </mountdisk/data/docker> from source link </mountdisk/data/docker -> /var/lib/docker>
	### Checked dir of </var/lib/docker> is a symlink for really dir </mountdisk/data/docker>, sys deleted.
	### Record really dir of </run/docker> from source link </var/run/docker -> /var/run/docker>
	### Record really dir of </etc/docker> from source link </etc/docker -> /etc/docker>
	### Record really dir of </mountdisk/logs/docker> from source link </mountdisk/logs/docker -> /mountdisk/logs/docker>
	### Checked dir of </mountdisk/conf/docker> is a symlink for really dir </etc/docker>, sys deleted.
	### Record really dir of </opt/docker> from source link </opt/docker -> /opt/docker>
	echo_style_wrap_text "Starting 'resolve dirs' of soft(<${_TMP_DIRS_TRAIL_CLEAR_NAME}>)"

	function _dirs_trail_clear_remove_sym_dir()
	{
		echo_style_text "'|'Found <really> dir [${2}], symlink '${1}' was deleted."
		rm -rf ${1}
	}

	# 转换为真实目录，防止不识别
	bind_dirs_convert_truthful_action "_TMP_DIRS_TRAIL_CLEAR_TRUTHFUL_DIR_ARR" "_dirs_trail_clear_remove_sym_dir"
	
	if [ ${#_TMP_DIRS_TRAIL_CLEAR_TRUTHFUL_DIR_ARR[@]} -gt 0 ]; then
		echo_style_text "The 'dirs' from soft(<${_TMP_DIRS_TRAIL_CLEAR_NAME}>) was resolved"
	else
		echo_style_text "None 'dirs found' for 'trail' in soft(<${_TMP_DIRS_TRAIL_CLEAR_NAME}>)"
		script_check_action "${3}" "${1}"
		return
	fi

	# 备份 && 删除文件
	local _TMP_DIRS_TRAIL_CLEAR_CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
	local _TMP_DIRS_TRAIL_CLEAR_CURRENT_TIME_STAMP=$(date -d "${_TMP_DIRS_TRAIL_CLEAR_CURRENT_TIME}" +%s)
	local _TMP_DIRS_TRAIL_CLEAR_BACKUP_SCRIPT="[[ -a '%s' ]] && (mkdir -pv ${BACKUP_DIR}%s && cp -Rp %s ${BACKUP_DIR}%s/${_TMP_DIRS_TRAIL_CLEAR_CURRENT_TIME_STAMP} && rm -rf %s && echo_style_text \"Dir of '%s' [backuped] to <${BACKUP_DIR}%s/${_TMP_DIRS_TRAIL_CLEAR_CURRENT_TIME_STAMP}>\") || echo_style_text 'Backup dir <%s> not found'"
	# local _TMP_DIRS_TRAIL_CLEAR_FORCE_SCRIPT=${_TMP_DIRS_TRAIL_CLEAR_SOFT_SCRIPT//tmp\/backup/tmp\/force}
	local _TMP_DIRS_TRAIL_CLEAR_FORCE_SCRIPT="[[ -a '%s' ]] && (mkdir -pv ${FORCE_DIR}%s && cp -Rp %s ${FORCE_DIR}%s/${_TMP_DIRS_TRAIL_CLEAR_CURRENT_TIME_STAMP} && rm -rf %s && echo_style_text \"Dir of '%s' was [force deleted]。if u want to <restore>, please find it manually from '${FORCE_DIR}%s/${_TMP_DIRS_TRAIL_CLEAR_CURRENT_TIME_STAMP}'\") || echo_style_text 'Force [delete] dir <%s> not found'"
	function _dirs_trail_clear_exec_backup()
	{
		local _TMP_DIRS_TRAIL_CLEAR_SOFT_ECHO="([${_TMP_DIRS_TRAIL_CLEAR_NAME}]) Checked the trail dir of '${1}', please 'sure' u will <backup> 'still or not'"

		local _TMP_DIRS_TRAIL_CLEAR_PRINTF_BACKUP_SCRIPT="${1}"
		exec_text_printf "_TMP_DIRS_TRAIL_CLEAR_PRINTF_BACKUP_SCRIPT" "${_TMP_DIRS_TRAIL_CLEAR_BACKUP_SCRIPT}"
		local _TMP_DIRS_TRAIL_CLEAR_PRINTF_FORCE_SCRIPT="${1}"
		exec_text_printf "_TMP_DIRS_TRAIL_CLEAR_PRINTF_FORCE_SCRIPT" "${_TMP_DIRS_TRAIL_CLEAR_FORCE_SCRIPT}"

		# [docker]Checked the trail dir of '/mountdisk/data/docker', please sure u will 'backup still or not'?
		# Dir of </mountdisk/data/docker> backuped to </tmp/backup/mountdisk/data/docker/1669793077>

		path_exists_confirm_action "${1}" "${_TMP_DIRS_TRAIL_CLEAR_SOFT_ECHO}" "${_TMP_DIRS_TRAIL_CLEAR_PRINTF_BACKUP_SCRIPT}" "${_TMP_DIRS_TRAIL_CLEAR_PRINTF_FORCE_SCRIPT}" "echo_style_text 'Dir of <${1}> not found'" "Y"
	}
	
	# 有记录的情况下才执行
	echo_style_wrap_text "Starting 'trail' the dirs of soft(<${_TMP_DIRS_TRAIL_CLEAR_NAME}>)"
	if [ "${_TMP_DIRS_TRAIL_CLEAR_FORCE}" == "N" ]; then
		## 具备特殊性质的备份，优先执行
		local _TMP_DIRS_TRAIL_CLEAR_SPECIAL_FUNC="special_backup_${_TMP_DIRS_TRAIL_CLEAR_MARK_NAME}"
		if [ "$(type -t ${_TMP_DIRS_TRAIL_CLEAR_SPECIAL_FUNC})" == "function" ] ; then
			echo_style_text "Starting 'exec' the 'soft special func' of <${_TMP_DIRS_TRAIL_CLEAR_NAME}>"
			script_check_action "_TMP_DIRS_TRAIL_CLEAR_SPECIAL_FUNC" "${_TMP_DIRS_TRAIL_CLEAR_NAME}"
			echo_style_text "The 'soft special func' of <${_TMP_DIRS_TRAIL_CLEAR_NAME}> was executed"
		fi
		
		script_check_action "${3}" "${1}"

		items_split_action "_TMP_DIRS_TRAIL_CLEAR_TRUTHFUL_DIR_ARR" "_dirs_trail_clear_exec_backup"
	else
		script_check_action "${3}" "${1}"
		
		items_split_action "_TMP_DIRS_TRAIL_CLEAR_TRUTHFUL_DIR_ARR" "${_TMP_DIRS_TRAIL_CLEAR_FORCE_SCRIPT}"
	fi

	echo_style_text "The 'dirs' of soft(<${_TMP_DIRS_TRAIL_CLEAR_NAME}>) was trailed"
	return $?
}

# 软件安装目录痕迹清理与备份
# 参数1：软件名称名称
# 参数2：是否强制删除（Y/N），强制删除则不提醒，默认N
# 示例：
#     soft_trail_clear "wget" "N"
function soft_trail_clear() 
{
	local _TMP_SOFT_TRAIL_CLEAR_SOFT_NAME=${1}
	local _TMP_SOFT_TRAIL_CLEAR_FORCE=${2:-"N"}
	local _TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR=()
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[0]="/var/lib/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[1]="/var/log/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[2]="/run/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[3]="/etc/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[4]="/etc/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}.conf"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[5]="/home/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[6]="/root/.${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[7]="/run/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[8]="${LOGS_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[9]="${DATA_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[10]="${CONF_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[11]="${SETUP_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[12]="${LOGS_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}_apps"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[13]="${DATA_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}_apps"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[14]="${CONF_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}_apps"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[15]="${SETUP_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}_apps"

	# docker的情况
	local _TMP_SOFT_TRAIL_CLEAR_DOCKER_CTN_IDS=()
	if [ "${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}" == "docker" ]; then
		_TMP_SOFT_TRAIL_CLEAR_DOCKER_CTN_IDS=($(docker ps -a | awk 'NR>1' | cut -d' ' -f1 2>/dev/null))
	fi
	
	# 已经进入清理流程，不管选择是否备份。都要执行删除服务
	function _soft_trail_clear_remove_all()
	{
		if [ "${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}" == "docker" ]; then
			# 清理容器残留
			function _soft_trail_clear_docker_container()
			{
				local _TMP_SOFT_TRAIL_CLEAR_DOCKER_IMG_FULL_NAME=$(docker container inspect ${1} | jq '.[0].Config.Image' | grep -oP "(?<=^\").*(?=\"$)")
				echo_style_wrap_text "Starting 'trail clear' <docker> 'container'($((${2}+1))/${#_TMP_SOFT_TRAIL_CLEAR_DOCKER_CTN_IDS[@]}): <${_TMP_SOFT_TRAIL_CLEAR_DOCKER_IMG_FULL_NAME}>([${1}])"
				docker_soft_trail_clear "${1}" "${_TMP_SOFT_TRAIL_CLEAR_FORCE}"
			}
			
			items_split_action "_TMP_SOFT_TRAIL_CLEAR_DOCKER_CTN_IDS" "_soft_trail_clear_docker_container"
		fi
				
		## 清理服务残留（备份前执行，否则会有资源占用的问题）
		function _soft_trail_clear_svr_remove() 
		{
			echo_style_wrap_text "Starting 'remove systemctl' named <${1}>"
			systemctl stop ${1} && systemctl disable ${1} && rm -rf /usr/lib/systemd/system/${1} && rm -rf /etc/systemd/system/multi-user.target.wants/${1}
			echo_style_text "'Systemctl' <${1}> removed"
		}

		# export -f _soft_trail_clear_svr_remove
		# systemctl list-unit-files | grep ${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME} | cut -d' ' -f1 | grep -v '^$' | sort -r | xargs -I {} bash -c "_soft_trail_clear_svr_remove {}"
		systemctl list-unit-files | grep ${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME} | cut -d' ' -f1 | grep -v '^$' | sort -r | eval "script_channel_action '_soft_trail_clear_svr_remove'"
	}
		
	dirs_trail_clear "${1}" "${_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[*]}" "_soft_trail_clear_remove_all" "${2}"
	
	# 删除特定用户
	(id ${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME} &> /dev/null) && userdel -rf ${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME} &> /dev/null

	systemctl daemon-reload

	return $?
}

# Docker软件挂载目录痕迹清理与备份
# 参数1：绑定变量名/值，例 _TMP_DIR_ARR
# 参数2：容器ID，例 e75f9b427730
# 示例：
#     _TMP_DIR_ARR=() && docker_soft_dirs_bind "_TMP_DIR_ARR" "e75f9b427730" && echo "${_TMP_DIR_ARR[*]}"
#     _TMP_DIR_ARR=("/etc/test") && docker_soft_dirs_bind "_TMP_DIR_ARR" "e75f9b427730" && echo "${_TMP_DIR_ARR[*]}"
#     _TMP_DIR_STR="/etc/test" && docker_soft_dirs_bind "_TMP_DIR_STR" "e75f9b427730" && echo "${_TMP_DIR_STR}"
function docker_soft_dirs_bind() 
{
	# 完整的PSID docker ps -a -f name=xxx|id=xxx
	local _TMP_DOCKER_SOFT_DIRS_BIND_CTN_ID=$(docker ps -a --no-trunc | grep "^${2}" | cut -d' ' -f1)
	if [ -z "${_TMP_DOCKER_SOFT_DIRS_BIND_CTN_ID}" ]; then
		echo_style_text "Cannot found <containers>([${2}])"
		return
	fi
	# 完整的容器inspect
	local _TMP_DOCKER_SOFT_DIRS_BIND_CTN_INSPECT=$(docker container inspect ${_TMP_DOCKER_SOFT_DIRS_BIND_CTN_ID})
	# e75f9b427730
	local _TMP_DOCKER_SOFT_DIRS_BIND_IMG_ID=$(echo "${_TMP_DOCKER_SOFT_DIRS_BIND_CTN_INSPECT}" | jq '.[0].Image' | grep -oP "(?<=^\").*(?=\"$)" | cut -d':' -f2)
	# browserless/chrome:imgver111111
	local _TMP_DOCKER_SOFT_DIRS_BIND_IMG_FULL_NAME=$(echo "${_TMP_DOCKER_SOFT_DIRS_BIND_CTN_INSPECT}" | jq '.[0].Config.Image' | grep -oP "(?<=^\").*(?=\"$)")
	# browserless/chrome
	local _TMP_DOCKER_SOFT_DIRS_BIND_IMG_NAME=$(echo "${_TMP_DOCKER_SOFT_DIRS_BIND_IMG_FULL_NAME}" | cut -d':' -f1)
	# imgver111111
	local _TMP_DOCKER_SOFT_DIRS_BIND_IMG_VER=$(echo "${_TMP_DOCKER_SOFT_DIRS_BIND_IMG_FULL_NAME}" | cut -d':' -f2)
	# browserless_chrome
	local _TMP_DOCKER_SOFT_DIRS_BIND_IMG_MARK_NAME=${_TMP_DOCKER_SOFT_DIRS_BIND_IMG_NAME/\//_}
	# browserless_chrome/imgver111111
	local _TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR="${_TMP_DOCKER_SOFT_DIRS_BIND_IMG_MARK_NAME}/${_TMP_DOCKER_SOFT_DIRS_BIND_IMG_VER}"

	# 绑定变量的类型
	local _TMP_DOCKER_SOFT_DIRS_BIND_VAR_ARR=()
	bind_discern_exchange_var_arr "_TMP_DOCKER_SOFT_DIRS_BIND_VAR_ARR" "${1}"
	local _TMP_DOCKER_SOFT_DIRS_BIND_VAR_NAME=${_TMP_DOCKER_SOFT_DIRS_BIND_VAR_ARR[0]}
	local _TMP_DOCKER_SOFT_DIRS_BIND_VAR_TYPE=${_TMP_DOCKER_SOFT_DIRS_BIND_VAR_ARR[1]}
	local _TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR=(${_TMP_DOCKER_SOFT_DIRS_BIND_VAR_ARR[2]})

	# 真实路径 - 基础四大路径
	_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR[${#_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR[@]}]="${DOCKER_APP_DATA_DIR}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}"
	_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR[${#_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR[@]}]="${DOCKER_APP_CONF_DIR}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}"
	_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR[${#_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR[@]}]="${DOCKER_APP_SETUP_DIR}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}"
	_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR[${#_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR[@]}]="${DOCKER_APP_LOGS_DIR}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}"

	# 真实路径 - 挂载路径
	# 父目录存在的情况则不添加，例如:
	# 已知目录：/opt/docker_apps/browserless_chrome/054dce166530，则类似/opt/docker_apps/browserless_chrome/054dce166530/work不添加
	function _docker_soft_dirs_bind_combine_filter()
	{
		if [ -z "$(docker volume ls | grep "${1}")" ]; then	
			item_change_append_ignore_prefix_bind "_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR" "${1}" "/"
		else
			local _TMP_DOCKER_SOFT_DIRS_BIND_SOFT_MOUNT_POINT=$(docker volume inspect ${1} | jq ".[0].Mountpoint" | grep -oP "(?<=^\").*(?=\"[,]*$)")
			if [ -n "${_TMP_DOCKER_SOFT_DIRS_BIND_SOFT_MOUNT_POINT}" ]; then
				item_change_append_ignore_prefix_bind "_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR" "_TMP_DOCKER_SOFT_DIRS_BIND_SOFT_MOUNT_POINT" "/"
			fi
		fi
	}
	
	# 下述管道内赋值无法改变数组
	# su_bash_env_conda_channel_exec "runlike ${2}" | grep -oP '(?<=--volume=)[^ ]+(?=\s)' | cut -d':' -f1 | grep -v '^/etc/localtime$' | sort | eval "script_channel_action '_docker_soft_dirs_bind_combine_filter'"
	items_split_action "$(su_bash_env_conda_channel_exec "runlike ${2}" | grep -oP '(?<=--volume=)[^ ]+(?=\s)' | cut -d':' -f1 | grep -v '^/etc/localtime$' | grep -v '^/var/run/docker.sock$' | sort)" "_docker_soft_dirs_bind_combine_filter"

	# 虚拟目录的连接是存在重复的，在此声明主要为了清理无效软连接
	# 虚拟目录 - Docker目录
	item_change_append_bind "_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR" "^${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}$" "${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}"
	item_change_append_bind "_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR" "^${DOCKER_SETUP_DIR}/${DEPLOY_DATA_MARK}/apps/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}$" "${DOCKER_SETUP_DIR}/${DEPLOY_DATA_MARK}/apps/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}"
	item_change_append_bind "_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR" "^${DOCKER_SETUP_DIR}/${DEPLOY_CONF_MARK}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}$" "${DOCKER_SETUP_DIR}/${DEPLOY_CONF_MARK}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}"
	item_change_append_bind "_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR" "^${DOCKER_DATA_DIR}/containers/${_TMP_DOCKER_SOFT_DIRS_BIND_CTN_ID}$" "${DOCKER_DATA_DIR}/containers/${_TMP_DOCKER_SOFT_DIRS_BIND_CTN_ID}"

	# 虚拟目录 - 容器安装目录
	if [ -a "${DOCKER_APP_SETUP_DIR}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}" ]; then
		local _TMP_DOCKER_SOFT_DIRS_BIND_APP_DIRS="$(ls -l ${DOCKER_APP_SETUP_DIR}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}/ | awk -F' ' '{print $9}' | awk '$1=$1')"
		function _docker_soft_dirs_bind_combine_append_setup()
		{
			item_change_append_bind "_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR" "^${DOCKER_APP_SETUP_DIR}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}/${1}$" "${DOCKER_APP_SETUP_DIR}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}/${1}"
		}

		items_split_action "_TMP_DOCKER_SOFT_DIRS_BIND_APP_DIRS" "_docker_soft_dirs_bind_combine_append_setup"
	fi
	item_change_append_bind "_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR" "^${DOCKER_APP_SETUP_DIR}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}$" "${DOCKER_APP_SETUP_DIR}/${_TMP_DOCKER_SOFT_DIRS_BIND_STORE_REL_DIR}"

	if [ "${_TMP_DOCKER_SOFT_DIRS_BIND_VAR_TYPE}" == "array" ]; then
		eval ${_TMP_DOCKER_SOFT_DIRS_BIND_VAR_NAME}='(${_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR[*]})'
	else
		eval ${_TMP_DOCKER_SOFT_DIRS_BIND_VAR_NAME}='${_TMP_DOCKER_SOFT_DIRS_BIND_DIR_ARR[*]}'
	fi

	return $?
}

# Docker软件挂载目录痕迹清理与备份
# 参数1：容器ID，例 e75f9b427730
# 参数2：是否强制删除（Y/N），强制删除则不提醒，默认N
# 示例：
#     docker_soft_trail_clear "e75f9b427730" "N"
function docker_soft_trail_clear() 
{
	# 完整的PSID docker ps -a -f name=xxx|id=xxx
	local _TMP_DOCKER_SOFT_TRAIL_CLEAR_CTN_ID=$(docker ps -a --no-trunc | grep "^${1}" | cut -d' ' -f1)
	if [ -z "${_TMP_DOCKER_SOFT_TRAIL_CLEAR_CTN_ID}" ]; then
		echo_style_text "Cannot found <containers>([${1}])"
		return
	fi

	# 完整的容器inspect
	local _TMP_DOCKER_SOFT_TRAIL_CLEAR_CTN_INSPECT=$(docker container inspect ${_TMP_DOCKER_SOFT_TRAIL_CLEAR_CTN_ID})
	# browserless/chrome:imgver111111
	local _TMP_DOCKER_SOFT_TRAIL_CLEAR_IMG_FULL_NAME=$(echo "${_TMP_DOCKER_SOFT_TRAIL_CLEAR_CTN_INSPECT}" | jq '.[0].Config.Image' | grep -oP "(?<=^\").*(?=\"$)")
	# browserless/chrome
	local _TMP_DOCKER_SOFT_TRAIL_CLEAR_IMG_NAME=$(echo "${_TMP_DOCKER_SOFT_TRAIL_CLEAR_IMG_FULL_NAME}" | cut -d':' -f1)

	# 真实路径 - 基础四大路径
	typeset -u _TMP_DOCKER_SOFT_TRAIL_CLEAR_FORCE
	local _TMP_DOCKER_SOFT_TRAIL_CLEAR_FORCE=${2:-"N"}
	local _TMP_DOCKER_SOFT_TRAIL_CLEAR_DIR_ARR=()
	docker_soft_dirs_bind "_TMP_DOCKER_SOFT_TRAIL_CLEAR_DIR_ARR" "${1}"

	# 移除前记录挂载卷
	local _TMP_DOCKER_SOFT_TRAIL_CLEAR_VOLUMES=$(docker container inspect ${1} | jq --arg TYPE 'volume' '.[0].Mounts[] | select(.Type == $TYPE) | .Name' | grep -oP "(?<=^\").*(?=\"$)")

	# 容器移除
	function _docker_soft_trail_clear_ctn_remove()
	{
		echo_style_text "Starting 'stop&remove' <containers> from 'image'(<${_TMP_DOCKER_SOFT_TRAIL_CLEAR_IMG_FULL_NAME}>([${_TMP_DOCKER_SOFT_TRAIL_CLEAR_CTN_ID}]))"
		docker stop ${_TMP_DOCKER_SOFT_TRAIL_CLEAR_CTN_ID}
		docker rm ${_TMP_DOCKER_SOFT_TRAIL_CLEAR_CTN_ID}
	}
	dirs_trail_clear "<${_TMP_DOCKER_SOFT_TRAIL_CLEAR_IMG_FULL_NAME}>([${1}])" "${_TMP_DOCKER_SOFT_TRAIL_CLEAR_DIR_ARR[*]}" "_docker_soft_trail_clear_ctn_remove" "${_TMP_DOCKER_SOFT_TRAIL_CLEAR_FORCE}"
	
	# 挂载卷移除
	echo "${TMP_SPLITER2}"
	echo_style_text "Starting 'remove' <volumes> from 'image'(<${_TMP_DOCKER_SOFT_TRAIL_CLEAR_IMG_FULL_NAME}>([${_TMP_DOCKER_SOFT_TRAIL_CLEAR_CTN_ID}]))"
	items_split_action "_TMP_DOCKER_SOFT_TRAIL_CLEAR_VOLUMES" "docker volume rm %s"

	return $?
}

# 软件安装的路径还原（因为很多路径可能存在于手动创建，所以该功能针对于备份后的还原）
# 参数1：还原路径
# 参数2：提示文本
# 参数3：不存在备份，执行脚本
# 参数4：存在备份，执行脚本
#       参数1：操作目录，例如：/opt/docker
#       参数1：还原来源，例如：/mountdisk/repo/backup/opt/docker
# 示例：
#	   soft_path_restore_confirm_action "/opt/docker" "" "echo 'create_dir'" "echo 'exec_restore'"
#      -> [setup_docker] Checked current soft got some backup path for '/opt/docker', please sure u want to 'restore still or not'?
#      --> [setup_docker] Please sure 'which version' u want to 'restore', by follow keys, then enter it
#      ---> |>[1]1669633047
#      soft_path_restore_confirm_action "/etc/docker"
function soft_path_restore_confirm_action() 
{
	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC="${FUNCNAME[1]}"
	if [ "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}" == "soft_path_restore_confirm_create" ] || [ "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}" == "soft_path_restore_confirm_pcreate" ] || [ "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}" == "soft_path_restore_confirm_cust" ] || [ "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}" == "soft_path_restore_confirm_move" ] || [ "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}" == "soft_path_restore_confirm_copy" ] || [ "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}" == "soft_path_restore_confirm_swap" ]; then
		_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC="${FUNCNAME[2]}"
	fi

	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_LOCK_FUNC=(${FUNCNAME[*]})
	item_change_select_bind "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_LOCK_FUNC" "^docker_image_args_combine_bind$"

	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH="${1}"
	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_CONFIRM_ECHO="${2:-"([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) Checked 'backup path' for <${1}> exists, please sure u want to <restore> 'still or not'"}"
	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_N_SCRIPTS=${3}
	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_E_SCRIPTS=${4}

	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_PATH="${BACKUP_DIR}${1}"
	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_COVER_ECHO="([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) Checked 'current soft' already got 'path'(<${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}>), please sure u want to <cover> 'still or' <force>"

	# 备份到强制，然后删除
	# 参数1：操作目录，例如：/opt/docker
	function _soft_path_restore_confirm_action_force_exec()
	{
		# 移动到备份，再覆盖
		local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_FORCE_SCRIPT="[[ -a '%s' ]] && (mkdir -pv ${FORCE_DIR}%s && cp -Rp %s ${FORCE_DIR}%s/${LOCAL_TIMESTAMP} && rm -rf %s && echo_style_text \"Dir of '%s' was <force deleted>。if u want to <restore>，please find it manually from <${FORCE_DIR}%s/${LOCAL_TIMESTAMP}>\") || echo_style_text 'Force delete dir of <%s> not found'"

		local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_FORCE_SCRIPT="${1}"
		exec_text_printf "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_FORCE_SCRIPT" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_FORCE_SCRIPT}"

		script_check_action "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_FORCE_SCRIPT"
	}
	
	# 覆盖目录
	# 参数1：操作目录，例如：/opt/docker
	function _soft_path_restore_confirm_action_cover_exec()
	{
		echo
		echo_style_text "([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) Starting cover the path of '${1}'"
		
		# 直接覆盖，进cover
		# [formal_docker] Checked current soft already got the path of '/etc/docker', please sure u want to 'cover still or force'?
		local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_COVER_SCRIPT="[[ -a '%s' ]] && (mkdir -pv ${COVER_DIR}%s && cp -Rp %s ${COVER_DIR}%s/${LOCAL_TIMESTAMP} && rm -rf %s && echo_style_text \"Dir of '%s' backuped to <${COVER_DIR}%s/${_TMP_SOFT_TRAIL_CLEAR_CURRENT_TIME_STAMP}>\") || echo_style_text 'Cover dir of <%s> not found'"
		local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_COVER_SCRIPT="${1}"
		exec_text_printf "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_COVER_SCRIPT" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_COVER_SCRIPT}"

		# 文件不存在，直接复制
		script_check_action "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_COVER_SCRIPT"
		
		echo_style_text "([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) The path of <${1}> was covered"
		echo
	}
	
	function _soft_path_restore_confirm_action_restore_exec()
	{
		local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VERS=$(ls ${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_PATH} | egrep "^[0-9]{10}$" | sort -rV)
		local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VER=$(echo "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VERS}" | awk 'NR==1')

		## 提示&选择查找存在备份的最新文件
		# 参数1：检测到的备份文件的路径，例如：/tmp/backup/opt/docker/1666083394
		function _soft_path_restore_confirm_action_restore_choice_exec()
		{
			# 备份到强制，然后删除
			# 参数1：操作目录，例如：/opt/docker
			function _soft_path_restore_confirm_action_restore_choice_force_exec()
			{
				_soft_path_restore_confirm_action_force_exec "${@}"

				_soft_path_restore_confirm_action_restore_choice_cover_exec "${@}"
			}

			# 覆盖目录
			# 参数1：操作目录，例如：/opt/docker
			function _soft_path_restore_confirm_action_restore_choice_cover_exec()
			{
				# 有多个版本时，才提供选择操作
				local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VERS_COUNT=$(echo "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VERS}" | wc -w)
				if [ ${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VERS_COUNT} -gt 1 ]; then
					echo "${TMP_SPLITER2}"
					bind_if_choice "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VER" "([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) Please sure 'which version' of the path of '${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}' u want to [restore]" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VERS}"
				else
					_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VER="${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VERS}"
				fi
				local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_PATH="${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_PATH}/${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VER}"

				echo
				echo_style_text "([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) Starting <restore> the path of <${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}> from '${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_PATH}'"

				# 直接覆盖，进cover
				# [formal_docker] Checked current soft already got the path of '/etc/docker', please sure u want to 'cover still or force'?
				local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_COVER_SCRIPT="[[ -a '%s' ]] && (mkdir -pv ${COVER_DIR}%s && cp -Rp %s ${COVER_DIR}%s/${LOCAL_TIMESTAMP} && rsync -av ${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_PATH}/ %s  && echo_style_text \"Dir of '%s' backuped to <${COVER_DIR}%s/${_TMP_SOFT_TRAIL_CLEAR_CURRENT_TIME_STAMP}>\") || (mkdir -pv \$(dirname %s) && cp -Rp ${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_PATH} %s)"
				local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_PRINTF_COVER_SCRIPT="${1}"
				exec_text_printf "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_PRINTF_COVER_SCRIPT" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_COVER_SCRIPT}"

				# 文件不存在，直接复制
				script_check_action "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_PRINTF_COVER_SCRIPT"
				script_check_action "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_E_SCRIPTS" "${1}" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_PATH}"
				
				echo_style_text "([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) The path of <${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}> was resotred"
				echo
			}

			# 还原目标路径本身存在，移至强行删除目录中（如果是走安装程序过来，会被提前备份，不会触发此段）
			# 走到这步，已选择还原备份（是否覆盖还原/强制还原的过程，强制还原始终执行覆盖还原的逻辑）
			path_exists_confirm_action "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_COVER_ECHO}" "_soft_path_restore_confirm_action_restore_choice_cover_exec" "_soft_path_restore_confirm_action_restore_choice_force_exec" "_soft_path_restore_confirm_action_restore_choice_cover_exec" "N"
		}

		# 如果是 docker_image_args_combine_bind 调用，直接还原
		if [ ${#_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_LOCK_FUNC[@]} -gt 0 ]; then
			_soft_path_restore_confirm_action_restore_choice_exec
		else
			path_exists_confirm_action "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_PATH}/${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_RESTORE_BACKUP_VER:-"none"}" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_CONFIRM_ECHO}" "_soft_path_restore_confirm_action_restore_choice_exec" "_soft_path_restore_confirm_action_newer_exec" "_soft_path_restore_confirm_action_newer_exec" "Y"
		fi
	}
	
	# 新装，或没有备份时执行
	# 参数1：检测到的备份文件的路径，例如：/tmp/backup/opt/docker/1666083394
	function _soft_path_restore_confirm_action_newer_exec()
	{
		# path_exists_confirm_action "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_COVER_ECHO}" "_soft_path_restore_confirm_action_cover_exec" "_soft_path_restore_confirm_action_force_exec"
		
		script_check_action "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_N_SCRIPTS" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}" "${1}"
	}

	# 查找备份是否存在
	path_exists_yn_action "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_PATH}" "_soft_path_restore_confirm_action_restore_exec" "_soft_path_restore_confirm_action_newer_exec"

	return $?
}

# 软件安装的路径还原自定义（还原不存在则自定义）
# 参数1：还原路径
# 参数2：还原不存在的自定义执行脚本
# 示例：
#	   soft_path_restore_confirm_custom "/opt/docker"
function soft_path_restore_confirm_custom() 
{
	# soft_path_restore_confirm_action "${1}" "" "script_check_action '${2}' '${1}'" ""
	soft_path_restore_confirm_action "${1}" "" "${2}" ""
	return $?
}

# 软件安装的路径还原创建（还原不存在则创建父目录）
# 参数1：还原路径
# 参数2：还原不存在的自定义执行脚本
# 示例：
#	   soft_path_restore_confirm_pcreate "/opt/docker"
function soft_path_restore_confirm_pcreate() 
{
	soft_path_restore_confirm_action "${1}" "" "mkdir -pv $(dirname ${1}) && script_check_action '${2}' '${1}'" ""
	return $?
}

# 软件安装的路径还原创建（还原不存在则创建）
# 参数1：还原路径
# 参数2：创建后执行脚本
# 示例：
#	   soft_path_restore_confirm_create "/opt/docker"
function soft_path_restore_confirm_create() 
{
	soft_path_restore_confirm_action "${1}" "" "mkdir -pv ${1} && script_check_action '${2}' '${1}'" ""
	return $?
}

# 软件安装的路径还原复制（还原不存在则复制）
# 参数1：还原路径
# 参数2：来源路径
# 示例：
#	   soft_path_restore_confirm_copy "/mountdisk/data/docker" "/var/lib/docker" 
function soft_path_restore_confirm_copy() 
{
	soft_path_restore_confirm_action "${1}" "" "mkdir -pv $(dirname ${1}) && [[ -a ${2} ]] && cp -Rp ${2} ${1}" ""
	return $?
}

# 软件安装的路径还原移动（还原不存在则移动、存在则删除。适配来源路径不需要备份且来源路径一直存在的场景，自动软链）
# 参数1：还原路径
# 参数2：来源路径
# 示例：
#	   soft_path_restore_confirm_move "/mountdisk/data/docker_empty" "/var/lib/docker" 
function soft_path_restore_confirm_move() 
{
	soft_path_restore_confirm_action "${1}" "" "mkdir -pv $(dirname ${1}) && ([[ -a ${2} ]] && (cp -Rp ${2} ${1} && rm -rf ${2}) || mkdir -pv $(dirname ${2}) ${1}) && ln -sf ${1} ${2}" "rm -rf ${2} && ln -sf ${1} ${2}"
	return $?
}

# 软件安装的路径还原迁移（还原不存在则迁移且移动并备份原始目录，适配来源路径需要备份且来源路径一直存在的场景，自动软链）
# 参数1：还原路径
# 参数2：来源路径(为空则默认取还原路径)
# 示例：
#	   soft_path_restore_confirm_swap "/mountdisk/data/docker" "/var/lib/docker" 
function soft_path_restore_confirm_swap() 
{
	soft_path_restore_confirm_action "${1}" "" "mkdir -pv $(dirname ${1}) && ([[ -a ${2} ]] && (cp -Rp ${2} ${1} && mv ${2} ${1}_clean_${LOCAL_TIMESTAMP}) || mkdir -pv $(dirname ${2}) ${1}) && ln -sf ${1} ${2}" "mv ${2} ${1}_clean_${LOCAL_TIMESTAMP} && ln -sf ${1} ${2}"
	return $?
}

##########################################################################################################
# Docker操作类
##########################################################################################################
# 获取docker-hub仓库发布版本列表
# 参数1：获取docker-hub仓库地址
# 示例：
#	fetch_docker_hub_release_vers 'labring/sealos'
function fetch_docker_hub_release_vers()
{
	local _TMP_FETCH_DOCKER_HUB_RELEASE_VERS_REPO="${1}"

	function _fetch_docker_hub_release_vers_by_pw()
	{
		su_bash_env_conda_channel_exec "cd ${PLAYWRIGHT_SCRIPTS_DIR} && (python py/pw_async_fetch_docker_hub_vers.py ${_TMP_FETCH_DOCKER_HUB_RELEASE_VERS_REPO}) | grep -vE '\-rc[0-9]+.*$'"
	}
	
	path_exists_yn_action "${PLAYWRIGHT_SCRIPTS_DIR}/py/pw_async_fetch_docker_hub_vers.py" "_fetch_docker_hub_release_vers_by_pw" "not implement"
	return $?
}

# 获取docker-hub仓库发布版本的数字标记
# 参数1：获取docker-hub仓库地址
# 参数2：对应版本
# 示例：
#	fetch_docker_hub_release_ver_digests 'labring/sealos' 'imgver111111'
function fetch_docker_hub_release_ver_digests()
{
	local _TMP_FETCH_DOCKER_HUB_RELEASE_VER_DIGESTS_REPO="${1}"
	local _TMP_FETCH_DOCKER_HUB_RELEASE_VER_DIGESTS_REPO_VER="${2}"

	function _fetch_docker_hub_release_ver_digests_by_pw()
	{
		su_bash_env_conda_channel_exec "cd ${PLAYWRIGHT_SCRIPTS_DIR} && python py/pw_async_fetch_docker_hub_ver_digests.py ${_TMP_FETCH_DOCKER_HUB_RELEASE_VER_DIGESTS_REPO} ${_TMP_FETCH_DOCKER_HUB_RELEASE_VER_DIGESTS_REPO_VER}"
	}
	
	path_exists_yn_action "${PLAYWRIGHT_SCRIPTS_DIR}/py/pw_async_fetch_docker_hub_ver_digests.py" "_fetch_docker_hub_release_ver_digests_by_pw" "not implement"
}

# Docker容器检测输出
# 参数1：容器ID或名称值或变量名，用于检测
# 参数2：查询到容器后执行脚本
#       参数1：镜像ID，例 imgid111111
#       参数2：容器ID，例 ctnid111111
#       参数3：镜像名称，例 browserless/chrome
#       参数4：镜像版本，例 imgver111111_v1670329246
#       参数5：启动命令，例 /bin/sh
#       参数6：启动参数，例 --volume /etc/localtime:/etc/localtime:ro
# 示例：
#     docker_container_param_check_action "ctnid111111" "func_a"
function docker_container_param_check_action() 
{
	local _TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_ID_OR_NAME=$(echo_discern_exchange_var_val "${1}")	
	if [ -z "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_ID_OR_NAME}" ]; then
		echo_style_text "None container id or name define"
		return
	fi
	
	# docker ps -a -f name=xxx|id=xxx
	local _TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_PS=$(docker ps -a --no-trunc | awk "NR>1{if(\$1~\"${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_ID_OR_NAME}\"||\$NF==\"${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_ID_OR_NAME}\"){print}}")
	local _TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_ID=$(echo "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_PS}" | awk "{print \$1}")
	if [ -z "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_ID}" ]; then
		echo_style_text "None container found <${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_ID_OR_NAME}>"
		return
	fi

	local _TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_FULL_NAME=$(echo "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_PS}" | awk "{print \$2}")
	local _TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_NAME=$(echo ${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_FULL_NAME} | cut -d':' -f1)
	_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_NAME=$(echo_docker_image_formal_name "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_NAME}")

	local _TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_VER=$(echo ${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_FULL_NAME} | cut -d':' -f2)
	_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_FULL_NAME="${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_NAME}:${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_VER}"
	
	local _TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_ID=$(docker images | awk "NR>1{if(\$1==\"${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_NAME//library\//}\" && \$2==\"${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_VER}\"){print \$3}}")

	local _TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_RUNLIKE=$(su_bash_env_conda_channel_exec "runlike ${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_ID}")
	local _TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_CMD=$(echo "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_RUNLIKE}" | grep -oP "(?<=${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_FULL_NAME} ).+")
	local _TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_ARGS=$(echo "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_RUNLIKE}" | grep -oP "(?<=docker run ).+(?=${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_FULL_NAME})")

	script_check_action "${2}" "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_ID}" "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_ID}" "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_NAME}" "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_IMG_VER}" "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_CMD}" "${_TMP_DOCKER_CTN_PARAM_CHECK_ACTION_CTN_ARGS}"
	return $?
}

# Docker镜像检测输出（返回镜像列表）
# 参数1：镜像ID值或变量名，用于检测
# 参数2：查询到镜像后执行脚本
#       参数1：镜像ID，例 imgid111111
#       参数2：容器ID，例 ctnid111111
#       参数3：镜像名称，例 browserless/chrome
#       参数4：镜像版本，例 imgver111111_v1670329246
#       参数5：启动命令，例 /bin/sh
#       参数6：启动参数，例 --volume /etc/localtime:/etc/localtime:ro
# 示例：
#     docker_image_param_check_action "imgid111111" "func_a"
function docker_image_param_check_action() 
{
	local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ID=$(echo_discern_exchange_var_val "${1}")
	if [ -n "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ID}" ] && [ -n "${2}" ]; then
		local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_INSPECT="$(docker inspect ${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ID} 2>/dev/null | jq '.[0]')"
		if [ -n "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_INSPECT}" ]; then
			local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_FULL_NAME=$(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_INSPECT}" | jq '.RepoTags' | grep -oP "(?<=^  \").*(?=\",*$)")
			if [ -z "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_FULL_NAME}" ]; then
				_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_FULL_NAME=$(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_INSPECT}" | jq '.Config.Image' | xargs echo)
			fi
			
			local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_NAME=$(echo ${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_FULL_NAME} | cut -d':' -f1)
			local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_VER=$(echo ${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_FULL_NAME} | cut -d':' -f2)
			_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_NAME=$(echo_docker_image_formal_name "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_NAME}")
			_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_FULL_NAME="${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_NAME}:${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_VER}"

			local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CTN_IDS=$(echo_docker_container_grep "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_FULL_NAME}" | awk '{print $1}')
			local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD=""
			local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ARGS=""

			# 优先取runlike参数，较为精准
			local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CALC_INSPECT="${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_INSPECT}"
			function _docker_image_param_check_action_bind_ctn_data() {			
				_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD=${5}
				_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ARGS=${6}

				_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CALC_INSPECT="$(docker container inspect ${2} | jq '.[0]')"
			}
			docker_container_param_check_action "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CTN_IDS}" "_docker_image_param_check_action_bind_ctn_data" >> /dev/null

			trim_str "_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD"
			# 从Path中取
			if [[ -z "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD}" || "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD}" = "null" ]]; then
				local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_PATH=$(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CALC_INSPECT}" | jq '.Path' | xargs echo)
				if [ "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_PATH}" != "null" ]; then
					local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD_ARR=($(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CALC_INSPECT}" | jq '.Args' | grep -oP "(?<=^  \").*(?=\",*$)"))
					_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD="${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_PATH} ${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD_ARR[*]}"
				fi
			fi
			
			# 从.Config.Cmd中取
			if [[ -z "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD}" || "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD}" = "null" ]]; then
				local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD_ARR=($(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CALC_INSPECT}" | jq '.Config.Cmd' | grep -oP "(?<=^  \").*(?=\",*$)"))
				_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD="${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD_ARR[*]}"
			fi
			
			# 从.ContainerConfig.Cmd中取
			if [[ -z "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD}" || "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD}" = "null" ]]; then
				local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD_ARR=($(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CALC_INSPECT}" | jq '.ContainerConfig.Cmd'))
				_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD="${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD_ARR[*]}"
			fi

			trim_str "_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ARGS"
			if [ -z "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ARGS}" ]; then
				local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ENVS=$(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CALC_INSPECT}" | jq '.Config.Env' | grep -oP "(?<=^  \").*(?=\",*$)")
				local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_ARG_ENVS=
				if [ -n "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ENVS}" ]; then
					_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_ARG_ENVS=$(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ENVS}" | xargs printf "--env=%s ")
				fi

				if [ "$(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CALC_INSPECT}" | jq '.Mounts')" != "null" ]; then
					local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_MOUNTS=$(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CALC_INSPECT}" | jq '.Mounts[] | .Source + ":" + .Destination + ":" + .Mode' | grep -oP "(?<=^\").*(?=\"$)")
					local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_ARG_MOUNTS=
					if [ -n "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_MOUNTS}" ]; then
						_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_ARG_MOUNTS=$(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_MOUNTS}" | xargs printf "--volume=%s ")
					fi
				fi

				local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_LBLS=$(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CALC_INSPECT}" | jq '.Config.Labels' | grep -oP "(?<=^  \").*(?=\",*$)" | awk -F'": "' "{print \$1\"='\"\$2\"'\"}")
				local _TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_ARG_LBLS=
				if [ -n "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_LBLS}" ]; then
					_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_ARG_LBLS=$(echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_LBLS}" | xargs printf "--label='%s' ")
				fi

				_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ARGS="${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_ARG_ENVS} ${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_ARG_MOUNTS} ${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_ARG_LBLS}"
			fi

			trim_str "_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD"
			trim_str "_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ARGS"
			_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD=$([[ "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD}" != "null" ]] && echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD}" || echo)
			_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ARGS=$([[ "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ARGS}" != "null" ]] && echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ARGS}" || echo)

			script_check_action "${2}" "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ID}" "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_CTN_IDS}" "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_NAME}" "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_VER}" "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_CMD}" "${_TMP_DOCKER_IMAGE_PARAM_CHECK_ACTION_IMG_ARGS}"
			return $?
		fi
	fi

    return $?
}

# Docker镜像检测输出（返回镜像列表）
# 参数1：镜像名称(模糊正则查询)，用于检测
# 参数2：查询到镜像后执行脚本
#       参数1：镜像名称，例 browserless/chrome
#       参数2：镜像版本，例 imgver111111_v1670329246
#       参数3：启动命令，例 /bin/sh
#       参数4：启动参数，例 --volume /etc/localtime:/etc/localtime:ro
# 示例：
#     docker_images_param_check_action "browserless/" "func_a"
function docker_images_param_check_action() 
{
	local _TMP_DOCKER_CHECK_EXISTS_ACTION_REGEX_VAL=$(echo_discern_exchange_var_val "${1}")	
	if [ -n "${_TMP_DOCKER_CHECK_EXISTS_ACTION_REGEX_VAL}" ]; then
		items_split_action "$(docker images | egrep "${_TMP_DOCKER_CHECK_EXISTS_ACTION_REGEX_VAL}" | grep -Pv ".+_v[0-9]{10}(?=SC[0-9]+)" | awk '{print $3}')" "docker_image_param_check_action '%s' '${2}'"
	fi

    return $?
}

# Docker镜像检测输出（返回镜像列表）
# 参数1：容器ID变量值或名，用于检测
# 参数2：查询到卷后执行脚本
#       参数1：JSON项目
# 示例：
#     docker_container_mounts_json_action "ctnid1111111" "func_a"
function docker_container_mounts_json_action() 
{
	local _TMP_DOCKER_CONTAINER_MOUNTS_JSON_ACTION_CTN_ID_VAL=$(echo_discern_exchange_var_val "${1}")	
	if [[ -n "${_TMP_DOCKER_CONTAINER_MOUNTS_JSON_ACTION_CTN_ID_VAL}" && -n "${2}" ]]; then
		json_split_action "$(docker container inspect "${_TMP_DOCKER_CONTAINER_MOUNTS_JSON_ACTION_CTN_ID_VAL}" | jq ".[0].Mounts")" "${2}"
		return $?
	fi

    return $?
}

# Docker镜像检测输出（返回镜像列表）
# 参数1：容器ID变量值或名，用于检测
# 参数2：查询到卷后执行脚本
#       参数1：挂载类型，例 bind/volume
#       参数2：本地路径，例 /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose
#       参数3：镜像路径，例 /var/log/docker
#       参数4：读写模式，例 rw,z
# 示例：
#     docker_container_mounts_action "ctnid1111111" "func_a"
function docker_container_mounts_action() 
{
	local _TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_SCRIPT=$(echo_discern_exchange_var_val "${2}")
	function _docker_container_mounts_action()
	{
		local _TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_TYPE=$(echo "${1}" | jq '.Type' | xargs echo)
		local _TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_SOURCE=$(echo "${1}" | jq '.Source' | xargs echo)
		local _TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_DESTINATION=$(echo "${1}" | jq '.Destination' | xargs echo)
		local _TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_MODE=$(echo "${1}" | jq '.Mode' | xargs echo)
		
		script_check_action "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_SCRIPT}" "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_TYPE}" "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_SOURCE}" "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_DESTINATION}" "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_MODE:-rw}"
	}

	docker_container_mounts_json_action "${1}" "_docker_container_mounts_action"
    return $?
}

# Docker镜像检测输出（返回镜像列表）
# 参数1：容器ID变量值或名，用于检测
# 示例：
#     docker_container_mounts_echo "ctnid1111111"
function docker_container_mounts_echo() 
{
	function _docker_container_mounts_echo()
	{
		local _TMP_DOCKER_CONTAINER_MOUNTS_ECHO_VOL_OUTPUT="${2}:${3}"		
		if [ -n "${4}" ]; then
			_TMP_DOCKER_CONTAINER_MOUNTS_ECHO_VOL_OUTPUT="${_TMP_DOCKER_CONTAINER_MOUNTS_ECHO_VOL_OUTPUT}:${4}"
		fi
		
		echo "${_TMP_DOCKER_CONTAINER_MOUNTS_ECHO_VOL_OUTPUT}"
	}

	docker_container_mounts_action "${1}" "_docker_container_mounts_echo"
    return $?
}

# Docker镜像检测输出（返回镜像列表）
# 参数1：容器ID变量值或名，用于检测
# 参数2：查询到卷后执行脚本
# 参数3：原始行
#       参数1：原始行
#       参数2：本地路径，例 /mountdisk/logs/docker_apps/goharbor_harbor/v1.10.0/compose
#       参数3：镜像路径，例 /var/log/docker
#       参数4：读写模式，例 rw,z
# 示例：
#     docker_container_hostconfig_binds_action "ctnid1111111" "func_a"
function docker_container_hostconfig_binds_action() 
{
	local _TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_CTN_ID_VAL=$(echo_discern_exchange_var_val "${1}")	
	local _TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_SCRIPT=$(echo_discern_exchange_var_val "${2}")
	if [[ -n "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_CTN_ID_VAL}" && -n "${2}" ]]; then
		function _docker_container_hostconfig_binds_action() 
		{
			local _TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_SOURCE=$(echo "${1}" | awk -F':' '{print $1}')
			local _TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_DESTINATION=$(echo "${1}" | awk -F':' '{print $2}')
			local _TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_MODE=$(echo "${1}" | awk -F':' '{print $3}')
			
			script_check_action "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_SCRIPT}" "${1}" "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_SOURCE}" "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_DESTINATION}" "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_VOL_MODE}"
		}

		local _TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_CTN_INSPECT=$(docker container inspect "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_ACTION_CTN_ID_VAL}")
		if [ $(echo "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_CTN_INSPECT}" | jq ".[0].HostConfig.Binds | length") -gt 0 ]; then
			items_split_action "$(echo "${_TMP_DOCKER_CONTAINER_HOSTCONFIG_BINDS_CTN_INSPECT}" | jq ".[0].HostConfig.Binds[]" | xargs -I {} echo {})" "_docker_container_hostconfig_binds_action"
			return $?
		fi
	fi

    return $?
}

# Docker镜像检测输出（返回镜像列表）
# 参数1：容器ID变量值或名，用于检测
# 示例：
#     docker_container_hostconfig_binds_echo "ctnid1111111"
function docker_container_hostconfig_binds_echo() 
{
	function _docker_container_hostconfig_binds_echo()
	{
		if [ -n "${1}" ]; then
			echo "${1}"
		fi
	}

	docker_container_hostconfig_binds_action "${1}" "_docker_container_hostconfig_binds_echo"
    return $?
}

# Docker容器检测输出（返回JQ容器列表）
# 参数1：容器ID，用于检测
# 示例：
#      local _CHECK_ITEM="ctnid1111111"
#      docker_container_param_check_jq_item_echo "_CHECK_ITEM"
#      docker_container_param_check_jq_item_echo "ctnid1111111"
function docker_container_param_check_jq_item_echo()
{
	local _TMP_DOCKER_CTN_PARAM_CHECK_JQ_ITEM_ECHO_IMG_ID="${1}"
	local _TMP_DOCKER_CTN_PARAM_CHECK_JQ_ITEM_ECHO_JQ_ITEM="{}"

	function _docker_container_param_check_jq_item_echo_jq_item_bind()
	{
		_TMP_DOCKER_CTN_PARAM_CHECK_JQ_ITEM_ECHO_JQ_ITEM="{ \"ImageID\": \"${1}\", \"ContainerID\": \"${2}\", \"Image\": \"${3}\", \"Version\": \"${4}\", \"Cmd\": \"${5}\", \"Args\": \"${6}\" }"
	}

	docker_container_param_check_action "${1}" '_docker_container_param_check_jq_item_echo_jq_item_bind'

	echo "${_TMP_DOCKER_CTN_PARAM_CHECK_JQ_ITEM_ECHO_JQ_ITEM}"
	
	return $?
}

# Docker镜像检测输出（返回JQ镜像列表）
# 参数1：需要绑定的变量名/值
# 参数2：镜像名称(模糊正则查询)，用于检测
# 示例：
#      local _CHECK_ITEM="browserless/"
#      docker_images_param_check_jq_arr_echo "_CHECK_ITEM"
#      docker_images_param_check_jq_arr_echo "browserless/"
function docker_images_param_check_jq_arr_echo()
{
	local _TMP_DOCKER_CHECK_EXISTS_JQ_ARR_BIND_JQ_ARR="[]"

	function _docker_images_param_check_jq_arr_echo_jq_arr_bind()
	{
		change_json_node_arr "_TMP_DOCKER_CHECK_EXISTS_JQ_ARR_BIND_JQ_ARR" "." "" "{ \"ImageID\": \"${1}\", \"ContainerIDS\": \"${2}\", \"Image\": \"${3}\", \"Version\": \"${4}\", \"Cmd\": \"${5}\", \"Args\": \"${6}\" }"
	}

	docker_images_param_check_action "${1}" '_docker_images_param_check_jq_arr_echo_jq_arr_bind'

	echo "${_TMP_DOCKER_CHECK_EXISTS_JQ_ARR_BIND_JQ_ARR}"
	
	return $?
}

# Docker镜像检测输出（返回JQ镜像列表）
# 参数1：需要绑定的变量名/值
# 参数2：镜像名称(模糊正则查询)，用于检测
# 示例：
#      local _EXISTS_JQ_ARR=""
#      local _CHECK_ITEM="browserless/"
#      docker_images_param_check_jq_arr_bind "_EXISTS_JQ_ARR" "_CHECK_ITEM"
#      docker_images_param_check_jq_arr_bind "_EXISTS_JQ_ARR" "browserless/"
function docker_images_param_check_jq_arr_bind()
{
	local _TMP_DOCKER_CHECK_EXISTS_JQ_ARR_BIND_VAR_NAME=$(echo_discern_exchange_var_name "${1}")	
	local _TMP_DOCKER_CHECK_EXISTS_JQ_ARR_BIND_JQ_REGEX=$(echo_discern_exchange_var_val "${2}")
	local _TMP_DOCKER_CHECK_EXISTS_JQ_ARR_BIND_JQ_ARR=$(docker_images_param_check_jq_arr_echo "${_TMP_DOCKER_CHECK_EXISTS_JQ_ARR_BIND_JQ_REGEX}")

	eval ${_TMP_DOCKER_CHECK_EXISTS_JQ_ARR_BIND_VAR_NAME}='${_TMP_DOCKER_CHECK_EXISTS_JQ_ARR_BIND_JQ_ARR}'
	return $?
}

# Docker镜像检测输出（返回JQ镜像列表）
# 参数1：镜像ID，用于检测
# 示例：
#      local _CHECK_ITEM="imgid1111111"
#      docker_image_param_check_jq_item_echo "_CHECK_ITEM"
#      docker_image_param_check_jq_item_echo "imgid1111111"
function docker_image_param_check_jq_item_echo()
{
	local _TMP_DOCKER_IMAGE_PARAM_CHECK_JQ_ITEM_ECHO_IMG_ID="${1}"
	local _TMP_DOCKER_IMAGE_PARAM_CHECK_JQ_ITEM_ECHO_JQ_ITEM="{}"

	function _docker_image_param_check_jq_item_echo_jq_item_bind()
	{
		_TMP_DOCKER_IMAGE_PARAM_CHECK_JQ_ITEM_ECHO_JQ_ITEM="{ \"ImageID\": \"${1}\", \"ContainerIDS\": \"${2}\", \"Image\": \"${3}\", \"Version\": \"${4}\", \"Cmd\": \"${5}\", \"Args\": \"${6}\" }"
	}
	
	docker_image_param_check_action "${1}" '_docker_image_param_check_jq_item_echo_jq_item_bind'

	echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_JQ_ITEM_ECHO_JQ_ITEM}"
	
	return $?
}

# Docker镜像检测输出（返回JQ镜像列表）
# 参数1：需要绑定的变量名/值
# 参数2：镜像ID，用于检测
# 示例：
#      local _EXISTS_JQ_ARR=""
#      local _CHECK_ITEM="imgid1111111"
#      docker_image_param_check_jq_item_bind "_EXISTS_JQ_ARR" "_CHECK_ITEM"
#      docker_image_param_check_jq_item_bind "_EXISTS_JQ_ARR" "imgid1111111"
function docker_image_param_check_jq_item_bind()
{
	local _TMP_DOCKER_IMAGE_PARAM_CHECK_JQ_ITEM_BIND_VAR_NAME=$(echo_discern_exchange_var_name "${1}")	
	local _TMP_DOCKER_IMAGE_PARAM_CHECK_JQ_ITEM_BIND_JQ_ID=$(echo_discern_exchange_var_val "${2}")
	local _TMP_DOCKER_IMAGE_PARAM_CHECK_JQ_ITEM_BIND_JQ_ITEM=$(docker_image_param_check_jq_item_echo "${_TMP_DOCKER_IMAGE_PARAM_CHECK_JQ_ITEM_BIND_JQ_ID}")

	eval ${_TMP_DOCKER_IMAGE_PARAM_CHECK_JQ_ITEM_BIND_VAR_NAME}='${_TMP_DOCKER_IMAGE_PARAM_CHECK_JQ_ITEM_BIND_JQ_ITEM}'
	return $?
}

# 修改DOCKER容器包裹执行器
# 参数1：容器ID
# 参数2：中间执行脚本
# 示例：
#       docker_change_container_inspect_wrap "e75f9b427730" "docker_change_container_inspect_arg 'e75f9b427730' '.Config.WorkingDir' '/usr/src/app'"
function docker_change_container_inspect_wrap()
{
	local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_IDS=""
	local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STATUS=$(echo_service_node_content "docker" "Active")
	if [ "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STATUS}" != "inactive" ]; then
		local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_ID_ARR=()
		function docker_change_container_inspect_wrap_record_ids()
		{
			if [ "$(echo "${1}" | jq ".State.Status" | xargs echo)" == "running" ]; then
				local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_ID=$(echo "${1}" | jq ".Id" | xargs echo)
				item_change_append_bind "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_ID_ARR" "^${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_ID:0:12}$" "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_ID:0:12}"
			fi
		}
		json_split_action "$(docker ps | awk 'NR>1{print $1}' | xargs docker inspect)" "docker_change_container_inspect_wrap_record_ids"
		_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_IDS=${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_ID_ARR[*]}

		## 重新启动并构建新容器
		echo "${TMP_SPLITER2}"
		echo_style_text "Starting 'stop' all 'running containers'(<${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_IDS}>) & docker 'service', hold on please"
		echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_IDS}" | xargs docker container stop
		systemctl stop docker.socket
		systemctl stop docker.service
	fi

	script_check_action "${2}" "${1}" "${@:3}"
	
	echo "${TMP_SPLITER2}"
	echo_style_text "Starting 'boot' docker 'service', hold on please"
	systemctl start docker.service
	systemctl start docker.socket
	
	if [ -n "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_IDS}" ]; then
		# 启动容器
		echo "${TMP_SPLITER2}"
		echo_style_text "Starting 'boot' all 'stopped containers'(<${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_IDS}>), hold on please"
		echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_IDS}" | xargs docker container start
		exec_sleep 5 "Starting wait boot 'containers'(<${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_STOP_IDS}>)"
	fi

	# 挂载可能产生等待
	local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_PORT=$(su_bash_env_conda_channel_exec "runlike ${1}" | grep -oP "(?<=-p )\d+(?=:\d+)" | awk 'NR==1')
	if [ -n "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_PORT}" ]; then
		exec_sleep_until_not_empty "Starting wait [reboot] over 'inspect conf change'" "lsof -i:${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_WRAP_PORT}" 180 3
	fi

    return $?
}

# 添加Docker私有仓库地址
# 参数1：修改内容变量名或值
# 参数2：匹配内容正则变量名或值，默认为修改内容
# 示例：
#       docker_change_insecure_registries "127.0.0.1:19001"
function docker_change_insecure_registries()
{
	local _TMP_DOCKER_CHANGE_INSECURE_REGISTRIES_ADDR=$(echo_discern_exchange_var_val "${1}")
	local _TMP_DOCKER_CHANGE_INSECURE_REGISTRIES_REGEX=$(echo_discern_exchange_var_val "${2}")
	if [ -z "${_TMP_DOCKER_CHANGE_INSECURE_REGISTRIES_REGEX}" ]; then
		_TMP_DOCKER_CHANGE_INSECURE_REGISTRIES_REGEX="^${_TMP_DOCKER_CHANGE_INSECURE_REGISTRIES_ADDR}$"
	fi
	
	local _TMP_DOCKER_CHANGE_INSECURE_REGISTRIES_CONF=$(cat /etc/docker/daemon.json)
    change_json_node_arr "_TMP_DOCKER_CHANGE_INSECURE_REGISTRIES_CONF" '."insecure-registries"' "${_TMP_DOCKER_CHANGE_INSECURE_REGISTRIES_REGEX}" "\"${_TMP_DOCKER_CHANGE_INSECURE_REGISTRIES_ADDR}\""
	change_json_node_item "_TMP_DOCKER_CHANGE_INSECURE_REGISTRIES_CONF" '."live-restore"' "true"
	echo "${_TMP_DOCKER_CHANGE_INSECURE_REGISTRIES_CONF}" | jq > /etc/docker/daemon.json

	return $?
}


# 修改DOCKER容器信息
# 参数1：容器ID
# 参数2：修改的参数节点，例 .Config.WorkingDir
# 参数3：修改的参数节点内容，例 /usr/src/app
# 示例：
#       docker_change_container_inspect_arg "e75f9b427730" ".Config.WorkingDir" "/usr/src/app"
function docker_change_container_inspect_arg()
{
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ARG_DATA_PATH=$(find ${DOCKER_DATA_DIR} -name ${1}* | grep "/container[s]*/" | awk 'NR==1')
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ARG_CONFV2_PATH="${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ARG_DATA_PATH}/config.v2.json"
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ARG_CONFV2=$(cat ${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ARG_CONFV2_PATH})
	
    change_json_node_item "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ARG_CONFV2" "${2}" "\"${3}\""

    echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ARG_CONFV2}" | jq > ${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ARG_CONFV2_PATH}

    return $?
}

# 修改DOCKER容器环境信息
# 参数1：容器ID
# 参数2：环境变量名，例 LANG
# 参数3：环境变量值，例 C.UTF-8
# 示例：
#       docker_change_container_inspect_env "e75f9b427730" "LANG" "C.UTF-8"
function docker_change_container_inspect_env()
{
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ENV_DATA_PATH=$(find ${DOCKER_DATA_DIR} -name ${1}* | grep "/container[s]*/" | awk 'NR==1')
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ENV_CONFV2_PATH="${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ENV_DATA_PATH}/config.v2.json"
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ENV_CONFV2=$(cat ${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ENV_CONFV2_PATH})
    
	change_json_node_arr "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ENV_CONFV2" ".Config.Env" "^${2}=.*$" "\"${2}=${3}\""
    
    echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ENV_CONFV2}" > ${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_ENV_CONFV2_PATH}

    return $?
}

# 修改DOCKER容器挂载信息
# 参数1：容器ID
# 参数2：挂载路径，例 /opt/docker_apps/browserless_chrome/imgver111111
# 参数3：容器路径 /usr/src/app
# 参数4：指定的config.v2.json路径
# 参数5：指定的hostconfig.json路径
# 参数6：指定容器可操作的权限，例 rw,z
# 示例：
#       docker_change_container_inspect_mount "e75f9b427730" "/opt/docker_apps/browserless_chrome/imgver111111" "/usr/src/app"
function docker_change_container_inspect_mount()
{
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_DATA_PATH=$(find ${DOCKER_DATA_DIR} -name ${1}* | grep "/container[s]*/" | awk 'NR==1')
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_PATH="${4:-${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_DATA_PATH}/config.v2.json}"
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2=$(cat ${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_PATH})
	
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_HOSTCONF_PATH="${5:-${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_DATA_PATH}/hostconfig.json}"
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_HOSTCONF=$(cat ${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_HOSTCONF_PATH})

	local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_MODE=${6}
	if [ -z "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_MODE}" ]; then
		local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_ITEM_INDEX=$(echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_HOSTCONF}" | jq ".Binds[]" | xargs -I {} echo {} | grep -n "" | awk -F':' "{if(\$3==\"${3}\"){print \$1}}" | xargs -I {} echo {}-1 | bc)
		if [ -n "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_ITEM_INDEX}" ]; then
			_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_MODE=$(echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_HOSTCONF}" | jq ".Binds[${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_ITEM_INDEX}]" | xargs echo | awk -F':' '{print $3}')
		fi
	fi
    
    # {
    #     "Source": "/etc/localtime",
    #     "Destination": "/etc/localtime",
    #     "RW": true,
    #     "Name": "",
    #     "Driver": "",
    #     "Type": "bind",
    #     "Propagation": "rprivate",
    #     "Spec": {
    #       "Type": "bind",
    #       "Source": "/etc/localtime",
    #       "Target": "/etc/localtime"
    #     },
    #     "SkipMountpointCreation": false
    # }
	# "/tmp/test": {
	# 	  "Source": "/mountdisk/data/docker/volumes/test/_data",
	# 	  "Destination": "/tmp/test",
	# 	  "RW": true,
	# 	  "Name": "test",
	# 	  "Driver": "local",
	# 	  "Type": "volume",
	# 	  "Relabel": "z",
	# 	  "ID": "b086f05646ed02699b5059e60fbf7e2f9a4d56959600e1ff9e1f5d032868640c",
	# 	  "Spec": {
	# 	  	"Type": "volume",
	# 	  	"Source": "test",
	# 	  	"Target": "/tmp/test"
	# 	  },
	# 	  "SkipMountpointCreation": false
    # }
	# 修改 config.v2.json
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST=$(echo ${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2} | jq ".MountPoints.\"${3}\"")
    if [ "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST}" == "null" ]; then
		# BIND
		_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST='{ "RW": true, "Name": "", "Driver": "", "Type": "bind", "Propagation": "rprivate", "Spec": { "Type": "bind" }, "SkipMountpointCreation": false }'
    fi

	# VOL
	if [ -z "$(echo "${2}" | grep -o "^/")" ]; then
		change_json_node_item "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST" ".NAME" "\"${2}\""
		change_json_node_item "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST" ".Source" "\"${DOCKER_DATA_DIR}/volumes/${2}/_data\""
		change_json_node_item "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST" ".Driver" "\"local\""
		change_json_node_item "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST" ".Type" "\"volume\""
		change_json_node_item "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST" ".Spec.Type" "\"volume\""
	else
		change_json_node_item "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST" ".Source" "\"${2}\""
	fi

	# 读写属性
	local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_NEWER_BIND="${2}:${3}"
	if [ -n "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_MODE}" ]; then
		change_json_node_item "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST" ".Relabel" "\"${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_MODE}\""
		_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_NEWER_BIND="${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_NEWER_BIND}:${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_MODE}"
	fi

    change_json_node_item "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST" ".Destination" "\"${3}\""

    change_json_node_item "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST" ".Spec.Source" "\"${2}\""
    change_json_node_item "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST" ".Spec.Target" "\"${3}\""

    # argjson相关参考：https://www.jianshu.com/p/e05a5940f833
    echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2}" | jq --argjson change "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_DEST}" ".MountPoints.\"${3}\" = \$change" > ${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_PATH}

	# 修改 hostconfig.json
	change_json_node_arr "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_HOSTCONF" ".Binds" "^.+:${3}(:\S+)*$" "\"${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_CONFV2_MOUNT_NEWER_BIND}\""

	echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_HOSTCONF}" > ${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNT_HOSTCONF_PATH}
    
    return $?
}

# 修改DOCKER容器挂载卷信息
# 参数1：容器ID
# 参数2：挂载KV对，例 /opt/docker_apps/browserless_chrome/imgver111111:/usr/src/app 
# 参数3：创建迁移后执行函数
# 参数4：是否自动删除无效挂载卷（默认false，可用于新增时的判断）
# 示例：
#       docker_change_container_volume_migrate "e75f9b427730" "/opt/docker_apps/browserless_chrome/imgver111111:/usr/src/app"
function docker_change_container_volume_migrate()
{	
	local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_ID="${1}"
	# imgver111111 docker ps -a -f name=xxx|id=xxx
	local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_IMG="$(docker ps -a --no-trunc | grep "^${1}" | awk -F' ' '{print $2}')"
	
	# ??? 换行可能是个无效操作，故在此注释
	# local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS=$(echo "${2}" | sed 's@ @\n@g' | sort)
	local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_AUTO_REMOVE_UNUSE_VOL=${4:-false}

	# 没挂载卷，直接跳过
	if [ -z "${2}" ]; then
		echo_style_text "'|'Cannot found volumes in 'current container'([${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_ID:0:12}]), migrate stopped"
		return
	fi

	local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS="${2}"	
	trim_str "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS"
	# 自动调整挂载目录层级，只认最顶级。子集修改为软连接(主要避免重复挂载的情况以及在本机修改时，因为多重文件存在导致修改误判)
	## 以coder-server案例为例，配置文件与日志均在workdir目录中，故挂载时可能被重复路径引用。此处保障以下三处路径一致：
	### /opt/docker_apps/codercom_code-server/4.14.1/conf/app/
	### /mountdisk/data/docker_apps/codercom_code-server/4.14.1/.config/
	### /mountdisk/conf/docker_apps/codercom_code-server/4.14.1/app/
	echo_style_text "'|'Starting 'formal keep base dir' in 'current container'([${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_ID:0:12}])"
	echo_style_text "[Before]:"
	echo "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS}" | sed 's@ @\n@g'
	function _docker_change_container_volume_migrate_keep_base()
	{
		# /opt/docker_apps/mattermost_docker/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/work:/mattermost:rw,z
		## /opt/docker_apps/mattermost_docker/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/work
		local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_LCL_DIR=$(echo "${1}" | cut -d':' -f1)
		## /mattermost
        local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_DIR=$(echo "${1}" | cut -d':' -f2)		
		## mattermost
        local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_MID_DIR="${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_DIR}"
		
		# 删除末尾字符
		trim_str "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_MID_DIR" "/"

		function _docker_change_container_volume_migrate_keep_base_convert_link()
		{
			# /mountdisk/data/docker_apps/mattermost_docker/v2.4/compose/mattermost:/mattermost/data:rw
			## /mountdisk/data/docker_apps/mattermost_docker/v2.4/compose/mattermost
			local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_LCL_CDIR=$(echo "${1}" | cut -d':' -f1)
			## /mattermost/data
			local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_CDIR=$(echo "${1}" | cut -d':' -f2)
			## /data
			local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_REL_DIR=${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_CDIR/\/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_MID_DIR}\//}
			
			## 获取文件夹所有者
			## /mountdisk/data/docker_apps/mattermost_docker/v2.4/compose/mattermost/data
			local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_DIR=${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_LCL_DIR}/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_REL_DIR}
			## mattermost:mattermost
			local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHOWNS=$(ls -l $(dirname ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_DIR}) | awk "{if(\$9==\"${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_DIR##*/}\"){print \$3\":\"\$4}}")

			## !!!废弃，父层已判断该逻辑
			## 如果容器内的目录在上层目录之下时
			### 例如：已挂载父级 _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_DIR -> /home/coder/.local/share/code-server
			### 但是子集也被挂载 _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_CDIR -> /home/coder/.local/share/code-server/coder-logs
			# if [ -n "$(echo "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_CDIR}" | awk -v h="${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_DIR}/" '$0 ~ h {print "MATCH"}')" ]; then
			
			## 获取本地的真实链接，再进行swap，谨防被挂载进容器，本地修改不生效的问题
			
			local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_TRUTH_DIR="${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_DIR}"
			bind_symlink_link_path "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_TRUTH_DIR"

			# 1：将根目录作为主链接 !!! 此处只能如此，采用2的话，软链接在容器内会将内容拷贝至容器再操作
			# !Checked container dir(/home/coder/.local/share/code-server/coder-logs) already exists in parent mounted dir(/home/coder/.local/share/code-server), this will swap to /mountdisk/data/docker_apps/codercom_code-server/f947063c3d26/coder-logs as real
			echo_style_text "'!'[Checked] 'container dir'(<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_CDIR}>) 'already exists' [in] 'parent mounted dir'([${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_DIR}]), this will [swap] to '${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_DIR}' as 'real'"
			if [ "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_TRUTH_DIR}" != "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_DIR}" ]; then
				echo_style_text "'?'[Checked] 'local dir'(<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_DIR}>) is 'symlink' [to] 'trueth'([${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_TRUTH_DIR}]), this will 'change' to it as 'real'"
				# 删除原始软链接
				rm -rf ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_DIR}
			fi

			## 完成如下两种链接，因可能为备份的盘，此处做swap处理
			### /mountdisk/conf/docker_apps/codercom_code-server/4.14.1/app -> /mountdisk/data/docker_apps/codercom_code-server/4.14.1/.config
			### /mountdisk/data/docker_apps/mattermost_docker/v2.4/compose/mattermost -> /opt/docker_apps/mattermost_docker/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/work/data
			path_swap_link "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_DIR}" "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_LCL_CDIR}"
		
			## 2：将挂载目录作为主链接
			# echo_style_text "'!'[Checked] 'container dir'(<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_CDIR}>) 'already exists' in 'parent mounted dir'([${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_DIR}]), this will [swap] to '${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_LCL_CDIR}' as 'real'"
			# rm -rf ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_TRUTH_DIR}

			# ## 完成如下两种链接
			# ### /mountdisk/data/docker_apps/codercom_code-server/4.14.1/.config -> /mountdisk/conf/docker_apps/codercom_code-server/4.14.1/app
			# ### /opt/docker_apps/mattermost_docker/v2.4/rely/mattermost_mattermost-enterprise-edition/v7.1/work/data -> /mountdisk/data/docker_apps/mattermost_docker/v2.4/compose/mattermost
			# path_not_exists_link "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_DIR}" "" "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_LCL_CDIR}"

			## 同步授权
			if [ -n "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHOWNS}" ]; then
				chown -R ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHOWNS} ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHECK_DIR}
				chown -R ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CHOWNS} ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_LCL_CDIR}
			fi

			# 重新赋值变量
			_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS="${3}"
		}

		local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_TMP="${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS}"
		item_change_remove_action "^\S+:/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_MID_DIR}/\S+$" "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS" "_docker_change_container_volume_migrate_keep_base_convert_link"
		if [ "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS}" != "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_TMP}" ]; then
			echo_style_text "'!'[After combine](</${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_CTN_MID_DIR}/>)↓:"
			ls -lia ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS_LCL_DIR}
		fi
	}
	
	items_split_action "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS" "_docker_change_container_volume_migrate_keep_base"
	echo_style_text "[Final]:"
	echo "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS}" | sed 's@ @\n@g'
		
	local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME_ARR=()
	function _docker_change_container_volume_migrate_formal()
	{
		# 记录值，因为后期会被修改
		local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL_SOURCE=$(echo "${1}" | awk -F':' '{print $1}')
		local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL=${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL_SOURCE}
		local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_MOUNT=$(echo "${1}" | awk -F':' '{print $2}')

		# 必须满足KV对的形式，循环中可能被rw,z的逗号给隔断
		if [[ -z "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL}" || -z "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_MOUNT}" ]]; then
			return
		fi

		echo_style_text "'|'Starting 'formal volume'(<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL}:${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_MOUNT}>) in 'current container'([${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_ID:0:12}])"
		
		# # 如果是文件的情况，直接转换为目录
		# if [[ -f ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL} ]]; then
		# 	_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL=$(dirname ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL})
		# 	_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_MOUNT=$(dirname ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_MOUNT})
		# fi
		
		# 谨防读取的路径为相对路径，而非绝对路径
		if [[ -f ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL} || -S ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL} ]]; then
			_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL=$(cd $(dirname ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL});pwd)/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL##*/}
			# 暂时忽略文件类型的挂载，因其会变成 _data -> 指向文件
			echo_style_text "'|👉' Checked 'volume'(<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL}>:[${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_MOUNT}]) is file, formal return"
			return
		else
			# 目录存在，或非挂载卷的情况
			if [ -a ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL} ]; then
				# _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL=$(cd ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL};pwd)
				bind_symlink_link_path "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL"
			fi
			
		fi

		# 转换为真实链接
		bind_symlink_link_path "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL"

		local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME="$(echo_docker_volume_name "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL}")"

		# 符合指定命名挂载盘不存在的情况
		if [ -z "$(docker volume ls | awk "NR>1{if(\$2==\"${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}\"){print \$2}}")" ]; then
			# 查找容器中盘存在相同挂载的目录
			local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME=$(docker inspect ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_ID} | jq --arg TYPE 'volume' --arg DEST "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_MOUNT}" '.[0].Mounts[] | select(.Type == $TYPE) | select(.Destination == $DEST) | .Name' | xargs echo)
			if [ -n "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME}" ]; then
				# 此处主要是新装可能产生（提示应该去除，但未去除） 及 备份还原后可能产生卷（已验证）
				item_change_append_bind "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME_ARR" "^${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME}$" "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME}"
				echo_style_text "'|👉' Record 'replace volume'(<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME}>:[${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_MOUNT}])"
			fi
			
			# 已经是挂载卷，但命名未符合规范的情况
			if [ -n "$(docker volume ls | awk "NR>1{if(\$2==\"${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME}\"){print}}")" ]; then
				local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_PATH=$(docker volume inspect ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME} | jq ".[0].Mountpoint" | xargs echo)
				
				# 转换为真实链接
				bind_symlink_link_path "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_PATH"
							
				echo_style_text "'|'Create 'replace volume'(<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}>)"
				docker volume create ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}

				# 卷未指向正确路径
				if [[ ! -a ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL} ]]; then
					echo_style_text "'|' Rsync 'volume'(<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME}>:[${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_PATH}]) → (<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}>)"

					# 重新调整挂载卷路径
					rsync -av ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_PATH}/ ${DOCKER_DATA_DIR}/volumes/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}/_data
				else
					echo_style_text "'|' Change 'volume'(<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME}>) → (<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}>:[${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL}])"
					# 迁移源目录到新目录下
					rm -rf ${DOCKER_DATA_DIR}/volumes/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}/_data

					path_not_exists_link "${DOCKER_DATA_DIR}/volumes/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}/_data" "" "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL}"
				fi
			else
				echo_style_text "'|'Create 'newer volume'(<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}>)"
				docker volume create ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}

				# 迁移源目录到新目录下
				rm -rf ${DOCKER_DATA_DIR}/volumes/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}/_data

				path_not_exists_link "${DOCKER_DATA_DIR}/volumes/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}/_data" "" "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL}"	
			fi
			
			# 修改源字符串为新的替代字符串
			# _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS="${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL_SOURCE}:/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}:}"
		else
			# 多容器依赖的场景，即A，B两个容器挂载到了同一个地址（例如，harbor的registry与registryctl）
			# if [ "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL}" != "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}" ]; then			
				echo_style_text "'|'Transfer 'replace volume'(<${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}> ← [${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL}])"

				# 修改源字符串为新的替代字符串
				# _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS="${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL_SOURCE}:/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}:}"
			# else
			# 	echo_style_text "Volume <${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}>([${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL}]:'${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_MOUNT}') already exists"
			# fi
		fi

		# 修改源字符串为新的替代字符串
		_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS="${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_BIND_LOCAL_SOURCE}:/${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_VOLUME_NAME}:}"
	}
	
	# 过滤，记录。格式化挂载盘信息
	echo "${TMP_SPLITER2}"
	items_split_action "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS" "_docker_change_container_volume_migrate_formal"

	function _docker_change_container_volume_migrate_mount()
	{
		# latest 版本修改会出问题
		docker_change_container_inspect_arg "${1}" ".Config.Image" "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_IMG}"

		# 挂载目录(必须停止服务才能修改，否则会无效)
		docker_change_container_inspect_mounts "${1}" "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_MOUNTS}"
	}

	# 挂载
	docker_change_container_inspect_wrap "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_ID}" "_docker_change_container_volume_migrate_mount"

	# 移除已被替换的挂载卷，或使用如下直接清理
	# docker volume ls --quiet --filter 'dangling=true'
	function _docker_change_container_volume_migrate_remove_local_confirm()
	{
		function _docker_change_container_volume_migrate_remove_local()
		{
			# 还原挂载的路径
			local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_MOUNT_POINT=$(docker volume inspect ${1} | jq ".[0].Mountpoint" | grep -oP "(?<=^\").*(?=\"[,]*$)")

			# 转换为挂载的真实路径
			bind_symlink_link_path "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_MOUNT_POINT"

			if [[ -a ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_MOUNT_POINT} ]]; then
				rm -rf ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_MOUNT_POINT}
			fi

			docker volume rm ${1}
		}
		
		if [ ${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_AUTO_REMOVE_UNUSE_VOL} == true ]; then
			echo_style_text "Starting auto [remove unuse] volume(<${1}>)"
			docker volume rm ${1}
		else
			local _TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME_YN_REMOVE="N"
			confirm_y_action "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME_YN_REMOVE" "'Volume'(<${1}>) already [unuse], please sure u will <remove> 'still or not'" "_docker_change_container_volume_migrate_remove_local" "${@}"
		fi
	}

	if [ -n "${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME_ARR[*]}" ]; then
		echo "${TMP_SPLITER3}"
		echo_style_text "Starting sure which [unuse] volumes will be <remove>, auto remove <${_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_AUTO_REMOVE_UNUSE_VOL}>)"
		items_split_action "_TMP_DOCKER_CHANGE_CONTAINER_VOLUME_MIGRATE_CTN_HIS_VOLUME_NAME_ARR" "_docker_change_container_volume_migrate_remove_local_confirm"
	fi

	return $?
}

# 修改DOCKER容器挂载信息
# 参数1：容器ID
# 参数2：挂载KV对，例 /opt/docker_apps/browserless_chrome/imgver111111:/usr/src/app /opt/docker_apps/browserless_chrome/imgver111111:/usr/src/app:rw,z
# 示例：
#       docker_change_container_inspect_mounts "e75f9b427730" "/opt/docker_apps/browserless_chrome/imgver111111:/usr/src/app"
function docker_change_container_inspect_mounts()
{
	local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_ID="${1}"

    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_DATA_PATH=$(find ${DOCKER_DATA_DIR} -name ${1}* | grep "/container[s]*/" | awk 'NR==1')
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_HOSTCONF_PATH="${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_DATA_PATH}/hostconfig.json"
    local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_HOSTCONF=$(cat ${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_HOSTCONF_PATH})

    # local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MOUNTS=$(docker container inspect ${1} | jq ".[0].HostConfig.Binds" | awk '$1=$1' | grep -v "/etc/localtime:/etc/localtime" | grep -oP "(?<=^\").*(?=\"$)")
	local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MOUNTS=$(echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_HOSTCONF}" | jq ".Binds" | awk '$1=$1' | grep -v "/etc/localtime:/etc/localtime" | grep -v "/var/run/docker.sock:/var/run/docker.sock" | grep -oP "(?<=^\").*(?=\"[,]*$)" | sort)
	local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_NEW_MOUNTS=$(echo "${2}" | sed 's@ @\n@g' | sort)

	if [ "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MOUNTS}" != "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_NEW_MOUNTS}" ]; then
		function formal_dc_browserless_chrome_ctn_bind()
		{
			# 检测倒未绑定对象
			local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_LOCAL=$(echo "${1}" | awk -F':' '{print $1}')
			local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_MOUNT=$(echo "${1}" | awk -F':' '{print $2}')
			local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_MODE=$(echo "${1}" | awk -F':' '{print $3}')
			if [[ -z "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_LOCAL}" || -z "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_MOUNT}" ]]; then
				return
			fi

			# fix 本条不识别 /mattermost /mattermost/config 同时存在的场景
			# local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MATCH_PAIR=$(echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MOUNTS}" | grep -oE "[^:]+:${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_MOUNT}(\S+)*$")
			local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MATCH_PAIR=$(echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MOUNTS}" | awk -F':' "{if(\$2==\"${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_MOUNT}\"){print}}")
			
			if [ -z "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MATCH_PAIR}" ]; then				
				echo_style_text "'Mounting' newer pair → <${1}>"	

				docker_change_container_inspect_mount "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_ID}" "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_LOCAL}" "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_MOUNT}" "" "" "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_MODE}"
			else
				local _TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MATCH_LOCAL=$(echo "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MATCH_PAIR}" | awk -F':' '{print $1}')
				if [ "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_LOCAL}" != "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MATCH_LOCAL}" ]; then
					echo_style_text "'Matched' fit local: <${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_MATCH_LOCAL}> → [${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_LOCAL}]"
					echo_style_text "'Mounting' fit pair → <${1}>"

					docker_change_container_inspect_mount "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_ID}" "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_LOCAL}" "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_MOUNT}" "" "" "${_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_CTN_BIND_MODE}"
				else
					echo_style_text "'Keep' mount pair → <${1}>"	
				fi
			fi
		}

		items_split_action "_TMP_DOCKER_CHANGE_CONTAINER_INSPECT_MOUNTS_NEW_MOUNTS" "formal_dc_browserless_chrome_ctn_bind"
	fi

    return $?
}

# 对compose.yml进行格式化处理
# 参数1：分组名称
# 参数2：指定网络
# 参数3：存放docker-compose.yml文件的目录，为空则取当前目录
function docker_compose_yml_formal_exec()
{
	local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_GROUP_NAME=${1}
	local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_NETWORK=${2}
	local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_DIR=${3:-$(pwd)}
	local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH="${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_DIR}/docker-compose.yml"

	# 执行格式化
	# 参数1：yaml节点
	# 参数2：索引
	# 参数3：key
	function _docker_compose_yml_formal_exec()
	{
		# 调整容器配置
		local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_YML_FMT_NODE=$([[ -a ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_DIR}/.env ]] && echo "$(env_format_echo "$(cat ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_DIR}/.env)" "${1}")" || echo "${1}")

		local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_IMG_FULL_NAME=$(echo "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_YML_FMT_NODE}" | yq ".image")
		local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_IMG_NAME=$(echo "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_IMG_FULL_NAME}" |  cut -d':' -f1)
		local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_IMG_VER=$(echo "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_IMG_FULL_NAME}" | cut -d':' -f2 | awk '$1=$1')

		## 1：调整容器名称
		# 格式化容器名称
		local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_NAME=$(echo "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_YML_FMT_NODE}" | yq ".container_name")
		if [[ -z "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_NAME}" || "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_NAME}" == "null" ]]; then
			_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_NAME="${3}"
		fi

		local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_FMT_NAME="${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_NAME}"
		if [ "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_GROUP_NAME}" == "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_NAME}" ]; then
			_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_FMT_NAME="main"
		fi

		local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_NEW_NAME="${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_GROUP_NAME}_${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_FMT_NAME}_${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_IMG_VER}"
		echo_style_text "Starting 'formal' service <${3}>('${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_IMG_FULL_NAME}') container 'rename' <${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_NAME}> → [${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_NEW_NAME}]"
		yq -i '.services.'${3}'.container_name = "'${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_CTN_NEW_NAME}'"' ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH}

		## 2：调整容器网络 会有两种场景，一种是纯字符串、一种是对象类型。故判断
        ## 支持如下类型：
        # networks:
        #     - cuckoo-network
        #     - harbor
        ## 排除如下类型：
        # networks:
        #     - harbor:
        #         harbor-clair:
        #         aliases:
        #             - harbor-db
		if [ -n "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_NETWORK}" ]; then
			echo "${1}" | yq ".networks + [\"${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_NETWORK}\"]" &>/dev/null
			if [ $? -eq 0 ]; then
				yq -i ".services.${3}.networks = [\"${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_NETWORK}\"] + .services.${3}.networks" ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH}
			fi
		fi

        ## 2：调整容器权限privileged
        yq -i ".services.${3}.privileged = true" ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH}
        
        ## 3：调整容器挂载卷 volumes
        yq -i ".services.${3}.volumes = [\"/etc/localtime:/etc/localtime:ro\"] + .services.${3}.volumes" ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH}
		yq -i ".services.${3}.volumes = [\"$(which jq):/usr/bin/jq:ro\"] + .services.${3}.volumes" ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH}
		yq -i ".services.${3}.volumes = [\"$(which yq):/usr/bin/yq:ro\"] + .services.${3}.volumes" ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH}
		yq -i ".services.${3}.volumes = [\"$(which gum):/usr/bin/gum:ro\"] + .services.${3}.volumes" ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH}
		yq -i ".services.${3}.volumes = [\"$(which pup):/usr/bin/pup:ro\"] + .services.${3}.volumes" ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH}

        ## 4：调整容器环境 env
        if [ -z "$(echo "${1}" | yq ".environment | select(has(\"TZ\"))")" ]; then
			echo "${1}" | yq ".environment.TZ" &>/dev/null
			if [ $? -eq 0 ]; then
				yq -i ".services.${3}.environment = .services.${3}.environment + {\"TZ\": \"Asia/Shanghai\"}" ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH}
			fi
        fi

        ## 5：调整容器端口 expose
        local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_SERVICE_KEY="${3}"
        function _docker_compose_yml_formal_exec_port_loop() {
            local _TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_OPN_PORT=$(echo "${1}" | awk -F':' '{if(NF==3){print $2}else{print $1}}')
			if [ -z "$(echo "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_YML_FMT_NODE}" | yq ".expose[] | select(. == \"${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_OPN_PORT}\")")" ]; then
				echo_style_text "Starting 'formal' service <${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_SERVICE_KEY}>('${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_IMG_FULL_NAME}') container 'expose port' [${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_OPN_PORT}], 'source port' [${1}]"

				yq -i ".services.${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_SERVICE_KEY}.expose = [\"${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_OPN_PORT}\"] + .services.${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_SERVICE_KEY}.expose" ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH}

				# 更新node
				_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_YML_FMT_NODE=$(cat ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH} | yq ".services.${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_SERVICE_KEY}")
			fi
        }

        yaml_split_action "$(echo "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_YML_FMT_NODE}" | yq ".ports")" "_docker_compose_yml_formal_exec_port_loop"
	}
			
	# 从docker-compose.yml中取已安装镜像信息
	if [ -a ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH} ]; then
		if [ -n "${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_NETWORK}" ]; then
			# 调整集成网络配置
			echo_style_text "Starting 'formal' <docker-compose> 'integration network' [${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_NETWORK}]"
			## 指定外部网络cuckoo-network
			yq -i ".networks.${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_NETWORK}.external = true" ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_DIR}/docker-compose.yml
			## 修改默认网络
			yq -i '.networks.default.name = "'${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_NETWORK}'"' ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_DIR}/docker-compose.yml
		fi

		yaml_split_action "$(cat ${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH} | yq '.services')" "_docker_compose_yml_formal_exec"
		echo "${TMP_SPLITER2}"
		return $?
	fi

	echo_style_wrap_text "Cannot found <${_TMP_DOCKER_COMPOSE_YML_FORMAL_EXEC_COMPOSE_YML_PATH}>, please check"
}

# 输出Docker挂载卷名称
# 参数1：挂载本地路径
# 参数2：容器ID
# 示例：
#       echo_docker_volume_name "/opt/docker/data"
#       echo_docker_volume_name "/opt/docker/data" "verctnid"
function echo_docker_volume_name()
{
	local _TMP_ECHO_DOCKER_VOLUME_NAME_VOL_PATH="${1}"
	local _TMP_ECHO_DOCKER_VOLUME_NAME_CTN_ID="${2:-000000000000}"
	
	# 如果是文件夹
	if [ -d ${_TMP_ECHO_DOCKER_VOLUME_NAME_VOL_PATH} ]; then
		_TMP_ECHO_DOCKER_VOLUME_NAME_VOL_PATH=$(cd ${_TMP_ECHO_DOCKER_VOLUME_NAME_VOL_PATH};pwd)
	fi
	echo "${_TMP_ECHO_DOCKER_VOLUME_NAME_CTN_ID:0:12}_$(echo -n "${_TMP_ECHO_DOCKER_VOLUME_NAME_VOL_PATH}" | md5sum | cut -d ' ' -f1)"

	return $?
}

# 输出Docker镜像数字版本
# 参数1：镜像名称，用于检测，例 browserless/chrome
# 参数2：镜像版本，用于检测，例 imgver111111
# 示例：
#       echo_docker_image_digests "browserless/chrome" "imgver111111"
function echo_docker_image_digests()
{
	local _TMP_ECHO_DOCKER_IMAGE_DIGESTS_GREP_DIGESTS=$(docker images --digests | egrep "^${1}")			
	if [ -n "${2}" ]; then
		_TMP_ECHO_DOCKER_IMAGE_DIGESTS_GREP_DIGESTS=$(echo "${_TMP_ECHO_DOCKER_IMAGE_DIGESTS_GREP_DIGESTS}" | awk '{if($2~"'${2}'"){print}}')
	fi

	echo "${_TMP_ECHO_DOCKER_IMAGE_DIGESTS_GREP_DIGESTS}" | egrep "sha256:" | awk -F' ' '{print $3}'

	return $?
}

# 输出Docker镜像已存在版本集合
# 参数1：镜像名称，用于检测，例 browserless/chrome
# 示例：
#       echo_docker_images_exists_vers "browserless/chrome"
function echo_docker_images_exists_vers()
{
	docker images | awk "NR>1{if(\$1~\"${1}\"){if(\$2==\"latest\"||\$2==\"<none>\"){print \$3} else {print \$2}}}" | grep -Pv ".+_v[0-9]{10}(?=SC[0-9]+$)" | sed 's/S[A-Z][0-9|A-Z]*$//' | uniq

	return $?
}

# 输出Docker镜像所有版本集合
# 参数1：镜像名称，用于检测，例 browserless/chrome
# 参数2：忽略版本数组字符串，例 clean snapshot hub
# 示例：
#       echo_docker_image_vers "browserless/chrome"
#       echo_docker_image_vers "browserless/chrome" "hub"
function echo_docker_image_vers()
{
	local _TMP_ECHO_DOCKER_IMAGE_VERS_IMG="${1}"
	local _TMP_ECHO_DOCKER_IMAGE_VERS_IMG_MARK_NAME="${1/\//_}"
	
    # /mountdisk/repo/migrate/snapshot/browserless_chrome/
    local _TMP_ECHO_DOCKER_IMAGE_VERS_SNAP_DIR="${MIGRATE_DIR}/snapshot/${_TMP_ECHO_DOCKER_IMAGE_VERS_IMG_MARK_NAME}"
    # /mountdisk/repo/migrate/clean/browserless_chrome/
    local _TMP_ECHO_DOCKER_IMAGE_VERS_CLEAN_DIR="${MIGRATE_DIR}/clean/${_TMP_ECHO_DOCKER_IMAGE_VERS_IMG_MARK_NAME}"

    local _TMP_ECHO_DOCKER_IMAGE_VERS_SNAP_VERS=""
    local _TMP_ECHO_DOCKER_IMAGE_VERS_CLEAN_VERS=""
	local _TMP_ECHO_DOCKER_IMAGE_VERS_HUB_VERS=""
	
	function _echo_docker_image_vers_fill_snapshot()
	{
		if [[ -a "${_TMP_ECHO_DOCKER_IMAGE_VERS_SNAP_DIR}" ]]; then
			_TMP_ECHO_DOCKER_IMAGE_VERS_SNAP_VERS=$(ls ${_TMP_ECHO_DOCKER_IMAGE_VERS_SNAP_DIR} | cut -d'.' -f1 | uniq)
		fi
	}
	item_not_exists_action "^snapshot$" "${2}" "_echo_docker_image_vers_fill_snapshot"

	function _echo_docker_image_vers_fill_clean()
	{
		if [[ -a "${_TMP_ECHO_DOCKER_IMAGE_VERS_CLEAN_DIR}" ]]; then
			_TMP_ECHO_DOCKER_IMAGE_VERS_CLEAN_VERS=$(ls ${_TMP_ECHO_DOCKER_IMAGE_VERS_CLEAN_DIR} | cut -d'.' -f1 | uniq)
		fi
	}
	item_not_exists_action "^clean$" "${2}" "_echo_docker_image_vers_fill_clean"

	item_not_exists_action "^hub$" "${2}" "_TMP_ECHO_DOCKER_IMAGE_VERS_HUB_VERS=\$(fetch_docker_hub_release_vers '${_TMP_ECHO_DOCKER_IMAGE_VERS_IMG}')"

    # 打标记，已安装的版本做标注
    local _TMP_ECHO_DOCKER_IMAGE_VERS_ARR=()
    function _echo_docker_image_vers_combine()
    {
		item_not_exists_action "^${_TMP_ECHO_DOCKER_IMAGE_VERS_VER_TEMP}$" "${_TMP_ECHO_DOCKER_IMAGE_VERS_ARR[*]}" "_TMP_ECHO_DOCKER_IMAGE_VERS_ARR[${2}]='${1}'"
    }
	
    items_split_action "${_TMP_ECHO_DOCKER_IMAGE_VERS_SNAP_VERS} ${_TMP_ECHO_DOCKER_IMAGE_VERS_CLEAN_VERS} ${_TMP_ECHO_DOCKER_IMAGE_VERS_HUB_VERS}" "_echo_docker_image_vers_combine"

    echo "${_TMP_ECHO_DOCKER_IMAGE_VERS_ARR[*]}" | sed 's@ @\n@g' | uniq

    return $?
}

# 输出Docker镜像所有版本集合(已安装版本会打√)
# 参数1：镜像名称，用于检测，例 browserless/chrome
# 参数2：忽略版本数组字符串，例 clean snapshot hub
# 示例：
#       echo_docker_image_mark_vers "browserless/chrome"
#       echo_docker_image_mark_vers "browserless/chrome" "hub"
function echo_docker_image_mark_vers()
{
	local _TMP_ECHO_DOCKER_IMAGE_MARK_VERS_IMG="${1}"
	local _TMP_ECHO_DOCKER_IMAGE_MARK_VERS_IMG_MARK_NAME="${1/\//_}"
	# local _TMP_ECHO_DOCKER_IMAGE_MARK_VERS_STORE="${3}"
	local _TMP_ECHO_DOCKER_IMAGE_MARK_VERS_IMG_VERS=$(echo_docker_image_vers "${1}" "${2}")
	local _TMP_ECHO_DOCKER_IMAGE_MARK_VERS_IMG_EXISTS_VERS=$(echo_docker_images_exists_vers "${1}")
	
    # 打标记，已安装的版本做标注
    local _TMP_ECHO_DOCKER_IMAGE_MARK_VERS_ARR=()
    function _echo_docker_image_mark_vers_combine()
    {
        local _TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP="${1}"
        local _TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_INDEX="${2}"

        function _echo_docker_image_mark_vers_combine_mark()
        {
			# # 列表版本等于latest版的情况
			# if [ "${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP}" == "latest" ]; then
			# 	# 已安装版本ID，在hub的latest-IMGID中存在时，latest版本标记为已安装
			# 	if [ -n "$(echo "${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_IMG_LAST_VER_IMG_IDS[*]}" | grep "^${1}$")" ]; then
			# 		_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP="${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP}√"
			# 	fi
			# fi

			# 已安装版本与版本列表版本号相同
            if [ "${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP}" == "${1}" ]; then
                _TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP="${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP}√"
				return
            fi

			# 已安装版本是版本列表的子版本，例：imgver111111_v1675941850SRC -> imgver111111_v1675941850
			if [ -n "$(echo "${1}" | grep -oP "^${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP}")" ]; then
                _TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP="${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP}√"
				return
			fi
        }

        items_split_action "${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_IMG_EXISTS_VERS}" "_echo_docker_image_mark_vers_combine_mark"

		item_not_exists_action "^${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP}$" "${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_ARR[*]}" "_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_ARR[${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_INDEX}]='${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_VER_TEMP}'"
    }
	
    items_split_action "${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_IMG_EXISTS_VERS} ${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_IMG_VERS}" "_echo_docker_image_mark_vers_combine"

    echo "${_TMP_ECHO_DOCKER_IMAGE_MARK_VERS_ARR[*]}" | sed 's@ @\n@g' | uniq

    return $?
}

# 输出Docker镜像存储方式
# 参数1：镜像名称，用于检测，例 browserless/chrome
# 参数2：镜像版本
# 示例：
#       echo_docker_images_store "browserless/chrome"
#       echo_docker_images_store "browserless/chrome" "hub"
function echo_docker_images_store()
{
	if [ -n "$(echo_docker_image_vers "${1}" "snapshot hub" | egrep "^${2}$")" ]; then
		echo "clean"
		return $?
	fi
	
	if [ -n "$(echo_docker_image_vers "${1}" "clean hub" | egrep "^${2}$")" ]; then
		echo "snapshot"
		return $?
	fi
	
	if [ -n "$(echo_docker_image_vers "${1}" "clean snapshot" | egrep "^${2}$")" ]; then
		echo "hub"
		return $?
	fi

	echo "unknow"
	return $?
}

# 输出Docker镜像名称
# 参数1：原镜像名称，用于检测，例 browserless/chrome
# 示例：
#       echo_docker_image_formal_name "browserless/chrome"
#       echo_docker_image_formal_name "mysql"
#       echo_docker_image_formal_name "library/mysql"
function echo_docker_image_formal_name()
{
	# 取左边
	# local _TMP_ECHO_DOCKER_IMG_FORMAL_NAME_REPO="${1%/*}"
	if [ "${1//\//}" == "${1}" ]; then
		echo "library/${1}"
		return $?
	fi

	echo "${1}"
	return $?
}

# 输出Docker镜像查询结果
# 参数1：镜像名称，用于检测，例 browserless/chrome
# 示例：
#       echo_docker_image_grep "browserless/chrome"
#       echo_docker_image_grep "mysql"
#       echo_docker_image_grep "library/mysql"
function echo_docker_image_grep()
{
	# 取左边
	local _TMP_ECHO_DOCKER_IMG_GREP_REPO="${1%/*}"
	if [[ "${_TMP_ECHO_DOCKER_IMG_GREP_REPO}" == "library" || "${_TMP_ECHO_DOCKER_IMG_GREP_REPO}" == "${1}" ]]; then
		# 取右边
		docker images | awk "NR>1{if(\$1~\"${1#*/}\"){print}}"
	else
		docker images | awk "NR>1{if(\$1~\"${1}\"){print}}"
	fi

	return $?
}

# 输出Docker容器查询结果
# 参数1：镜像名称，用于检测，例 browserless/chrome
# 示例：
#       echo_docker_container_grep "browserless/chrome"
#       echo_docker_container_grep "mysql"
#       echo_docker_container_grep "library/mysql"
function echo_docker_container_grep()
{
	# 取左边
	local _TMP_ECHO_DOCKER_CTN_GREP_REPO="${1%/*}"
	if [[ "${_TMP_ECHO_DOCKER_CTN_GREP_REPO}" == "library" || "${_TMP_ECHO_DOCKER_CTN_GREP_REPO}" == "${1}" ]]; then
		# 取右边
		docker ps -a --no-trunc | awk "NR>1{if(\$2~\"${1#*/}\"){print}}"
	else
		docker ps -a --no-trunc | awk "NR>1{if(\$2~\"${1}\"){print}}"
	fi

	return $?
}

# Docker镜像选中版本再执行
# 参数1：镜像名称，用于检测，例 browserless/chrome
# 参数2：选择所弹出的提示文本
# 参数3：选择版本后执行脚本
#       参数1：是否已安装，不为空则表示已安装
#       参数2：安装版本
#       参数3：版本存储类型，例 clean snapshot hub
# 参数4：指定的版本数组字符串
# 示例：
#       docker_choice_cust_vers_action "browserless/chrome" "choice echo text" "func_a" "a b c"
function docker_choice_cust_vers_action()
{
	local _TMP_DOCKER_CHOICE_CUST_VERS_ACTION_IMG="${1}"
	local _TMP_DOCKER_CHOICE_CUST_VERS_ACTION_IMG_MARK_NAME="${1/\//_}"
	local _TMP_DOCKER_CHOICE_CUST_VERS_ACTION_SCRIPTS=${3}
	local _TMP_DOCKER_CHOICE_CUST_VERS_ACTION_VERS="${4}"

	echo_style_text "Checking 'image'(<${_TMP_DOCKER_CHOICE_CUST_VERS_ACTION_IMG}>) 'versions', wait for a moment"

	function _docker_choice_cust_vers_action()
	{
		local _TMP_DOCKER_CHOICE_CUST_VERS_ACTION_STORE_TYPE="hub"
		if [[ -a ${MIGRATE_DIR} ]]; then
			_TMP_DOCKER_CHOICE_CUST_VERS_ACTION_STORE_TYPE=$(find ${MIGRATE_DIR} -name ${1}.* | grep "${_TMP_DOCKER_CHOICE_CUST_VERS_ACTION_IMG_MARK_NAME}" | cut -d'.' -f1 | uniq | grep -oP "(?<=^${MIGRATE_DIR}/)\w+(?=/${_TMP_DOCKER_CHOICE_CUST_VERS_ACTION_IMG_MARK_NAME}/${1}$)")
		fi
		
		script_check_action "_TMP_DOCKER_CHOICE_CUST_VERS_ACTION_SCRIPTS" "${2}" "${1}" "${_TMP_DOCKER_CHOICE_CUST_VERS_ACTION_STORE_TYPE:-hub}"
	}

	mark_if_choice_action  "${_TMP_DOCKER_CHOICE_CUST_VERS_ACTION_VERS}" "${2}" "_docker_choice_cust_vers_action"
    return $?
}

# Docker镜像选中版本再执行
# 参数1：镜像名称，用于检测，例 browserless/chrome
# 参数2：选择所弹出的提示文本
# 参数3：选择版本后执行脚本
#       参数1：是否已安装，不为空则表示已安装
#       参数2：安装版本
#       参数3：版本存储类型，例 clean snapshot hub
# 参数4：忽略版本数组字符串，例 clean snapshot hub
# 示例：
#       docker_images_choice_vers_action "browserless/chrome" "choice echo text" "func_a"
#       docker_images_choice_vers_action "browserless/chrome" "choice echo text" "func_a" "hub"
function docker_images_choice_vers_action()
{
	docker_choice_cust_vers_action "${1}" "${2}" "${3}" "$(echo_docker_image_mark_vers "${1}" "${4}")"
    return $?
}

# 参数覆盖, 镜像参数覆盖启动设定
# 参数1：向上覆盖的参数变量名/值
# 参数2：初始化参数变量名/值
# 示例：
#       local _COVER_ARR=()
#       _COVER_ARR[0]="--name=gallant_mirzakhani"
#       _COVER_ARR[1]="--hostname=bad2c8f30402"
#       _COVER_ARR[2]="--user=blessuser"
#       _COVER_ARR[3]="--env=PREBOOT_CHROME=true"
#       _COVER_ARR[4]="--env=CONNECTION_TIMEOUT=3000"
#       _COVER_ARR[5]="--env=MAX_CONCURRENT_SESSIONS=10"
#       _COVER_ARR[6]="--env=WORKSPACE_DELETE_EXPIRED=true"
#       _COVER_ARR[7]="--env=WORKSPACE_EXPIRE_DAYS=7"
#       _COVER_ARR[8]="--volume=/etc/localtime:/etc/localtime:ro"
#       _COVER_ARR[9]="--workdir=/usr/src/app"
#       _COVER_ARR[10]="--restart=always"
#       _COVER_ARR[11]="--runtime=runc"
#       _COVER_ARR[12]="--detach=true"
#       
#       local _OUTPUT_ARR=()
#       _OUTPUT_ARR[0]="-p 13000:3000"
#       _OUTPUT_ARR[1]="--network=cuckoo-network"
#       _OUTPUT_ARR[2]="--user=root"
#       _OUTPUT_ARR[3]="--env=CONNECTION_TIMEOUT=-1"
#       _OUTPUT_ARR[4]="--volume=bad2c8f30402_3d93737dc2d5aa6bf14bde0af5b11979:/usr/src/app"
#       _OUTPUT_ARR[5]="--volume=bad2c8f30402_cc27bf97eaf53f381e930e39623a61d7:/usr/src/app/workspace"
#       docker_image_args_combine_bind "_OUTPUT_ARR" "_COVER_ARR" && echo "${_OUTPUT_ARR[*]}"
#       docker_image_args_combine_bind "_OUTPUT_ARR" "${_COVER_ARR[*]}" && echo "${_OUTPUT_ARR[*]}"
function docker_image_args_combine_bind()
{
	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_ARR=()
	bind_discern_exchange_var_arr "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_ARR" "${1}"
	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_NAME=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_ARR[0]}
	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_TYPE=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_ARR[1]}
	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_VAL=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_ARR[2]}

	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VAR_PAIR=()
	bind_discern_exchange_var_pair "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VAR_PAIR" "${2}"
	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VAR_NAME=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VAR_PAIR[0]}
	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VAR_VAL=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VAR_PAIR[1]}
	
	# 卸载无用的变量
	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_PORT_PAIR=$(echo "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_VAL}" | grep -oP "(?<=-p )[0-9|:]+(?=\s*)")
	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_VAL//-p ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_PORT_PAIR}/}
	# item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL" "^--name=\w+$"
	item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL" "^--hostname=\w+$"
	item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL" "^--mac-address=\w+$"
	# 记录特定变量
	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_ENV_VAL=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL}
	item_change_select_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_ENV_VAL" "^--env=.+$"
	# item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_ENV_VAL" "^--env=.*PASSWORD.+$"
	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VOLUME_VAL=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL}
	item_change_select_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VOLUME_VAL" "^--volume=.+$"
	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_LBL_VAL=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL}
	item_change_select_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_LBL_VAL" "^--label=.+$"
	# 清理无关联变量
	item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL" "^--env=.+$"
	item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL" "^--volume=.+$"
	item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL" "^--label=.+$"

	# 不为空则操作
	if [ -n "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VAR_VAL}" ]; then
		# 卸载无用的变量
		local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_PORT_PAIR=$(echo "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VAR_VAL}" | grep -oP "(?<=-p )[0-9|:]+(?=\s*)")
		local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VAR_VAL//-p ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_PORT_PAIR}/}
		# item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL" "^--name=\w+$"
		item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL" "^--hostname=\w+$"
		item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL" "^--mac-address=\w+$"
		item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL" "^--runtime=runc\w+$"
		item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL" "^--detach=\w+$"
		
		# 记录特定变量
		local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_ENV_VAL=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL}
		item_change_select_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_ENV_VAL" "^--env=.+$"
		local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VOLUME_VAL=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL}
		item_change_select_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VOLUME_VAL" "^--volume=.+$"
		local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_LBL_VAL=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL}
		item_change_select_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_LBL_VAL" "^--label=.+$"

		# 清理无关联变量
		item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL" "^--env=.+$"
		item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL" "^--volume=.+$"
		item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL" "^--label=.+$"
		
		# 覆盖环境变量
		function _docker_image_args_combine_bind_split()
		{
			local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_KEY=$(echo "${1}" | grep -oP "(?<=^--)[^\=]+(?=\=)")
			item_change_cover_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL" "^--${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_KEY}=.+$" "${1}"
		}
		items_split_action "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_CLEAN_VAL" "_docker_image_args_combine_bind_split"

		# 覆盖环境变量
		function _docker_image_args_combine_bind_pair_split()
		{
			local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_KEY=$(echo "${1}" | grep -oP "(?<=^--)[^\=]+(?=\=)")
			typeset -u _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_UPPER_KEY
			local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_UPPER_KEY="${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_KEY}"
			local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL=$(echo "${1}" | grep -oP "(?<=^--${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_KEY}\=).+")
			local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_SPLIT_CHAR=""	
			local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_WRAP_CHAR=""

			case "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_KEY}" in
			'env' | 'label')
				_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_SPLIT_CHAR="="
			;;
			'volume')
				_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_SPLIT_CHAR=":"
			;;
			*)
				continue
			esac

			local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY=$(echo "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL}" | awk -F"${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_SPLIT_CHAR}" '{print $1}')
			local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_VAL=$(echo "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL}" | awk -F"${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_SPLIT_CHAR}" '{print $2}')
			local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_REPLACE_KEY="${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY}"
			# 挂载盘替换为挂载卷参数(当挂载卷本地不存在时，DOCKER机制上默认会从容器中copy)
			local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY_PREFIX="$(echo "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY}" | awk -F'/' '{print $2}')"
			if [ "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_KEY}" == "volume" ]; then
				# 满足脚本设定的路径规格时
				if [ "/${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY_PREFIX}" == "${MOUNT_DIR}" ] || [ "/${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY_PREFIX}" == "${SETUP_DIR}" ]; then
					# 判断是否存在还原
					function _docker_image_args_combine_bind_echo_dir()
					{
						if [[ ! -a ${BACKUP_DIR}${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY} ]]; then
							echo_style_text "Cannot found exits 'backuped dir'(<${1}>), process will sync it from <container> 'default'"
						else
							echo_style_text "Cancel [restore] 'backuped dir'(<${1}>), process will sync it from <container> 'default'"
						fi
					}
					soft_path_restore_confirm_custom "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY}" "_docker_image_args_combine_bind_echo_dir"

					# 重新命名为挂载卷
					_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_REPLACE_KEY="$(echo_docker_volume_name "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY}")"
					if [ -z "$(docker volume ls | grep "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_REPLACE_KEY}")" ]; then
						if [[ -a ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY} ]]; then
							docker volume create ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_REPLACE_KEY}
							# 迁移源目录到新目录下
							rm -rf ${DOCKER_DATA_DIR}/volumes/${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_REPLACE_KEY}/_data			
							path_not_exists_link "${DOCKER_DATA_DIR}/volumes/${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_REPLACE_KEY}/_data" "" "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY}"	
						fi
					fi
				fi
			fi
						
			item_change_cover_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_UPPER_KEY}_VAL" "^--${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_KEY}=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_KEY}${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_SPLIT_CHAR}.+" "--${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_KEY}=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_REPLACE_KEY}${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_SPLIT_CHAR}${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_ARG_VAL_VAL}"
		}
		
		_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_PORT_PAIR=${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_PORT_PAIR:-${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_PORT_PAIR}}
		items_split_action "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_ENV_VAL" "_docker_image_args_combine_bind_pair_split"
		items_split_action "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_VOLUME_VAL" "_docker_image_args_combine_bind_pair_split"
		items_split_action "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_LBL_VAL" "_docker_image_args_combine_bind_pair_split"
	fi

	# 网络参数不存在的情况直接删除
    local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_IMG_NETWORK=$(echo "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL}" | grep -oP "(?<=--network\=)\S+(?=\s*)")
	if [ -n "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_IMG_NETWORK}" ]; then
		if [ -z "$(docker network inspect ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_IMG_NETWORK} 2>/dev/null)" ]; then
			item_change_remove_bind "_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL" "^--network=.+$"
		fi
	fi

	local _TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_FINAL_VAL="-p ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_PORT_PAIR} ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_CLEAN_VAL} ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_ENV_VAL} ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VOLUME_VAL} ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_COVER_LBL_VAL}"
	if [ "${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_TYPE}" == "array" ]; then
		eval ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_NAME}='(${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_FINAL_VAL})'
	else
		eval ${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_NAME}='${_TMP_DOCKER_IMAGE_ARGS_COMBINE_BIND_OUTPUT_VAR_FINAL_VAL}'
	fi
	
	return $?
}

# 传入卷信息，分多卷与单点
# 参数1：当前节点信息
# 参数2：节点内容相对地址 例 common/config
# 参数3：需要挂载到的路径 例 /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0
# 参数4：要写入的节点路径 例 .services.core.volumes[0]/.services.core.volumes.[]
function docker_compose_formal_print_node_volumes()
{
	if [ "${1}" != "null" ]; then
		# 匹配节点模型
		local _TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_NODE_MODE=$([[ $(echo "${1}" | yq ".source") ]] && echo "node" || echo "item")
		local _TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_SOURCE=
		if [ "${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_NODE_MODE}" == "item" ]; then
			# 匹配KV模型
			_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_SOURCE=$(echo "${1}" | cut -d':' -f1)
		else
			_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_SOURCE=$(echo "${1}" | yq ".source")
		fi

		# 在当前compose目录的情况
		## 相对路径
		### 适配 ./common/config/core/app.conf 或 common/config/core/app.conf
		if [ "$(echo "${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_SOURCE}" | egrep -o '^[.|a-zA-Z]')" ]; then
			# 相对路径 /core/app.conf
			local _TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_REL_SOURCE="${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_SOURCE##*${2}}"
			# core
			# local _TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_REL_KEY=$(echo "${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_REL_SOURCE}" | cut -d'/' -f2)
			# /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/core
			# local _TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_LNK_CONF_NODE_SOURCE=${3}/${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_REL_KEY}
			# /opt/docker_apps/goharbor_harbor/v1.10.0/compose/common/config/core
			# local _TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_CPS_CONF_NODE_SOURCE=$(pwd)/${2}/${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_REL_KEY}
			# /mountdisk/conf/docker_apps/goharbor_harbor/v1.10.0/core/app.conf
			local _TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_LNK_CONF_CHANGE_SOURCE=${3}${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_REL_SOURCE}
			
			# if [[ ! -a ${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_LNK_CONF_NODE_SOURCE} && -a ${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_CPS_CONF_NODE_SOURCE} ]]; then
			# 	# 复制配置（只能复制，不能迁移，否则会无法识别软连接从而无法编译）
			# 	soft_path_restore_confirm_copy "${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_LNK_CONF_NODE_SOURCE}" "${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_CPS_CONF_NODE_SOURCE}"

			# 	echo "[-]"
			# 	ls -lia ${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_LNK_CONF_NODE_SOURCE}
			# 	echo "[-]"
			# 	ls -lia ${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_CPS_CONF_NODE_SOURCE}
			# fi

			# 修改compose.yml中对应的数据为最新节点
			if [ "${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_NODE_MODE}" == "item" ]; then
				local _TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_CURRENT_NODE=$(echo "${4}" | awk -F'.' '{print $NF}' | egrep -o "\w+" | awk 'NR==1')
				if [ "${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_CURRENT_NODE}" == "volumes" ]; then
					local _TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_FULL_TARGET=$(echo "${1}" | awk -F':' '{print $2":"$3}')
					yq -i ${4}' = "'${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_LNK_CONF_CHANGE_SOURCE}:${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_FULL_TARGET}'"' docker-compose.yml
				else
					yq -i ${4}' = "'${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_LNK_CONF_CHANGE_SOURCE}'"' docker-compose.yml
				fi
			else
				yq -i ${4}'.source = "'${_TMP_DOCKER_COMPOSE_FORMAL_PRINT_NODE_LNK_CONF_CHANGE_SOURCE}'"' docker-compose.yml
			fi
		fi
	fi
	
	return $?
}

# 登录仓库
# 参数1：仓库地址
# 参数2：仓库账号，为空则先找寻配置文件，找不到则提示输入
# 参数3：仓库密码，为空则先找寻配置文件，找不到则提示输入
# 参数4：登录成功后执行函数
#       参数1：仓库地址
#       参数2：仓库账号
#       参数3：仓库密码
# 示例：
#       function func_print()
# 		{
# 			echo "${1}"
# 			echo "${2}"
# 			echo "${3}"
# 			echo
# 		}
#      docker_login_insecure_registries_action "http://127.0.0.1:10080" "" "" "func_print"
#      docker_login_insecure_registries_action "http://127.0.0.1:10080" "admin" "" "func_print"
#      docker_login_insecure_registries_action "http://127.0.0.1:10080" "admin" "Aa123321" "func_print"
function docker_login_insecure_registries_action()
{
	local _TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL=$(echo_discern_exchange_var_val "${1}")

	if [ -z "${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}" ]; then
		_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL="$(cat /etc/docker/daemon.json | jq '."insecure-registries"[]' | awk "NR==1" | xargs echo)"
	fi
	local _TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_USER=$(echo_discern_exchange_var_val "${2}")
	local _TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_PASSWD=$(echo_discern_exchange_var_val "${3}")

	bind_empty_if_input "_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL" "Please sure your 'insecure registry url' from [${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}]" "" "admin"

	if [ -n "${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}" ]; then
		local _TMP_DOCKER_LOGIN_INSECURE_REGISTRY_ACCOUNT_PATH=$(su - docker -c "pwd")/.harbor
		if [ -f ${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_ACCOUNT_PATH} ]; then
			local _TMP_DOCKER_LOGIN_INSECURE_REGISTRY_ACCOUNT_PAIR=$(cat ${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_ACCOUNT_PATH} | grep -oP "(?<=^${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}@).+" | awk 'NR==1')
			if [ -n "${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_ACCOUNT_PAIR}" ]; then
				_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_USER="${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_USER:-$(echo "${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_ACCOUNT_PAIR}" | cut -d'@' -f1)}"
				# 重新找寻账号，重新检索（同地址可能存在不同的账密）
				_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_PASSWD="${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_PASSWD:-$(cat ${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_ACCOUNT_PATH} | grep -oP "(?<=^${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}@${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_USER}@).+" | awk 'NR==1')}"
			fi	
		fi

		bind_empty_if_input "_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_USER" "Please sure your 'insecure registry user' from [${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}]" "" "admin"
		bind_empty_if_input "_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_PASSWD" "Please sure your 'insecure registry password' from <${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_USER}>@[${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}]" "Y" "_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_PASSWD"

		# 登录
		docker login ${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL} -u ${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_USER} -p ${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_PASSWD} >& /dev/null
		if [ $? -ne 0 ]; then
			echo_style_text "'Input' <insecure registry>(${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}@${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_USER}@${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_PASSWD}) auth error"
			return	
		fi

		# 始终保存配置
		file_content_not_exists_echo "^${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}@${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_USER}@" "${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_ACCOUNT_PATH}" "${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}@${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_USER}@${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_PASSWD}"

		# 添加配置
		docker_change_insecure_registries "${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}"

		# 成功后执行
		script_check_action "${4}" "${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_URL}" "${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_USER}" "${_TMP_DOCKER_LOGIN_INSECURE_REGISTRY_HB_PASSWD}"
		return $?
	fi

	return $?
}

# 提交 Docker容器为 备份镜像至仓库
# 参数1：容器ID，例 e75f9b427730
# 参数2：快照存储的时间戳，例 1670329246
# 参数3：仓库地址，例 http://127.0.0.1:10080
# 参数4：仓库账号，有则写，例 admin
# 参数5：仓库密码，有则写，例 Harbor123
# 示例：
#       docker_snap_commit "fe04328164ee" "1681290197" "" "admin" "Aa123123"
function docker_snap_commit()
{
	local _TMP_DOCKER_SNAP_COMMIT_TIMESTAMP=$(echo_discern_exchange_var_val "${2}")
	local _TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY=$(echo_discern_exchange_var_val "${3}")
	local _TMP_DOCKER_SNAP_COMMIT_HB_USER=$(echo_discern_exchange_var_val "${4}")
	local _TMP_DOCKER_SNAP_COMMIT_HB_PASSWD=$(echo_discern_exchange_var_val "${5}")

	# 参数1：镜像ID，例 imgid111111
	# 参数2：容器ID，例 ctnid111111
	# 参数3：镜像名称，例 browserless/chrome
	# 参数4：镜像版本，例 imgver111111_v1670329246
	# 参数5：启动命令，例 /bin/sh
	# 参数6：启动参数，例 --volume /etc/localtime:/etc/localtime
	function _docker_snap_commit()
	{
		# browserless/chrome
		local _TMP_DOCKER_SNAP_COMMIT_IMG_NAME="${3}"
		# imgver111111_v1670329246
		local _TMP_DOCKER_SNAP_COMMIT_IMG_VER="${4}"
		# 统计镜像数，根据不同情况下的提交，做不同的镜像标记
		## 根据提交的情况下则做标记：SCx(snap commit 第x次)，有容器必定存在镜像
		## 还原标记则为SR(Snap restore c/i/d)			
		local _TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_COUNT=$(docker images | awk "NR>1{if(\$1~\"${3}\"){print \$2}}" | grep -oP "(?<=^${4}_v[0-9]{10})SC(?=[0-9]+$)" | wc -l)
		# imgver111111_v1675749340
		local _TMP_DOCKER_SNAP_COMMIT_SNAP_VER="${4}_v${_TMP_DOCKER_SNAP_COMMIT_TIMESTAMP}"
		# imgver111111_v1675749340SC0
		local _TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_VER="${_TMP_DOCKER_SNAP_COMMIT_SNAP_VER}SC${_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_COUNT}"
		# browserless/chrome:imgver111111_v1675749340SC0
		local _TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_NAME="${3}:${_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_VER}"
		
		# 提交状态
		local _TMP_DOCKER_SNAP_COMMIT_STATUS=""
		# 判断是否有配置私有镜像库
		_TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY=${_TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY:-$(cat /etc/docker/daemon.json | jq '."insecure-registries"[]' | awk "NR==1" | xargs echo)}
		if [ -n "${_TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY}" ]; then
			local _TMP_DOCKER_SNAP_COMMIT_IMG_PRJ="${3%/*}"

			# habor的项目不进行仓库备份
			if [ "${_TMP_DOCKER_SNAP_COMMIT_IMG_PRJ}" != "goharbor" ]; then
				local _TMP_DOCKER_SNAP_COMMIT_IMG_PRJ_EXISTS=$(curl -s -H "Content-Type: application/json" "${_TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY}/api/projects" | jq --arg NAME "${_TMP_DOCKER_SNAP_COMMIT_IMG_PRJ}" '.[] | select(.name == $NAME)')

				function _docker_snap_login()
				{
					_TMP_DOCKER_SNAP_COMMIT_HB_USER=$(echo_url_encode "${2}")
					_TMP_DOCKER_SNAP_COMMIT_HB_PASSWD=$(echo_url_encode "${3}")
				}

				docker_login_insecure_registries_action "_TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY" "${_TMP_DOCKER_SNAP_COMMIT_HB_USER}" "${_TMP_DOCKER_SNAP_COMMIT_HB_PASSWD}" "_docker_snap_login"
				
				# 判断仓库是否存在，不存在则创建
				if [ -z "${_TMP_DOCKER_SNAP_COMMIT_IMG_PRJ_EXISTS}" ]; then
					echo_style_text "Cannot found project on [${_TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY}]/<${_TMP_DOCKER_SNAP_COMMIT_IMG_PRJ}>, start create it & user(<${_TMP_DOCKER_SNAP_COMMIT_HB_USER}>)"

					curl -u "${_TMP_DOCKER_SNAP_COMMIT_HB_USER}:${_TMP_DOCKER_SNAP_COMMIT_HB_PASSWD}" -X POST -H "Content-Type: application/json" "${_TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY}/api/projects" -d'{"project_name": "'${_TMP_DOCKER_SNAP_COMMIT_IMG_PRJ}'","metadata": {"public": "true"}}'
					_TMP_DOCKER_SNAP_COMMIT_STATUS="$?"
					echo_style_text "Project [${_TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY}]/<${_TMP_DOCKER_SNAP_COMMIT_IMG_PRJ}> created(${_TMP_DOCKER_SNAP_COMMIT_STATUS})"
				fi
				
				# 重新计算提交信息
				echo_style_text "[View] the 'container snap tags' <${3}>([${4}])↓:"
				local _TMP_DOCKER_SNAP_COMMIT_SNAP_TAGS=$(curl -s -H "Content-Type: application/json" "${_TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY}/api/repositories/${_TMP_DOCKER_SNAP_COMMIT_IMG_NAME}/tags")
				echo "${_TMP_DOCKER_SNAP_COMMIT_SNAP_TAGS}"
				_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_COUNT=$(echo "${_TMP_DOCKER_SNAP_COMMIT_SNAP_TAGS}" | jq ".[].name" | grep -oP "(?<=^\"${_TMP_DOCKER_SNAP_COMMIT_IMG_VER}_v[0-9]{10})SC${LOCAL_ID}(?=[0-9]+\"$)" | wc -l)
				_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_VER="${_TMP_DOCKER_SNAP_COMMIT_SNAP_VER}SC${LOCAL_ID}${_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_COUNT}"
				_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_NAME="${_TMP_DOCKER_SNAP_COMMIT_IMG_NAME}:${_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_VER}"
				
				local _TMP_DOCKER_SNAP_COMMIT_PRJ_TAG="${_TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY#*//}/${_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_NAME}"
				echo_style_text "Starting push image(<${3}>:[${4}]) to project([${_TMP_DOCKER_SNAP_COMMIT_INSECURE_REGISTRY}]/<${_TMP_DOCKER_SNAP_COMMIT_IMG_PRJ}>), taged '${_TMP_DOCKER_SNAP_COMMIT_PRJ_TAG}'"
				docker tag ${3}:${4} ${_TMP_DOCKER_SNAP_COMMIT_PRJ_TAG}
				docker push ${_TMP_DOCKER_SNAP_COMMIT_PRJ_TAG}
				docker rmi ${_TMP_DOCKER_SNAP_COMMIT_PRJ_TAG}
			fi
		fi

		# 为空说明可能未提交成功，则进行再次备份
		if [ -z "${_TMP_DOCKER_SNAP_COMMIT_STATUS}" ]; then
			echo_style_text "[View] the 'container commit' <${3}>([${4}] → [${_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_VER}])↓:"
			docker commit -a "unity-special_backup ${3}:${4}" -m "backup version ${4} to ${_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_VER}" ${2} ${_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_NAME}

			echo "${TMP_SPLITER2}"
			echo_style_text "Commit History <${_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_NAME}>↓:"
			docker history ${_TMP_DOCKER_SNAP_COMMIT_SNAP_COMMIT_NAME}
		fi
	}

	docker_container_param_check_action "${1}" "_docker_snap_commit"
	return $?
}



# 创建 docker 快照
# 参数1：容器ID或名称，例 e75f9b427730
# 参数2：快照存放路径，例 /mountdisk/repo/migrate/snapshot
# 参数3：快照存储的时间戳，例 1670329246
# 参数4：创建完执行
#       参数1：容器ID，完整的
#       参数2：镜像名称
#       参数3：保存路径
#       参数4：快照版本
# 示例：
#    docker_snap_create_action 'e75f9b427730' '/mountdisk/repo/migrate/snapshot' '1670329246'
function docker_snap_create_action()
{
	# 完整的PSID
	local _TMP_DOCKER_SNAP_CREATE_SNAP_DIR=${2}
	local _TMP_DOCKER_SNAP_CREATE_TIMESTAMP=${3}
	local _TMP_DOCKER_SNAP_CREATE_SCRIPT=${4}

	function _docker_snap_create_action()
	{
		# 完整的PSID
		local _TMP_DOCKER_SNAP_CREATE_CTN_ID=${2}
		# 完整的容器inspect
		local _TMP_DOCKER_SNAP_CREATE_CTN_INSPECT=$(docker container inspect ${_TMP_DOCKER_SNAP_CREATE_CTN_ID})
		# 完整的IMGID
		# local _TMP_DOCKER_SNAP_CREATE_IMG_ID=$(echo "${_TMP_DOCKER_SNAP_CREATE_CTN_INSPECT}" | jq '.[0].Image' | grep -oP "(?<=^\").*(?=\"$)" | cut -d':' -f2)
		local _TMP_DOCKER_SNAP_CREATE_IMG_ID=${1}
		# 完整的镜像inspect
		local _TMP_DOCKER_SNAP_CREATE_IMG_INSPECT=$(docker inspect ${_TMP_DOCKER_SNAP_CREATE_IMG_ID})

		# browserless/chrome:imgver111111
		# local _TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME=$(docker container inspect ${_TMP_DOCKER_SNAP_CREATE_CTN_ID} -f {{".Config.Image"}})
		# local _TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME=$(echo "${_TMP_DOCKER_SNAP_CREATE_CTN_INSPECT}" | jq '.[0].Config.Image' | grep -oP "(?<=^\").*(?=\"$)")
		# local _TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME=$(echo "${_TMP_DOCKER_SNAP_CREATE_IMG_INSPECT}" | jq ".[0].RepoTags" | grep -oP "(?<=^  \").*(?=\",*$)")
		local _TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME="${3}:${4}"
		# browserless/chrome
		# local _TMP_DOCKER_SNAP_CREATE_IMG_NAME=$(echo "${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}" | cut -d':' -f1)
		local _TMP_DOCKER_SNAP_CREATE_IMG_NAME=${3}
		# browserless_chrome
		local _TMP_DOCKER_SNAP_CREATE_IMG_MARK_NAME=${_TMP_DOCKER_SNAP_CREATE_IMG_NAME/\//_}
		# imgver111111，匹配IMG_FULL_NAME=browserless/chrome:imgver111111的情况
		# local _TMP_DOCKER_SNAP_CREATE_IMG_SOURCE_VER=$(echo "${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}" | cut -d':' -f2)
		local _TMP_DOCKER_SNAP_CREATE_IMG_SOURCE_VER=${4}
		# imgver111111，匹配IMG_FULL_NAME=imgver111111_v1677823121SRC的情况
		local _TMP_DOCKER_SNAP_CREATE_IMG_SNAP_VER=$(echo "${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}" | grep -oP "(?<=^${_TMP_DOCKER_SNAP_CREATE_IMG_NAME}:).+(?=_v[0-9]{10}S\w+$)")
		# imgver111111
		local _TMP_DOCKER_SNAP_CREATE_IMG_VER="${_TMP_DOCKER_SNAP_CREATE_IMG_SNAP_VER:-${_TMP_DOCKER_SNAP_CREATE_IMG_SOURCE_VER}}"
		# imgver111111_v1670329246/1-puppeteer-13.1.3_v1670329246
		local _TMP_DOCKER_SNAP_CREATE_SNAP_VER="${_TMP_DOCKER_SNAP_CREATE_IMG_VER}_v${_TMP_DOCKER_SNAP_CREATE_TIMESTAMP}"
		# browserless_chrome/imgver111111_v1670329246
		local _TMP_DOCKER_SNAP_CREATE_FILE_REL_PATH=${_TMP_DOCKER_SNAP_CREATE_IMG_MARK_NAME}/${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}
		# /mountdisk/repo/migrate/snapshot/browserless_chrome/imgver111111_v1670329246
		local _TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH=${_TMP_DOCKER_SNAP_CREATE_SNAP_DIR}/${_TMP_DOCKER_SNAP_CREATE_FILE_REL_PATH}
				
		echo_style_text "([docker_snap_create_action]) Starting make snapshot <${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}>([${_TMP_DOCKER_SNAP_CREATE_CTN_ID}]) to version <${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}> stored at '${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.(ctn.gz/img.tar)'"
		
		# 强制检测如果容器非运行状态，则手动启动容器再继续
		local _TMP_DOCKER_SNAP_CREATE_BOOT_STATUS=""
		function _docker_snap_create_action_status_check() {
			_TMP_DOCKER_SNAP_CREATE_BOOT_STATUS=$(echo "${_TMP_DOCKER_SNAP_CREATE_CTN_INSPECT}" | jq ".[0].State.Status" | grep -oP "(?<=^\").*(?=\"$)")
			if [ "${_TMP_DOCKER_SNAP_CREATE_BOOT_STATUS}" != "running" ]; then
				echo "${TMP_SPLITER2}"
				echo_style_text "[Checked] the container of <${_TMP_DOCKER_SNAP_CREATE_IMG_NAME}>:[${_TMP_DOCKER_SNAP_CREATE_IMG_VER}]('${_TMP_DOCKER_SNAP_CREATE_CTN_ID}') is not running, please check by follow state info↓:"
				echo "${_TMP_DOCKER_SNAP_CREATE_CTN_INSPECT}" | jq ".[0].State"

				echo "${TMP_SPLITER3}"
				echo_style_text "Running 'containers'↓:"
				# docker ps -a -f name=xxx|id=xxx
				docker ps -a | grep "^${_TMP_DOCKER_SNAP_CREATE_CTN_ID:0:12}" | cut -d' ' -f1

				echo "${TMP_SPLITER3}"
				echo_style_text "Please <boot the container> then 'press any keys' to go on..."
				read -e __TMP_DOCKER_SNAP_CREATE

				# 重新加载状态
				_TMP_DOCKER_SNAP_CREATE_CTN_INSPECT=$(docker container inspect ${_TMP_DOCKER_SNAP_CREATE_CTN_ID})
				if [ -z "${_TMP_DOCKER_SNAP_CREATE_CTN_INSPECT}" ]; then
					echo_style_text "[Checked] the container of <${_TMP_DOCKER_SNAP_CREATE_IMG_NAME}>:[${_TMP_DOCKER_SNAP_CREATE_IMG_VER}]('${_TMP_DOCKER_SNAP_CREATE_CTN_ID}') not exists, snap create abord"
					return 0
				fi

				# 非启动状态，一直循环下去
				_docker_snap_create_action_status_check
			fi
		}

		_docker_snap_create_action_status_check

		echo "${TMP_SPLITER2}"
		echo_style_text "Starting 'init' snap create dir↓:"	
		mkdir -pv $(dirname ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH})

		# 备份容器信息
		echo "${TMP_SPLITER2}"
		echo_style_text "Starting 'export&package' <container> snap↓:"	
		echo "${_TMP_DOCKER_SNAP_CREATE_CTN_INSPECT}" | jq > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.inspect.ctn.json
		docker container export ${_TMP_DOCKER_SNAP_CREATE_CTN_ID} | gzip > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.ctn.gz
		ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.ctn.gz
		## 打开后不是标准json格式，先格式化！
		### :%!python -m json.tool
		local _TMP_DOCKER_SNAP_CREATE_SETUP_DATA_DIR=$(docker info | grep "Docker Root Dir" | cut -d':' -f2 | tr -d ' ')
		cp -p -f ${_TMP_DOCKER_SNAP_CREATE_SETUP_DATA_DIR}/containers/${_TMP_DOCKER_SNAP_CREATE_CTN_ID}/config.v2.json ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.config.v2.json
		cp -p -f ${_TMP_DOCKER_SNAP_CREATE_SETUP_DATA_DIR}/containers/${_TMP_DOCKER_SNAP_CREATE_CTN_ID}/hostconfig.json ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.hostconfig.json

		# 备份镜像信息
		echo "${TMP_SPLITER2}"
		echo_style_text "Starting 'export&package' <image> snap↓:"	
		echo "${_TMP_DOCKER_SNAP_CREATE_IMG_INSPECT}" | jq > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.inspect.img.json
		docker save ${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME} > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.img.tar
		ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.img.tar

		# 初始化依赖分析(取最后一天时间为起始)
		echo "${TMP_SPLITER2}"
		echo_style_text "Starting gen 'update container & install dependency' script"
		## 管道运行出现的错误太多，故改为脚本形式操作（EOF带双引号时可以不进行转义）
		# tee ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.extract.sh <<EOF
		# cat > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.extract.sh << 'EOF'
		local _TMP_DOCKER_SNAP_CREATE_INIT_EXTRACT_SCRIPT=$(cat <<'EOF'
#!/bin/sh

func_backup_current_image_init_script()
{
	# 兼容ubuntu
	if [ -f /var/log/apt/history.log ]; then
		## 2022-12-14  03 -> 1670958000
		local _LAST_DATE_HOUR_PAIR=$(cat /var/log/apt/history.log | tail -n1 | cut -d ':' -f2 | sed 's/^\s//')
		## 2022-12-14  02
		local _LAST_DATE_HOUR_PRE_PAIR=$(date -d "1970-01-01 UTC $(($(date +%s -d "${_LAST_DATE_HOUR_PAIR}")-$((1*60*60)))) seconds" "+%F %H")
		local _LAST_DATE_HOUR_PRE_PAIR_DAY=$(echo ${_LAST_DATE_HOUR_PRE_PAIR} | cut -d' ' -f1)
		local _LAST_DATE_HOUR_PRE_PAIR_HOUR=$(echo ${_LAST_DATE_HOUR_PRE_PAIR} | cut -d' ' -f2)

		## 查找最后记录上1小时是否存在记录，若存在，则起始行标注为上一行
		local _LAST_DATE_HOUR_START_LINE=$(cat /var/log/apt/history.log | grep -oPn "^Start-Date: ${_LAST_DATE_HOUR_PRE_PAIR_DAY}  ${_LAST_DATE_HOUR_PRE_PAIR_HOUR}.+" | awk 'NR==1' | cut -d':' -f1)
		if [ -z "${_LAST_DATE_HOUR_START_LINE}" ]; then
			local _LAST_DATE_HOUR_PAIR_DAY=$(echo ${_LAST_DATE_HOUR_PAIR} | cut -d' ' -f1)
			local _LAST_DATE_HOUR_PAIR_HOUR=$(echo ${_LAST_DATE_HOUR_PAIR} | cut -d' ' -f2)
			
			_LAST_DATE_HOUR_START_LINE=$(cat /var/log/apt/history.log | grep -oPn "^Start-Date: ${_LAST_DATE_HOUR_PAIR_DAY}  ${_LAST_DATE_HOUR_PAIR_HOUR}.+" | awk 'NR==1' | cut -d':' -f1)
		fi
		
		### 导出命令临时文件
		tail -n +${_LAST_DATE_HOUR_START_LINE} /var/log/apt/history.log > history_tmp.log
		#### 该处为隔行提取Commandline，误删保留
		#### cat history_tmp.log | grep -oPn '^Start-Date: .+' | cut -d':' -f1 | sed 's/^/1+&/g' | bc | xargs -I {} sed -n '{}p;' /var/log/apt/history.log | cut -d':' -f2 | sed 's/^\s//'
		#### 获取关键字所在行，再根据行号进行命令提取
		cat history_tmp.log | grep -oPn '^Commandline: .+' | cut -d':' -f1 | xargs -I {} sed -n '{}p;' history_tmp.log | cut -d':' -f2 | sed 's/^\s//'
		rm -rf history_tmp.log
	fi

	# 兼容centos
	if [ -f /var/log/yum.log ]; then
		cat /var/log/yum.log | awk '{print $5}' | uniq | xargs -I {} echo 'yum -y install {}'
	fi
}

func_backup_current_image_init_script
EOF
)
		# 更新并安装容器依赖（应用到bc命令时需要，参考上述脚本。注意安装bc操作可能会覆盖了初始化段落）
		# docker exec -u root -it ${_TMP_DOCKER_SNAP_CREATE_CTN_ID} sh -c "apt-get update && apt-get -y -qq install bc"

		# 拷贝提取脚本至容器
		# 运行时才能拷贝并提取依赖文件
		if [ "${_TMP_DOCKER_SNAP_CREATE_BOOT_STATUS}" == "running" ]; then
			# 拷贝依赖提取脚本至容器
			## !!! Error response from daemon: container rootfs is marked read-only
			# docker cp ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.extract.sh ${_TMP_DOCKER_SNAP_CREATE_CTN_ID}:/tmp
			# ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.extract.sh
			# rm -rf ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.extract.sh

			docker_bash_channel_exec "${_TMP_DOCKER_SNAP_CREATE_CTN_ID}" "cat << 'EOF' | tee -a /tmp/${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}.init.extract.sh
${_TMP_DOCKER_SNAP_CREATE_INIT_EXTRACT_SCRIPT}
EOF" "d" "root"
			echo_style_text "'|'[Container exec]↓:"
			docker_bash_channel_exec "${_TMP_DOCKER_SNAP_CREATE_CTN_ID}" "ls -lia /tmp/${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}.init.extract.sh" "" "root"
			
			# 执行提取脚本，获得原始提取操作命令，并清理二进制报错
			echo "#!/bin/sh" > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh.tmp
			# docker exec -u root -i ${_TMP_DOCKER_SNAP_CREATE_CTN_ID} sh -c "sh /tmp/${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}.init.extract.sh && rm -rf /tmp/${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}.init.extract.sh" >> ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh.tmp
			docker_bash_channel_exec "${_TMP_DOCKER_SNAP_CREATE_CTN_ID}" "(test -f /bin/bash && bash /tmp/${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}.init.extract.sh || sh /tmp/${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}.init.extract.sh) && rm -rf /tmp/${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}.init.extract.sh" "" "root" >> ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh.tmp
			# docker_bash_channel_exec "${_TMP_DOCKER_SNAP_CREATE_CTN_ID}" "sh /tmp/${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}.init.extract.sh && rm -rf /tmp/${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}.init.extract.sh" "" "root" >> ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh.tmp
			grep -v "^tail: cannot open" ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh.tmp > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh
			
			echo_style_text "'|'[Local output]↓:"
			ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh
			echo "[-]"
			cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh
			rm -rf ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh.tmp
		fi

		# 备份脚本模板
		local _TMP_DOCKER_SNAP_CREATE_BACKUP_SCRIPT_FORMAT="[[ -a '%s' ]] && (mkdir -pv ${BACKUP_DIR}%s && cp -Rp %s ${BACKUP_DIR}%s/${_TMP_DOCKER_SNAP_CREATE_TIMESTAMP} && echo ${_TMP_DOCKER_SNAP_CREATE_CTN_ID} >> ${BACKUP_DIR}%s/${_TMP_DOCKER_SNAP_CREATE_TIMESTAMP}/.snaphis.log && echo_style_text \"Dir of '%s' [backuped] to <${BACKUP_DIR}%s/${_TMP_DOCKER_SNAP_CREATE_TIMESTAMP}>\") || echo_style_text 'Backup dir <%s> not found'"
		
		# 预先取得runlike
		local _TMP_DOCKER_SNAP_CREATE_BOOT_RUN=$(su_bash_env_conda_channel_exec "runlike ${_TMP_DOCKER_SNAP_CREATE_CTN_ID}")

		# 创建挂载盘备份
		local _TMP_DOCKER_SNAP_CREATE_VOLUMES=$(docker container inspect ${_TMP_DOCKER_SNAP_CREATE_CTN_ID} | jq --arg TYPE 'volume' '.[0].Mounts[] | select(.Type == $TYPE) | .Name' | grep -oP "(?<=^\").*(?=\"$)")
		if [ -n "${_TMP_DOCKER_SNAP_CREATE_VOLUMES}" ]; then
			echo "${TMP_SPLITER2}"
			echo_style_text "Starting 'backup&change' image <${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}> about 'volume dirs'↓:"

			function _docker_snap_create_action_volume_path_restore()
			{
				# 还原挂载的路径
				local _TMP_DOCKER_SNAP_CREATE_BOOT_RUN_MOUNT_POINT=$(docker volume inspect ${1} | jq ".[0].Mountpoint" | grep -oP "(?<=^\").*(?=\"[,]*$)")
				# 转换为挂载的真实路径
				bind_symlink_link_path "_TMP_DOCKER_SNAP_CREATE_BOOT_RUN_MOUNT_POINT"

				# 备份挂载盘路径
				echo "${TMP_SPLITER3}"
				echo_style_text "Starting 'backup' image <${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}> 'volume dir'(<${_TMP_DOCKER_SNAP_CREATE_BOOT_RUN_MOUNT_POINT}>)↓:"
				local _TMP_DOCKER_SNAP_CREATE_PRINTF_BACKUP_SCRIPT="${_TMP_DOCKER_SNAP_CREATE_BOOT_RUN_MOUNT_POINT}"
				exec_text_printf "_TMP_DOCKER_SNAP_CREATE_PRINTF_BACKUP_SCRIPT" "_TMP_DOCKER_SNAP_CREATE_BACKUP_SCRIPT_FORMAT"
				path_exists_action "${_TMP_DOCKER_SNAP_CREATE_BOOT_RUN_MOUNT_POINT}" "${_TMP_DOCKER_SNAP_CREATE_PRINTF_BACKUP_SCRIPT}" "Volume dir <${_TMP_DOCKER_SNAP_CREATE_BOOT_RUN_MOUNT_POINT}> not found"
				ls -lia ${_TMP_DOCKER_SNAP_CREATE_BOOT_RUN_MOUNT_POINT}

				# 修改RUN脚本路径指向为真实路径
				# _TMP_DOCKER_SNAP_CREATE_BOOT_RUN=$(echo "${_TMP_DOCKER_SNAP_CREATE_BOOT_RUN}" | sed "s@${1}:@${_TMP_DOCKER_SNAP_CREATE_BOOT_RUN_MOUNT_POINT}:@g")
				_TMP_DOCKER_SNAP_CREATE_BOOT_RUN=${_TMP_DOCKER_SNAP_CREATE_BOOT_RUN//${1}:/${_TMP_DOCKER_SNAP_CREATE_BOOT_RUN_MOUNT_POINT}:}

				# 修改json文件的路径为得到对应挂载在容器的路径
				echo "${TMP_SPLITER3}"
				echo_style_text "Starting 'change ref volume dirs file' <${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.(hostconfig/config.v2).json>↓:"
				local _TMP_DOCKER_SNAP_CREATE_HOST_BINDS=$(cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.hostconfig.json | jq ".Binds")
				if [ $(echo "${_TMP_DOCKER_SNAP_CREATE_HOST_BINDS}" | jq "length") -gt 0 ]; then
					local _TMP_DOCKER_SNAP_CREATE_BOOT_HOST_BIND_CTN_DIR=$(echo "${_TMP_DOCKER_SNAP_CREATE_HOST_BINDS}" | jq ".[]" | grep -oP "(?<=^\"${1}:).+(?=\"$)")
					if [ -n "${_TMP_DOCKER_SNAP_CREATE_BOOT_HOST_BIND_CTN_DIR}" ]; then
						echo "${TMP_SPLITER3}"
						docker_change_container_inspect_mount "${_TMP_DOCKER_SNAP_CREATE_CTN_ID}" "${_TMP_DOCKER_SNAP_CREATE_BOOT_RUN_MOUNT_POINT}" "${_TMP_DOCKER_SNAP_CREATE_BOOT_HOST_BIND_CTN_DIR}" "${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.config.v2.json" "${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.hostconfig.json"
						echo_style_text "'hostconfig' → Binds↓:"
						cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.hostconfig.json | jq ".Binds[]"

						echo "${TMP_SPLITER3}"
						echo_style_text "'config.v2' → MountPoints↓:"
						cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.config.v2.json | jq ".MountPoints"
					fi
				fi
			}

			items_split_action "_TMP_DOCKER_SNAP_CREATE_VOLUMES" "_docker_snap_create_action_volume_path_restore"
		fi
		
		echo "${TMP_SPLITER2}"
		echo_style_text "Starting make 'image boot run' script↓:"
		echo "${_TMP_DOCKER_SNAP_CREATE_BOOT_RUN}" > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.run
		ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.run
		echo "[-]"
		cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.run
		
		# 创建文件备份
		# echo "${TMP_SPLITER2}"
		# echo_style_text "Starting 'backup dirs' <${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}>↓:"
		# local _TMP_DOCKER_SNAP_CREATE_DIR_ARR=()
		# docker_soft_dirs_bind "_TMP_DOCKER_SNAP_CREATE_DIR_ARR" "${2}"
		# bind_dirs_convert_truthful_action "_TMP_DOCKER_SNAP_CREATE_DIR_ARR"
		
		# function _docker_snap_create_action_exec_backup()
		# {
		# 	local _TMP_DOCKER_SNAP_CREATE_PRINTF_BACKUP_SCRIPT="${1}"
		# 	exec_text_printf "_TMP_DOCKER_SNAP_CREATE_PRINTF_BACKUP_SCRIPT" "${_TMP_DOCKER_SNAP_CREATE_BACKUP_SCRIPT_FORMAT}"

		# 	path_exists_action "${1}" "${_TMP_DOCKER_SNAP_CREATE_PRINTF_BACKUP_SCRIPT}" "Dir of <${1}> not found"
		# }
		# items_split_action "_TMP_DOCKER_SNAP_CREATE_DIR_ARR" "_docker_snap_create_action_exec_backup"
		
		echo "${TMP_SPLITER2}"
		echo_style_text "Starting pull 'dockerfile builder'↓:"
		# 判断是否存在dockerfile操作工具
		# alpine/dfimage是一个镜像，是由Whaler 工具构建而来的。主要功能有：
		# 【1】从一个docker镜像生成Dockerfile内容
		# 【2】搜索添加的文件名以查找潜在的秘密文件
		# 【3】提取Docker ADD/COPY指令添加的文件
		# 【4】展示暴露的端口、环境变量信息等等。
		local _TMP_DOCKER_SNAP_CREATE_ALISA_BASE="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock"
		if [ -z "$(docker images | awk 'NR>1{if($1=="alpine/dfimage"){print}}')" ]; then
			docker pull alpine/dfimage

			# dfimage -sV=1.36 nginx:latest
			echo "alias dfimage='${_TMP_DOCKER_SNAP_CREATE_ALISA_BASE} alpine/dfimage'" >> /etc/bashrc
			echo
		fi

		if [ -z "$(docker images | awk 'NR>1{if($1=="cucker/image2df"){print}}')" ]; then
			docker pull cucker/image2df

			echo "alias image2df='${_TMP_DOCKER_SNAP_CREATE_ALISA_BASE} cucker/image2df'" >> /etc/bashrc
			echo
		fi

		# 如果想要更加详细的内容，比如每一层的信息，以及每一层对应的文件增减情况，那么dive工具可以帮助我们更好的分析镜像。
		# dive用于探索docker镜像、layer内容和发现缩小docker/OCI镜像大小的方法的工具。
		# 左边是镜像和layer的信息，右边是当前选中镜像layer对应的文件磁盘文件信息，右边是会根据左边的选择变动的，比如我在某一层进行了文件的复制新增或者删除，右边会以不同的颜色进行展示的。
		if [ -z "$(docker images | awk 'NR>1{if($1=="wagoodman/dive"){print}}')" ]; then
			docker pull wagoodman/dive
			
			alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
			# dive nginx:latest
			echo "alias dive='${_TMP_DOCKER_SNAP_CREATE_ALISA_BASE} wagoodman/dive'" >> /etc/bashrc
			echo
		fi

		source /etc/bashrc
		
		echo "${TMP_SPLITER2}"
		echo_style_text "Source History <${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}>↓:"
		docker history ${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}
		
		# 将容器打包成镜像
		echo "${TMP_SPLITER2}"
		docker_snap_commit "_TMP_DOCKER_SNAP_CREATE_CTN_ID" "${_TMP_DOCKER_SNAP_CREATE_TIMESTAMP}"

		# 输出构建yml(docker build -f /mountdisk/repo/migrate/snapshot/browserless_chrome/1670329246.dockerfile.yml -t browserless/chrome .)
		local _TMP_DOCKER_SNAP_CREATE_SNAP_WORKING_DIR=$(docker container inspect --format '{{.Config.WorkingDir}}' ${_TMP_DOCKER_SNAP_CREATE_CTN_ID})
		if [ -n "${_TMP_DOCKER_SNAP_CREATE_SNAP_WORKING_DIR}" ]; then
			local _TMP_DOCKER_SNAP_CREATE_SNAP_DCFILE=${_TMP_DOCKER_SNAP_CREATE_SNAP_WORKING_DIR}/Dockerfile
			# if [ -n "$(docker exec -u root -i ${_TMP_DOCKER_SNAP_CREATE_CTN_ID} sh -c "test -f ${_TMP_DOCKER_SNAP_CREATE_SNAP_DCFILE} && echo 1")" ]; then
			if [ "$(docker_bash_channel_exec "${_TMP_DOCKER_SNAP_CREATE_CTN_ID}" "test -f ${_TMP_DOCKER_SNAP_CREATE_SNAP_DCFILE} && echo 1")" == "1" ]; then
				echo "${TMP_SPLITER2}"
				echo_style_text "[View] the 'extract dockerfile from workdir' <${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}>([${_TMP_DOCKER_SNAP_CREATE_SNAP_WORKING_DIR}])↓:"
				docker cp -a ${_TMP_DOCKER_SNAP_CREATE_CTN_ID}:${_TMP_DOCKER_SNAP_CREATE_SNAP_DCFILE} ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.Dockerfile
				ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.Dockerfile
				echo "[-]"
				cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.Dockerfile		
			fi
		fi

		# docker-compose.yml不存在时才输出

		# Dockerfile不存在时才输出
		if [[ ! -a ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.Dockerfile ]]; then
			echo "${TMP_SPLITER2}"
			echo_style_text "[View] the 'build yaml from dfimage' <${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}>↓:"
			## dfimage 部分
			${_TMP_DOCKER_SNAP_CREATE_ALISA_BASE} alpine/dfimage ${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME} | sed "s/# buildkit//g" > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.dfimage.md
			echo "FROM ${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}" > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.dfimage.yml
			cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.dfimage.md | grep -n "Dockerfile:" | cut -d':' -f1 | xargs -I {} echo "{}+1" | bc | xargs -I {} tail -n +{} ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.dfimage.md >> ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.dfimage.yml
			ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.dfimage.md
			echo "[-]"
			cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.dfimage.md
			ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.dfimage.yml
			echo "[-]"
			cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.dfimage.yml
			
			## imagedf 部分
			echo "${TMP_SPLITER2}"
			echo_style_text "[View] the 'build yaml from image2df' <${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}>↓:"
			${_TMP_DOCKER_SNAP_CREATE_ALISA_BASE} cucker/image2df ${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME} | sed "s/# buildkit//g" > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.image2df.yml
			ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.image2df.yml
			echo "[-]"
			cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.image2df.yml
		fi
		
		# 创建完执行
		script_check_action "${_TMP_DOCKER_SNAP_CREATE_SCRIPT}" "${_TMP_DOCKER_SNAP_CREATE_CTN_ID}" "${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}" "${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}" "${_TMP_DOCKER_SNAP_CREATE_SNAP_VER}"
		return $?
	}

	docker_container_param_check_action "${1}" "_docker_snap_create_action"
	return $?
}

# 还原 Docker 快照
# 参数1：镜像名称，例 browserless/chrome
# 参数2：镜像版本(为空时自动检索)，例 imgver111111_v1670329246
# 参数3：还原快照后后执行脚本
#       参数1：镜像名称，例 browserless/chrome
#       参数2：快照版本，例 imgver111111_v1670329246
#       参数3：启动命令，例 /bin/sh
#       参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#       参数5：快照类型，例 image/container/dockerfile
#       参数6：快照来源，例 snapshot/clean，默认snapshot
# 参数4：快照不存在时执行脚本
# 参数5：指定如果镜像快照存在时，快照的还原出处的类别，为空时取并集（默认新镜像安装都会在clean下创建初始快照），例 snapshot/clean
# 示例：
#       docker_snap_restore_choice_action "browserless/chrome" "clean"
function docker_snap_restore_choice_action()
{
    # browserless/chrome
    # local _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_IMG_NAME="${1}"
    # browserless_chrome
    local _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_IMG_MARK_NAME="${1/\//_}"	
    # 可选还原版本合集
	local _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VERS="${2}"
    # snapshot or clean
    local _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_STORE_TYPE="${5}"
	# /mountdisk/repo/migrate/clean/browserless_chrome/
	local _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_CLEAN_DIR="${MIGRATE_DIR}/clean/${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_IMG_MARK_NAME}"

    # 指定存储类型存在判断
    if [ -n "${5}" ]; then
        local _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_DEST_DIR="${MIGRATE_DIR}/${5}/${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_IMG_MARK_NAME}"
        if [[ ! -a ${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_DEST_DIR} ]]; then
            echo "${TMP_SPLITER2}"
            echo_style_text "Cannot found 'snapshot' <${1}> typed [${5}] based '${MIGRATE_DIR}', please check"
            return 0
        fi

        local _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_DEST_VERS=$(ls ${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_DEST_DIR} | cut -d'.' -f1 | uniq)
        if [ -z "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_DEST_VERS}" ]; then
            echo "${TMP_SPLITER2}"
            echo_style_text "Cannot found 'snapshot version' <${1}> typed [${5}] based '${MIGRATE_DIR}', please check"
            return 0
        fi

		# 指定了类型，未指定版本直接覆盖
		if [ -z "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VERS}" ]; then
			_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VERS="${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_DEST_VERS}"
		fi
    fi
	
    # 合集操作
    if [ -z "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VERS}" ]; then
        _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VERS=$(echo_docker_image_mark_vers "${1}" "hub")
    fi
	
	if [ -n "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VERS}" ]; then
		# 去除已存在的容器版本
		## browserless/chrome:v1673604625SRC
		## browserless/chrome:v1673955750SCB 还原备份后本地将初始的latest版本还原至该版
		local _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_EXISTS_VERS=$(echo_docker_images_exists_vers "${1}")
		## 有运行版本存在时
		function _docker_snap_restore_choice_action_remove_exists_vers()
		{
			_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VERS="${3}"
			echo_style_text "[Checked] the image of <${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_IMG_NAME}>:[${1}] exists, version list removed"
		}
		items_change_combine_remove_action "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_EXISTS_VERS}" "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VERS}" "_docker_snap_restore_choice_action_remove_exists_vers"
		
		if [ -n "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VERS}" ]; then
			# 默认版本 /mountdisk/repo/migrate/snapshot/browserless_chrome/1670392779
			local _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VER=$(echo "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VERS}" | cut -d' ' -f1)

			docker_choice_cust_vers_action "${1}" "Please sure 'which version' u want to [restore] from snapshot <${1}>" '_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VER=${2}' "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VERS}"

			local _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_TYPE="Image"
			local _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_TYPES="Image,Container,Dockerfile"

			echo "${TMP_SPLITER2}"
			bind_if_choice "_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_TYPE" "Please sure 'which type' u want to [restore] from snapshot <${1}>:[${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VER}]" "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_TYPES}"
			typeset -l _TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_TYPE

			# 快照存储类型已被重新加载
			if [ -z "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_STORE_TYPE}" ]; then
				_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_STORE_TYPE=$(find ${MIGRATE_DIR} -name ${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VER}.* | grep "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_IMG_MARK_NAME}" | cut -d'.' -f1 | uniq | grep -oP "(?<=^${MIGRATE_DIR}/)\w+(?=/${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_IMG_MARK_NAME}/${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VER}$)")
			fi
			
			docker_snap_restore_action "${1}" "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_VER}" "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_TYPE}" "${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_STORE_TYPE}" "${3}"
		else
			echo_style_text "[Checked] 'image'(<${1}>), got exists vers ([${_TMP_DOCKER_SNAP_RESTORE_CHOICE_ACTION_EXISTS_VERS}]), snapshot restore stoped"
		fi

		# ？？？Commit的版本备份再还原data目录后，启动报错。
		# Checked the image of browserless/chrome:1674055518 exists, version list removed
		# Checked the image of browserless/chrome:1674054906 exists, version list removed
		# Checked the image of browserless/chrome, got exists vers (1674055518 1674054906), snapshot restore stoped
		# ---------------------------------
		# None image of browserless/chrome version assign, this will set it automatic
		# Please sure which version u want to boot from snapshot browserless/chrome, by follow keys, then enter it
		# Choice of 'v1674054906SC0' checked
		# The image of browserless/chrome boot version set to v1674054906SC0
		# ---------------------------------
		# Cannot found created container of browserless/chrome:v1674054906SC0, start to build it
		# Boot failure, please check
		# ---------------------------------
		# Checked the container of browserless/chrome:v1674054906SC0(4cc7f85e5667c00464990d277830a40e62b6724cd80a4d299da7242235ec471b) boot failure, please check by follow state info↓:
		# {
		# "Status": "restarting",
		# "Running": true,
		# "Paused": false,
		# "Restarting": true,
		# "OOMKilled": false,
		# "Dead": false,
		# "Pid": 0,
		# "ExitCode": 1,
		# "Error": "",
		# "StartedAt": "2023-01-18T15:34:53.505554276Z",
		# "FinishedAt": "2023-01-18T15:34:53.551342995Z"
		# }
		# [root@cuckoo ~]# docker logs 4cc
		# rm: cannot remove '/tmp/.X99-lock': Operation not permitted
		# rm: cannot remove '/tmp/.X99-lock': Operation not permitted
		# rm: cannot remove '/tmp/.X99-lock': Operation not permitted
		# rm: cannot remove '/tmp/.X99-lock': Operation not permitted
		# rm: cannot remove '/tmp/.X99-lock': Operation not permitted
		# rm: cannot remove '/tmp/.X99-lock': Operation not permitted
		# rm: cannot remove '/tmp/.X99-lock': Operation not permitted


	else
		echo_style_text "Cannot found the 'snapshot' <${1}>, based '${MIGRATE_DIR}'"

		if [ -n "${4}" ]; then
			echo_style_text "Starting <execute> 'scripts'([${4}]), args([${1}])"
			script_check_action "${4}" "${1}"
		fi
	fi

    return $?
}

# 还原 Docker 快照
# 参数1：镜像名称，例 browserless/chrome
# 参数2：快照版本，例 imgver111111_v1670329246
# 参数3：快照类型，例 image/container/dockerfile
# 参数4：快照来源，例 snapshot/clean，默认snapshot
# 参数5：完成后执行脚本
#       参数1：镜像名称，例 browserless/chrome
#       参数2：镜像版本，例 latest
#       参数3：启动命令，例 /bin/sh
#       参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#       参数5：快照类型(还原时有效)，例 image/container/dockerfile
#       参数6：快照来源，例 snapshot/clean/hub/commit，默认snapshot
# 示例：
#   docker_snap_restore_action "browserless/chrome" "1673604625" "container" "clean"
function docker_snap_restore_action()
{
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_NAME="${1}"
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_MARK_NAME="${1/\//_}"
	typeset -l _TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_TYPE
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER="${2}"
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_TYPE="${3:-"image"}"
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_FROM="${4}"
	if [ -z "${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_FROM}" ]; then
		_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_FROM=$(find ${MIGRATE_DIR} -name ${2}.* | grep "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_MARK_NAME}" | cut -d'.' -f1 | uniq | grep -oP "(?<=^${MIGRATE_DIR}/).+(?=/${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_MARK_NAME}/${2}$)")
	fi

	# 检测 镜像是否存在，存在则不开启还原行为(暂未判断结束版本标记，例如SRC/SCI等)
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_RESTORED=""
    echo_style_wrap_text "Checking 'snapshot'([${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_TYPE}]) exists of <${1}>:[${2}] from docker images"
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_CURR_IMGS=$(docker images | awk "NR>1{if(\$1~\"${1}\"){print}}")
	if [ -n "${_TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_CURR_IMGS}" ]; then
		local _TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_CURR_IMG_VERS=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_CURR_IMGS}" | awk -F' ' '{print $2}' | egrep "^${2}" | grep -Pv ".+_v[0-9]{10}(?=SC[0-9]+$)")
		echo_style_text "[Checked] 'snapshot'([${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_TYPE}]) of <${1}>:[${2}] from docker images exists versions('${_TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_CURR_IMG_VERS}')"
		if [ -n "${_TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_CURR_IMG_VERS}" ]; then
			# 镜像存在，但未有容器
			function _docker_snap_restore_action_change_ver_check()
			{
				# docker ps -a -f name=xxx|id=xxx
				local _TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_CTN="$(docker ps -a --no-trunc | awk -F' ' "{if(\$2==\"${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_NAME}:${1}\"){print}}")"
				if [ -z "${_TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_CTN}" ]; then
					echo_style_text "[Checked] 'snapshot'([${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_TYPE}]) of <${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_NAME}>:[${1}], but got none 'container', restore <stoped>, boot mark 'version changed' from [${_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER}] to <${1}>"
					_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER="${1}"
					_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_RESTORED="true"
					break
				fi
			}
			
			items_split_action "_TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_CURR_IMG_VERS" "_docker_snap_restore_action_change_ver_check"

			# 镜像存在，已有容器
			if [ -z "${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_RESTORED}" ]; then
				echo_style_text "[Checked] 'snapshot'([${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_TYPE}]) of <${1}>:[${2}] from docker images exists, restore stoped"
				return
			fi
		fi
	fi
	
	# 卸载无用的变量
	# item_change_remove_bind "_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS" "^--name=\w+$"
	item_change_remove_bind "_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS" "^--hostname=\w+$"
	item_change_remove_bind "_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS" "^--mac-address=[\w|:]+$"
	item_change_remove_bind "_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS" "^--runtime=\w+$"
	item_change_remove_bind "_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS" "^--detach=\w+$"
	
	# /mountdisk/repo/migrate/snapshot/browserless_chrome/
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_BASE_DIR="${MIGRATE_DIR}/${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_FROM}/${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_MARK_NAME}"
	# local TMP_DOCKER_SNAP_RESTORE_ACTION_LNK_NAME="${1/_//}"
	# /mountdisk/repo/migrate/snapshot/browserless_chrome/1673604625
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH="${_TMP_DOCKER_SNAP_RESTORE_ACTION_BASE_DIR}/${2}"	
	# /bin/sh
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_RUN_CMD=$([[ -a ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.run ]] && cat ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.run)
	# imgver111111
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_VER=$(echo "${2}" | grep -oP "[^_]+(?=_v[0-9]{10})")
	# /bin/sh
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_CMD=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_RUN_CMD}" | grep -oP "(?<=${1}:${_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_VER:-${2}} ).+")
	# --volume /etc/localtime:/etc/localtime:ro
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_RUN_CMD}" | grep -oP "(?<=^docker run ).+(?=${1}:.+)")
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_REPO_TAGS=$(cat ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.inspect.img.json | jq ".[0].RepoTags" | grep -oP "(?<=^  \").*(?=\",*$)")
    
	if [ -z "${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_RESTORED}" ]; then
			
		echo "${TMP_SPLITER2}"
		echo_style_text "Starting <restore> 'snapshot'([${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_TYPE}]) <${1}>:[${2}] from '${_TMP_DOCKER_SNAP_RESTORE_ACTION_REPO_TAGS:-"snapshot restore"}'"
		case "${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_TYPE}" in
			"container")
				_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER="${2}SRC"
				zcat ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.ctn.gz | docker import - ${1}:${_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER}
			;;
			"image")
				_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER="${2}SRI"
				docker load < ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.img.tar
				
				local _TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_ID=$(cat ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.inspect.img.json | jq ".[0].Id" | xargs echo | cut -d':' -f2)
				docker tag ${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_ID} ${1}:${_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER}
				
				if [ -n "${_TMP_DOCKER_SNAP_RESTORE_ACTION_REPO_TAGS}" ]; then
					items_split_action "${_TMP_DOCKER_SNAP_RESTORE_ACTION_REPO_TAGS}" "docker rmi %s"
				fi
				
				# local _TMP_DOCKER_SNAP_RESTORE_ACTION_REPO_TAG=$(cat ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.inspect.img.json | jq ".[0].RepoTags" | grep -oP "(?<=^  \").*(?=\",*$)")
				# docker tag ${_TMP_DOCKER_SNAP_RESTORE_ACTION_REPO_TAG} ${1}:${_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER}
			;;
			"dockerfile")
				_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER="${2}SRD"
				docker build -f ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.Dockerfile -t ${1}:${_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER} .
			;;
			*)
				echo
		esac
		
		echo_style_text "The '${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_TYPE} snapshot' restored to <${1}>:[${_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER}]"
	fi

	local _TMP_DOCKER_SNAP_RESTORE_ACTION_WORKING_DIR=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_RUN_CMD}" | grep -oP "(?<=--workdir\=)[^\s]+")

	# 补充丢失的环境参数
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_ARG_ENVS=""
	if [ -a ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.inspect.ctn.json ]; then
		local _TMP_DOCKER_SNAP_RESTORE_ACTION_CTN_FILE_INSPECT=$(cat ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.inspect.ctn.json)
		if [ -n "${_TMP_DOCKER_SNAP_RESTORE_ACTION_CTN_FILE_INSPECT}" ]; then
			# 必须指定启动命令
			if [ -z "${_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_CMD}" ]; then
				_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_CMD=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_CTN_FILE_INSPECT}" | jq ".[0].Config.Cmd" | grep -oP "(?<=^  \").*(?=\",*$)")
			fi

			# 必须指定工作目录，否则会出现（OCI，no such file or directory）
			if [ -z "${_TMP_DOCKER_SNAP_RESTORE_ACTION_WORKING_DIR}" ]; then
				_TMP_DOCKER_SNAP_RESTORE_ACTION_WORKING_DIR=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_CTN_FILE_INSPECT}" | jq ".[0].Config.WorkingDir" | grep -oP "(?<=^\").*(?=\"$)")
			fi
			
			# 容器恢复丢失环境信息，故需要读取容器inspect信息
			local _TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_ENVS=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_CTN_FILE_INSPECT}" | jq ".[0].Config.Env" | grep -oP "(?<=^  \").*(?=\",*$)")
			if [ -n "${_TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_ENVS}" ]; then
				_TMP_DOCKER_SNAP_RESTORE_ACTION_ARG_ENVS=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_ENVS}" | xargs printf "--env=%s ")
			fi
			
			# 容器的参数覆盖传参的参数		
			function _docker_snap_restore_action_filter_arg_envs()
			{
				# --env=APP_DIR=/usr/src/app
				local _TMP_DOCKER_SNAP_RESTORE_ACTION_ENV_KEY=$(echo "${1}" | cut -d'=' -f1)
				item_change_remove_bind "_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS" "^--env=${_TMP_DOCKER_SNAP_RESTORE_ACTION_ENV_KEY}="
			}
			items_split_action "_TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_ENVS" "_docker_snap_restore_action_filter_arg_envs"
		fi
	fi

	local _TMP_DOCKER_SNAP_RESTORE_ACTION_ARG_MOUNTS=""
	if [ -a ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.hostconfig.json ]; then
		local _TMP_DOCKER_SNAP_RESTORE_ACTION_CTN_FILE_HOSTCONF=$(cat ${_TMP_DOCKER_SNAP_RESTORE_ACTION_NONE_PATH}.hostconfig.json)
		# 挂载盘信息获取
		local _TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_MOUNTS=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_CTN_FILE_HOSTCONF}" | jq ".Binds" | grep -oP "(?<=^  \").*(?=\",*$)")
		if [ -n "${_TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_MOUNTS}" ]; then
			_TMP_DOCKER_SNAP_RESTORE_ACTION_ARG_MOUNTS=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_MOUNTS}" | xargs printf "--volume=%s ")
		fi
		
		function _docker_snap_restore_action_filter_arg_mounts()
		{
			# --volume=/mountdisk/data/docker_apps/browserless_chrome/imgver111111:/usr/src/app/workspace
			local _TMP_DOCKER_SNAP_RESTORE_ACTION_MOUNT_KEY=$(echo "${1}" | cut -d':' -f2)
			item_change_remove_bind "_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS" "^--volume=.+:${_TMP_DOCKER_SNAP_RESTORE_ACTION_MOUNT_KEY}$"
		}
		items_split_action "_TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_MOUNTS" "_docker_snap_restore_action_filter_arg_mounts"
	fi

	item_change_cover_bind "_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS" "^--workdir=.+:${_TMP_DOCKER_SNAP_RESTORE_ACTION_MOUNT_KEY}$" "--workdir=${_TMP_DOCKER_SNAP_RESTORE_ACTION_WORKING_DIR}"
	
	_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS="${_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS} ${_TMP_DOCKER_SNAP_RESTORE_ACTION_ARG_ENVS} ${_TMP_DOCKER_SNAP_RESTORE_ACTION_ARG_MOUNTS}"

	trim_str "_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS"
	script_check_action "${5}" "${1}" "${_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER}" "${_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_CMD}" "${_TMP_DOCKER_SNAP_RESTORE_ACTION_BOOT_ARGS}" "${_TMP_DOCKER_SNAP_RESTORE_ACTION_SNAP_TYPE}" "${4}"
    return $?
}

# docker容器启动等待
# 参数1：等待端口
# 参数2：等待输出
function docker_container_boot_wait()
{
	local _TMP_DOCKER_CTN_BOOT_WAIT_PS_PORT="${1}"
	
	# 指定端口，则等待
	if [ -n "${_TMP_DOCKER_CTN_BOOT_WAIT_PS_PORT}" ]; then
		# 等待执行完毕 产生端口
		exec_sleep_until_not_empty "${2}" "lsof -i:${_TMP_DOCKER_CTN_BOOT_WAIT_PS_PORT}" 180 3
		if [ -z "$(lsof -i:${_TMP_DOCKER_CTN_BOOT_WAIT_PS_PORT})" ]; then
			echo_style_text "Boot failure, please check"
			return 0
		fi
	fi
	
    return $?
}

# Docker容器信息打印
# 参数1：容器ID或名称值或变量名，用于检测
# 参数2：授权及备份前运行脚本
#	    参数1：启动后的进程ID
#       参数2：最终启动端口
#       参数3：最终启动版本
#	    参数4：最终启动命令
#	    参数5：最终启动参数
function docker_container_print() 
{
    local _TMP_DOCKER_CTN_PRINT_ID_OR_NAME=$(echo_discern_exchange_var_val "${1}")
    local _TMP_DOCKER_CTN_PRINT_CHANGE_SCRIPT=$(echo_discern_exchange_var_val "${2}")

    function _docker_container_print()
    {
        local _TMP_DOCKER_CTN_PRINT_IMG_ID=${1}
        local _TMP_DOCKER_CTN_PRINT_CTN_ID=${2}
        local _TMP_DOCKER_CTN_PRINT_IMG_NAME=${3}
        local _TMP_DOCKER_CTN_PRINT_IMG_MARK_NAME="${3/\//_}"
        local _TMP_DOCKER_CTN_PRINT_VER=${4}
        local _TMP_DOCKER_CTN_PRINT_CMD=${5}
        local _TMP_DOCKER_CTN_PRINT_ARGS=${6}

        # -P :是容器内部端口随机映射到主机的端口。
        # -p : 是容器内部端口绑定到指定的主机端口。
        local _TMP_DOCKER_CTN_PRINT_CTN_PORT_PAIR=$(echo "${_TMP_DOCKER_CTN_PRINT_ARGS}" | grep -oP "(?<=-p )[0-9|:]+(?=\s*)")
        local _TMP_DOCKER_CTN_PRINT_CTN_OPN_PORT=$(echo "${_TMP_DOCKER_CTN_PRINT_CTN_PORT_PAIR}" | cut -d':' -f1)
        local _TMP_DOCKER_CTN_PRINT_CTN_INN_PORT=$(echo "${_TMP_DOCKER_CTN_PRINT_CTN_PORT_PAIR}" | cut -d':' -f2)

		# 常规登录用户与配置用户（详情查看code-server体现）
		local _TMP_DOCKER_CTN_PRINT_CTN_LOGIN_USER=$(docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "whoami" "t")
		local _TMP_DOCKER_CTN_PRINT_CTN_CONFG_USER=$(echo "${_TMP_DOCKER_CTN_PRINT_ARGS}" | grep -oP "(?<=--env=USER=)\S+")
		if [ -z "${_TMP_DOCKER_CTN_PRINT_CTN_CONFG_USER}" ]; then
			_TMP_DOCKER_CTN_PRINT_CTN_CONFG_USER=$(echo "${_TMP_DOCKER_CTN_PRINT_ARGS}" | grep -oP "(?<=--user=)\S+")
			# 如果是数字, 例如 1000
			expr ${_TMP_DOCKER_CTN_PRINT_CTN_CONFG_USER} "+" 0 &> /dev/null
			if [ $? -eq 0 ]; then
				_TMP_DOCKER_CTN_PRINT_CTN_CONFG_USER=$(docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "getent passwd ${_TMP_DOCKER_CTN_PRINT_CTN_CONFG_USER} | cut -d':' -f1" "t")
			fi
		fi
        
        echo_style_text "[View] the 'container user'↓:"
        echo_style_text "Docker exec [login]: <${_TMP_DOCKER_CTN_PRINT_CTN_LOGIN_USER}>"
        echo_style_text "Docker env [configuration]: <${_TMP_DOCKER_CTN_PRINT_CTN_CONFG_USER:-None}>"

        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'container time'↓:"
        # docker exec -it ${_TMP_DOCKER_CTN_PRINT_CTN_ID} sh -c "date"
        docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "date" "t"

        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'container occupancy rate'↓:"
        
		# 有些容器不支持xargs故分拆
        docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "cd /;ls | grep -v 'proc' | xargs du -sh" "t"
		if [ $? -ne 0 ]; then
			echo_style_text "Cannot support command 'xargs', try another choice"
			local _TMP_DOCKER_CTN_PRINT_CTN_BASE_DIRS=($(docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "cd /;ls" "t"))
			items_split_action "_TMP_DOCKER_CTN_PRINT_CTN_BASE_DIRS" "docker_bash_channel_exec '${_TMP_DOCKER_CTN_PRINT_CTN_ID}' 'du -sh /%s' 't'"
		fi

        # 展开Dockerfile，用于后续提取信息
        local _TMP_DOCKER_CTN_PRINT_CTN_INSPECT=$(docker container inspect ${_TMP_DOCKER_CTN_PRINT_CTN_ID})
        local _TMP_DOCKER_CTN_PRINT_CTN_WORKING_DIR=$(echo "${_TMP_DOCKER_CTN_PRINT_CTN_INSPECT}" | jq ".[0].Config.WorkingDir" | grep -oP '(?<=^").*(?="$)')

        local _TMP_DOCKER_CTN_PRINT_CTN_DCFILE_CHOWN_SCRIPT=""
        if [ -n "${_TMP_DOCKER_CTN_PRINT_CTN_WORKING_DIR}" ]; then
            if [ "$(docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "echo 1")" == "1" ]; then
                # local _TMP_DOCKER_CTN_PRINT_CTN_DCFILE=$(docker exec -u root -it ${_TMP_DOCKER_CTN_PRINT_CTN_ID} sh -c "test -f ${_TMP_DOCKER_CTN_PRINT_CTN_WORKING_DIR}/Dockerfile && cat ${_TMP_DOCKER_CTN_PRINT_CTN_WORKING_DIR}/Dockerfile")
                local _TMP_DOCKER_CTN_PRINT_CTN_DCFILE=$(docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "test -f ${_TMP_DOCKER_CTN_PRINT_CTN_WORKING_DIR}/Dockerfile && cat ${_TMP_DOCKER_CTN_PRINT_CTN_WORKING_DIR}/Dockerfile" "t")
                if [ -n "${_TMP_DOCKER_CTN_PRINT_CTN_DCFILE}" ]; then
                    _TMP_DOCKER_CTN_PRINT_CTN_DCFILE_CHOWN_SCRIPT=$(echo "${_TMP_DOCKER_CTN_PRINT_CTN_DCFILE}" | grep -oP "(?<=chown ).+\s+\w+:\w+\s+[$|\w]+" | xargs -I {} echo "chown {}")
                else
                    local _TMP_DOCKER_CTN_PRINT_CTN_WORKSPACE_CHOWNS=()

                    function _docker_container_print_chown_workspace()
                    {
                        local _TMP_DOCKER_CTN_PRINT_CHOWN_WORKSPACE_DIR=$(echo ${1} | cut -d' ' -f2)
                        if [ "${_TMP_DOCKER_CTN_PRINT_CHOWN_WORKSPACE_DIR}" != ".." ]; then

                            local _TMP_DOCKER_CTN_PRINT_CHOWN_WORKSPACE_SCRIPT=""
                            if [ "${_TMP_DOCKER_CTN_PRINT_CHOWN_WORKSPACE_DIR}" == "." ]; then
                                local _TMP_DOCKER_CTN_PRINT_CHOWN_WORKSPACE_PER=$(echo ${1} | cut -d' ' -f1)
                                _TMP_DOCKER_CTN_PRINT_CHOWN_WORKSPACE_SCRIPT="chown ${_TMP_DOCKER_CTN_PRINT_CHOWN_WORKSPACE_PER} /${_TMP_DOCKER_CTN_PRINT_CTN_WORKING_DIR}"
                            else
                                _TMP_DOCKER_CTN_PRINT_CHOWN_WORKSPACE_SCRIPT="chown -R ${1}"
                            fi
                        
                            _TMP_DOCKER_CTN_PRINT_CTN_WORKSPACE_CHOWNS[${#_TMP_DOCKER_CTN_PRINT_CTN_WORKSPACE_CHOWNS[@]}]="${_TMP_DOCKER_CTN_PRINT_CHOWN_WORKSPACE_SCRIPT}"
                        fi
                    }

					# 如果产生配置用户则手动调整
                    local _TMP_DOCKER_CTN_PRINT_CTN_WORKSPACE_PERS=
					if [ -z "${_TMP_DOCKER_CTN_PRINT_CTN_CONFG_USER}" ]; then
						_TMP_DOCKER_CTN_PRINT_CTN_WORKSPACE_PERS=$(docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "ls -la /${_TMP_DOCKER_CTN_PRINT_CTN_WORKING_DIR} | awk 'NR>1' | awk -F' ' '{print \$3\":\"\$4\" \"\$9}'" "t" | tr -d "\r")
					else
						_TMP_DOCKER_CTN_PRINT_CTN_WORKSPACE_PERS=$(docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "ls -la /${_TMP_DOCKER_CTN_PRINT_CTN_WORKING_DIR} | awk 'NR>1' | awk -F' ' '{print ${_TMP_DOCKER_CTN_PRINT_CTN_CONFG_USER}\" \"\$9}'" "t" | tr -d "\r")
					fi

                    echo "${_TMP_DOCKER_CTN_PRINT_CTN_WORKSPACE_PERS}" | eval "script_channel_action '_docker_container_print_chown_workspace'"
                    _TMP_DOCKER_CTN_PRINT_CTN_DCFILE_CHOWN_SCRIPT="${_TMP_DOCKER_CTN_PRINT_CTN_WORKSPACE_CHOWNS}"
                fi
            fi
        fi
        
        script_check_action "${_TMP_DOCKER_CTN_PRINT_CHANGE_SCRIPT}" "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "${_TMP_DOCKER_CTN_PRINT_CTN_OPN_PORT}" "${_TMP_DOCKER_CTN_PRINT_VER}" "${_TMP_DOCKER_CTN_PRINT_CMD}" "${_TMP_DOCKER_CTN_PRINT_ARGS}" "${_TMP_DOCKER_CTN_PRINT_MARK_VER}"

        # 重新加载容器inspect
        _TMP_DOCKER_CTN_PRINT_CTN_INSPECT=$(docker container inspect ${_TMP_DOCKER_CTN_PRINT_CTN_ID})
        
        # 修改授权
        if [ -n "${_TMP_DOCKER_CTN_PRINT_CTN_DCFILE_CHOWN_SCRIPT}" ]; then
            echo_style_text "[View] the 'dockerfile chowns'↓:"
            echo "${_TMP_DOCKER_CTN_PRINT_CTN_DCFILE_CHOWN_SCRIPT}"

            function _docker_container_print_chown_mounts()
            {
                # docker exec -u root -i ${_TMP_DOCKER_CTN_PRINT_CTN_ID} sh -c "${1}"
                docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "${1}"
            }

            echo "${_TMP_DOCKER_CTN_PRINT_CTN_DCFILE_CHOWN_SCRIPT}" | eval "script_channel_action '_docker_container_print_chown_mounts'"
            
            # 重启容器
            echo "${TMP_SPLITER2}"
            echo_style_text "[View] the 'restart'↓:"
            docker container restart ${_TMP_DOCKER_CTN_PRINT_CTN_ID}
            
            # 二次等待
            docker_container_boot_wait "${_TMP_DOCKER_CTN_PRINT_CTN_OPN_PORT}" "Rebooting the image <${1}:[${_TMP_DOCKER_CTN_PRINT_VER}]>([${_TMP_DOCKER_CTN_PRINT_CTN_ID}]) over chown mounts, wait for a moment"
        fi
        
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] clear list 'unuse symlink'↓:"
        # 清空无效软连接
        function _docker_container_print_clear_unuse_link()
        {
            if [[ ! -a ${1} ]]; then
                echo_style_text "rm -rf ${1}"
                rm -rf ${1}
            fi
        }

        [[ -a ${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${_TMP_DOCKER_CTN_PRINT_IMG_MARK_NAME} ]] && find ${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${_TMP_DOCKER_CTN_PRINT_IMG_MARK_NAME} -type l | eval "script_channel_action '_docker_container_print_clear_unuse_link'"
        [[ -a ${DOCKER_SETUP_DIR}/${DEPLOY_CONF_MARK}/${_TMP_DOCKER_CTN_PRINT_IMG_MARK_NAME} ]] && find ${DOCKER_SETUP_DIR}/${DEPLOY_CONF_MARK}/${_TMP_DOCKER_CTN_PRINT_IMG_MARK_NAME} -type l | eval "script_channel_action '_docker_container_print_clear_unuse_link'"

        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'boot info'↓:"
        local _TMP_DOCKER_CTN_PRINT_RUNLIKE=$(su_bash_env_conda_channel_exec "runlike ${_TMP_DOCKER_CTN_PRINT_CTN_ID}")
        echo "${_TMP_DOCKER_CTN_PRINT_RUNLIKE}"
            
        function _docker_container_print_ls_mounts()
        {
            echo "${TMP_SPLITER2}"
            echo_style_text "[View] the 'mount dir(${1})'↓:"
            # docker exec -u root -i ${_TMP_DOCKER_CTN_PRINT_CTN_ID} sh -c "ls -lia ${1}"
            docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "ls -lia ${1}"
        }
        
        local _TMP_DOCKER_CTN_PRINT_MOUNT_ARR=($(echo "${_TMP_DOCKER_CTN_PRINT_RUNLIKE}" | grep -oP '(?<=--volume=)[^ ]+(?=\s)' | cut -d':' -f2 | grep -v '^/etc/localtime$' | grep -v '^/var/run/docker.sock$' | sort | tr -d '\r'))
        items_split_action "${_TMP_DOCKER_CTN_PRINT_MOUNT_ARR[*]}" "_docker_container_print_ls_mounts"
        
        # 查看日志（config/image）
        if [[ -a ${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${_TMP_DOCKER_CTN_PRINT_IMG_MARK_NAME} ]]; then
            echo "${TMP_SPLITER2}"
            echo_style_text "[View] the 'container inspect'↓:"
            echo "${_TMP_DOCKER_CTN_PRINT_CTN_INSPECT}" | jq > ${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${_TMP_DOCKER_CTN_PRINT_IMG_MARK_NAME}/${_TMP_DOCKER_CTN_PRINT_CTN_ID}.ctn.inspect.json
            cat ${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${_TMP_DOCKER_CTN_PRINT_IMG_MARK_NAME}/${_TMP_DOCKER_CTN_PRINT_CTN_ID}.ctn.inspect.json
        fi

        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'container logs'↓:"
        docker logs ${_TMP_DOCKER_CTN_PRINT_CTN_ID}

        # 区分是否是初始化产生的提取类型容器 docker ps -a -f name=xxx|id=xxx
        local _TMP_DOCKER_CTN_PRINT_PS=$(docker ps -a --no-trunc | grep "^${_TMP_DOCKER_CTN_PRINT_CTN_ID}")
        if [ -n "${_TMP_DOCKER_CTN_PRINT_PS}" ]; then
            # 最后更新一次容器内包
            echo "${TMP_SPLITER2}"
            echo_style_text "[View] the 'container update'↓:"
            # docker exec -u root -w /tmp -it ${_TMP_DOCKER_CTN_PRINT_CTN_ID} sh -c "apt-get update"
			local _TMP_DOCKER_CTN_PRINT_ISSUE=$(docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "cat /etc/issue" "t")
			# 控制读写
			##1 ERROR: Unable to lock database: Read-only file system
			##1 ERROR: Failed to open apk database: Read-only file system
			##2 Error response from daemon: container rootfs is marked read-only
			## 临时重新挂载
			docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "mount -o remount,rw -o /" "d" "root"
			if [[ "${_TMP_DOCKER_CTN_PRINT_ISSUE//Ubuntu/}" != "${_TMP_DOCKER_CTN_PRINT_ISSUE}" || "${_TMP_DOCKER_CTN_PRINT_ISSUE//Debian/}" != "${_TMP_DOCKER_CTN_PRINT_ISSUE}" ]]; then
				docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "apt-get update" "t"
			else
				if [ "${_TMP_DOCKER_CTN_PRINT_ISSUE//Photon/}" != "${_TMP_DOCKER_CTN_PRINT_ISSUE}" ]; then
					# docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "cd /etc/yum.repos.d/ && sed -i 's/dl.bintray.com\/vmware/packages.vmware.com\/photon\/\$releasever/g' photon.repo photon-updates.repo photon-extras.repo photon-debuginfo.repo" "t"
					docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "tdnf -y update" "t"
					# echo_style_text "'Photon' system, do nothing"
				elif [ "${_TMP_DOCKER_CTN_PRINT_ISSUE//Alpine/}" != "${_TMP_DOCKER_CTN_PRINT_ISSUE}" ]; then
					docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "apk update" "t"
				else
					docker_bash_channel_exec "${_TMP_DOCKER_CTN_PRINT_CTN_ID}" "yum -y update" "t"
				fi
			fi
            
            # 备份当前容器，仅在第一次 	
            local TMP_DOCKER_SETUP_CTN_CLEAN_DIR="${MIGRATE_DIR}/clean"
            path_not_exists_action "${TMP_DOCKER_SETUP_CTN_CLEAN_DIR}/${_TMP_DOCKER_CTN_PRINT_IMG_MARK_NAME}" "echo '${TMP_SPLITER2}' && docker_snap_create_action '${_TMP_DOCKER_CTN_PRINT_CTN_ID}' '${TMP_DOCKER_SETUP_CTN_CLEAN_DIR}' '${LOCAL_TIMESTAMP}'"
        fi
    }

    docker_container_param_check_action "_TMP_DOCKER_CTN_PRINT_ID_OR_NAME" "_docker_container_print"
	return $?
}

# Docker启动执行脚本
# 参数1：镜像名称，例 browserless/chrome
# 参数2：启动版本，例 imgver111111_v1670329246
# 参数3：初始启动命令
# 参数4：初始启动参数
# 参数5：启动前运行脚本
#	    参数1：镜像名称
# 参数6：成功启动后运行脚本
#	    参数1：启动后的进程ID
#       参数2：最终启动端口
#       参数3：最终启动版本
#	    参数4：最终启动命令
#	    参数5：最终启动参数
function docker_image_boot_print() 
{
	local _TMP_DOCKER_IMG_BOOT_PRINT_IMG_REP_NAME="${1#*/}"
    local _TMP_DOCKER_IMG_BOOT_PRINT_IMG_MARK_NAME="${1/\//_}"
    local _TMP_DOCKER_IMG_BOOT_PRINT_VER="${2}"
    local _TMP_DOCKER_IMG_BOOT_PRINT_CMD="${3}"
    local _TMP_DOCKER_IMG_BOOT_PRINT_ARGS="${4}"
	local _TMP_DOCKER_IMG_BOOT_PRINT_IMG_GREP=$(echo_docker_image_grep "${1}")
	
	# -P :是容器内部端口随机映射到主机的端口。
	# -p : 是容器内部端口绑定到指定的主机端口。
    local _TMP_DOCKER_IMG_BOOT_PRINT_CTN_PORT_PAIR=$(echo "${_TMP_DOCKER_IMG_BOOT_PRINT_ARGS}" | grep -oP "(?<=-p )[0-9|:]+(?=\s*)")
    local _TMP_DOCKER_IMG_BOOT_PRINT_CTN_OPN_PORT=$(echo "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_PORT_PAIR}" | cut -d':' -f1)
    local _TMP_DOCKER_IMG_BOOT_PRINT_CTN_INN_PORT=$(echo "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_PORT_PAIR}" | cut -d':' -f2)
    
	local _TMP_DOCKER_IMG_BOOT_PRINT_BEFORE_BOOT_SCRIPTS=${5}
	
	# docker ps -a -f name=xxx|id=xxx
	local _TMP_DOCKER_IMG_BOOT_PRINT_PS=$(docker ps -a --no-trunc | awk -F' ' "{if(\$2~\"${1}:\"){print}}")
	if [ -n "${_TMP_DOCKER_IMG_BOOT_PRINT_PS}" ]; then
		echo "${TMP_SPLITER2}"
		echo_style_text "[View] the 'exists containers no-trunc' <${1}>'↓:"
		docker ps -a --no-trunc | awk 'NR==1'
		echo "${_TMP_DOCKER_IMG_BOOT_PRINT_PS}"
	fi
	
	# 确认版本: 未指定版本则通过选项来启动
	if [ -z "${_TMP_DOCKER_IMG_BOOT_PRINT_VER}" ]; then
		echo "${TMP_SPLITER2}"
		echo_style_text "None 'image'(<${1}>) version assign, this will set it automatic"

		# 返回已存在容器中的版本，例imgver111111/imgver111111_v1670329246SRC
		# local _TMP_DOCKER_IMG_BOOT_PRINT_CTN_VERS=$(echo "${_TMP_DOCKER_IMG_BOOT_PRINT_PS}" | awk -F' ' '{print $2}' | cut -d':' -f2)
		# 返回已存在镜像中的版本，例imgver111111/imgver111111_v1670329246SRC
		local _TMP_DOCKER_IMG_BOOT_PRINT_VERS=$(echo "${_TMP_DOCKER_IMG_BOOT_PRINT_IMG_GREP}" | awk -F' ' '{print $2}')
		# 与镜像对比，排除已存在的版本（同一版本限定只能启动一次）
		# items_change_combine_remove_action "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_VERS}" "${_TMP_DOCKER_IMG_BOOT_PRINT_VERS}" '_TMP_DOCKER_IMG_BOOT_PRINT_VERS="${3}"'
		
		# 剩余版本提供选择
		docker_choice_cust_vers_action "${1}" "Please sure 'which version' u want to boot from snapshot <${1}>" '_TMP_DOCKER_IMG_BOOT_PRINT_VER="${2}"' "${_TMP_DOCKER_IMG_BOOT_PRINT_VERS}"
		
		if [ -n "${_TMP_DOCKER_IMG_BOOT_PRINT_VER}" ]; then
			echo_style_text "The 'image'(<${1}>) boot version set to [${_TMP_DOCKER_IMG_BOOT_PRINT_VER}]"
		else
			echo_style_text "[Checked] 'image'(<${1}>) no versions less to switch for boot"
			return 0
		fi
	fi
	
	# 未指定版本，又找不到需启动的版本，则直接退出
	if [ -z "${_TMP_DOCKER_IMG_BOOT_PRINT_VER}" ]; then
		echo "${TMP_SPLITER2}"
		echo_style_text "None 'image'(<${1}>) boot version found, boot exit"
		return 0
	fi

	# 启动命令设置
	if [ -z "${_TMP_DOCKER_IMG_BOOT_PRINT_CMD}" ]; then
		local _TMP_DOCKER_IMG_BOOT_PRINT_IMG_ID=$(echo "${_TMP_DOCKER_IMG_BOOT_PRINT_IMG_GREP}" | grep "${_TMP_DOCKER_IMG_BOOT_PRINT_VER}" | awk -F' ' '{print $3}')
		_TMP_DOCKER_IMG_BOOT_PRINT_CMD=$(docker inspect ${_TMP_DOCKER_IMG_BOOT_PRINT_IMG_ID} -f {{".Config.Cmd"}} | grep -oP "(?<=^\[).*(?=\]$)")
		if [ -n "${_TMP_DOCKER_IMG_BOOT_PRINT_CMD}" ]; then
			echo "${TMP_SPLITER2}"
			echo_style_text "None boot cmd assign of 'image'(<${1}>), this will set it to ('${_TMP_DOCKER_IMG_BOOT_PRINT_CMD}')"
		fi
	fi

    # 启动前执行
    script_check_action "${_TMP_DOCKER_IMG_BOOT_PRINT_BEFORE_BOOT_SCRIPTS}" "${@}"

	# 确认是否构建新容器
	## 容器不存在
	local _TMP_DOCKER_IMG_BOOT_PRINT_MARK_VER="${_TMP_DOCKER_IMG_BOOT_PRINT_VER}"
    local _TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID=$(echo "${_TMP_DOCKER_IMG_BOOT_PRINT_PS}" | grep ":${_TMP_DOCKER_IMG_BOOT_PRINT_VER}" | cut -d' ' -f1)
    if [ -z "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}" ]; then
		echo "${TMP_SPLITER2}"
		echo_style_text "Cannot found 'created container' from 'image'(<${1}>:[${_TMP_DOCKER_IMG_BOOT_PRINT_VER}]), start to [build] it"
		
		# 检测端口是否有占用
		bind_exchange_port "_TMP_DOCKER_IMG_BOOT_PRINT_CTN_OPN_PORT"
		# _TMP_DOCKER_IMG_BOOT_PRINT_ARGS=$(echo "${_TMP_DOCKER_IMG_BOOT_PRINT_ARGS}" | sed "s@${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_PORT_PAIR}@${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_OPN_PORT}:${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_INN_PORT}@g")
		_TMP_DOCKER_IMG_BOOT_PRINT_ARGS=${_TMP_DOCKER_IMG_BOOT_PRINT_ARGS//${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_PORT_PAIR}/${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_OPN_PORT}:${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_INN_PORT}}
		
		trim_str "_TMP_DOCKER_IMG_BOOT_PRINT_ARGS"
        # docker run -d -p ${TMP_DOCKER_SETUP_TEST_PS_PORT}:5000 training/webapp python app.py
		echo_style_text "Booting <${1}>:[${_TMP_DOCKER_IMG_BOOT_PRINT_VER}] by args && cmd↓:"
		echo "Args: ${_TMP_DOCKER_IMG_BOOT_PRINT_ARGS}"
		echo "Cmd: ${_TMP_DOCKER_IMG_BOOT_PRINT_CMD:-"None"}"

		# 挂载盘的情况下，此步会生成一个overlay
		# !!! 此处如不使用eval执行，当--label='x'存在时，会被重写成--label=''x''
        _TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID=$(eval "docker run -d ${_TMP_DOCKER_IMG_BOOT_PRINT_ARGS} ${1}:${_TMP_DOCKER_IMG_BOOT_PRINT_VER} ${_TMP_DOCKER_IMG_BOOT_PRINT_CMD}")

		if [ -z "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}" ]; then
			echo "${TMP_SPLITER2}"
			echo_style_text "Boot <${1}> failure, exit"
			return 0
		fi

		echo_style_text "Booted <${1}>:[${_TMP_DOCKER_IMG_BOOT_PRINT_VER}]('${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}'), starting print container info"

		if [ -a "${_TMP_DOCKER_IMG_BOOT_PRINT_NONE_PATH}.init.depend.sh" ]; then
			# 启动等待一次
			docker_container_boot_wait "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_OPN_PORT}" "Booting the image <${1}:[${_TMP_DOCKER_IMG_BOOT_PRINT_VER}]>([${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}]) to port '${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_OPN_PORT}', wait for a moment"

			echo "${TMP_SPLITER2}"
			echo_style_text "[View] the 'update dependency exec'↓:"
			docker cp ${_TMP_DOCKER_IMG_BOOT_PRINT_NONE_PATH}.init.depend.sh ${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}:/tmp
			# docker exec -u root -it ${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID} sh -c "apt-get update"
			# docker exec -u root -it ${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID} sh -c "sh /tmp/${_TMP_DOCKER_IMG_BOOT_PRINT_VER_SRC}.init.depend.sh"
			## 临时重新挂载
			docker_bash_channel_exec "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}" "mount -o remount,rw -o /" "d" "root"
			local _TMP_DOCKER_IMG_BOOT_PRINT_ISSUE=$(docker_bash_channel_exec "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}" "cat /etc/issue" "t")
			if [[ "${_TMP_DOCKER_IMG_BOOT_PRINT_ISSUE//Ubuntu/}" != "${_TMP_DOCKER_IMG_BOOT_PRINT_ISSUE}" || "${_TMP_DOCKER_CTN_PRINT_ISSUE//Debian/}" != "${_TMP_DOCKER_CTN_PRINT_ISSUE}" ]]; then
				docker_bash_channel_exec "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}" "apt-get update && apt-get -y install procps vim" "t"
			else
				if [ "${_TMP_DOCKER_IMG_BOOT_PRINT_ISSUE//Photon/}" != "${_TMP_DOCKER_IMG_BOOT_PRINT_ISSUE}" ]; then
					# docker_bash_channel_exec "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}" "cd /etc/yum.repos.d/ && sed -i 's/dl.bintray.com\/vmware/packages.vmware.com\/photon\/\$releasever/g' photon.repo photon-updates.repo photon-extras.repo photon-debuginfo.repo" "t"
					docker_bash_channel_exec "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}" "tdnf -y update" "t"
					# echo_style_text "'Photon' system, do nothing"
				elif [ "${_TMP_DOCKER_IMG_BOOT_PRINT_ISSUE//Alpine/}" != "${_TMP_DOCKER_IMG_BOOT_PRINT_ISSUE}" ]; then
					docker_bash_channel_exec "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}" "apk update" "t"
				else
					docker_bash_channel_exec "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}" "yum -y update && yum -y install procps vim" "t"
				fi
			fi
			docker_bash_channel_exec "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}" "sh /tmp/${_TMP_DOCKER_IMG_BOOT_PRINT_VER_SRC}.init.depend.sh" "t"
			
			# 停止，后续再启动，预防依赖生效问题
			echo "${TMP_SPLITER2}"
			echo_style_text "Starting restart the container of <${1}>:[${_TMP_DOCKER_IMG_BOOT_PRINT_VER}]('${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}')"
			docker stop ${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}
			docker start ${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}
		fi
    else
		echo "${TMP_SPLITER2}"
        echo_style_text "[Checked] the container of <${1}>:[${_TMP_DOCKER_IMG_BOOT_PRINT_VER}]('${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}') exists, ignore args&cmd, start boot it"
        docker start ${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}

        # 复原后，端口可能改变
        _TMP_DOCKER_IMG_BOOT_PRINT_CTN_OPN_PORT=$(docker port ${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID} | cut -d':' -f2 | awk 'NR==1')
    fi

	docker_container_boot_wait "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_OPN_PORT}" "Booting the image <${1}:[${_TMP_DOCKER_IMG_BOOT_PRINT_VER}]>([${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}]) to port '${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_OPN_PORT}', wait for a moment"
	
	# 启动状态异常则不往下走
	# "State": {
	# 	"Status": "restarting",
	# 	"Running": true,
	# 	"Paused": false,
	# 	"Restarting": true,
	# 	"OOMKilled": false,
	# 	"Dead": false,
	# 	"Pid": 0,
	# 	"ExitCode": 1,
	# 	"Error": "",
	# 	"StartedAt": "2023-01-18T06:56:26.225732513Z",
	# 	"FinishedAt": "2023-01-18T06:56:26.266309017Z"
	# }
	local _TMP_DOCKER_IMG_BOOT_PRINT_BOOT_STATUS=$(docker container inspect --format '{{.State.Status}}' ${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID})
	if [ "${_TMP_DOCKER_IMG_BOOT_PRINT_BOOT_STATUS}" != "running" ]; then
		echo "${TMP_SPLITER2}"
		echo_style_text "[Checked] the container of <${1}>:[${_TMP_DOCKER_IMG_BOOT_PRINT_VER}]('${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}') boot failure, please check by follow state info↓:"
		docker container inspect ${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID} | jq ".[0].State"
		return 0
	fi

    echo "${TMP_SPLITER2}"
	docker_container_print "${_TMP_DOCKER_IMG_BOOT_PRINT_CTN_ID}" "${6}"
	return $?
}

##########################################################################################################
# 安装操作类
##########################################################################################################
# 安装软件基础
# 参数1：软件安装打印名称
# 参数2：软件安装需调用的函数
function soft_setup_basic()
{
	local _TMP_SOFT_SETUP_BASIC_CURRENT_DIR=$(pwd)
	local _TMP_SOFT_SETUP_BASIC_PRINT_NAME="${1}"
	
	if [ -n "${2}" ]; then
		echo_style_wrap_text "Starting 'install' <${_TMP_SOFT_SETUP_BASIC_PRINT_NAME}>"

		local _TMP_SOFT_SETUP_BASIC_INSTALL_NAME="${1}"
		typeset -l _TMP_SOFT_SETUP_BASIC_INSTALL_NAME

		mkdir -pv ${DOWN_DIR} && cd ${DOWN_DIR}
		local _TMP_SOFT_SETUP_BASIC_PRINT_PARAMS=$(echo "${_TMP_SOFT_SETUP_BASIC_INSTALL_NAME} ${@:3}" | awk '$1=$1')
		echo_style_text "Starting <execute> 'scripts'([${2}]), params('${_TMP_SOFT_SETUP_BASIC_PRINT_PARAMS}')"
		
		script_check_action "${2}" "${_TMP_SOFT_SETUP_BASIC_INSTALL_NAME}" "${@:3}"

		echo_style_wrap_text "Install <${_TMP_SOFT_SETUP_BASIC_PRINT_NAME}> completed"

		cd ${_TMP_SOFT_SETUP_BASIC_CURRENT_DIR}
	fi

	return $?
}

# 路径不存在时下载软件
# 参数1：检测路径
# 参数2：软件下载地址
# 参数3：软件下载后执行函数名称
#       参数1：软件解压路径
# 示例：
#      path_check_wget_action "/opt/gum" "https://github.com/charmbracelet/gum/releases/download/v0.8.0/gum_0.8.0_linux_amd64.rpm" "exec_step_gum"
function path_check_wget_action()
{
	local _TMP_PATH_CHECK_WGET_CHECK_DIR=${1}
	local _TMP_PATH_CHECK_WGET_URL=${2}
	local _TMP_PATH_CHECK_WGET_EXEC_SCRIPT=${3}
	local _TMP_PATH_CHECK_WGET_CURR_DIR=$(pwd)
	
	function _path_check_wget()
	{
		local _TMP_PATH_CHECK_WGET_FILE_NAME=
		local _TMP_PATH_CHECK_WGET_FILE_DIR="${DOWN_DIR}"
		while_wget "${_TMP_PATH_CHECK_WGET_URL}" '_TMP_PATH_CHECK_WGET_FILE_DIR=$(pwd) && _TMP_PATH_CHECK_WGET_FILE_NAME=${_TMP_WHILE_WGET_FILE_DEST_NAME}'

		# 回到while_wget下载的目录中去
		cd ${_TMP_PATH_CHECK_WGET_FILE_DIR}

		local _TMP_PATH_CHECK_WGET_FILE_NAME_NO_EXTS="${DOWN_DIR}/tmp"
		local _TMP_PATH_CHECK_WGET_UNPACK_FILE_EXT=$(echo ${_TMP_PATH_CHECK_WGET_FILE_NAME##*.})
		if [ "${_TMP_PATH_CHECK_WGET_UNPACK_FILE_EXT}" = "zip" ]; then
			_TMP_PATH_CHECK_WGET_PACK_DIR_LINE=$(unzip -v ${_TMP_PATH_CHECK_WGET_FILE_NAME} | awk '/----/{print NR}' | awk 'NR==1{print}')
			local _TMP_PATH_CHECK_WGET_FILE_NAME_UNZIP=$(unzip -v ${_TMP_PATH_CHECK_WGET_FILE_NAME} | awk 'NR==LINE{print $NF}' LINE=$((_TMP_PATH_CHECK_WGET_PACK_DIR_LINE+1)))
			_TMP_PATH_CHECK_WGET_FILE_NAME_NO_EXTS=${_TMP_PATH_CHECK_WGET_FILE_NAME_UNZIP%/*}
			
			# 没有层级的情况
			local _TMP_PATH_CHECK_WGET_FILE_NAME_UNZIP_ARGS=""
			if [ "${_TMP_PATH_CHECK_WGET_FILE_NAME_UNZIP}" == "${_TMP_PATH_CHECK_WGET_FILE_NAME_NO_EXTS}" ]; then
				_TMP_PATH_CHECK_WGET_FILE_NAME_NO_EXTS="${_TMP_PATH_CHECK_WGET_LOWER_NAME}"
				_TMP_PATH_CHECK_WGET_FILE_NAME_UNZIP_ARGS="-d ${_TMP_PATH_CHECK_WGET_LOWER_NAME}"
			fi

			# 本地是否存在目录
			if [ ! -d "${_TMP_PATH_CHECK_WGET_FILE_NAME_NO_EXTS}" ]; then
				unzip -o ${_TMP_PATH_CHECK_WGET_FILE_NAME} ${_TMP_PATH_CHECK_WGET_FILE_NAME_UNZIP_ARGS}
			fi
		else
			_TMP_PATH_CHECK_WGET_FILE_NAME_NO_EXTS=$(tar -tf ${_TMP_PATH_CHECK_WGET_FILE_NAME} | grep '/' | awk 'NR==1{print}' | sed s@/.*@""@g)
			if [ ! -d "${_TMP_PATH_CHECK_WGET_FILE_NAME_NO_EXTS}" ]; then
				if [ "${_TMP_PATH_CHECK_WGET_UNPACK_FILE_EXT}" = "xz" ]; then
					xz -d ${_TMP_PATH_CHECK_WGET_FILE_NAME}
					local _TMP_PATH_CHECK_WGET_FILE_NAME_TAR=${_TMP_PATH_CHECK_WGET_FILE_NAME%%.xz*}
					tar -xvf ${_TMP_PATH_CHECK_WGET_FILE_NAME_TAR}
					rm -rf ${_TMP_PATH_CHECK_WGET_FILE_NAME_TAR}
				else
					tar -zxvf ${_TMP_PATH_CHECK_WGET_FILE_NAME}
				fi
			fi
		fi

		script_check_action "_TMP_PATH_CHECK_WGET_EXEC_SCRIPT" "$(pwd)/${_TMP_PATH_CHECK_WGET_FILE_NAME_NO_EXTS}"
		
		cd ${_TMP_PATH_CHECK_WGET_CURR_DIR}
	}
	
	path_not_exists_action "${_TMP_PATH_CHECK_WGET_CHECK_DIR}" "_path_check_wget"

	return $?
}

# 安装软件下载模式(公共)
# 参数1：软件安装名称
# 参数2：软件下载地址
# 参数3：安装检测路径
# 参数4：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数5：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数6-N：附加参数
# 示例：
#      soft_setup_common_wget "gum" "0.8.0" "exec_step_gum"
function soft_setup_common_wget() 
{
	local _TMP_SOFT_SETUP_COMMON_WGET_NAME=${1}
	# local _TMP_SOFT_SETUP_COMMON_WGET_MARK_NAME="${1/\//_}"
	local _TMP_SOFT_SETUP_COMMON_WGET_URL=${2}
	local _TMP_SOFT_SETUP_COMMON_WGET_DEPLOY_DIR=${3}
	local _TMP_SOFT_SETUP_COMMON_WGET_INSTALL_SCRIPT=${4}
	local _TMP_SOFT_SETUP_COMMON_WGET_INSTALLED_SCRIPT=${5}
	local _TMP_SOFT_SETUP_COMMON_WGET_EXTRA_DIR=
	local _TMP_SOFT_SETUP_COMMON_WGET_ATT_PARAMS=("${@:6}")
	
	function _soft_setup_common_wget()
	{
		_TMP_SOFT_SETUP_COMMON_WGET_EXTRA_DIR="${1}"
		script_check_action "_TMP_SOFT_SETUP_COMMON_WGET_INSTALL_SCRIPT" "${_TMP_SOFT_SETUP_COMMON_WGET_NAME}" "${_TMP_SOFT_SETUP_COMMON_WGET_DEPLOY_DIR}" "${1}" "${_TMP_SOFT_SETUP_COMMON_WGET_ATT_PARAMS[*]}"

		# 清理解压包
		if [ -n "${1}" ]; then
			rm -rf ${1}
		fi
	}

	path_check_wget_action "${_TMP_SOFT_SETUP_COMMON_WGET_DEPLOY_DIR}" "${_TMP_SOFT_SETUP_COMMON_WGET_URL}" "_soft_setup_common_wget"
    # ls -d ${_TMP_SOFT_SETUP_COMMON_WGET_DEPLOY_DIR} && $? -ne 0   #ps -fe | grep ${_TMP_SOFT_SETUP_COMMON_WGET_NAME} | grep -v grep
	if [ -z "${_TMP_SOFT_SETUP_COMMON_WGET_EXTRA_DIR}" ]; then
		script_check_action "_TMP_SOFT_SETUP_COMMON_WGET_INSTALLED_SCRIPT" "${_TMP_SOFT_SETUP_COMMON_WGET_NAME}" "${_TMP_SOFT_SETUP_COMMON_WGET_DEPLOY_DIR}" "${1}" "${_TMP_SOFT_SETUP_COMMON_WGET_ATT_PARAMS[*]}"
		return $?
	fi

	return $?
}

# 安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载地址
# 参数3：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数4：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数5-N：附加参数
# 示例：
#      soft_setup_wget "gum" "0.8.0" "exec_step_gum"
function soft_setup_wget() 
{
	typeset -l _TMP_SOFT_SETUP_WGET_LOWER_NAME
	local _TMP_SOFT_SETUP_WGET_LOWER_NAME=${1}
	local _TMP_SOFT_SETUP_WGET_DEPLOY_DIR=${SETUP_DIR}/${_TMP_SOFT_SETUP_WGET_LOWER_NAME}

	soft_setup_common_wget "${1}" "${2}" "${_TMP_SOFT_SETUP_WGET_DEPLOY_DIR}" "${3}" "${4}" "${@:5}"
	return $?
}

# 安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载地址
# 参数3：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数4：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数5-N：附加参数(5:版本号)
# 示例：
#      soft_setup_docker_wget "goharbor/harbor" "https://github.com/goharbor/harbor/releases/download/v1.10.17/harbor-offline-installer-v1.10.17.tgz" "exec_step_harbor"
function soft_setup_docker_wget() 
{
	local _TMP_SOFT_SETUP_DOCKER_WGET_MARK_NAME="${1/\//_}"
	
	typeset -l _TMP_SOFT_SETUP_DOCKER_WGET_LOWER_NAME
	local _TMP_SOFT_SETUP_DOCKER_WGET_LOWER_NAME=${1}
	local _TMP_SOFT_SETUP_DOCKER_WGET_DEPLOY_DIR=${DOCKER_APP_SETUP_DIR}/${_TMP_SOFT_SETUP_DOCKER_WGET_MARK_NAME}

	if [ -n "${5}" ]; then
		_TMP_SOFT_SETUP_DOCKER_WGET_DEPLOY_DIR=${_TMP_SOFT_SETUP_DOCKER_WGET_DEPLOY_DIR}/v${5}
	fi

	soft_setup_common_wget "${1}" "${2}" "${_TMP_SOFT_SETUP_DOCKER_WGET_DEPLOY_DIR}" "${3}" "${4}" "${@:5}"
	return $?
}

# 安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载地址
# 参数3：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数4：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数5-N：附加参数
# 示例：
#      soft_setup_conda_wget "browserless/chrome" "0.8.0" "exec_step_gum"
function soft_setup_conda_wget() 
{
	local _TMP_SOFT_SETUP_CONDA_WGET_NAME=${1}
	local _TMP_SOFT_SETUP_CONDA_WGET_MARK_NAME="${1/\//_}"
	
	typeset -l _TMP_SOFT_SETUP_CONDA_WGET_LOWER_NAME
	local _TMP_SOFT_SETUP_CONDA_WGET_LOWER_NAME=${_TMP_SOFT_SETUP_CONDA_WGET_NAME}
	local _TMP_SOFT_SETUP_CONDA_WGET_DEPLOY_DIR=${CONDA_APP_SETUP_DIR}/${_TMP_SOFT_SETUP_CONDA_WGET_MARK_NAME}

	soft_setup_common_wget "${1}" "${2}" "${_TMP_SOFT_SETUP_CONDA_WGET_DEPLOY_DIR}" "${3}" "${4}" "${@:5}"
	return $?
}

# 安装软件下载模式
# 参数1：软件安装名称
# 参数2：仓库名称，charmbracelet/gum
# 参数3：链接地址，https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm
# 参数4：默认版本，0.8.0
# 参数5：软件安装类型（docker,conda,空），默认普通
# 参数6：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：软件安装版本
# 参数7：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：软件安装版本
# 示例：
#      soft_setup_git_common_wget "gum" "charmbracelet/gum" "https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm" "0.8.0" "" "exec_step_gum"
function soft_setup_git_common_wget() 
{
	# 查找及确认版本
	local _TMP_SOFT_SETUP_GIT_COMMON_WGET_VER_NEWER="${4}"
	set_github_soft_releases_newer_version "_TMP_SOFT_SETUP_GIT_COMMON_WGET_VER_NEWER" "${2}"
	
	local _TMP_SOFT_SETUP_GIT_COMMON_WGET_NEWER_LINK="${_TMP_SOFT_SETUP_GIT_COMMON_WGET_VER_NEWER}"
	exec_text_printf "_TMP_SOFT_SETUP_GIT_COMMON_WGET_NEWER_LINK" "${3}"

	local _TMP_SOFT_SETUP_GIT_COMMON_WGET_FUNC_NAME="soft_setup_wget"
	if [ -n "${5}" ]; then
		_TMP_SOFT_SETUP_GIT_COMMON_WGET_FUNC_NAME="soft_setup_${5}_wget"
	fi
	
	${_TMP_SOFT_SETUP_GIT_COMMON_WGET_FUNC_NAME} "${1}" "${_TMP_SOFT_SETUP_GIT_COMMON_WGET_NEWER_LINK}" "${6}" "${7}" "${_TMP_SOFT_SETUP_GIT_COMMON_WGET_VER_NEWER}"
	
	return $?
}

# 安装软件下载模式
# 参数1：软件安装名称
# 参数2：仓库名称，charmbracelet/gum
# 参数3：链接地址，https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm
# 参数4：默认版本，0.8.0
# 参数5：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
# 参数6：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
# 示例：
#       soft_setup_git_wget "gum" "charmbracelet/gum" "https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm" "0.8.0" "exec_step_gum"
function soft_setup_git_wget() 
{
	soft_setup_git_common_wget "${1}" "${2}" "${3}" "${4}" "" "${5}" "${6}"
	
	return $?
}

# 安装软件下载模式
# 参数1：软件安装名称
# 参数2：仓库名称，charmbracelet/gum
# 参数3：链接地址，https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm
# 参数4：默认版本，0.8.0
# 参数5：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
# 参数6：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
# 示例：
#       soft_setup_docker_git_wget "gum" "charmbracelet/gum" "https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm" "0.8.0" "exec_step_gum"
function soft_setup_docker_git_wget() 
{
	soft_setup_git_common_wget "${1}" "${2}" "${3}" "${4}" "docker" "${5}" "${6}"
	
	return $?
}

# 安装软件下载模式
# 参数1：软件安装名称
# 参数2：仓库名称，charmbracelet/gum
# 参数3：链接地址，https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm
# 参数4：默认版本，0.8.0
# 参数5：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
# 参数6：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
# 示例：
#       soft_setup_conda_git_wget "gum" "charmbracelet/gum" "https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm" "0.8.0" "exec_step_gum"
function soft_setup_conda_git_wget() 
{
	soft_setup_git_common_wget "${1}" "${2}" "${3}" "${4}" "conda" "${5}" "${6}"
	
	return $?
}

# 安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载地址
# 参数3：安装检测路径
# 参数4：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数5：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数6-N：附加参数
# 示例：
#       soft_setup_common_git "" "" "" "" "" ""
function soft_setup_common_git() 
{
	local _TMP_SOFT_SETUP_COMMON_GIT_NAME=${1}
	local _TMP_SOFT_SETUP_COMMON_GIT_URL=${2}
	local _TMP_SOFT_SETUP_COMMON_GIT_DEPLOY_DIR=${3}
	local _TMP_SOFT_SETUP_COMMON_GIT_INSTALL_SCRIPTS=${4}
	local _TMP_SOFT_SETUP_COMMON_GIT_INSTALLED_SCRIPTS=${5}
	local _TMP_SOFT_SETUP_COMMON_GIT_ATT_PARAMS=("${@:6}")
	
	typeset -l TMP_SOFT_LOWER_NAME
	local TMP_SOFT_LOWER_NAME=${1}
	# local TMP_SOFT_DEPLOY_DIR=${SETUP_DIR}/${TMP_SOFT_LOWER_NAME}

	function _soft_setup_common_git() 
	{
		# local _TMP_SOFT_SETUP_COMMON_GIT_FOLDER_NAME=$(echo "${_TMP_SOFT_SETUP_COMMON_GIT_URL}" | awk -F'/' '{print $NF}')
		local _TMP_SOFT_SETUP_COMMON_GIT_FOLDER_NAME="${_TMP_SOFT_SETUP_COMMON_GIT_URL##*/}"

		mkdir -pv ${DOWN_DIR} && cd ${DOWN_DIR}
		if [ ! -d "${_TMP_SOFT_SETUP_COMMON_GIT_FOLDER_NAME}" ]; then
			git clone ${_TMP_SOFT_SETUP_COMMON_GIT_URL}
		fi
		
		cd ${_TMP_SOFT_SETUP_COMMON_GIT_FOLDER_NAME}

		# 安装函数调用
		script_check_action "${_TMP_SOFT_SETUP_COMMON_GIT_INSTALL_SCRIPTS}" "${_TMP_SOFT_SETUP_COMMON_GIT_NAME}" "${_TMP_SOFT_SETUP_COMMON_GIT_DEPLOY_DIR}" "$(pwd)" "${_TMP_SOFT_SETUP_COMMON_GIT_ATT_PARAMS[*]}"
		return $?
	}
	
	path_exists_yn_action "${3}" "${_TMP_SOFT_SETUP_COMMON_GIT_INSTALLED_SCRIPTS}" "_soft_setup_common_git"
	return $?
}

# 安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载地址
# 参数3：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数4：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数5-N：附加参数
function soft_setup_git() 
{
	typeset -l TMP_SOFT_SETUP_GIT_LOWER_NAME
	local TMP_SOFT_SETUP_GIT_LOWER_NAME=${1}
	local TMP_SOFT_SETUP_GIT_DEPLOY_DIR=${SETUP_DIR}/${TMP_SOFT_SETUP_GIT_LOWER_NAME}

	soft_setup_common_git "${1}" "${2}" "${TMP_SOFT_SETUP_GIT_DEPLOY_DIR}" "${3}" "${4}" "${@:5}"
	return $?
}

# 安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载地址
# 参数3：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数4：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数5-N：附加参数
function soft_setup_docker_git() 
{
	local TMP_SOFT_SETUP_DOCKER_GIT_NAME=${1}
	local TMP_SOFT_SETUP_DOCKER_GIT_MARK_NAME="${1/\//_}"

	typeset -l TMP_SOFT_SETUP_DOCKER_GIT_LOWER_NAME
	local TMP_SOFT_SETUP_DOCKER_GIT_LOWER_NAME=${TMP_SOFT_SETUP_DOCKER_GIT_MARK_NAME}
	local TMP_SOFT_SETUP_DOCKER_GIT_DEPLOY_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_SOFT_SETUP_DOCKER_GIT_LOWER_NAME}

	soft_setup_common_git "${1}" "${2}" "${TMP_SOFT_SETUP_DOCKER_GIT_DEPLOY_DIR}" "${3}" "${4}" "${@:5}"
	return $?
}

# 安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载地址
# 参数3：软件下载后执行函数名称
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数4：软件已安装执行函数
#       参数1：软件安装名称
#       参数2：软件安装路径
#       参数3：软件解压路径
#       参数4：附加参数等
# 参数5-N：附加参数
function soft_setup_conda_git() 
{
	local TMP_SOFT_SETUP_CONDA_GIT_NAME=${1}
	local TMP_SOFT_SETUP_CONDA_GIT_MARK_NAME="${1/\//_}"

	typeset -l TMP_SOFT_SETUP_CONDA_GIT_LOWER_NAME
	local TMP_SOFT_SETUP_CONDA_GIT_LOWER_NAME=${TMP_SOFT_SETUP_CONDA_GIT_MARK_NAME}
	local TMP_SOFT_SETUP_CONDA_GIT_DEPLOY_DIR=${CONDA_APP_SETUP_DIR}/${TMP_SOFT_SETUP_CONDA_GIT_LOWER_NAME}

	soft_setup_common_git "${1}" "${2}" "${TMP_SOFT_SETUP_CONDA_GIT_DEPLOY_DIR}" "${3}" "${4}" "${@:5}"
	return $?
}

# # PIP安装软件下载模式
# # 参数1：软件安装名称
# # 参数2：软件下载后执行函数名称
# # 参数3：pip版本，默认2
# function soft_setup_pip() 
# {

# 	local _TMP_SOFT_SETUP_PIP_NAME=$(echo "${1}" | awk -F',' '{print $1}')
# 	local _TMP_SOFT_SETUP_PIP_SETUP_FUNC=${2}
# 	local _TMP_SOFT_SETUP_PIP_VERS=${3:-2}
	
# 	# 版本2为linux系统默认自带，所以未装py3时判断
# 	if [ ${_TMP_SOFT_SETUP_PIP_VERS} -eq 2 ] && [ ! -f "/usr/bin/pip" ]; then
# 		while_curl "https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py" "python get-pip.py && rm -rf get-pip.py"
# 		pip install --upgrade pip
# 		pip install --upgrade setuptools
		
# 		local TMP_PY_DFT_SETUP_PATH=$(pip show pip | grep "Location" | awk -F' ' '{print $2}')
# 		mv ${TMP_PY_DFT_SETUP_PATH} ${PY_PKGS_DEPLOY_DIR}
# 		ln -sf ${PY_PKGS_DEPLOY_DIR} ${TMP_PY_DFT_SETUP_PATH}
# 	fi

# 	typeset -l TMP_SOFT_LOWER_NAME
# 	local TMP_SOFT_LOWER_NAME=${_TMP_SOFT_SETUP_PIP_NAME}
# 	local TMP_SOFT_DEPLOY_DIR=$(pip show ${TMP_SOFT_LOWER_NAME} | grep "Location" | awk -F' ' '{print $2}' | xargs -I {} echo "{}/${TMP_SOFT_LOWER_NAME}")

# 	# pip show supervisor
# 	# pip freeze | grep "supervisor=="
# 	if [ -z "${TMP_SOFT_DEPLOY_DIR}" ]; then
# 		echo_style_text "Pip start to install '${_TMP_SOFT_SETUP_PIP_NAME}'"
# 		pip install ${TMP_SOFT_LOWER_NAME}
# 		echo_style_text "Pip installed '${_TMP_SOFT_SETUP_PIP_NAME}'"

# 		#安装后配置函数
# 		script_check_action "_TMP_SOFT_SETUP_PIP_SETUP_FUNC" "${PY_PKGS_DEPLOY_DIR}/${TMP_SOFT_LOWER_NAME}"
# 	else
#     	ls -d ${TMP_SOFT_DEPLOY_DIR}   #ps -fe | grep ${_TMP_SOFT_SETUP_PIP_NAME} | grep -v grep

# 		return 1
# 	fi

# 	return $?
# }

# PIP安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件安装后，在管道中执行的脚本
# 参数3：软件安装版本
# 参数4：软件安装环境，默认取全局变量${PY_ENV}
# 示例：
#	   soft_setup_conda_channel_pip "playwright" "export DISPLAY=:0 && playwright install"
function soft_setup_conda_channel_pip() 
{
	local _TMP_SOFT_SETUP_CONDA_PIP_SETUP_SCRIPTS=${2:-"echo"}
	local _TMP_SOFT_SETUP_CONDA_PIP_ENV=${4:-"${PY_ENV}"}
	
	local _TMP_SOFT_SETUP_CONDA_PIP_PKG_FULL_NAME=${1}
	if [ -n "${3}" ]; then
		_TMP_SOFT_SETUP_CONDA_PIP_PKG_FULL_NAME="${1}==${3}"
	fi

	local _TMP_SOFT_SETUP_CONDA_PIP_SETUP_PATH=$(su_bash_env_conda_channel_exec "pip show ${1} 2>/dev/null | grep -oP '(?<=^Location: ).+' | xargs -I {} echo '{}/${1}'" "${_TMP_SOFT_SETUP_CONDA_PIP_ENV}")
	
	echo_style_wrap_text "Checking 'conda' pip package <${1}> from venv [${_TMP_SOFT_SETUP_CONDA_PIP_ENV}]"
	if [ -z "${_TMP_SOFT_SETUP_CONDA_PIP_SETUP_PATH}" ]; then
		echo_style_text "Starting 'install' the 'conda' pip package <${1}> to venv [${_TMP_SOFT_SETUP_CONDA_PIP_ENV}]"
		echo ${TMP_SPLITER2}
		su_bash_env_conda_channel_exec "pip install ${_TMP_SOFT_SETUP_CONDA_PIP_PKG_FULL_NAME} && ${_TMP_SOFT_SETUP_CONDA_PIP_SETUP_SCRIPTS}" "${_TMP_SOFT_SETUP_CONDA_PIP_ENV}"
		echo ${TMP_SPLITER3}
		echo_style_text "Pip package installed '${1}' to venv [${_TMP_SOFT_SETUP_CONDA_PIP_ENV}]"
	else
		echo_style_text "Pip package '${1}' from venv [${_TMP_SOFT_SETUP_CONDA_PIP_ENV}] exists in [${_TMP_SOFT_SETUP_CONDA_PIP_SETUP_PATH}]"
		su_bash_env_conda_channel_exec "pip list | grep '${1}'" "${_TMP_SOFT_SETUP_CONDA_PIP_ENV}"

		return 1
	fi
	
	return $?
}

# PIP安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件安装后，执行的脚本
#       参数1：安装包名称
#       参数2：安装包版本
#       参数3：安装包环境
#       参数4：安装路径
# 参数3：软件安装版本
# 参数4：软件安装环境，默认取全局变量${PY_ENV}
# 示例：
#	   soft_setup_conda_pip "playwright" "export DISPLAY=:0 && playwright install"
function soft_setup_conda_pip() 
{
	local _TMP_SOFT_SETUP_CONDA_PIP_SETUP_SCRIPTS=${2:-"echo"}
	local _TMP_SOFT_SETUP_CONDA_PIP_ENV=${4:-"${PY_ENV}"}
	
	local _TMP_SOFT_SETUP_CONDA_PIP_PKG_FULL_NAME=${1}
	if [ -n "${3}" ]; then
		_TMP_SOFT_SETUP_CONDA_PIP_PKG_FULL_NAME="${1}==${3}"
	fi

	local _TMP_SOFT_SETUP_CONDA_PIP_SETUP_PATH=$(su_bash_env_conda_channel_exec "pip show ${1} 2>/dev/null | grep -oP '(?<=^Location: ).+' | xargs -I {} echo '{}/${1}'" "${_TMP_SOFT_SETUP_CONDA_PIP_ENV}")
	
	echo_style_wrap_text "Checking <conda> pip package '${1}' from venv [${_TMP_SOFT_SETUP_CONDA_PIP_ENV}]"
	if [ -z "${_TMP_SOFT_SETUP_CONDA_PIP_SETUP_PATH}" ]; then
		echo_style_text "Starting <install> the <conda> pip package '${1}' to venv [${_TMP_SOFT_SETUP_CONDA_PIP_ENV}]"
		echo ${TMP_SPLITER2}
		su_bash_env_conda_channel_exec "pip install ${_TMP_SOFT_SETUP_CONDA_PIP_PKG_FULL_NAME}" "${_TMP_SOFT_SETUP_CONDA_PIP_ENV}"
		echo ${TMP_SPLITER2}
		echo_style_text "Pip package installed '${1}' to venv [${_TMP_SOFT_SETUP_CONDA_PIP_ENV}]"
		echo

		#安装后配置函数
		local _TMP_SOFT_SETUP_CONDA_PIP_SHOW=$(su_bash_env_conda_channel_exec "pip show ${1} 2>/dev/null" "${_TMP_SOFT_SETUP_CONDA_PIP_ENV}")
		local _TMP_SOFT_SETUP_CONDA_PIP_SETUP_VER=${3:-$(echo "${_TMP_SOFT_SETUP_CONDA_PIP_SHOW}" | grep 'Version' | awk '{print $2}')}
		local _TMP_SOFT_SETUP_CONDA_PIP_SETUP_PATH=$(echo "${_TMP_SOFT_SETUP_CONDA_PIP_SHOW}" | grep 'Location' | awk '{print $2}')
		script_check_action "${2}" "${1}" "${_TMP_SOFT_SETUP_CONDA_PIP_SETUP_VER}" "${_TMP_SOFT_SETUP_CONDA_PIP_ENV}" "${_TMP_SOFT_SETUP_CONDA_PIP_SETUP_PATH}/${1}"
	else
		echo_style_text "Pip package '${1}' from venv [${_TMP_SOFT_SETUP_CONDA_PIP_ENV}] exists in [${_TMP_SOFT_SETUP_CONDA_PIP_SETUP_PATH}]"
		su_bash_env_conda_channel_exec "pip list | grep '${1}'" "${_TMP_SOFT_SETUP_CONDA_PIP_ENV}"

		return 1
	fi
	
	return $?
}

#安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载后执行函数名称
# 参数3：指定node版本（node有兼容性问题）
function soft_setup_npm() 
{
	local _TMP_SOFT_SETUP_NPM_NAME=$(echo "${1}" | awk -F',' '{print $1}')
	local _TMP_SOFT_SETUP_NPM_PATH=$(echo "${1}" | awk -F',' '{print $NF}')
	local _TMP_SOFT_SETUP_NPM_FUNC=${2}
	local _TMP_SOFT_NPM_NODE_VERS=${3}
	
	typeset -l _TMP_SOFT_SETUP_NPM_NAME_LOWER
	local _TMP_SOFT_SETUP_NPM_NAME_LOWER=${_TMP_SOFT_SETUP_NPM_NAME}

	# 提前检查命令是否存在
	source ${__DIR}/scripts/lang/nodejs.sh

	npm install -g npm@next
	npm audit fix

	# 指定版本
	if [ -n "${_TMP_SOFT_NPM_NODE_VERS}" ]; then
		nvm install ${_TMP_SOFT_NPM_NODE_VERS}
		nvm use ${_TMP_SOFT_NPM_NODE_VERS}
	else
		_TMP_SOFT_NPM_NODE_VERS=$(nvm current)
	fi

	local _TMP_SOFT_SETUP_NPM_INFO=$(npm list -g --depth 0 | grep -o ${_TMP_SOFT_SETUP_NPM_NAME_LOWER}.*)
	# 在当前指定安装版本的目录下找是否安装
	local _TMP_SOFT_SETUP_NPM_DIR=$(dirname $(npm config get prefix))/${_TMP_SOFT_NPM_NODE_VERS}/lib/node_modules/${_TMP_SOFT_SETUP_NPM_NAME_LOWER}

	if [ -z "${_TMP_SOFT_SETUP_NPM_INFO}" ]; then
		npm update

		echo "Npm start to install ${_TMP_SOFT_SETUP_NPM_NAME}"
	
		# 谨防网速慢的情况，重复安装
		while [ ! -d "${_TMP_SOFT_SETUP_NPM_DIR}" ]; do
			npm cache clean --force
			npm install --verbose -g ${_TMP_SOFT_SETUP_NPM_NAME}
		done
		
		echo "Npm installed ${_TMP_SOFT_SETUP_NPM_NAME}"

		#安装后配置函数
		${_TMP_SOFT_SETUP_NPM_FUNC} "${_TMP_SOFT_SETUP_NPM_DIR}" "${_TMP_SOFT_NPM_NODE_VERS}"
	else
    	echo ${_TMP_SOFT_SETUP_NPM_INFO}

		return 1
	fi

	return $?
}

# 循环检测后YN执行（基于命令检测执行脚本，无备份操作）
# 参数1：循环选项（列表），例如具体的cmd命令、yum包名、npm包名等
# 参数2：命令检测脚本，以该脚本的输出为YN指向执行脚本
# 参数3：检测已存在时执行脚本名称，例如提示、更新
# 参数4：检测不存在时默认的执行脚本，例如安装
# 参数5：选项类型注释，例如command/yum/npm。默认command
# 示例：
# 	 soft_check_yn_action "vim,wget" "yum list installed | grep %s" "echo '%s exists'" "yum -y install %s"
function soft_check_yn_action() 
{
	local _TMP_SOFT_CHECK_YN_ACTION_CHECK_ITEMS="${1}"
    local _TMP_SOFT_CHECK_YN_ACTION_CHECK_SCRIPT="${2}"
    local _TMP_SOFT_CHECK_YN_ACTION_Y_SCRIPT="${3}"
	local _TMP_SOFT_CHECK_YN_ACTION_N_SCRIPT="${4}"
    local _TMP_SOFT_CHECK_YN_ACTION_TYPE_ECHO="${5:-command}"

	function _soft_check_yn_action()
	{
		local _TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM=${1}
		local _TMP_SOFT_CHECK_YN_ACTION_FINAL_CHECK_SCRIPT=${1}
		exec_text_printf "_TMP_SOFT_CHECK_YN_ACTION_FINAL_CHECK_SCRIPT" "${_TMP_SOFT_CHECK_YN_ACTION_CHECK_SCRIPT}"

		local _TMP_SOFT_CHECK_YN_ACTION_FINAL_Y_SCRIPT=${1}
		exec_text_printf "_TMP_SOFT_CHECK_YN_ACTION_FINAL_Y_SCRIPT" "${_TMP_SOFT_CHECK_YN_ACTION_Y_SCRIPT}"

		local _TMP_SOFT_CHECK_YN_ACTION_FINAL_N_SCRIPT=${1}
		exec_text_printf "_TMP_SOFT_CHECK_YN_ACTION_FINAL_N_SCRIPT" "${_TMP_SOFT_CHECK_YN_ACTION_N_SCRIPT}"
		
        echo_style_wrap_text "Checking <${_TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM}> from '${_TMP_SOFT_CHECK_YN_ACTION_TYPE_ECHO}'"
		
		# 获取判断响应
		local _TMP_SOFT_CHECK_YN_ACTION_RES=$(script_check_action '_TMP_SOFT_CHECK_YN_ACTION_FINAL_CHECK_SCRIPT' ${_TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM})
		
		# 不存在命令时执行
        # echo ${TMP_SPLITER2}
		if [ -z "${_TMP_SOFT_CHECK_YN_ACTION_RES}" ]; then
			# echo_style_text "[Checked] the '${_TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM}' not found"
			script_check_action "_TMP_SOFT_CHECK_YN_ACTION_FINAL_N_SCRIPT" ${_TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM}
		else
			# echo_style_text "[Checked] the '${_TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM}' found"
			script_check_action "_TMP_SOFT_CHECK_YN_ACTION_FINAL_Y_SCRIPT" ${_TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM}
		fi
	}
	
    items_split_action "${_TMP_SOFT_CHECK_YN_ACTION_CHECK_ITEMS}" "_soft_check_yn_action"

	return $?
}

# 命令检测后执行（基于命令检测执行脚本，无备份操作）
# 参数1：命令名称(列表)
# 参数2：命令不存在时默认的 执行安装/更新脚本
# 参数3：命令已存在时执行脚本名称
# 示例：
# 	 soft_cmd_check_action "vim,wget" "yum -y install %s" "echo '%s exists'"
function soft_cmd_check_action() 
{
	function _soft_cmd_check_action_echo()
	{
		local _TMP_SOFT_CMD_CHECK_ACTION_ECHO_CMD_TYPE=$(su_bash_env_channel_exec "type -t ${1}")
		local _TMP_SOFT_CMD_CHECK_ACTION_ECHO_CMD_WHERE=$(su_bash_env_channel_exec "whereis ${1}")

		echo "${_TMP_SOFT_CMD_CHECK_ACTION_ECHO_CMD_TYPE}${_TMP_SOFT_CMD_CHECK_ACTION_ECHO_CMD_WHERE/${1}:/}"
	}

	soft_check_yn_action "${1}" "_soft_cmd_check_action_echo" "${3}" "${2}"
	return $?
}

# 命令检测后安装，存在时覆盖安装（基于github仓库二进制安装包，无备份操作）
# 参数1：命令名称，gum
# 参数2：仓库名称，charmbracelet/gum
# 参数3：链接地址，https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm
# 参数4：默认版本，0.8.0
# 参数5：命令不存在时，执行脚本，rpm -ivh gum_%s_linux_amd64.rpm
# 参数6：命令存在时，执行脚本，例如可以定义提示是否覆盖安装类的操作
# 参数7：动作类型描述，action/install/reinstall
# 示例：
#     soft_cmd_check_git_action "gum" "charmbracelet/gum" "https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm" "0.8.0" "rpm -ivh gum_%s_linux_amd64.rpm" ''
function soft_cmd_check_git_action() 
{
	local _TMP_SOFT_CMD_CHECK_GIT_ACTION_E_SCRIPT="${6:-'_soft_cmd_check_git_action_echo'}"
	local _TMP_SOFT_CMD_CHECK_GIT_ACTION_TYPE_DESC="${7:-install}"

	# 命令不存在时，执行函数
	local _TMP_SOFT_CMD_CHECK_GIT_ACTION_PARAMS=("${@:2:5}")
	function _soft_cmd_check_git_action()
	{
		script_check_action 'soft_cmd_check_git_down_action' "${1}" "${_TMP_SOFT_CMD_CHECK_GIT_ACTION_PARAMS[@]}"
		echo "${TMP_SPLITER2}"
		echo_style_text "The soft command of <${1}> from [git] has ${_TMP_SOFT_CMD_CHECK_GIT_ACTION_TYPE_DESC}ed"
	}

	# 命令不存在时，执行的默认函数
	function _soft_cmd_check_git_action_echo()
	{
		# 此处如果是取用变量而不是实际值，则split_action中的printf不会进行格式化
		# print "${_SOFT_CMD_CHECK_GIT_ACTION_CMD_STD}" "${_TMP_SOFT_CMD_CHECK_SETUP}"
		echo_style_text "The soft command of <${1}> from [git] was ${_TMP_SOFT_CMD_CHECK_GIT_ACTION_TYPE_DESC}ed"
	}
	
	soft_cmd_check_action "${1}" "_soft_cmd_check_git_action" "${_TMP_SOFT_CMD_CHECK_GIT_ACTION_E_SCRIPT}"
	return $?
}

# 检测命令，并从仓库下载最新版执行
# 参数1：命令名称，用于检测
# 参数2：仓库名称，charmbracelet/gum
# 参数3：链接地址，https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm
# 参数4：默认版本，0.8.0
# 参数5：下载后执行脚本
function soft_cmd_check_git_down_action()
{
	local _TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_CMD="${1}"
	local _TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_REPO="${2}"
	local _TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_VER="${4}"

	set_github_soft_releases_newer_version "_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_VER" "${_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_REPO}"

	local _TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_DOWN="${_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_VER}"
	local _TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_SCRIPT="${_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_VER}"
	
	exec_text_printf "_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_DOWN" "${3}"
	exec_text_printf "_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_SCRIPT" "${5}"

	echo_style_text "Starting 'execute' <script>('${_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_SCRIPT}')"

	while_wget "--content-disposition ${_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_DOWN}" "${_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_SCRIPT}"
	# echo_style_text '[Command] of <${1}> installed'
	return $?
}

# 命令检测后安装，存在时提示覆盖安装（基于github仓库二进制安装包，无备份操作）
# 参数1：命令名称，gum
# 参数2：仓库名称，charmbracelet/gum
# 参数3：链接地址，https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm
# 参数4：默认版本，0.8.0
# 参数5：安装脚本，rpm -ivh gum_%s_linux_amd64.rpm
# 参数6：动作类型描述，action/install
# 示例：
#     soft_cmd_check_confirm_git_action "gum" "charmbracelet/gum" "https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm" "0.8.0" "rpm -ivh gum_%s_linux_amd64.rpm" ''
function soft_cmd_check_confirm_git_action() 
{
	# local _TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_CMD="${1}"
	local _TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC="${6:-install}"

	local _TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_PARAMS=("${@:2:5}")
	function _soft_cmd_check_confirm_git_action()
	{
		function __soft_cmd_check_confirm_git_action()
		{
			script_check_action 'soft_cmd_check_git_down_action' "${1}" "${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_PARAMS[@]}"

			echo "${TMP_SPLITER2}"
			echo_style_text "Command(<${1}>-'git') was re${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC}ed"
		}

		local _TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_YN_REINSTALL="N"
		confirm_yn_action "_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_YN_REINSTALL" "Checked 'command'(<${1}>-'git') was ${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC}ed, please 'sure' u will [re${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC}] 'still or not'" "__soft_cmd_check_confirm_git_action '${1}'" "echo_style_text \"Checked 'command'(<${1}>-'git') was ${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC}ed\""
	}

	soft_cmd_check_git_action "${1}" "${2}" "${3}" "${4}" "${5}" "_soft_cmd_check_confirm_git_action"
	return $?
}

# 命令检测后安装，存在时提示覆盖安装（基于github仓库二进制安装包，且调用时具有备份提示操作）
# 参数1：命令名称，用于检测
# 参数2：仓库名称，charmbracelet/gum
# 参数3：链接地址，https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm
# 参数4：默认版本，0.8.0
# 参数5：重装选择Y时 或命令不存在时默认的 执行安装/更新脚本
# 参数6：重装选择N时 或命令已存在时执行脚本名称
# 参数7：执行清理备份后自定义命令，例如卸载
# 参数8：动作类型描述，action/install
# 示例：
#     soft_cmd_check_git_upgrade_action "gum" "charmbracelet/gum" "https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm" "0.8.0" "rpm -ivh gum_%s_linux_amd64.rpm" 'gum update'
function soft_cmd_check_git_upgrade_action() 
{
	local _TMP_SOFT_CMD_CHECK_GIT_UPGRADE_ACTION_CMD="${1}"
	local _TMP_SOFT_CMD_CHECK_GIT_UPGRADE_ACTION_PARAMS=("${@:2:5}")
	local _TMP_SOFT_CMD_CHECK_GIT_UPGRADE_ACTION_TYPE_DESC="${8:-install}"

	function _soft_cmd_check_git_upgrade_action()
	{
		script_check_action 'soft_cmd_check_git_down_action' "${1}" "${_TMP_SOFT_CMD_CHECK_GIT_UPGRADE_ACTION_PARAMS[@]}"

		echo_style_text "The command of <${1}> from [git] by upgrade ${2:-"has "}${_TMP_SOFT_CMD_CHECK_GIT_UPGRADE_ACTION_TYPE_DESC}ed"
	}

	script_check_action 'soft_cmd_check_upgrade_action' "${1}" "_soft_cmd_check_git_upgrade_action" "${6}" "${7}"
	return $?
}

# 命令检测后安装，存在时提示覆盖安装（基于所有命令检测类型的安装，并具有备份提示操作）
# 参数1：命令名称，用于检测
# 参数2：重装选择Y时 或命令不存在时默认的 执行安装/更新脚本
# 参数3：重装选择N时 或命令已存在时执行脚本名称
# 参数4：执行清理备份后自定义命令，例如卸载
# 参数5：动作类型描述，action/install
# 示例：
#     soft_cmd_check_upgrade_action "conda" "exec_step_conda" "conda update -y conda"
function soft_cmd_check_upgrade_action() 
{
	local _TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CHECK_COMMAND="${1}"
    local _TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_NE_SCRIPT="${2}"
	local _TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_E_SCRIPT="${3}"
    local _TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CUS_SCRIPT="${4}"
	local _TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_TYPE_DESC="${5:-install}"
    
	function _soft_cmd_check_upgrade_action_exec()
	{
		# 当前操作软件名称(此处实际是对应的命令，因管道运行，故不做干扰)
		local _TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT=${1}

		# 卸载找到的关联包
		function _soft_cmd_check_upgrade_action_exec_remove()
		{
			# 重装先确认备份，默认备份
			## Please sure the soft of 'conda' u will 'backup check still or not'?
			local _TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_BACKUP_Y_N="Y"
			confirm_yn_action "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_BACKUP_Y_N" "Please sure soft 'command'(<${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}>) u will [backup check] 'still or not'"

			# 是否强制删除这里取反，soft_trail_clear参数需要
			local _TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_FORCE_TRAIL_Y_N="${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_BACKUP_Y_N}"
			bind_exchange_yn_val "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_FORCE_TRAIL_Y_N"

			# 卸载包前检测，备份残留或NO
			soft_trail_clear "${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}" "${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_FORCE_TRAIL_Y_N}"
			
			# 执行备份后自定义命令
			script_check_action "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CUS_SCRIPT" "${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}"

			# 执行安装			
			script_check_action "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_NE_SCRIPT" "${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}" "was re"
		}
		
		# 提示是否重装的值，默认不重装
		local _TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_REINSTALL_Y_N="N"
		## 检测到软件已安装，确认重装或不重装。
		## 例如：Checked the soft of 'conda' exists, please sure u will 'reinstall still or not'?
		confirm_yn_action "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_REINSTALL_Y_N" "Checked soft 'command'(<${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}>) was ${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_TYPE_DESC}ed, please 'sure' u will <re${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_TYPE_DESC}> 'still or not'" "_soft_cmd_check_upgrade_action_exec_remove" "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_E_SCRIPT" "${_NTMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}"
	}

	# 检测执行，未安装则运行外部安装脚本（exec_step_conda），已安装则运行内部函数(_soft_cmd_check_upgrade_action_exec)进行安装还原操作
	soft_cmd_check_action "${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CHECK_COMMAND}" "${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_NE_SCRIPT}" "_soft_cmd_check_upgrade_action_exec"
	return $?
}

# Rpm不存在执行
# 参数1：包名称
# 参数2：执行函数名称
# 参数3：包存在时输出信息
function soft_rpm_check_action() 
{
	local _TMP_SOFT_RPM_CHECK_ACTION_SOFT=${1}
	local _TMP_SOFT_RPM_CHECK_ACTION_SCRIPT=${2}

    local _TMP_SOFT_RPM_CHECK_ACTION_RPM_FIND_RESULTS=$(rpm -qa | grep ${_TMP_SOFT_RPM_CHECK_ACTION_SOFT})
	if [ -z "${_TMP_SOFT_RPM_CHECK_ACTION_RPM_FIND_RESULTS}" ]; then
		${_TMP_SOFT_RPM_CHECK_ACTION_SCRIPT}
	else
		echo ${3}

		return 0;
	fi

	return $?
}

# Yum包检测后执行
# 参数1：包名称（列表）
# 参数2：重装选择Y时 或包不存在时默认的 执行安装/更新脚本
# 参数3：重装选择N时 或包已存在时执行脚本名称
# 参数4：动作类型描述，action/install
# 示例：
# 	 soft_yum_check_action "vvv" "yum -y install %s" "echo '%s exists'"
# 	 soft_yum_check_action "sss" "test"
# 	 soft_yum_check_action "wget,vim" "echo '%s setup'"
function soft_yum_check_action() 
{
	local _TMP_SOFT_YUM_CHECK_ACTION_TYPE_DESC="${4:-install}"
	# 用于检测是否存在安装残留，可能文件存在，实际未安装
	# if [ "${FUNCNAME[4]}" != "soft_yum_check_setup" ]; then
	# 	soft_trail_clear "${_TMP_SOFT_YUM_CHECK_ACTION_CURRENT_SOFT_NAME}" "N"
	# fi
    soft_check_yn_action "${1}" "yum list installed | awk '{print \$1}' | grep '%s'" "${3}" "${2}" "yum ${_TMP_SOFT_YUM_CHECK_ACTION_TYPE_DESC}ed repos"
	return $?
}

# Yum包检测后安装
# 参数1：包名称
# 参数2：包存在时输出信息
# 示例：
#     soft_yum_check_setup "vvv" "%s exists"
#     soft_yum_check_setup "wget,vim" "%s exists"
function soft_yum_check_setup() 
{
	local _TMP_SOFT_YUM_CHECK_SETUP_SOFTS=${1}
	local _TMP_SOFT_YUM_CHECK_SETUP_SOFT_STD=${2}
    
	function _soft_yum_check_setup_echo()
	{
		local _TMP_SOFT_YUM_CHECK_SETUP_CURRENT_SOFT_NAME=${1}

		# 此处如果是取用变量而不是实际值，则split_action中的printf不会进行格式化
		# print "${_TMP_SOFT_YUM_CHECK_SETUP_SOFT_STD}" "${_TMP_SOFT_YUM_CHECK_SETUP}"
		echo_style_text "${_TMP_SOFT_YUM_CHECK_SETUP_SOFT_STD:-"Soft <${_TMP_SOFT_YUM_CHECK_SETUP_CURRENT_SOFT_NAME}> 'exists' in 'yum local'"}"
	}

	soft_yum_check_action "${_TMP_SOFT_YUM_CHECK_SETUP_SOFTS}" "yum -y -q install %s && echo_style_text 'Soft <%s> has installed by \'yum\''" "_soft_yum_check_setup_echo"
	return $?
}

# Yum包检测后安装，存在时提示覆盖安装
# 参数1：包名称
# 参数2：重装选择Y时 或包不存在时默认的 执行安装/更新脚本
# 参数3：重装选择N时 或包已存在时执行脚本名称
# 参数4：动作类型描述，action/install
# 示例：
#     soft_yum_check_upgrade_action "docker" "exec_step_docker" "yum -y update docker"
function soft_yum_check_upgrade_action() 
{
	local _TMP_SOFT_YUM_CHECK_UPGRADE_ACTION_TYPE_DESC="${4:-install}"

	function _soft_yum_check_upgrade_action_remove()
	{
		local _TMP_SOFT_YUM_CHECK_UPGRADE_ACTION_CURRENT_SOFT=${1}

		echo_style_wrap_text "Starting 'remove' yum repo of <${_TMP_SOFT_YUM_CHECK_UPGRADE_ACTION_CURRENT_SOFT}>"

		# 清理安装包，删除空行（cut -d可能带来空行）
		yum list installed | grep ${_TMP_SOFT_YUM_CHECK_UPGRADE_ACTION_CURRENT_SOFT} >> ${SETUP_DIR}/yum_remove_list.log
		yum list installed | grep ${_TMP_SOFT_YUM_CHECK_UPGRADE_ACTION_CURRENT_SOFT} | cut -d' ' -f1 | grep -v '^$' | xargs -I {} yum -y remove {}

		echo_style_text "The yum repo of '${_TMP_SOFT_YUM_CHECK_UPGRADE_ACTION_CURRENT_SOFT}' was removed"
		
		# 执行安装
		## 更新包
		soft_yum_check_setup "yum-utils"
		yum-complete-transaction --cleanup-only
		yum -y update && yum makecache fast

	}
    
	soft_cmd_check_upgrade_action "${1}" "${2}" "${3}" "_soft_yum_check_upgrade_action_remove" "${_TMP_SOFT_YUM_CHECK_UPGRADE_ACTION_TYPE_DESC}"
	return $?
}

# Npm不存在执行
# 参数1：包名称
# 参数2：执行函数名称
# 参数3：包存在时输出信息
# 参数4：模式
function soft_npm_check_action() 
{
	local _TMP_SOFT_NPM_CHECK_ACTION_SOFT=${1}
	local _TMP_SOFT_NPM_CHECK_ACTION_SOFT_SCRIPT=${2}
	local _TMP_SOFT_NPM_CHECK_ACTION_MODE=${4}

    local _TMP_SOFT_NPM_CHECK_ACTION_FIND_RESULTS=$(npm list --depth=0 ${_TMP_SOFT_NPM_CHECK_ACTION_MODE} | grep ${_TMP_SOFT_NPM_CHECK_ACTION_SOFT})
	if [ -z "${_TMP_SOFT_NPM_CHECK_ACTION_FIND_RESULTS}" ]; then
		${_TMP_SOFT_NPM_CHECK_ACTION_SOFT_SCRIPT}
	else
		echo "${3}"

		return 0
	fi

	return $?
}

# Docker镜像安装及检测增量操作
# 参数1：安装脚本
# 参数2：安装后执行脚本
function soft_docker_setup_increase_check_action()
{
	# 查找已安装docker 镜像，先做标记。用于判定是否有新增镜像
	local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_BEFORE_IMG_IDS=$(docker images | awk 'NR>1{print $3}')

	script_check_action "${1}"

	local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_LOOP_SCRIPT=${2}

	echo "${TMP_SPLITER}"

	# 执行安装脚本后的镜像
	local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_AFTER_IMG_IDS=$(docker images | awk 'NR>1{print $3}')

	# 差异镜像ID集合
	# 10a
	# 20ae43758ae7
	# .
	# local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_IDS=($(diff -e <(echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_BEFORE_IMG_IDS}") <(echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_AFTER_IMG_IDS}") | awk 'NR>1{if(line!=""){print line}{line=$0}}'))

	# 10a
	# 20ae43758ae7
	# .
	# 9a
	# cd66005c15eb
	# .
	local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_IDS=($(diff -e <(echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_BEFORE_IMG_IDS}") <(echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_AFTER_IMG_IDS}") | awk '{if(length($1)>10){print $1}}'))

	# 绑定参数
	# 参数1：镜像ID
	function _soft_soft_docker_setup_increase_check_action_loop()
	{
		# 提取参数信息
		local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM=$(docker_image_param_check_jq_item_echo "${1}")

		# 如果存在实例，则直接从实例中获取启动参数
		if [ "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM}" != "{}" ]; then
			local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_ID=$(echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM}" | jq ".ImageID" | xargs echo)
			local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_CTN_IDS=$(echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM}" | jq ".ContainerIDS" | xargs echo)
			local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_NAME=$(echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM}" | jq ".Image" | xargs echo)

			# 找到已启动的容器，重新定义参数
			if [ -n "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_CTN_IDS}" ]; then
				echo_style_wrap_text "[Checked] 'image'(<${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_NAME}>) booted 'container'(<${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_CTN_IDS}>), params will be reget"
				_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM=$(docker_container_param_check_jq_item_echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_CTN_IDS}")
			fi

			local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_VER=$(echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM}" | jq ".Version" | xargs echo)
			local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_CTN_ARG_CMD=$(echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM}" | jq ".Cmd" | xargs echo)
			# 复杂参数，不使用grep匹配可能报错:xargs: 未匹配的 单 引用；默认情况下，引用是针对 xargs 的，除非您使用了 -0 选项
			local _TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_CTN_ARGS=$(echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM}" | jq ".Args" | grep -oP "(?<=^\").*(?=\"$)")
		
			# 重新定义版本号
			if [ "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_VER}" == "latest" ]; then
				# 将版本号改为镜像ID
				_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM=$(echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM}" | jq ".Version=\"${1}\"")

				echo_style_text "[Checked] 'image'(<${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_NAME}>) ver marked 'latest', system remarked to 'image id'([${1}])"
				docker image tag ${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_NAME}:latest ${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_NAME}:${1}
				docker rmi ${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_NAME}:latest
			fi
			
			echo_style_wrap_text "[Checked] 'increase image'(<${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_NAME}>:[${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_VER}]), start 'display' attributes"
			echo_style_text "[View] the 'boot json'↓:"
			echo "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM}" | jq

			script_check_action "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_LOOP_SCRIPT}" "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_JQ_ITEM}"
		else
			echo_style_text "Resolve 'image'(<${1}>) failure, setup skip"
			return
		fi
	}
	
	if [ -n "${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_IDS}" ]; then
		echo_style_text "[Checked] 'increased images'(<${_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_IDS[*]}>), start bind params"
	fi
	
	items_split_action "_TMP_SOFT_DOCKER_SETUP_INCREASE_CHECK_ACTION_INCREASE_IMG_IDS" "_soft_soft_docker_setup_increase_check_action_loop"
	return $?
}

# Docker镜像检测后安装，存在时提示覆盖安装（基于Docker镜像检测类型的安装，并具有备份提示操作）
# 参数1：镜像名称，用于检测
# 参数2：镜像版本，为空时跳出选择框
# 参数3：安装脚本（例：docker pull、docker-compose）
# 参数4：重装选择Y时 或镜像不存在时默认的 安装/还原后后执行脚本
#        参数1：镜像名称，例 goharbor/prepare
#        参数2：镜像版本，例 imgver111111_v1670329246
#        参数3：启动命令，例 /bin/sh
#        参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#        参数5：快照类型（快照有效），例 image/container/dockerfile
#        参数6：镜像来源，例 snapshot/clean/hub/commit，默认snapshot
# 参数5：重装选择N时 或镜像已存在时执行脚本
# 参数6：动作类型描述，action/install
# 示例：
#     soft_docker_check_upgrade_custom "goharbor/prepare" "imgver111111" 'docker pull ${1}:${2}' "exec_step_browserless_chrome"
#     soft_docker_check_upgrade_custom "goharbor/prepare" "imgver111111" "bash prepare" "exec_step_browserless_chrome"
function soft_docker_check_upgrade_custom() 
{
	local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME="${1}"
	local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_MARK_NAME="${1/\//_}"
	local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_VER="${2}"
	local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INSTALL_SCRIPT=${3}
	local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_NE_SCRIPT=${4}
	#  | grep -oP "(?<=^_v)[0-9]+(?=\w+$)"
	local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_EXISTS_VERS=$(echo_docker_images_exists_vers "${1}")
	local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_EXISTS_GREP=$(docker images | awk "NR>1{if(\$1~\"${1}\"){print}}")

	# 检查Docker运行状态
	local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_DC_STATUS=$(echo_service_node_content "docker" "Active")
	if [ "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_DC_STATUS}" != "active" ]; then
		echo_style_text "[Checked] 'docker status' is [not running], it take <${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_DC_STATUS}>, please check"
		return
	fi
	
	function _soft_docker_check_upgrade_custom_print_image()
	{
		echo "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_EXISTS_GREP}" | awk "{if(\$2~\"${1}\"){print}}"
	}

	local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_PRINT_SCRIPT="(docker images | awk 'NR==1') && echo \"\${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_EXISTS_VERS}\" | eval script_channel_action '_soft_docker_check_upgrade_custom_print_image'"
	local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_E_SCRIPT=${5:-${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_PRINT_SCRIPT}}
	local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_TYPE_DESC=${6:-"install"}

	function _soft_docker_check_upgrade_custom()
	{
		# 参数1：是否已安装，不为空则表示已安装
		# 参数2：安装版本
		# 参数3：版本存储类型，例 clean snapshot hub
		function _soft_docker_check_upgrade_custom_choice_action()
		{
			local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CHOICE_VER="${2}"
			local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_NEWER_VER="${2}"
			local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_STORE_TYPE="${3:-$(echo_docker_images_store "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CHOICE_VER}")}"

			# 确认重装
			function _soft_docker_check_upgrade_custom_confrim_reinstall()
			{
				# 重装
				function _soft_docker_check_upgrade_custom_reinstall()
				{
					# 有镜像，没容器
					# 有容器则备份数据，有镜像直接重装
					echo_style_text "Starting <re${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_TYPE_DESC}> 'image'(<${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}>:[${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CHOICE_VER}])"
					
					function _soft_docker_check_upgrade_custom_ctn_trail()
					{						
						# 重装先确认备份，默认备份
						local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_BACKUP_Y_N="Y"
						confirm_yn_action "_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_BACKUP_Y_N" "Please sure the 'docker soft' of 'container'(<${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}>:[${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CHOICE_VER}]('${1}')) u will [backup check] 'still or not'"

						# 是否强制删除这里取反，docker_soft_trail_clear参数需要
						local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_FORCE_TRAIL_Y_N="${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_BACKUP_Y_N}"
						bind_exchange_yn_val "_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_FORCE_TRAIL_Y_N"

						# 卸载容器前检测，备份残留或NO
						docker_soft_trail_clear "${1}" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_FORCE_TRAIL_Y_N}"
					}

					function _soft_docker_check_upgrade_custom_img_trail()
					{
						# docker ps -a -f name=xxx|id=xxx
						local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CTN_IDS=$(docker ps -a | awk "{if(\$2~\"${1}\"){ print \$1}}")
						echo_style_text "Starting <trail> exists 'containers'(<${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}>:[${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CTN_IDS:-none}])"
						items_split_action "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CTN_IDS}" "_soft_docker_check_upgrade_custom_ctn_trail"
						
						echo_style_text "Starting <remove> 'image'(<${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}>:[${1}])"
						docker rmi ${1}
					}

					# 查找当前镜像的ID
					local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_IDS=$(echo "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_EXISTS_GREP}" | awk "{if(\$2~\"${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_NEWER_VER}\"){print \$3}}")
					echo_style_text "Starting <trail> exists 'images'(<${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}>:[${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_IDS:-none}])"
					items_split_action "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_IDS}" "_soft_docker_check_upgrade_custom_img_trail"
					
					_soft_docker_check_upgrade_custom_install
				}

				# 原始未指定版本的情况下不提示，避免多次选择 ??? 判断错误，无法正常安装
				if [ -z "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_VER}" ]; then
					confirm_yn_action "_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_YN_REINSTALL" "Special 'image'(<${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}>:[${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CHOICE_VER}]) was exists, got vers([${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_EXISTS_VERS:-none}]), please 'sure' u will [re${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_TYPE_DESC}] 'still or not'" "_soft_docker_check_upgrade_custom_reinstall" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_PRINT_SCRIPT} | grep '${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_NEWER_VER}'"
				else
					_soft_docker_check_upgrade_custom_reinstall
				fi
			}

			function _soft_docker_check_upgrade_custom_install()
			{
				# 为空则不进行安装操作
				if [ -z "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INSTALL_SCRIPT}" ]; then
					return
				fi

				# 因为latest版本曾经被修改为IMAGE ID，故需要在此还原
				if [ -n "$(echo "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_EXISTS_GREP}" | awk "{if(\$2==\"${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CHOICE_VER}\" && \$2==\$3){print}}")" ]; then
					_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CHOICE_VER="latest"
				fi

				echo_style_text "Starting 'pull image'(<${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}>:[${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CHOICE_VER}]) from [${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_STORE_TYPE}], hold on please"
				case "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_STORE_TYPE}" in 
					"hub" | "unknow")
						# 预先检索对应数字标记（针对 自定义tag与latest版本情况）
						local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_DIGESTS=$(echo_docker_image_digests "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CHOICE_VER}")
						
						function _soft_docker_check_upgrade_custom_install_exec()
						{
							# 执行安装脚本
							script_check_action "_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INSTALL_SCRIPT" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CHOICE_VER}" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_STORE_TYPE}"
						}
						
						function _soft_docker_check_upgrade_custom_install_after_exec()
						{
							local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_IMG_ID=$(echo "${1}" | jq ".ImageID" | xargs echo)
							# local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_CTN_IDS=$(echo "${1}" | jq ".ContainerIDS" | xargs echo)
							local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_IMG_NAME=$(echo "${1}" | jq ".Image" | xargs echo)
							local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_IMG_VER=$(echo "${1}" | jq ".Version" | xargs echo)
							
							local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_CTN_ARG_CMD=$(echo "${1}" | jq ".Cmd" | xargs echo)
							local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_CTN_ARGS=$(echo "${1}" | jq ".Args" | grep -oP "(?<=^\").*(?=\"$)")

							# 修正镜像全局参数								
							_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME="${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_IMG_NAME}"
							_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_MARK_NAME="${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_IMG_NAME/\//_}"
							# _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_VER="${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_IMG_VER}"

							# 重新获取数字标记
							local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_PULL_SHA256=$(docker inspect ${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_IMG_ID} | jq ".[0].RepoDigests[]" | xargs echo | cut -d':' -f2)

							# 版本未更新则不操作（???新增修改，看是否可以通过docker镜像内安装镜像来判断是否存在新版本）   ???此处因为mattermost的postgres版本不对，故修改成读取新增的image版本
							item_exists_yn_action "^${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_PULL_SHA256}$" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_DIGESTS}" "_soft_docker_check_upgrade_custom_confrim_reinstall" "script_check_action '_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_NE_SCRIPT' '${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_IMG_NAME}' '${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_IMG_VER}' \"${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_CTN_ARG_CMD}\" \"${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_INCREASE_CTN_ARGS}\" '' 'hub'"
						}
						
						# 循环安装检测
						soft_docker_setup_increase_check_action "_soft_docker_check_upgrade_custom_install_exec" "_soft_docker_check_upgrade_custom_install_after_exec"
					;;
					*)
						docker_snap_restore_choice_action "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_NEWER_VER}" "_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_NE_SCRIPT" "echo 'Cannot found snap ver('${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}:${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_CHOICE_VER}')" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_STORE_TYPE}"
				esac
			}
			
			if [ -n "${1}" ]; then
				# 第二次确认，确认选择是否是安装过的版本。
				_soft_docker_check_upgrade_custom_confrim_reinstall
			else
				_soft_docker_check_upgrade_custom_install
			fi
		}

		# 未指定版本则选择版本
		if [ -z "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_VER}" ]; then
			docker_images_choice_vers_action "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}" "Please sure 'which version' u want to '${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_TYPE_DESC}' of 'image' <${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}>" "_soft_docker_check_upgrade_custom_choice_action"
		else
			# 确认当前版本是否已安装
			local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IS_INSTALL=$(echo "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_EXISTS_VERS}" | egrep "^${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_VER}$" && echo 1)
			script_check_action "_soft_docker_check_upgrade_custom_choice_action" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IS_INSTALL}" "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_VER}"
		fi
	}

	# 第一次确认，确认有安装过的版本。是否继续选择安装其它版本
	if [ -n "${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_EXISTS_VERS}" ]; then
		local _TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_YN_REINSTALL="N"
		confirm_yn_action "_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_YN_REINSTALL" "Checked 'image'(<${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_IMG_NAME}>) was got vers([${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_EXISTS_VERS//[[:space:]]/,}]), please 'sure' u will [${_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_TYPE_DESC}] 'still or not'" "_soft_docker_check_upgrade_custom" "_TMP_SOFT_DOCKER_CHECK_UPGRADE_CUSTOM_E_SCRIPT"
	else
		_soft_docker_check_upgrade_custom
	fi

    return $?
}

# Docker镜像检测后安装，存在时提示覆盖安装（基于Docker镜像检测类型的安装，并具有备份提示操作）
# 参数1：镜像名称，用于检测
# 参数2：镜像版本，为空时跳出选择框
# 参数3：重装选择Y时 或镜像不存在时默认的 安装/还原后后执行脚本
#        参数1：镜像名称，例 browserless/chrome
#        参数2：镜像版本，例 imgver111111_v1670329246
#        参数3：启动命令，例 /bin/sh
#        参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#        参数5：快照类型（快照有效），例 image/container/dockerfile
#        参数6：镜像来源，例 snapshot/clean/hub/commit，默认snapshot
# 参数4：重装选择N时 或镜像已存在时执行脚本
# 参数5：动作类型描述，action/install
# 示例：
#     soft_docker_check_upgrade_action "browserless/chrome" "imgver111111" "exec_step_browserless_chrome"
function soft_docker_check_upgrade_action() 
{
	soft_docker_check_upgrade_custom "${1}" "${2}" 'docker pull ${1}:${2}' "${@:3:5}"
    return $?
}

# Docker镜像检测后安装，存在时提示覆盖安装（基于Docker镜像检测类型的安装，并具有备份提示操作）
# 参数1：镜像名称，用于检测
# 参数2：重装选择Y时 或镜像不存在时默认的 安装/还原后后执行脚本
#        参数1：镜像名称，例 browserless/chrome
#        参数2：镜像版本，例 imgver111111_v1670329246
#        参数3：启动命令，例 /bin/sh
#        参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#        参数5：快照类型（快照有效），例 image/container/dockerfile
#        参数6：镜像来源，例 snapshot/clean/hub/commit，默认snapshot
# 参数3：重装选择N时 或镜像已存在时执行脚本
# 参数4：动作类型描述，action/install
# 示例：
#     soft_docker_check_choice_upgrade_action "browserless/chrome" "exec_step_browserless_chrome"
function soft_docker_check_choice_upgrade_action() 
{
	soft_docker_check_upgrade_action "${1}" "" "${@:2:4}"
    return $?
}

# # Docker镜像检测后安装，存在时提示覆盖安装（基于Docker-Compose镜像检测类型的安装，并具有备份提示操作）
# # 参数1：镜像正则名称变量值或名，用于检测的基准镜像名，例：goharbor/ 或 browserless/chrome
# # 参数2：预编译脚本，即安装前执行（例：生成docker-compose.yml）
# # 参数3：Compose脚本（生成docker-compose.yml）
# # 参数4：重装选择Y时 或镜像不存在时默认的 安装/还原后后执行脚本
# #        参数1：镜像名称，例 browserless/chrome
# #        参数2：镜像版本，例 imgver111111_v1670329246
# #        参数3：启动命令，例 /bin/sh
# #        参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
# #        参数5：快照类型（快照有效），例 image/container/dockerfile
# #        参数6：镜像来源，例 snapshot/clean/hub/commit，默认snapshot
# # 参数5：重装选择N时 或镜像已存在时执行脚本
# # 参数6：动作类型描述，action/install
# # 示例：
# #     soft_docker_compose_check_upgrade_action "goharbor/prepare" "imgver111111" "bash prepare" "bash install" "exec_step_browserless_chrome"
# function soft_docker_compose_check_upgrade_action() 
# {
# 	local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_VER=""
# 	local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_COMPILE_SCRIPT=${3}
# 	local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_COMPOSE_GEN_SCRIPT=${4}
# 	local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INSTALL_SCRIPT=${5}
# soft_docker_check_upgrade_custom "${1}" "${TMP_DC_CPS_HB_SETUP_VER}" "" 'docker pull ${1}:${2}' "${@:3:5}"
# 	# 编译操作
# 	# 参数1：镜像名称
# 	# 参数2：版本信息
# 	function _soft_docker_compose_check_upgrade_action_compile()
# 	{
# 		if [ -n "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_COMPILE_SCRIPT}" ]; then
# 			echo_style_wrap_text "Starting 'compile image'(<${1}>:[${2}]) from [${3}], hold on please"

# 			# 查找已安装docker 镜像，先做标记。用于判定是否有新增镜像
# 			local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_BEFORE_IMG_IDS=$(docker images | awk 'NR>1{print $3}')
# 			script_check_action "_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_COMPILE_SCRIPT" "${1}" "${2}"
# 			local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_AFTER_IMG_IDS=$(docker images | awk 'NR>1{print $3}')
# 			local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_IMG_IDS=($(diff -e <(echo "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_BEFORE_IMG_IDS}") <(echo "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_AFTER_IMG_IDS}") | awk 'NR>1{if(line!=""){print line}{line=$0}}'))

# 			# 绑定参数
# 			# 参数1：ID
# 			function _soft_docker_compose_check_upgrade_action_compile_bind_param()
# 			{
# 				# 从已安装容器中提取参数
# 				local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_JQ_ITEM=$(docker_image_param_check_jq_item_echo "${1}")
				
# 				if [ "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_JQ_ITEM}" != "{}" ]; then
# 					local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_IMG_ID=$(echo "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_JQ_ITEM}" | jq ".ImageID")
# 					local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_CTN_ID=$(echo "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_JQ_ITEM}" | jq ".ContainerIDS")
# 					local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_IMG_NAME=$(echo "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_JQ_ITEM}" | jq ".ImageName")
# 					local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_IMG_VER=$(echo "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_JQ_ITEM}" | jq ".Version")
# 					local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_CTN_ARG_CMD=$(echo "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_JQ_ITEM}" | jq ".Cmd")
# 					local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_CTN_ARGS=$(echo "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_JQ_ITEM}" | jq ".Args")
					
# 					echo_style_wrap_text "[Checked] 'increase image'(<${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_IMG_NAME}>:[${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_IMG_VER}('${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_IMG_ID}'/'${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_CTN_ID:-None}')]), start bind param"
# 					echo "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_JQ_ITEM}" | jq

# 					script_check_action "_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INSTALL_SCRIPT" "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_IMG_NAME}" "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_IMG_VER}" "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_CTN_ARG_CMD}" "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_CTN_ARGS}" "hub"
# 				else
# 					echo_style_text "Resolve 'image'(<${1}>) failure, setup skip"
# 					return
# 				fi
# 			}

# 			items_split_action "_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INCREASE_IMG_IDS" "_soft_docker_compose_check_upgrade_action_compile_bind_param"
# 		fi
# 	}
	
# 	# 安装操作(compose之前需判断是否已安装)
# 	# 参数1：镜像名称
# 	# 参数2：版本信息
# 	function _soft_docker_compose_check_upgrade_action_compose()
# 	{
# 		if [ -n "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_COMPOSE_GEN_SCRIPT}" ]; then
# 			# 自定义安装
# 			echo_style_wrap_text "Starting 'compose image'(<${1}>:[${2}]) from [${3}], hold on please"
# 			script_check_action "_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_COMPOSE_GEN_SCRIPT" "${1}" "${2}"

# 			# 执行安装
# 			# 参数1：yaml节点
# 			function _soft_docker_compose_check_upgrade_action_install()
# 			{
# 				local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_FULL_NAME=$(echo "${1}" | yq ".image")
# 				local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_NAME=$(echo "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_FULL_NAME}" |  cut -d':' -f1)
# 				local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_VER=$(echo "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_FULL_NAME}" | cut -d':' -f2 | awk '$1=$1')
# 				local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_CTN_ARG_CMD=
# 				local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_CTN_ARGS=
				
# 				echo_style_wrap_text "[Checked] 'increase image'(<${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_NAME}>:[${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_VER}]), start bind param"

# 				# 从已安装容器中提取参数
# 				local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_JQ_ARR=$(docker_images_param_check_jq_arr_echo "^${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_NAME}")
				
# 				# 绑定参数
# 				# 参数1：JQ-ITEM
# 				if [ "${TMP_DC_CPS_HB_IMG_BUILD_JQ_ARR}" != "[]" ]; then
# 					function _soft_docker_compose_check_upgrade_action_install_bind_param()
# 					{
# 						echo_style_text "[View] 'bind param'↓:"
# 						echo "${1}" | jq
# 						_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_VER=${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_VER:-$(echo "${1}" | jq ".Version")}
# 						_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_CTN_ARG_CMD=$(echo "${1}" | jq ".Cmd")
# 						_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_CTN_ARGS=$(echo "${1}" | jq ".Args")

# 						script_check_action "_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_INSTALL_SCRIPT" "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_NAME}" "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_VER}" "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_CTN_ARG_CMD}" "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_CTN_ARGS}" "hub"	
# 					}

# 					# 绑定启动参数
# 					json_split_action "_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_JQ_ARR" "_soft_docker_compose_check_upgrade_action_install_bind_param"
# 				else
# 					echo_style_text "Resolve 'image'(<${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_NAME}>:[${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_VER}]) failure, setup skip"
# 					return
# 				fi
# 			}

# 			# 从docker-compose.yml中取已安装镜像信息
# 			if [ -a docker-compose.yml ]; then
# 				yaml_split_action "$(cat docker-compose.yml | yq '.services')" "_soft_docker_compose_check_upgrade_action_install"
# 				return $?
# 			fi

# 			echo_style_wrap_text "Cannot found docker-compose.yml, please check"
# 		fi
# 	}

# 	soft_docker_check_upgrade_custom "${1}" "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_VER}" "_soft_docker_compose_check_upgrade_action_compile" "${@:4:6}"
#     return $?
# }

# Docker镜像检测后安装，存在时提示覆盖安装（基于Docker-Compose镜像检测类型的安装，并具有备份提示操作）
# 参数1：镜像正则名称变量值或名，用于检测的基准镜像名，例：goharbor/ 或 browserless/chrome
# 参数2：镜像版本变量值或名，用于检测的基准镜像版本，例：imgver111111
# 参数3：预编译脚本，即安装前执行（例：bash prepare.sh / 生成docker-compose.yml）
# 参数4：重装选择Y时 或镜像不存在时默认的 安装/还原后后执行脚本
#        参数1：镜像名称，例 browserless/chrome
#        参数2：镜像版本，例 imgver111111_v1670329246
#        参数3：启动命令，例 /bin/sh
#        参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#        参数5：快照类型（快照有效），例 image/container/dockerfile
#        参数6：镜像来源，例 snapshot/clean/hub/commit，默认snapshot
# 参数5：重装选择N时 或镜像已存在时执行脚本
# 参数6：动作类型描述，action/install
# 示例：
#     soft_docker_compile_check_upgrade_action "goharbor/prepare" "imgver111111" "bash prepare" "resolve_compose_dc_goharbor_harbor_loop"
#     soft_docker_compile_check_upgrade_action "goharbor/prepare" "imgver111111" "docker-compose -d up" "resolve_compose_dc_goharbor_harbor_loop"
#     soft_docker_compile_check_upgrade_action "mattermost/mattermost-enterprise-edition" "imgver111111" "" "resolve_compose_dc_mattermost_loop"
function soft_docker_compile_check_upgrade_action() 
{
	local _TMP_SOFT_DOCKER_COMPILE_CHECK_UPGRADE_ACTION_COMPOSE_GEN_SCRIPT=${3}

	# 安装操作(重命名container名称)
	# 参数1：镜像名称
	# 参数2：版本信息
	function _soft_docker_compile_check_upgrade_action_compile()
	{
		if [ -n "${_TMP_SOFT_DOCKER_COMPILE_CHECK_UPGRADE_ACTION_COMPOSE_GEN_SCRIPT}" ]; then
			# 自定义安装
			echo_style_wrap_text "Starting 'compile image'(<${1}>:[${2}]) from [${3}], hold on please"
			script_check_action "_TMP_SOFT_DOCKER_COMPILE_CHECK_UPGRADE_ACTION_COMPOSE_GEN_SCRIPT" "${1}" "${2}"
		fi

		# docker_compose_yml_formal_exec "${1%%/*}" "$(pwd)"
	}

	soft_docker_check_upgrade_custom "${1}" "${2}" "_soft_docker_compile_check_upgrade_action_compile" "${@:4}"
	
	return $?
}

# Docker镜像检测后安装，存在时提示覆盖安装（基于Docker-Compose镜像检测类型的安装，并具有备份提示操作）
# 参数1：打印镜像的标题
# 参数2：打印获取版本号
# 参数3：compose编译脚本（例：bash install.sh / docker-compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d）
# 参数4：镜像轮询操作脚本
# 示例：
#     soft_docker_compose_check_upgrade_action "bash prepare" "resolve_compose_dc_goharbor_harbor_loop"
#     soft_docker_compose_check_upgrade_action "docker-compose -d up" "resolve_compose_dc_goharbor_harbor_loop"
#     soft_docker_compose_check_upgrade_action "" "resolve_compose_dc_mattermost_loop"
function soft_docker_compose_check_upgrade_action() 
{
	local _TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_LOOP_SCRIPTS="${4}"
	echo_style_text "Starting 'pull images'(<${1}>:[${2}]) from [compose], hold on please"
	
	function _soft_soft_docker_compose_check_upgrade_action_loop()
	{
		local TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_ID=$(echo "${1}" | jq ".ImageID" | xargs echo)
		# local TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_CTN_IDS=$(echo "${1}" | jq ".ContainerIDS" | xargs echo)
		local TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_NAME=$(echo "${1}" | jq ".Image" | xargs echo)
		local TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_VER=$(echo "${1}" | jq ".Version" | xargs echo)
		local TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_CMD=$(echo "${1}" | jq ".Cmd" | xargs echo)
		local TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_ARGS=$(echo "${1}" | jq ".Args" | grep -oP "(?<=^\").*(?=\"$)")

		# 版本未更新则不操作（???新增修改，看是否可以通过docker镜像内安装镜像来判断是否存在新版本）
		script_check_action "_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_LOOP_SCRIPTS" "${TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_NAME}" "${TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_VER}" "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_CMD}" "${_TMP_SOFT_DOCKER_COMPOSE_CHECK_UPGRADE_ACTION_IMG_ARGS}"
	}
	
	# 循环安装检测
	soft_docker_setup_increase_check_action "${3}" "_soft_soft_docker_compose_check_upgrade_action_loop"
	return $?
}