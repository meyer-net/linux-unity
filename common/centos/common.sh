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

#获取IP
# 参数1：需要设置的变量名
function get_iplocal () {
	#  | grep noprefixroute，qcloud无此属性
	local _TMP_GET_IP_LOCAL_IP=`ip addr | grep inet | grep brd | grep -v inet6 | grep -v 127 | grep -v docker | awk '{print $2}' | awk -F'/' '{print $1}' | awk 'END {print}'`
    [ -z ${_TMP_GET_IP_LOCAL_IP} ] && _TMP_GET_IP_LOCAL_IP=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1`

	if [ -n "$_TMP_GET_IP_LOCAL_IP" ]; then
		eval ${1}='$_TMP_GET_IP_LOCAL_IP'
	fi

	return $?
}

#获取IPv4
# 参数1：需要设置的变量名
function get_ipv4 () {
	#wget -qO- -t1 -T2 ipv4.icanhazip.com
    local _TMP_GET_IPV4_LOCAL_IPV4=`curl -s -A Mozilla ipv4.icanhazip.com | awk 'NR==1'`
    [ -z ${_TMP_GET_IPV4_LOCAL_IPV4} ] && _TMP_GET_IPV4_LOCAL_IPV4=`curl -s -A Mozilla ipinfo.io/ip | awk 'NR==1'`
    [ -z ${_TMP_GET_IPV4_LOCAL_IPV4} ] && _TMP_GET_IPV4_LOCAL_IPV4=`curl -s -A Mozilla ip.sb | awk 'NR==1'`

	if [ -n "$_TMP_GET_IPV4_LOCAL_IPV4" ]; then
		eval ${1}='$_TMP_GET_IPV4_LOCAL_IPV4'
	fi

	return $?
}

#获取IPv6
# 参数1：需要设置的变量名
function get_ipv6 () {
    local _TMP_GET_IPV6_IP=`curl -s -A Mozilla ipv6.icanhazip.com | awk 'NR==1'`

	if [ -n "${_TMP_GET_IPV6_IP}" ]; then
		eval ${1}='$_TMP_GET_IPV6_IP'
	fi

	return $?
}

#获取国码
# 参数1：需要设置的变量名
function get_country_code () {
	local _TMP_GET_COUNTRY_CODE_DFT=`eval echo '$'${1}`
	local _TMP_GET_COUNTRY_CODE_CODE=`echo ${_TMP_GET_COUNTRY_CODE_DFT:-"CN"}`
	
	local TMP_LOCAL_IPV4=`curl -s ip.sb`

	# 项目开始判断服务器所在地，未初始化epel时无法安装JQ，故此处不使用JQ
	local _TMP_GET_COUNTRY_CODE_RESP=`curl -s -A Mozilla https://api.ip.sb/geoip/${TMP_LOCAL_IPV4}`

	if [ -f "/usr/bin/jq" ]; then
		_TMP_GET_COUNTRY_CODE_CODE=`echo "${_TMP_GET_COUNTRY_CODE_RESP}" | jq '.country_code' | tr -d '"'`
	else
		_TMP_GET_COUNTRY_CODE_CODE=`echo "${_TMP_GET_COUNTRY_CODE_RESP}" | grep -oP "(?<=\"country_code\"\:\").*(?=\",)"`
	fi
	
	eval ${1}='$_TMP_GET_COUNTRY_CODE_CODE'

	return $?
}

# 绑定系统域名设定
# 参数1：需要设置的变量名
function bind_sysdomain() {
    local _TMP_BIND_SYS_DOMAIN_VAL="mydomain.com"
	if [ -f "${SETUP_DIR}/.sys_domain" ]; then
		_TMP_BIND_SYS_DOMAIN_VAL=`cat ${SETUP_DIR}/.sys_domain`
	fi

	eval ${1}='${_TMP_BIND_SYS_DOMAIN_VAL}'

	return $?
}

# 绑定交换YN项(Yy,YESyes,TRUE,true)，意图取反获得统一YN值
# 参数1：需要设置的变量名，自带YN值
function bind_exchange_yn_val()
{
	local _TMP_BIND_EXCHANGE_YN_VAL_VAR_VAL=`eval echo '$'${1}`
	
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
	local _TMP_EXCHANGE_SOFT_LINK_ACTION_BEFORE=${3:-}

	if [ -f ${_TMP_EXCHANGE_SOFT_LINK_CHECK_PATH} ]; then
		local _TMP_EXCHANGE_SOFT_LINK_CHECK_IS_LINK=`ls -il ${_TMP_EXCHANGE_SOFT_LINK_CHECK_PATH} | grep '\->'`
		if [ -z "${_TMP_EXCHANGE_SOFT_LINK_CHECK_IS_LINK}" ]; then
			if [ -n "${_TMP_EXCHANGE_SOFT_LINK_ACTION_BEFORE}" ]; then
				eval "${_TMP_EXCHANGE_SOFT_LINK_ACTION_BEFORE}"
			fi

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

# 免密登录远程主机
# 参数1：需要免密登录的机器
# 参数2：需要免密登录的用户
function nopwd_login () {
    local _TMP_NOPWD_LOGIN_REMOTE_HOST=${1}
    local _TMP_NOPWD_LOGIN_REMOTE_USER=${2:-"root"}
    local _TMP_NOPWD_LOGIN_REMOTE_HOST_PORT=${1:-22}

	if [ -n "${_TMP_NOPWD_LOGIN_REMOTE_HOST}" ]; then
		local _TMP_NOPWD_LOGIN_ID_RSA_PATH="~/.ssh/id_rsa"

		path_not_exists_action "${_TMP_NOPWD_LOGIN_ID_RSA_PATH}" "ssh-keygen -t rsa"
		
		ssh-copy-id ${_TMP_NOPWD_LOGIN_REMOTE_USER}@${_TMP_NOPWD_LOGIN_REMOTE_HOST} -p ${_TMP_NOPWD_LOGIN_REMOTE_HOST_PORT}
	fi

	return $?
}

# 执行脚本,如果内容不存在
# 参数1：内容正则
# 参数2：内容路径
# 参数3：执行脚本
function action_if_content_not_exists() 
{
	local _TMP_ACTION_IF_CONTENT_NOT_EXISTS_REGEX=${1}
	local _TMP_ACTION_IF_CONTENT_NOT_EXISTS_PATH=${2}
	local _TMP_ACTION_IF_CONTENT_NOT_EXISTS_ACTION=${3}

	#create group if not exists
	egrep "${_TMP_ACTION_IF_CONTENT_NOT_EXISTS_REGEX}" ${_TMP_ACTION_IF_CONTENT_NOT_EXISTS_PATH} >& /dev/null
	if [ $? -ne 0 ]; then
		if [ -n "${_TMP_ACTION_IF_CONTENT_NOT_EXISTS_ACTION}" ]; then
			eval "${_TMP_ACTION_IF_CONTENT_NOT_EXISTS_ACTION}"
		fi
	fi

	return $?
}

# 输出信息,如果内容不存在
# 参数1：内容正则
# 参数2：内容路径
# 参数3：输出内容
function echo_if_content_not_exists() 
{
	action_if_content_not_exists "${1}" "${2}" "echo '${3:-${1}}' >> ${2}"

	return $?
}

# 执行脚本,如果选项不存在
# 参数1：内容正则变量
# 参数2：内容判断数组
# 参数3：不存在执行脚本
# 参数4：存在执行脚本
# 示例：
#      local _ARR=()
#      _ARR[0]="/opt/docker"
#      _ARR[1]="/var/lib/docker"
#      _ARR[2]="/var/log/docker"
#      _ARR[3]="/etc/docker"
#      local _CHECK_ITEM="^/etc/docker$"
#      action_if_item_not_exists "_CHECK_ITEM" "${_ARR[*]}" "echo 'not exists'" "echo 'exists'"
#      action_if_item_not_exists "^/etc/docker$" "${_ARR[*]}" "echo 'not exists'" "echo 'exists'"
function action_if_item_not_exists() 
{
	local _TMP_ACTION_IF_ITEM_NOT_EXISTS_VAR_REGEX=`eval echo '$'${1}`
	if [ "\$${1}" == "${_TMP_ACTION_IF_ITEM_NOT_EXISTS_VAR_REGEX}" ]; then
		_TMP_ACTION_IF_ITEM_NOT_EXISTS_VAR_REGEX="${1}"
	fi

	local _TMP_ACTION_IF_ITEM_NOT_EXISTS_ARR=(${2})
	local _TMP_ACTION_IF_ITEM_NOT_EXISTS_CON_N_ACTION=${3}
	local _TMP_ACTION_IF_ITEM_NOT_EXISTS_CON_E_ACTION=${4}

	#create group if not exists
	local _TMP_ACTION_IF_ITEM_NOT_EXISTS_ITEM=""
	for _TMP_ACTION_IF_ITEM_NOT_EXISTS_CURRENT in ${_TMP_ACTION_IF_ITEM_NOT_EXISTS_ARR[@]}; do
		echo "${_TMP_ACTION_IF_ITEM_NOT_EXISTS_CURRENT}" | egrep "${_TMP_ACTION_IF_ITEM_NOT_EXISTS_VAR_REGEX}" >& /dev/null
		if [ $? -eq 0 ]; then
			_TMP_ACTION_IF_ITEM_NOT_EXISTS_ITEM=${_TMP_ACTION_IF_ITEM_NOT_EXISTS_CURRENT}
			break
		fi
	done
	
	if [ -n "${_TMP_ACTION_IF_ITEM_NOT_EXISTS_ITEM}" ]; then
		exec_check_action "_TMP_ACTION_IF_ITEM_NOT_EXISTS_CON_E_ACTION" ${_TMP_ACTION_IF_ITEM_NOT_EXISTS_ITEM}
	else
		exec_check_action "_TMP_ACTION_IF_ITEM_NOT_EXISTS_CON_N_ACTION"
	fi

	return $?
}

# 创建用户及组，如果不存在
# 参数1：组
# 参数2：用户
# 参数3：默认目录
function create_user_if_not_exists() 
{
	local _TMP_CREATE_USER_IF_NOT_EXISTS_GROUP=${1}
	local _TMP_CREATE_USER_IF_NOT_EXISTS_USER=${2}
	local _TMP_CREATE_USER_IF_NOT_EXISTS_DFT_DIR=${3}

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
		if [ -n "${_TMP_CREATE_USER_IF_NOT_EXISTS_DFT_DIR}" ] && [ ! -d "${_TMP_CREATE_USER_IF_NOT_EXISTS_DFT_DIR}" ]; then
			_TMP_CREATE_USER_IF_NOT_EXISTS_COMMAND_EXT="-d ${_TMP_CREATE_USER_IF_NOT_EXISTS_DFT_DIR}"
		fi

		# 正在创建信箱文件: 文件已存在
		if [ ! -f /var/spool/mail/${_TMP_CREATE_USER_IF_NOT_EXISTS_USER} ]; then
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

			useradd -g ${_TMP_CREATE_USER_IF_NOT_EXISTS_GROUP} ${_TMP_CREATE_USER_IF_NOT_EXISTS_USER} ${_TMP_CREATE_USER_IF_NOT_EXISTS_COMMAND_EXT}
		fi

		# docker用户及组的情况
		if [ "${_TMP_CREATE_USER_IF_NOT_EXISTS_USER}" == "docker" ] || [ "${_TMP_CREATE_USER_IF_NOT_EXISTS_GROUP}" == "docker" ]; then
			# 给docker添加sudo权限
			chmod -v u+w /etc/sudoers
			curx_line_insert "_TMP_LINE" "/etc/sudoers" "root    ALL=(ALL)       ALL" "${_TMP_CREATE_USER_IF_NOT_EXISTS_USER}  ALL=(ALL)       ALL"
			chmod -v u-w /etc/sudoers

			# 以当前用户修改docker对应的用户UID
			local _TMP_CREATE_USER_IF_NOT_EXISTS_USER_ID=$(id -u ${_TMP_CREATE_USER_IF_NOT_EXISTS_USER})
			local _TMP_CREATE_USER_IF_NOT_EXISTS_CURRENT_USER_ID=$(id -u $(whoami))
			sed -i "s@^\(${_TMP_CREATE_USER_IF_NOT_EXISTS_USER}:x\):${_TMP_CREATE_USER_IF_NOT_EXISTS_USER_ID}@\1:${_TMP_CREATE_USER_IF_NOT_EXISTS_CURRENT_USER_ID}@g" /etc/passwd
		fi
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

	return $?
}

# 随机数
# 参数1：需要设置的变量名
# 参数2：最小值
# 参数3：最大值
#调用：rand_val "TMP_CURR_RAND" 1000 2000
function rand_val() {
    local _TMP_RAND_VAL_MIN=${2}
    local _TMP_RAND_VAL_MID=$((${3}-${_TMP_RAND_VAL_MIN}+1))  
    # local _TMP_RAND_VAL_CURR=$(cat /proc/sys/kernel/random/uuid | cksum | awk -F ' ' '{print $1}')

    # eval ${1}=$((${_TMP_RAND_VAL_CURR}%${_TMP_RAND_VAL_MID}+${_TMP_RAND_VAL_MIN}))
	eval ${1}=$(shuf -i ${2}-${3} -n 1)

	return $?
}

#随机数
# 参数1：需要设置的变量名
# 参数2：指定长度
#调用：rand_str "TMP_CURR_RAND" 1000 2000
function rand_str() {
	local _TMP_RAND_STR_VAR_NAME=${1}
    local _TMP_RAND_STR_LEN_VAL=${2} 
	# random-string()
	# {
	# 	cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
	# }
	# $(random-string 32)
    local _TMP_RAND_STR_FINAL_VAL=$(cat /dev/urandom | head -n ${_TMP_RAND_STR_LEN_VAL} | md5sum | head -c ${_TMP_RAND_STR_LEN_VAL})

    eval ${1}='$_TMP_RAND_STR_FINAL_VAL'

	return $?
}

# 清除首尾字符
# 参数1：需要存储清除后数据的变量名
# 参数2：指定清除的字符串，默认空
function trim_str() {
	local _TMP_TRIM_STR_VAR_NAME=${1}
	local _TMP_TRIM_STR_VAR_VAL=`eval echo '$'${1}`
    local _TMP_TRIM_STR_CHAR=${2:-"[:space:]"}
	
	: "${_TMP_TRIM_STR_VAR_VAL#"${_TMP_TRIM_STR_VAR_VAL%%[!${_TMP_TRIM_STR_CHAR}]*}"}" 
	: "${_%"${_##*[!${_TMP_TRIM_STR_CHAR}]}"}"
	
    eval ${1}='$_'

	return $?
}

#转换路径
# 参数1：原始路径
function convert_path () {
	local _TMP_CONVERT_PATH_SOURCE=`eval echo '$'${1}`
	local _TMP_CONVERT_PATH_CONVERT_VAL=`echo "${_TMP_CONVERT_PATH_SOURCE}" | sed "s@^~@/root@g"`

	eval ${1}='$_TMP_CONVERT_PATH_CONVERT_VAL'

	return $?
}

# 查找软链接真实路径
# 参数1：用于查找的变量
function symlink_link_path()
{
	local _TMP_SYMLINK_TRUE_PATH_SOURCE=`eval echo '$'${1}`
	convert_path "_TMP_SYMLINK_TRUE_PATH_SOURCE"

	local _TMP_SYMLINK_TRUE_PATH_CONVERT_VAL=`echo "${_TMP_SYMLINK_TRUE_PATH_SOURCE}" | sed "s@^~@/root@g"`

	# 记录链接层数，有可能是死链
	local _TMP_SYMLINK_TRUE_PATH_INDEX=0
	local _TMP_SYMLINK_TRUE_PATH_TMP="${_TMP_SYMLINK_TRUE_PATH_CONVERT_VAL}"
	[[ ${_TMP_SYMLINK_TRUE_PATH_CONVERT_VAL} =~ ^/ ]] && _TMP_SYMLINK_TRUE_PATH_TMP=${_TMP_SYMLINK_TRUE_PATH_CONVERT_VAL} || _TMP_SYMLINK_TRUE_PATH_TMP=`pwd`/${_TMP_SYMLINK_TRUE_PATH_CONVERT_VAL}
	while [ -h ${_TMP_SYMLINK_TRUE_PATH_TMP} ]
	do
		local _TMP_SYMLINK_TRUE_PATH_TMP_1=`ls -ld ${_TMP_SYMLINK_TRUE_PATH_TMP} | awk '{print $NF}'`
		local _TMP_SYMLINK_TRUE_PATH_TMP_2=`ls -ld ${_TMP_SYMLINK_TRUE_PATH_TMP} | awk '{print $(NF-2)}'`

		[[ $_TMP_SYMLINK_TRUE_PATH_TMP_1 =~ ^/ ]] && _TMP_SYMLINK_TRUE_PATH_TMP=${_TMP_SYMLINK_TRUE_PATH_TMP_1} || _TMP_SYMLINK_TRUE_PATH_TMP=`dirname ${_TMP_SYMLINK_TRUE_PATH_TMP_2}`/${_TMP_SYMLINK_TRUE_PATH_TMP_1}
		
		_TMP_SYMLINK_TRUE_PATH_INDEX=$((_TMP_SYMLINK_TRUE_PATH_INDEX+1))
		if [ ${_TMP_SYMLINK_TRUE_PATH_INDEX} -gt 9 ]; then
			echo_text_style "The symlink of '${_TMP_SYMLINK_TRUE_PATH_TMP}' linked too much more depth, Cannot resolve, please check, system exit."
			exit
		fi
	done

	eval ${1}='$_TMP_SYMLINK_TRUE_PATH_TMP'

	return $?
}

# 查询内容所在行
# 参数1：需要设置的变量名
# 参数2：文件路径
# 参数3：关键字
# 示例：
#      get_line "_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE" "/usr/lib/systemd/system/docker.service" "User="
#      -> 10:User=docker -> 10
function get_line()
{
	local _TMP_GET_LINE_FILE_PATH=${2}
	local _TMP_GET_LINE_KEY_WORDS=${3}

	local TMP_KEY_WORDS_LINE=`cat ${_TMP_GET_LINE_FILE_PATH} | grep -nE "${_TMP_GET_LINE_KEY_WORDS}" | cut -d':' -f1 | awk NR==1`

	eval ${1}='$TMP_KEY_WORDS_LINE'

	return $?
}

# 关键行插入
# 参数1：需要设置的变量名
# 参数2：文件路径
# 参数3：关键字
# 参数4：插入内容
# 示例：
#      curx_line_insert "_TMP_LINE" "/etc/sudoer" "root    ALL=(ALL)       ALL" "docker    ALL=(ALL)       ALL"
function curx_line_insert()
{
	get_line "${1}" "${2}" ${3}

	local _TMP_CURX_LINE_INSERT_CURX_LINE=`eval echo '$'${1}`

	if [ ${#_TMP_CURX_LINE_INSERT_CURX_LINE} -gt 0 ]; then
		# 插入行内容相同则不插入
		local _TMP_CURX_LINE_INSERT_LINE=$((_TMP_CURX_LINE_INSERT_CURX_LINE+1))
		local _TMP_CURX_LINE_INSERT_TEXT=`cat ${2} | awk "NR==${_TMP_CURX_LINE_INSERT_LINE}"`
		if [ "${_TMP_CURX_LINE_INSERT_TEXT}" != "${4}" ]; then
			sed -i "${_TMP_CURX_LINE_INSERT_LINE}i ${4}" ${2}
		fi
	else
		eval ${1}=`echo -1`
	fi

	return $?
}

# 修改服务运行时用户
# 参数1：需要修改的服务名称
# 参数2：服务运行时所用的用户
# 示例：
#      change_service_user "docker" "docker"
function change_service_user()
{
	local _TMP_CHANGE_SERVICE_USER_SNAME=${1}
	local _TMP_CHANGE_SERVICE_USER_UNAME=${2}

	local _TMP_CHANGE_SERVICE_USER_SERVICE_PATH="/usr/lib/systemd/system/${1}.service"
	local _TMP_CHANGE_SERVICE_USER_SOCKET_PATH="/usr/lib/systemd/system/${1}.socket"
	local _TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE=""
	# get_line "_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE" "${_TMP_CHANGE_SERVICE_USER_SERVICE_PATH}" "^([#]*[[:space:]]*)User="
	get_line "_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE" "${_TMP_CHANGE_SERVICE_USER_SERVICE_PATH}" '^([[:space:]]*)User='

	# 不存在用户设置
	if [ -z "${_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE}" ]; then
		get_line "_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE" "${_TMP_CHANGE_SERVICE_USER_SERVICE_PATH}" '^\[Service\]$'
		_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE=$((_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE+1))
	else
		# 删除用户设置
		sed -i "${_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE}d" ${_TMP_CHANGE_SERVICE_USER_SERVICE_PATH}
		_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE=$((_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE-1))
	fi

	# 有socket的情况
	if [ -f ${_TMP_CHANGE_SERVICE_USER_SOCKET_PATH} ]; then
		local _TMP_CHANGE_SERVICE_USER_SOCKET_UGROUP=$(groups ${_TMP_CHANGE_SERVICE_USER_UNAME} | cut -d' ' -f3)
		sed -i "s@\(SocketUser\)=.\+@\1=${_TMP_CHANGE_SERVICE_USER_UNAME}@g" ${_TMP_CHANGE_SERVICE_USER_SOCKET_PATH}
		
		if [ -n "${_TMP_CHANGE_SERVICE_USER_SOCKET_UGROUP}" ]; then
			sed -i "s@\(SocketGroup\)=.\+@\1=${_TMP_CHANGE_SERVICE_USER_SOCKET_UGROUP}@g" ${_TMP_CHANGE_SERVICE_USER_SOCKET_PATH}
		fi
	fi

	# 插入用户设置
	sed -i "${_TMP_CHANGE_SERVICE_USER_SNAME_SET_LINE}a User=${_TMP_CHANGE_SERVICE_USER_UNAME}" ${_TMP_CHANGE_SERVICE_USER_SERVICE_PATH}

	# 重新加载服务配置
    systemctl daemon-reload

	return $?
}

# 执行休眠
# 参数1：休眠数值
# 参数2：休眠等待文字
function exec_sleep()
{
	local _TMP_EXEC_SLEEP_TIMES=${1}
	local _TMP_EXEC_SLEEP_ECHO=${2}

	function _TMP_EXEC_SLEEP_NORMAL_FUNC() {
		echo_text_style "${_TMP_EXEC_SLEEP_ECHO}"
		sleep ${_TMP_EXEC_SLEEP_TIMES}
		return $?
	}
	
	function _TMP_EXEC_SLEEP_GUM_FUNC() {
		exec_text_style "_TMP_EXEC_SLEEP_ECHO"
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
		local _TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CURRENT_VAL=$(eval "${_TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CHECK_SCRIPTS}")		
		if [ -z "${_TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CURRENT_VAL}" ]; then
			exec_sleep 1 "${1}, take [${_TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_CURRENT_INDEX}/${_TMP_EXEC_SLEEP_UNTIL_NOT_EMPTY_SLEEP_SECONDS}]s"
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
# 参数1：需要设置的变量名
function get_mount_root() {
	local _TMP_GET_MOUNT_ROOT=""
	local _TMP_GET_MOUNT_ROOT_LSBLK_DISKS_STR=`lsblk | grep "0 disk" | grep -v "^${FDISK_L_SYS_DEFAULT}" | awk 'NR==1{print \${1}}' | xargs -I {} echo '/dev/{}'`
	if [ -n "${_TMP_GET_MOUNT_ROOT_LSBLK_DISKS_STR}" ]; then
		_TMP_GET_MOUNT_ROOT=`df -h | grep "${_TMP_GET_MOUNT_ROOT_LSBLK_DISKS_STR}" | awk -F' ' '{print \$NF}'`
	fi

	eval ${1}='${_TMP_GET_MOUNT_ROOT}'

	return $?
}

# 识别磁盘挂载
# 参数1：磁盘挂载数组，当带入参数时，以带入的参数来决定脚本挂载几块硬盘
function resolve_unmount_disk () {

	local _TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE="MountDisk"
	local _TMP_RESOLVE_UNMOUNT_DISK_ARR_MOUNT_PATH_PREFIX_STR=${1:-}
	# http://wxnacy.com/2018/05/26/shell-split/
	local _TMP_RESOLVE_UNMOUNT_DISK_ARR_MOUNT_PATH_PREFIX=(${_TMP_RESOLVE_UNMOUNT_DISK_ARR_MOUNT_PATH_PREFIX_STR//,/ })
	
	# 获取当前磁盘的格式，例如sd,vd
	local _TMP_RESOLVE_UNMOUNT_DISK_LSBLK_DISKS_STR=`lsblk | grep "0 disk" | grep -v "^${FDISK_L_SYS_DEFAULT}" | awk '{print \${1}}'`
	
	local _TMP_RESOLVE_UNMOUNT_DISK_ARR_DISK_POINT=(${_TMP_RESOLVE_UNMOUNT_DISK_LSBLK_DISKS_STR// / })
	
	for I in ${!_TMP_RESOLVE_UNMOUNT_DISK_ARR_DISK_POINT[@]};  
	do
		local _TMP_RESOLVE_UNMOUNT_DISK_POINT="/dev/${_TMP_RESOLVE_UNMOUNT_DISK_ARR_DISK_POINT[$I]}"

		# 判断未格式化
		local _TMP_RESOLVE_UNMOUNT_DISK_FORMATED_COUNT=`fdisk -l | grep "^${_TMP_RESOLVE_UNMOUNT_DISK_POINT}" | wc -l`

		if [ ${_TMP_RESOLVE_UNMOUNT_DISK_FORMATED_COUNT} -eq 0 ]; then
			echo "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Checked there's one of disk[$((I+1))/${#_TMP_RESOLVE_UNMOUNT_DISK_ARR_DISK_POINT[@]}] '${_TMP_RESOLVE_UNMOUNT_DISK_POINT}' ${red}not format${reset}"
			echo "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Suggest step："
			echo "                                Type ${green}n${reset}, ${red}enter${reset}"
			echo "                                Type ${green}p${reset}, ${red}enter${reset}"
			echo "                                Type ${green}1${reset}, ${red}enter${reset}"
			echo "                                Type ${red}enter${reset}"
			echo "                                Type ${red}enter${reset}"
			echo "                                Type ${green}w${reset}, ${red}enter${reset}"
			echo "---------------------------------------------"

			fdisk ${_TMP_RESOLVE_UNMOUNT_DISK_POINT}
			
			echo "---------------------------------------------"

			# 格式化：
			mkfs.ext4 ${_TMP_RESOLVE_UNMOUNT_DISK_POINT}

			fdisk -l | grep "^${_TMP_RESOLVE_UNMOUNT_DISK_POINT}"
			echo "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Disk of '${_TMP_RESOLVE_UNMOUNT_DISK_POINT}' ${green}formated${reset}"
	
			echo "---------------------------------------------"
		fi

		# 判断未挂载
		local _TMP_RESOLVE_UNMOUNT_DISK_MOUNTED_COUNT=`df -h | grep "^${_TMP_RESOLVE_UNMOUNT_DISK_POINT}" | wc -l`
		if [ ${_TMP_RESOLVE_UNMOUNT_DISK_MOUNTED_COUNT} -eq 0 ]; then
			echo "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Checked there's one of disk[$((I+1))/${#_TMP_RESOLVE_UNMOUNT_DISK_ARR_DISK_POINT[@]}] '${_TMP_RESOLVE_UNMOUNT_DISK_POINT}' ${red}no mount${reset}"

			# 必要判断项
			# 1：数组为空，检测到所有项都提示
			# 2：数组不为空，多余的略过
			local _TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT=""
			if [ ${#_TMP_RESOLVE_UNMOUNT_DISK_ARR_MOUNT_PATH_PREFIX_STR} -eq 0 ]; then
				input_if_empty "_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT" "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Please ender the disk of '${_TMP_RESOLVE_UNMOUNT_DISK_POINT}' mount path prefix like '/tmp/downloads'"
			else
				_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT=${_TMP_RESOLVE_UNMOUNT_DISK_ARR_MOUNT_PATH_PREFIX[${I}]}
				# [ ${_TMP_RESOLVE_UNMOUNT_DISK_ARR_MOUNT_PATH_PREFIX_LEN} -gt $((I+1)) ];
			fi

			if [ -n "${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT}" ]; then
				# 挂载
				mkdir -pv ${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT}
				echo "${_TMP_RESOLVE_UNMOUNT_DISK_POINT} ${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT} ext4 defaults 0 0" >> /etc/fstab
				mount -a
		
				df -h | grep "${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT}"
				echo "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Disk of '${_TMP_RESOLVE_UNMOUNT_DISK_POINT}' ${green}mounted${reset}"
			else
				echo "${_TMP_RESOLVE_UNMOUNT_DISK_FUNC_TITLE}: Path of '${_TMP_RESOLVE_UNMOUNT_DISK_MOUNT_PATH_PREFIX_CURRENT}' error，the disk '${_TMP_RESOLVE_UNMOUNT_DISK_POINT}' ${red}not mount${reset}"
			fi

			echo "---------------------------------------------"
		fi

	done

	return $?
}

#复制nginx启动器
# 参数1：程序命名
# 参数2：程序启动的目录
# 参数3：程序启动的端口
function cp_nginx_starter()
{
	local _TMP_CP_NGX_STT_NAME=${1}
	local _TMP_CP_NGX_STT_RUNNING_DIR=${2}
	local _TMP_CP_NGX_STT_RUNNING_PORT=${3}

	local _TMP_CP_NGX_STT_CONTAINER_DIR=${NGINX_DIR}/${1}_${3}

	mkdir -pv ${NGINX_DIR}

	echo "Copy '${__DIR}/templates/nginx/server' To '${_TMP_CP_NGX_STT_CONTAINER_DIR}'"
	cp -r ${__DIR}/templates/nginx/server ${_TMP_CP_NGX_STT_CONTAINER_DIR}
	
	if [ ! -d "$_TMP_CP_NGX_STT_RUNNING_DIR" ]; then
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
    echo_startup_config "${_TMP_CP_NGX_STT_NAME}" "${_TMP_CP_NGX_STT_CONTAINER_DIR}" "bash start.sh master" "" "99"

	return $?
}

#生成nginx启动器
function gen_nginx_starter()
{
    local _TMP_GEN_NGX_STT_DATE=`date +%Y%m%d%H%M%S`

    local _TMP_GEN_NGX_STT_BOOT_NAME="tmp"
    local _TMP_GEN_NGX_STT_BOOT_PORT=""
	rand_val "_TMP_GEN_NGX_STT_BOOT_PORT" 1024 2048
    
    input_if_empty "_TMP_GEN_NGX_STT_BOOT_NAME" "NGX_CONF: Please ender application name"
	set_if_empty "_TMP_GEN_NGX_STT_BOOT_NAME" "prj_${_TMP_GEN_NGX_STT_DATE}"
    
    local _TMP_GEN_NGX_STT_NGX_BOOT_PATH="${NGINX_DIR}/${_TMP_GEN_NGX_STT_BOOT_NAME}"
    input_if_empty "_TMP_GEN_NGX_STT_NGX_BOOT_PATH" "NGX_CONF: Please ender application path"
	set_if_empty "_TMP_GEN_NGX_STT_NGX_BOOT_PATH" "${NGINX_DIR}"
    
    input_if_empty "_TMP_GEN_NGX_STT_BOOT_PORT" "Please ender application port Like '8080'"
	set_if_empty "_TMP_GEN_NGX_STT_BOOT_PORT" "${_TMP_GEN_NGX_STT_NGX_CONF_PORT}"

	cp_nginx_starter "${_TMP_GEN_NGX_STT_BOOT_NAME}" "${_TMP_GEN_NGX_STT_NGX_BOOT_PATH}" "${_TMP_GEN_NGX_STT_BOOT_PORT}"
	
	# 添加系统启动命令
    echo_startup_config "ngx_${_TMP_GEN_NGX_STT_BOOT_NAME}" "${_TMP_GEN_NGX_STT_NGX_BOOT_PATH}" "bash start.sh" "" "999"

    # 生成web授权访问脚本
    echo_web_service_init_scripts "${_TMP_GEN_NGX_STT_BOOT_NAME}${LOCAL_ID}" "${_TMP_GEN_NGX_STT_BOOT_NAME}${LOCAL_ID}.${SYS_DOMAIN}" ${_TMP_GEN_NGX_STT_BOOT_PORT} "${LOCAL_HOST}"

	return $?
}

#安装软件基础
# 参数1：软件安装名称
# 参数2：软件安装需调用的函数
function setup_soft_basic()
{
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_SETUP_SOFT_BASIC_CURRENT=`pwd`
	local _TMP_SETUP_SOFT_BASIC_NAME=${1}
	local _TMP_SETUP_SOFT_BASIC_FUNC=${2}

	local _TMP_SETUP_SOFT_BASIC_NAME_LEN=${#_TMP_SETUP_SOFT_BASIC_NAME}
	
	if [ -n "$_TMP_SETUP_SOFT_BASIC_FUNC" ]; then
		local _TMP_SETUP_SOFT_BASIC_SPLITER=""

		fill_right "_TMP_SETUP_SOFT_BASIC_SPLITER" "-" $((_TMP_SETUP_SOFT_BASIC_NAME_LEN+20))
		echo ${_TMP_SETUP_SOFT_BASIC_SPLITER}
		echo "Start to install '${green}${_TMP_SETUP_SOFT_BASIC_NAME}${reset}'"
		echo ${_TMP_SETUP_SOFT_BASIC_SPLITER}

		mkdir -pv ${DOWN_DIR} && cd ${DOWN_DIR}
		$_TMP_SETUP_SOFT_BASIC_FUNC

		echo ${_TMP_SETUP_SOFT_BASIC_SPLITER}
		echo "Install '${green}${_TMP_SETUP_SOFT_BASIC_NAME}${reset}' completed"
		echo ${_TMP_SETUP_SOFT_BASIC_SPLITER}

		cd ${_TMP_SETUP_SOFT_BASIC_CURRENT}
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
		_TMP_PATH_NOT_EXISTS_ACTION_E_SCRIPT="echo_text_style '${_TMP_PATH_NOT_EXISTS_ACTION_E_ECHO}'"
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
			exec_check_action "_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH_Y_SCRIPT" ${_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH}
		}

		# 非path_exists_yn_action调用时才执行，这里保持函数复用
		if [ "${FUNCNAME[1]}" != "path_exists_yn_action" ]; then
			function _path_exists_confirm_action_exec_yn()
			{
				_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH_Y_SCRIPT=''
				
				exec_check_action "_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH_Y_N_SCRIPT" ${_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH}
			}

			confirm_yn_action "_TMP_PATH_EXISTS_CONFIRM_ACTION_YN_VAL" "${_TMP_PATH_EXISTS_CONFIRM_ACTION_ECHO:-"The path of '${_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH}' exists, please sure u will exec action 'still or not'"}" "" "_path_exists_confirm_action_exec_yn"
		fi

		_path_exists_confirm_action_exec
	else
		exec_check_action "_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH_N_SCRIPT" ${_TMP_PATH_EXISTS_CONFIRM_ACTION_PATH}

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

# 执行文本格式化
# 参数1：需要格式化的变量名
# 参数2：格式化字符串规格
# 示例：
#	TMP_TEST_STYLED_TEXT="[Hello] world"
#	exec_text_style "TMP_TEST_STYLED_TEXT" "red"
#	echo "The styled text is ‘$TMP_TEST_STYLED_TEXT’"
function exec_text_style()
{
	local _TMP_EXEC_TEXT_STYLE_VAR_NAME=${1}
	local _TMP_EXEC_TEXT_STYLE_VAR_STYLE=${2} #${2:-"${red}"}
	# local _TMP_EXEC_TEXT_STYLE_VAR_VAL=`eval echo '${'${_TMP_EXEC_TEXT_STYLE_VAR_NAME}'/ /}'`
	local _TMP_EXEC_TEXT_STYLE_VAR_VAL=`eval echo '$'${_TMP_EXEC_TEXT_STYLE_VAR_NAME}`

	function _TMP_EXEC_TEXT_STYLE_WRAP_FUNC() {
		local _TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_LEFT=${1}
		local _TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_RIGHT=${1}
		local _TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_ESCAPE='\'
		local _TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_STYLE="${_TMP_EXEC_TEXT_STYLE_VAR_STYLE}"

		function _TMP_EXEC_TEXT_STYLE_NORMAL_FUNC() {
			if [ -z "$(echo ${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_STYLE} | grep -vE '[0-9]+')" ]; then
				_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_STYLE=""
			fi

			_TMP_EXEC_TEXT_STYLE_MATCH_STYLE_ITEM="${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_STYLE:-"${red}"}${_TMP_EXEC_TEXT_STYLE_MATCH_STYLE_ITEM}${reset}"

			return $?
		}
		
		function _TMP_EXEC_TEXT_STYLE_GUM_FUNC() {
			# Gum模式存在默认样式，普通模式不存在
			_TMP_EXEC_TEXT_STYLE_MATCH_STYLE_ITEM=$(gum style --foreground ${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_STYLE:-"${GUM_INPUT_PROMPT_FOREGROUND}"} "${_TMP_EXEC_TEXT_STYLE_MATCH_STYLE_ITEM}")

			return $?
		}

		case ${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_LEFT} in
		'[')
			# 加入转义符
			_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_LEFT='['
			_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_RIGHT=']'
			# 紫红
			_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_STYLE=${_TMP_EXEC_TEXT_STYLE_VAR_STYLE:-"201"}
		;;
		# '{')
		# 	_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_LEFT='{'
		# 	_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_RIGHT='}'
		# ;;
		'<')
			_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_LEFT='<'
			_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_RIGHT='>'
			_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_ESCAPE=''
			# 红色
			_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_STYLE=${_TMP_EXEC_TEXT_STYLE_VAR_STYLE:-"202"}
		;;
		'"')
			_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_RIGHT='"'
		;;
		*)
			_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_ESCAPE=''
		esac

		local _TMP_EXEC_TEXT_STYLE_WRAP_FUNC_SAVEIFS=$IFS   # Save current IFS
		IFS=$'\n'      # Change IFS to new line

		local _TMP_EXEC_TEXT_STYLE_WRAP_FUNC_ITEM_LEFT="${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_ESCAPE}${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_LEFT}"
		local _TMP_EXEC_TEXT_STYLE_WRAP_FUNC_ITEM_RIGHT="${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_ESCAPE}${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_RIGHT}"
		local _TMP_EXEC_TEXT_STYLE_WRAP_FUNC_ITEM_REGEX="${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_ITEM_LEFT}[^${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_ITEM_LEFT}]+${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_ITEM_RIGHT}"
		# local _TMP_EXEC_TEXT_STYLE_MATCH_PREFIX=`echo "${_TMP_EXEC_TEXT_STYLE_VAR_VAL}" | egrep -o '^\[[^]]+\]'`
		# wrap类型 [] <>
		local _TMP_EXEC_TEXT_STYLE_MATCH_ITEM_ARR=(`echo "${_TMP_EXEC_TEXT_STYLE_VAR_VAL}" | egrep -o "${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_ITEM_REGEX}"`)
		for _TMP_EXEC_TEXT_STYLE_MATCH_ITEM in ${_TMP_EXEC_TEXT_STYLE_MATCH_ITEM_ARR[@]}; do
			local _TMP_EXEC_TEXT_STYLE_MATCH_STYLE_ITEM="${_TMP_EXEC_TEXT_STYLE_MATCH_ITEM}"
			if [ -n "${_TMP_EXEC_TEXT_STYLE_MATCH_STYLE_ITEM}" ]; then
				# 清除第一个]及其左边字符串
				# echo "${A/\[reset_os\]/}" 
				trim_str "_TMP_EXEC_TEXT_STYLE_MATCH_STYLE_ITEM" "${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_ITEM_LEFT}"
				if [ "${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_LEFT}" != "${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_CHAR_RIGHT}" ]; then
					trim_str "_TMP_EXEC_TEXT_STYLE_MATCH_STYLE_ITEM" "${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_ITEM_RIGHT}"
				fi
				
				local _TMP_EXEC_TEXT_STYLE_MATCH_TRIMED_ITEM="${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_ITEM_LEFT}${_TMP_EXEC_TEXT_STYLE_MATCH_STYLE_ITEM}${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_ITEM_RIGHT}"
				path_exists_yn_action "${GUM_PATH}" "_TMP_EXEC_TEXT_STYLE_GUM_FUNC" "_TMP_EXEC_TEXT_STYLE_NORMAL_FUNC"	

				_TMP_EXEC_TEXT_STYLE_VAR_VAL=`echo ${_TMP_EXEC_TEXT_STYLE_VAR_VAL/${_TMP_EXEC_TEXT_STYLE_MATCH_TRIMED_ITEM}/${_TMP_EXEC_TEXT_STYLE_MATCH_STYLE_ITEM}}`
			fi
		done

		IFS=${_TMP_EXEC_TEXT_STYLE_WRAP_FUNC_SAVEIFS}   # Restore IFS

		return $?
	}

	# 自动样式化消息
	_TMP_EXEC_TEXT_STYLE_WRAP_FUNC "["
	_TMP_EXEC_TEXT_STYLE_WRAP_FUNC "<"
	_TMP_EXEC_TEXT_STYLE_WRAP_FUNC "'"
	_TMP_EXEC_TEXT_STYLE_WRAP_FUNC '"'
	# _TMP_EXEC_TEXT_STYLE_WRAP_FUNC "{"

	eval ${_TMP_EXEC_TEXT_STYLE_VAR_NAME}='${_TMP_EXEC_TEXT_STYLE_VAR_VAL}'

	return $?
}

# 输出文本格式化
# 参数1：需要格式化的变量名
# 参数2：格式化字符串规格
# 示例：
#	TMP_ECHO_TEXT_STYLED_TEXT="[Hello] 'World'"
#	echo_text_style "TMP_ECHO_TEXT_STYLED_TEXT"
function echo_text_style() {
	local _TMP_EXEC_TEXT_STYLE_VAL="${1}"
	exec_text_style "_TMP_EXEC_TEXT_STYLE_VAL" "${2}"
	echo ${_TMP_EXEC_TEXT_STYLE_VAL}
	
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
		exec_check_action "_TMP_PATH_NOT_EXISTS_CREATE_SCRIPT" "${_TMP_PATH_NOT_EXISTS_CREATE_PATH}"
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
	local _TMP_PATH_NOT_EXISTS_LINK_ECHO=${2:-"The link of '${1}' exists."}
	local _TMP_PATH_NOT_EXISTS_LINK_SOUR=${3}
	local _TMP_PATH_NOT_EXISTS_LINK_SCRIPT=${4}

	function _path_not_exists_link()
	{
		exec_check_action "_TMP_PATH_NOT_EXISTS_LINK_SCRIPT" "${_TMP_PATH_NOT_EXISTS_LINK_SOUR}" "${_TMP_PATH_NOT_EXISTS_LINK_PATH}"
	}
	
    path_not_exists_action "${_TMP_PATH_NOT_EXISTS_LINK_PATH}" "mkdir -pv `dirname ${_TMP_PATH_NOT_EXISTS_LINK_PATH}` && ln -sf ${_TMP_PATH_NOT_EXISTS_LINK_SOUR} ${_TMP_PATH_NOT_EXISTS_LINK_PATH} && _path_not_exists_link" "${_TMP_PATH_NOT_EXISTS_LINK_ECHO}"
	return $?
}

# 软件安装的路径还原（因为很多路径可能存在于手动创建，所以该功能针对于备份后的还原）
# 参数1：还原路径
# 参数2：提示文本
# 参数3：不存在备份，执行脚本
# 参数4：存在备份，执行脚本
# 示例：
#	   soft_path_restore_confirm_action "/opt/docker" "" "echo 'create_dir'" "echo 'exec_restore'"
#      -> [setup_docker] Checked current soft got some backup path for '/opt/docker', please sure u want to 'restore still or not'?
#      --> [setup_docker] Please sure 'which version' u want to 'restore', by follow keys, then enter it
#      ---> |>[1]1669633047
#      soft_path_restore_confirm_action "/etc/docker"
function soft_path_restore_confirm_action() 
{
	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC="${FUNCNAME[1]}"
	if [ "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}" == "soft_path_restore_confirm_create" ] || [ "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}" == "soft_path_restore_confirm_move" ] || [ "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}" == "soft_path_restore_confirm_copy" ] || [ "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}" == "soft_path_restore_confirm_swap" ]; then
		_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC="${FUNCNAME[2]}"
	fi

	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH="${1}"
	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_CONFIRM_ECHO="${2:-"([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) Checked current soft got some backup path for <${1}>, please sure u want to 'restore still or not'"}"
	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_N_SCRIPTS=${3}
	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_E_SCRIPTS=${4}

	local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_PATH="${BACKUP_DIR}${1}"
	function _soft_path_restore_confirm_action_restore_exec()
	{
		local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_VERS=`ls ${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_PATH} | sort -rV`
		local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_VER=`echo "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_VERS}" | awk 'NR==1'`

		## 提示&选择查找存在备份的最新文件
		# 参数1：检测到的备份文件的路径，例如：/tmp/backup/opt/docker/1666083394
		function _soft_path_restore_confirm_action_restore_choice_exec()
		{
			# 覆盖目录
			# 参数1：操作目录，例如：/opt/docker
			function _soft_path_restore_confirm_action_restore_choice_cover_exec()
			{
				set_if_choice "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_VER" "([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) Please sure 'which version' of the path of '${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}' u want to [restore]" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_VERS}"

				local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_RESTORE_PATH="${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_PATH}/${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_VER}"

				echo
				echo_text_style "([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) Starting resotre the path of '${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_RESTORE_PATH}' to <${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}>"
				
				# 直接覆盖，进cover
				# [formal_docker] Checked current soft already got the path of '/etc/docker', please sure u want to 'cover still or force'?
				local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_COVER_SCRIPT="[[ -a '%s' ]] && (mkdir -pv ${COVER_DIR}%s && cp -Rp %s ${COVER_DIR}%s/${LOCAL_TIMESTAMP} && rsync -av ${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_RESTORE_PATH}/ %s  && echo_text_style 'Dir of <%s> backuped to <${COVER_DIR}%s/${_TMP_SOFT_TRAIL_CLEAR_CURRENT_TIME_STAMP}>') || cp -Rp ${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_RESTORE_PATH} %s"
				local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_COVER_SCRIPT="${1}"
				exec_text_printf "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_COVER_SCRIPT" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_COVER_SCRIPT}"

				# 文件不存在，直接复制
				exec_check_action "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_COVER_SCRIPT"
				exec_check_action "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_E_SCRIPTS" "${1}" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_RESTORE_PATH}"
				
				echo_text_style "([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) The path of '${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_RESTORE_PATH}' was resotred"
				echo
			}

			# 备份到强制，然后删除
			# 参数1：操作目录，例如：/opt/docker
			function _soft_path_restore_confirm_action_restore_choice_force_exec()
			{
				# 移动到备份，再覆盖
				local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_FORCE_SCRIPT="[[ -a '%s' ]] && (mkdir -pv ${FORCE_DIR}%s && cp -Rp %s ${FORCE_DIR}%s/${LOCAL_TIMESTAMP} && rm -rf %s && echo_text_style 'Dir of <%s> was force deleted。if u want to restore，please find it by yourself to <${FORCE_DIR}%s/${LOCAL_TIMESTAMP}>') || echo_text_style 'Force delete dir <%s> not found'"

				local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_FORCE_SCRIPT="${1}"
				exec_text_printf "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_FORCE_SCRIPT" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_FORCE_SCRIPT}"

				exec_check_action "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_FORCE_SCRIPT"
				_soft_path_restore_confirm_action_restore_choice_cover_exec "${@}"
			}

			# 还原目标路径本身存在，移至强行删除目录中（如果是走安装程序过来，会被提前备份，不会触发此段）
			# 走到这步，已选择还原备份（是否覆盖还原/强制还原的过程，强制还原始终执行覆盖还原的逻辑）
			local _TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_COVER_ECHO="([${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PREV_FUNC}]) Checked current soft already got the path of '${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}', please sure u want to 'cover still or force'"
			path_exists_confirm_action "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_PRINTF_COVER_ECHO}" "_soft_path_restore_confirm_action_restore_choice_cover_exec" "_soft_path_restore_confirm_action_restore_choice_force_exec" "_soft_path_restore_confirm_action_restore_choice_cover_exec" "N"
		}
		
		path_exists_confirm_action "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_PATH}/${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_VER:-"none"}" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_CONFIRM_ECHO}" "_soft_path_restore_confirm_action_restore_choice_exec" "_soft_path_restore_confirm_action_create_exec" "_soft_path_restore_confirm_action_create_exec" "Y"
	}
	
	# 参数1：检测到的备份文件的路径，例如：/tmp/backup/opt/docker/1666083394
	function _soft_path_restore_confirm_action_create_exec()
	{
		exec_check_action "_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_N_SCRIPTS" "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_PATH}" "${1}"
	}

	# 查找备份是否存在
	path_exists_yn_action "${_TMP_SOFT_PATH_RESTORE_CONFIRM_ACTION_SOFT_BACKUP_PATH}" "_soft_path_restore_confirm_action_restore_exec" "_soft_path_restore_confirm_action_create_exec"

	return $?
}

# 软件安装的路径还原创建（还原不存在则创建）
# 参数1：还原路径
# 示例：
#	   soft_path_restore_confirm_create "/opt/docker"
function soft_path_restore_confirm_create() 
{
	soft_path_restore_confirm_action "${1}" "" "mkdir -pv ${1}" ""
	return $?
}

# 软件安装的路径还原复制（还原不存在则复制）
# 参数1：还原路径
# 参数2：来源路径
# 示例：
#	   soft_path_restore_confirm_copy "/mountdisk/data/docker" "/var/lib/docker" 
function soft_path_restore_confirm_copy() 
{
	soft_path_restore_confirm_action "${1}" "" "mkdir -pv `dirname ${1}` && cp -Rp ${2} ${1}" ""
	return $?
}

# 软件安装的路径还原移动（还原不存在则移动、存在则删除。适配来源路径不需要备份且来源路径一直存在的场景，自动软链）
# 参数1：还原路径
# 参数2：来源路径
# 示例：
#	   soft_path_restore_confirm_move "/mountdisk/data/docker_empty" "/var/lib/docker" 
function soft_path_restore_confirm_move() 
{
	soft_path_restore_confirm_action "${1}" "" "mkdir -pv `dirname ${1}` && cp -Rp ${2} ${1} && rm -rf ${2} && ln -sf ${1} ${2}" "rm -rf ${2} && ln -sf ${1} ${2}"
	return $?
}

# 软件安装的路径还原迁移（还原不存在则迁移且移动并备份原始目录，适配来源路径需要备份且来源路径一直存在的场景，自动软链）
# 参数1：还原路径
# 参数2：来源路径(为空则默认取还原路径)
# 示例：
#	   soft_path_restore_confirm_swap "/mountdisk/data/docker" "/var/lib/docker" 
function soft_path_restore_confirm_swap() 
{
	soft_path_restore_confirm_action "${1}" "" "mkdir -pv `dirname ${1}` && cp -Rp ${2} ${1} && mv ${2} ${1}_clean_${LOCAL_TIMESTAMP} && ln -sf ${1} ${2}" "mv ${2} ${1}_clean_${LOCAL_TIMESTAMP} && ln -sf ${1} ${2}"
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
	typeset -u _TMP_SOFT_TRAIL_CLEAR_FORCE
	local _TMP_SOFT_TRAIL_CLEAR_FORCE=${2:-"N"}
	local _TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR=()
	local _TMP_SOFT_TRAIL_CLEAR_SOFT_REALLY_DIR_ARR=()

	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[0]="/var/lib/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[1]="/var/log/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[2]="/run/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[3]="/etc/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[4]="/home/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[5]="/run/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[6]="${DATA_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[7]="${ATT_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[8]="${SETUP_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
	_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[9]="${LOGS_DIR}/${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"

	# 备份文件	
	## 获取软链接后的真实路径
	### Record really dir of </mountdisk/data/docker> from source link </mountdisk/data/docker -> /var/lib/docker>
	### Checked dir of </var/lib/docker> is a symlink for really dir </mountdisk/data/docker>, sys deleted.
	### Record really dir of </run/docker> from source link </var/run/docker -> /var/run/docker>
	### Record really dir of </etc/docker> from source link </etc/docker -> /etc/docker>
	### Record really dir of </mountdisk/logs/docker> from source link </mountdisk/logs/docker -> /mountdisk/logs/docker>
	### Checked dir of </mountdisk/etc/docker> is a symlink for really dir </etc/docker>, sys deleted.
	### Record really dir of </opt/docker> from source link </opt/docker -> /opt/docker>
	echo "${TMP_SPLITER3}"
	echo_text_style "Starting 'resolve the dirs' of soft <${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}>"
	for _TMP_SOFT_TRAIL_CLEAR_DIR_INDEX in ${!_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[@]};  
	do
		# 指定链接
		local _TMP_SOFT_TRAIL_CLEAR_SYM_DIR="${_TMP_SOFT_TRAIL_CLEAR_SOFT_SOURCE_DIR_ARR[${_TMP_SOFT_TRAIL_CLEAR_DIR_INDEX}]}"

		# 真实链接
		local _TMP_SOFT_TRAIL_CLEAR_LNK_DIR="${_TMP_SOFT_TRAIL_CLEAR_SYM_DIR}"
		symlink_link_path "_TMP_SOFT_TRAIL_CLEAR_LNK_DIR"

		# 如果数组中不存在指定链接，则添加
		local _TMP_SOFT_TRAIL_CLEAR_PREFIX=""
		function _soft_trail_clear_record_rel_arr()
		{
			if [ -a ${_TMP_SOFT_TRAIL_CLEAR_LNK_DIR} ]; then
				# 绝对链接
				local _TMP_SOFT_TRAIL_CLEAR_ABS_DIR=$(su -c "cd ${_TMP_SOFT_TRAIL_CLEAR_LNK_DIR} && pwd -P")
				if [ "${_TMP_SOFT_TRAIL_CLEAR_SYM_DIR}" != "${_TMP_SOFT_TRAIL_CLEAR_ABS_DIR}" ]; then
					_TMP_SOFT_TRAIL_CLEAR_PREFIX="|"
				fi

				echo_text_style "Record really dir of [${_TMP_SOFT_TRAIL_CLEAR_ABS_DIR}], marked '${_TMP_SOFT_TRAIL_CLEAR_SYM_DIR}' -> '${_TMP_SOFT_TRAIL_CLEAR_LNK_DIR}'"
				_TMP_SOFT_TRAIL_CLEAR_SOFT_REALLY_DIR_ARR[${#_TMP_SOFT_TRAIL_CLEAR_SOFT_REALLY_DIR_ARR[@]}]="${_TMP_SOFT_TRAIL_CLEAR_ABS_DIR}"
			fi
		}
		
		action_if_item_not_exists "^${_TMP_SOFT_TRAIL_CLEAR_LNK_DIR}$" "${_TMP_SOFT_TRAIL_CLEAR_SOFT_REALLY_DIR_ARR[*]}" "_soft_trail_clear_record_rel_arr"

		# 如果是软链接，直接删除
		if [ "${_TMP_SOFT_TRAIL_CLEAR_SYM_DIR}" != "${_TMP_SOFT_TRAIL_CLEAR_LNK_DIR}" ]; then
			echo_text_style "${_TMP_SOFT_TRAIL_CLEAR_PREFIX}Checked dir of '${_TMP_SOFT_TRAIL_CLEAR_SYM_DIR}' is a symlink for really dir <${_TMP_SOFT_TRAIL_CLEAR_LNK_DIR}>, sys [deleted]."
			echo 
			rm -rf ${_TMP_SOFT_TRAIL_CLEAR_SYM_DIR}
		fi
	done
	
	if [ ${#_TMP_SOFT_TRAIL_CLEAR_SOFT_REALLY_DIR_ARR} -gt 0 ]; then
		echo_text_style "The 'soft dirs' of <${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}> was resolved"
	else
		echo_text_style "None 'soft dirs found for trail' in <${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}>"
	fi
	echo

	# 备份 && 删除文件
	local _TMP_SOFT_TRAIL_CLEAR_CURRENT_TIME=`date "+%Y-%m-%d %H:%M:%S"`
	local _TMP_SOFT_TRAIL_CLEAR_CURRENT_TIME_STAMP=`date -d "${_TMP_SOFT_TRAIL_CLEAR_CURRENT_TIME}" +%s` 
	local _TMP_SOFT_TRAIL_CLEAR_BACKUP_SCRIPT="[[ -a '%s' ]] && (mkdir -pv ${BACKUP_DIR}%s && cp -Rp %s ${BACKUP_DIR}%s/${_TMP_SOFT_TRAIL_CLEAR_CURRENT_TIME_STAMP} && rm -rf %s && echo_text_style 'Dir of <%s> [backuped] to <${BACKUP_DIR}%s/${_TMP_SOFT_TRAIL_CLEAR_CURRENT_TIME_STAMP}>') || echo_text_style 'Backup dir <%s> not found'"
	# local _TMP_SOFT_TRAIL_CLEAR_FORCE_SCRIPT=${_TMP_SOFT_TRAIL_CLEAR_SOFT_SCRIPT//tmp\/backup/tmp\/force}
	local _TMP_SOFT_TRAIL_CLEAR_FORCE_SCRIPT="[[ -a '%s' ]] && (mkdir -pv ${FORCE_DIR}%s && cp -Rp %s ${FORCE_DIR}%s/${_TMP_SOFT_TRAIL_CLEAR_CURRENT_TIME_STAMP} && rm -rf %s && echo_text_style 'Dir of <%s> was [force deleted]。if u want to restore，please find it by yourself to <${FORCE_DIR}%s/${_TMP_SOFT_TRAIL_CLEAR_CURRENT_TIME_STAMP}>') || echo_text_style 'Force delete dir <%s> not found'"
	function _soft_trail_clear_exec_backup()
	{
		local _TMP_SOFT_TRAIL_CLEAR_SOFT_NOTICE="([${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}]) Checked the trail dir of '${1}', please sure u will 'backup still or not'"

		local _TMP_SOFT_TRAIL_CLEAR_PRINTF_BACKUP_SCRIPT="${1}"
		exec_text_printf "_TMP_SOFT_TRAIL_CLEAR_PRINTF_BACKUP_SCRIPT" "${_TMP_SOFT_TRAIL_CLEAR_BACKUP_SCRIPT}"
		local _TMP_SOFT_TRAIL_CLEAR_PRINTF_FORCE_SCRIPT="${1}"
		exec_text_printf "_TMP_SOFT_TRAIL_CLEAR_PRINTF_FORCE_SCRIPT" "${_TMP_SOFT_TRAIL_CLEAR_FORCE_SCRIPT}"

		# [docker]Checked the trail dir of '/mountdisk/data/docker', please sure u will 'backup still or not'?
		# Dir of </mountdisk/data/docker> backuped to </tmp/backup/mountdisk/data/docker/1669793077>
		path_exists_confirm_action "${1}" "${_TMP_SOFT_TRAIL_CLEAR_SOFT_NOTICE}" "${_TMP_SOFT_TRAIL_CLEAR_PRINTF_BACKUP_SCRIPT}" "${_TMP_SOFT_TRAIL_CLEAR_PRINTF_FORCE_SCRIPT}" "echo_text_style 'Do nothing for dir <${1}>'" "Y"
	}
	
	# 有记录的情况下才执行
	if [ ${#_TMP_SOFT_TRAIL_CLEAR_SOFT_REALLY_DIR_ARR} -gt 0 ]; then
		# 已经进入清理流程，不管选择是否备份。都要执行删除服务
		function _soft_trail_clear_svr_remove_all()
		{
			## 清理服务残留（备份前执行，否则会有资源占用的问题）
			function _soft_trail_clear_svr_remove() 
			{
				echo "${TMP_SPLITER3}"
				echo_text_style "Starting 'remove the systemctl' of <${1}>"
				systemctl stop ${1} && systemctl disable ${1} && rm -rf /usr/lib/systemd/system/${1} && rm -rf /etc/systemd/system/multi-user.target.wants/${1}
				echo_text_style "The 'systemctl' of <${1}> was removed"
			}

			# export -f _soft_trail_clear_svr_remove
			# systemctl list-unit-files | grep ${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME} | cut -d' ' -f1 | grep -v '^$' | sort -r | xargs -I {} bash -c "_soft_trail_clear_svr_remove {}"
			systemctl list-unit-files | grep ${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME} | cut -d' ' -f1 | grep -v '^$' | sort -r | eval "exec_channel_action '_soft_trail_clear_svr_remove'"
			echo "${TMP_SPLITER3}"
		}
		
		echo "${TMP_SPLITER3}"
		echo_text_style "Starting 'trail the soft dirs' of <${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}>"
		if [ "${_TMP_SOFT_TRAIL_CLEAR_FORCE}" == "N" ]; then
			## 具备特殊性质的备份，优先执行
			local _TMP_SOFT_TRAIL_CLEAR_SPECIAL_FUNC="special_backup_${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
			if [ "$(type -t ${_TMP_SOFT_TRAIL_CLEAR_SPECIAL_FUNC})" == "function" ] ; then
				echo "${TMP_SPLITER3}"
				echo_text_style "Starting exec the 'soft special func' of <${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}>"
				exec_check_action "_TMP_SOFT_TRAIL_CLEAR_SPECIAL_FUNC" "${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}"
				echo_text_style "The 'soft special func' of <${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}> was executed"
			fi

			_soft_trail_clear_svr_remove_all

			exec_split_action "${_TMP_SOFT_TRAIL_CLEAR_SOFT_REALLY_DIR_ARR[*]}" "_soft_trail_clear_exec_backup"
		else
			_soft_trail_clear_svr_remove_all

			exec_split_action "${_TMP_SOFT_TRAIL_CLEAR_SOFT_REALLY_DIR_ARR[*]}" "${_TMP_SOFT_TRAIL_CLEAR_FORCE_SCRIPT}"
		fi

		echo_text_style "The 'soft dirs trail' of <${_TMP_SOFT_TRAIL_CLEAR_SOFT_NAME}> was executed"
		echo
	fi

	systemctl daemon-reload

	return $?
}

# 创建 docker 快照
# 参数1：容器ID，例 e75f9b427730
# 参数2：快照存放路径，例 /mountdisk/repo/migrate/snapshot
# 参数3：快照存储的时间戳，例 1670329246
# 参数4：创建完执行
# 例：
#    docker_snap_create_action 'e75f9b427730' '/mountdisk/repo/migrate/snapshot' '1670329246'
function docker_snap_create_action()
{
	# 完整的PSID
	local _TMP_DOCKER_SNAP_CREATE_PS_ID=$(docker ps -a --no-trunc | grep ${1} | cut -d' ' -f1)
	# browserless/chrome
	local _TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME=$(docker container inspect ${_TMP_DOCKER_SNAP_CREATE_PS_ID} -f {{".Config.Image"}})
	# browserless/chrome
	local _TMP_DOCKER_SNAP_CREATE_IMG_NAME=$(echo "${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}" | cut -d':' -f1)
	# browserless_chrome
	local _TMP_DOCKER_SNAP_CREATE_IMG_REL_NAME=${_TMP_DOCKER_SNAP_CREATE_IMG_NAME/\//_}
	# browserless_chrome/1670329246
	local _TMP_DOCKER_SNAP_CREATE_FILE_REL_PATH=${_TMP_DOCKER_SNAP_CREATE_IMG_REL_NAME}/${3}
	# /mountdisk/repo/migrate/snapshot/browserless_chrome/1670329246
	local _TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH=${2}/${_TMP_DOCKER_SNAP_CREATE_FILE_REL_PATH}
	
	echo_text_style "([docker_snap_create_action]) Starting make snapshot <${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}>([${_TMP_DOCKER_SNAP_CREATE_PS_ID}]) to '${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.(ctn.gz/img.tar)'"
	
	mkdir -pv `dirname ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}`

	# 备份容器信息
	docker container inspect ${_TMP_DOCKER_SNAP_CREATE_PS_ID} > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.inspect.ctn.json
	docker container export ${_TMP_DOCKER_SNAP_CREATE_PS_ID} | gzip > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.ctn.gz
	## 打开后不是标准json格式，先格式化！
	### :%!python -m json.tool
	local _TMP_DOCKER_SNAP_CREATE_SETUP_DATA_DIR=$(docker info | grep "Docker Root Dir" | cut -d':' -f2 | tr -d ' ')
	cp ${_TMP_DOCKER_SNAP_CREATE_SETUP_DATA_DIR}/containers/${_TMP_DOCKER_SNAP_CREATE_PS_ID}/config.v2.json ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.config.v2.json

	# 备份镜像信息
	docker inspect ${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME} > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.inspect.img.json
	docker save ${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME} > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.img.tar

	# 初始化依赖分析(取最后一天时间为起始)
    echo "${TMP_SPLITER2}"
    echo_text_style "Starting gen 'update container & install dependency' script"
	## 管道运行出现的错误太多，故改为脚本形式操作（EOF带双引号时可以不进行转义）
	# tee ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.extract.sh <<EOF
	cat > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.extract.sh << 'EOF'
#!/bin/bash

func_backup_current_image_init_script()
{
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
}

func_backup_current_image_init_script
EOF

	# 更新并安装容器依赖（应用到bc命令时需要，参考上述脚本。注意安装bc操作可能会覆盖了初始化段落）
	# docker exec -u root -it ${_TMP_DOCKER_SNAP_CREATE_PS_ID} sh -c "apt-get update && apt-get -y -qq install bc"

	# 拷贝提取脚本至容器
	docker cp ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.extract.sh ${_TMP_DOCKER_SNAP_CREATE_PS_ID}:/tmp
	ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.extract.sh
	rm -rf ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.extract.sh
	
	# 执行提取脚本，获得原始提取操作命令，并清理二进制报错
	echo "#!/bin/bash" > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh.tmp
	docker exec -u root -i ${_TMP_DOCKER_SNAP_CREATE_PS_ID} sh -c "sh /tmp/${3}.init.extract.sh && rm -rf /tmp/${3}.init.extract.sh" >> ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh.tmp
	grep -v "^tail: cannot open" ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh.tmp > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh
	ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh
	echo "[-]"
	cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh
	rm -rf ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.init.depend.sh.tmp

	# 提取容器启动命令
    echo "${TMP_SPLITER2}"
    echo_text_style "Starting make 'container boot' script"
	docker ps -a --no-trunc | grep ${_TMP_DOCKER_SNAP_CREATE_PS_ID} | cut -d' ' -f7 | grep -oP "(?<=^\").*(?=\"$)" > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.cmd
	ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.cmd
	echo "[-]"
	cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.cmd
	
    echo "${TMP_SPLITER2}"
    echo_text_style "Starting pull 'dockerfile builder'"
	# 判断是否存在dockerfile操作工具
	# alpine/dfimage是一个镜像，是由Whaler 工具构建而来的。主要功能有：
	# 【1】从一个docker镜像生成Dockerfile内容
	# 【2】搜索添加的文件名以查找潜在的秘密文件
	# 【3】提取Docker ADD/COPY指令添加的文件
	# 【4】展示暴露的端口、环境变量信息等等。
	local _TMP_DOCKER_SNAP_ALISA_BASE="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock"
	if [ -z "$(docker images | grep 'alpine/dfimage')" ]; then
		docker pull alpine/dfimage

		# dfimage -sV=1.36 nginx:latest
		echo "alias dfimage='${_TMP_DOCKER_SNAP_ALISA_BASE} alpine/dfimage'" >> /etc/bashrc
		echo
	fi

	if [ -z "$(docker images | grep 'cucker/image2df')" ]; then
		docker pull cucker/image2df

		echo "alias image2df='${_TMP_DOCKER_SNAP_ALISA_BASE} cucker/image2df'" >> /etc/bashrc
		echo
	fi

	# 如果想要更加详细的内容，比如每一层的信息，以及每一层对应的文件增减情况，那么dive工具可以帮助我们更好的分析镜像。
	# dive用于探索docker镜像、layer内容和发现缩小docker/OCI镜像大小的方法的工具。
	# 左边是镜像和layer的信息，右边是当前选中镜像layer对应的文件磁盘文件信息，右边是会根据左边的选择变动的，比如我在某一层进行了文件的复制新增或者删除，右边会以不同的颜色进行展示的。
	if [ -z "$(docker images | grep 'wagoodman/dive')" ]; then
		docker pull wagoodman/dive
		
		alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
		# dive nginx:latest
		echo "alias dive='${_TMP_DOCKER_SNAP_ALISA_BASE} wagoodman/dive'" >> /etc/bashrc
		echo
	fi
	source /etc/bashrc
	
	# 将容器打包成镜像
    local _TMP_DOCKER_SNAP_CREATE_SNAP_NAME="${_TMP_DOCKER_SNAP_CREATE_IMG_NAME}:v${3}"
	echo "${TMP_SPLITER2}"
	echo_text_style "View the 'container commit (${_TMP_DOCKER_SNAP_CREATE_SNAP_NAME})'↓:"
	## 统计镜像数，根据不同情况下的提交，做不同的镜像标记
	### 第一次提交的情况下则做标记：SMI(snap commit init)，备份标记则为SMB(snap commit backup)，还原标记则为SR(Snap restore c/i/d)
	local _TMP_DOCKER_SNAP_CREATE_SNAP_VCOUNT=$(docker images | grep "${_TMP_DOCKER_SNAP_CREATE_IMG_NAME}" | grep -v "latest" | wc -l)
	if [ ${_TMP_DOCKER_SNAP_CREATE_SNAP_VCOUNT} -eq 0 ]; then
		_TMP_DOCKER_SNAP_CREATE_SNAP_NAME="${_TMP_DOCKER_SNAP_CREATE_SNAP_NAME}SMI"
	else
		_TMP_DOCKER_SNAP_CREATE_SNAP_NAME="${_TMP_DOCKER_SNAP_CREATE_SNAP_NAME}SMB"
	fi
	docker commit -a "unity-special_backup" -m "backup at ${3}" ${_TMP_DOCKER_SNAP_CREATE_PS_ID} ${_TMP_DOCKER_SNAP_CREATE_SNAP_NAME}

	echo "${TMP_SPLITER2}"
	echo_text_style "Source History <${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}>"
	docker history ${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}

	echo "${TMP_SPLITER2}"
	echo_text_style "Commit History <${_TMP_DOCKER_SNAP_CREATE_SNAP_NAME}>"
	docker history ${_TMP_DOCKER_SNAP_CREATE_SNAP_NAME}

	# 输出构建yml(docker build -f /mountdisk/repo/migrate/snapshot/browserless_chrome/1670329246.dockerfile.yml -t browserless/chrome .)
	echo "${TMP_SPLITER2}"
	echo_text_style "View the 'build dfimage yaml' <${_TMP_DOCKER_SNAP_CREATE_SNAP_NAME}>'↓:"
	## dfimage 部分
	${_TMP_DOCKER_SNAP_ALISA_BASE} alpine/dfimage ${_TMP_DOCKER_SNAP_CREATE_SNAP_NAME} | sed "s/# buildkit//g" > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.dfimage.md
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
	echo_text_style "View the 'build image2df yaml' <${_TMP_DOCKER_SNAP_CREATE_SNAP_NAME}>'↓:"
	${_TMP_DOCKER_SNAP_ALISA_BASE} cucker/image2df ${_TMP_DOCKER_SNAP_CREATE_SNAP_NAME} | sed "s/# buildkit//g" > ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.image2df.yml
	ls -lia ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.image2df.yml
	echo "[-]"
	cat ${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}.image2df.yml
	
	# 创建完执行
	echo
	exec_check_action "${4}" "${_TMP_DOCKER_SNAP_CREATE_PS_ID}" "${_TMP_DOCKER_SNAP_CREATE_IMG_FULL_NAME}" "${_TMP_DOCKER_SNAP_CREATE_FILE_NONE_PATH}" "${3}"

	return $?
}

# 还原 Docker 快照
# 参数1：镜像名称，例 browserless/chrome
# 参数2：还原快照后后执行脚本
#       参数1：镜像名称，例 browserless/chrome
#       参数2：快照版本，例 latest/1673604625
#       参数3：快照类型，例 image/container/dockerfile
#       参数4：快照来源，例 snapshot/clean，默认snapshot
# 参数3：快照不存在时执行脚本
# 参数4：快照存放类别，例 snapshot/clean，默认snapshot
# 例：
#   docker_snap_restore_if_choice_action "browserless/chrome" "clean"
function docker_snap_restore_if_choice_action()
{
    # browserless/chrome
    # local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_IMG_NAME="${1}"
    # browserless_chrome
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_IMG_MARK_NAME="${1/\//_}"	
    # snapshot or clean
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_STORE_TYPE="${4}"
	# /mountdisk/repo/migrate/clean/browserless_chrome/
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_CLEAN_DIR="${MIGRATE_DIR}/clean/${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_IMG_MARK_NAME}"
	# /mountdisk/repo/migrate/snapshot/browserless_chrome/
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_SNAP_DIR="${MIGRATE_DIR}/snapshot/${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_IMG_MARK_NAME}"
    # 可选还原版本合集
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VERS=""

    # 指定存储类型存在判断
    if [ -n "${4}" ]; then
        local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_DEST_DIR="${MIGRATE_DIR}/${4}/${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_IMG_MARK_NAME}"
        if [ ! -a "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_DEST_DIR}" ]; then
            echo "${TMP_SPLITER2}"
            echo_text_style "Cannot found 'snapshot' <${1}> typed [${4}] based '${MIGRATE_DIR}', please check"
            return $?
        fi

        _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VERS=$(ls ${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_DEST_DIR} | cut -d'.' -f1 | uniq)
        if [ -z "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VERS}" ]; then
            echo "${TMP_SPLITER2}"
            echo_text_style "Cannot found 'snapshot version' <${1}> typed [${4}] based '${MIGRATE_DIR}', please check"
            return $?
        fi
    fi

    # 合集操作
    if [ -z "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VERS}" ]; then
        local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_SNAP_VERS=""
		if [ -a "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_SNAP_DIR}" ]; then
			_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_SNAP_VERS=$(ls ${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_SNAP_DIR} | cut -d'.' -f1 | uniq)
		fi

        local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_CLEAN_VERS=""
		if [ -a "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_CLEAN_DIR}" ]; then
			_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_CLEAN_VERS=$(ls ${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_CLEAN_DIR} | cut -d'.' -f1 | uniq)
		fi
        _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VERS=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_SNAP_VERS} ${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_CLEAN_VERS}" | awk '$1=$1' | sort -rV)
    fi
    
	if [ -n "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VERS}" ]; then
		# 去除已存在的容器版本 
		## browserless/chrome:v1673604625SRC
		local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_PS_VER=$(docker images | grep "^${1}" | cut -d' ' -f4 | grep -oP "(?<=^v)[0-9]+(?=([A-Z]+)$)")
		## 有运行版本存在时
		if [ -n "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_PS_VER}" ]; then
			_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VERS=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VERS}" | sed "/${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_PS_VER}/d")
		fi

		if [ -n "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VERS}" ]; then
			# 默认版本 /mountdisk/repo/migrate/snapshot/browserless_chrome/1670392779
			local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VER=$(echo ${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VERS} | cut -d' ' -f1)
			local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_TYPES="Image,Container,Dockerfile"
			local _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_TYPE="Image"
		
			# 有版本时，才提供操作
			set_if_choice "_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VER" "Please sure 'which version' u want to [restore] of the snapshot <${1}>" "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VERS}"
			set_if_choice "_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_TYPE" "Please sure 'which type' u want to [restore] of the snapshot <${1}>([${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VER}])" ${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_TYPES}
			typeset -l _TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_TYPE

			# 快照存储类型已被重新加载
			if [ -z "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_STORE_TYPE}" ]; then
				_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_STORE_TYPE=$([[ -a "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_CLEAN_DIR}/${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VER}.config.v2.json" ]] && echo "clean" || echo "snapshot")
			fi
			
			docker_snap_restore_action "${1}" "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_VER}" "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_TYPE}" "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_STORE_TYPE}" "${2}"
		else
			echo_text_style "Checked the image of <${1}>:[${_TMP_DOCKER_SNAP_RESTORE_ACTION_IF_CHOICE_PS_VER}] exists, snapshot restore stoped"
		fi
	else
		echo "${TMP_SPLITER2}"
		echo_text_style "Cannot found the 'snapshot' <${1}>, based '${MIGRATE_DIR}'"

		if [ -n "${3}" ]; then
			exec_check_action "${3}" "${1}"
		fi
	fi

    return $?
}

# 还原 Docker 快照
# 参数1：镜像名称，例 browserless/chrome
# 参数2：快照版本，例 latest/1673604625
# 参数3：快照类型，例 image/container/dockerfile
# 参数4：快照来源，例 snapshot/clean，默认snapshot
# 参数5：完成后执行脚本，传递参数 1-4
# 例：
#   docker_snap_restore_action "browserless/chrome" "1673604625" "container" "clean"
function docker_snap_restore_action()
{
    # browserless/chrome
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_NAME="${1}"
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_VER="${2}"

	typeset -l _TMP_DOCKER_SNAP_RESTORE_ACTION_TYPE
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_TYPE="${3:-"image"}"
    # browserless_chrome
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_MARK_NAME="${1/\//_}"
    # /mountdisk/repo/migrate/snapshot/browserless_chrome/
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_BASE_DIR="${MIGRATE_DIR}/${4:-"snapshot"}/${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_MARK_NAME}"
    # local TMP_DOCKER_SNAP_RESTORE_ACTION_LNK_NAME="${1/_//}"
    # /mountdisk/repo/migrate/snapshot/browserless_chrome/1673604625
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_NONE_PATH="${_TMP_DOCKER_SNAP_RESTORE_ACTION_BASE_DIR}/${_TMP_DOCKER_SNAP_RESTORE_ACTION_VER}"
    
    # 还原版本
    local _TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER="latest"

	# 检测 镜像是否存在，存在则不开启还原行为
    echo_text_style "Checking the '${_TMP_DOCKER_SNAP_RESTORE_ACTION_TYPE} snapshot' of <${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_NAME}>:[v${_TMP_DOCKER_SNAP_RESTORE_ACTION_VER}] from docker images"
	local _TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_IMGS=$(docker images | grep "${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_NAME}")
	if [ -n "${_TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_IMGS}" ]; then
		local _TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_IMG=$(echo "${_TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_IMGS}" | grep "v${_TMP_DOCKER_SNAP_RESTORE_ACTION_VER}")
		if [ -n "${_TMP_DOCKER_SNAP_RESTORE_ACTION_EXISTS_IMG}" ]; then
			echo_text_style "Checked the '${_TMP_DOCKER_SNAP_RESTORE_ACTION_TYPE} snapshot' of <${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_NAME}>:[v${_TMP_DOCKER_SNAP_RESTORE_ACTION_VER}] from docker images exists, restore stoped"
			return $?
		fi
	fi
	    
    echo "${TMP_SPLITER2}"
    echo_text_style "Starting restore the '${_TMP_DOCKER_SNAP_RESTORE_ACTION_TYPE} snapshot' of <${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_NAME}>:[v${_TMP_DOCKER_SNAP_RESTORE_ACTION_VER}] from snapshot restore"
    case ${_TMP_DOCKER_SNAP_RESTORE_ACTION_TYPE} in
        "container")
            _TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER="v${_TMP_DOCKER_SNAP_RESTORE_ACTION_VER}SRC"
            zcat ${_TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_NONE_PATH}.ctn.gz | docker import - ${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_NAME}:${_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER}

            # 容器恢复丢失环境信息，故需要读取容器inspect信息
            cat ${_TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_NONE_PATH}.inspect.ctn.json | jq ".[0].Config.Env" | xargs -I {} sh -c 'echo {} | grep "=" | sed -E "s/,$//"' > ${_TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_NONE_PATH}.ctn.env
        ;;
        "image")
            # SRI
            # _TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER="v${_TMP_DOCKER_SNAP_RESTORE_ACTION_VER}SRI"
            docker load < ${_TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_NONE_PATH}.img.tar
        ;;
        "dockerfile")
            # ？？？缺少有效反向构建dockefile的操作，故存在bug
            _TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER="v${_TMP_DOCKER_SNAP_RESTORE_ACTION_VER}SRD"
            docker build -f ${_TMP_DOCKER_SNAP_RESTORE_ACTION_FILE_NONE_PATH}.dockerfile.yml -t ${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_NAME}:${_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER} .
        ;;
        *)
            echo
    esac
    
    echo_text_style "The '${_TMP_DOCKER_SNAP_RESTORE_ACTION_TYPE} snapshot' restored to <${_TMP_DOCKER_SNAP_RESTORE_ACTION_IMG_NAME}>:[${_TMP_DOCKER_SNAP_RESTORE_ACTION_MARK_VER}]"

	exec_check_action "${5}" "${@:1:4}"

    return $?
}

# Docker镜像检测后安装，存在时提示覆盖安装（基于Docker镜像检测类型的安装，并具有备份提示操作）
# 参数1：镜像名称，用于检测
# 参数2：镜像安装/还原后后执行脚本
# 参数3：指定如果镜像快照存在时，快照的还原出处的类别，为空时取并集（默认新镜像安装都会在clean下创建初始快照），例 snapshot/clean
# 示例：
#     soft_docker_check_upgrade_setup "browserless/chrome" "exec_step_browserless_chrome"
function soft_docker_check_upgrade_setup() 
{
	docker_snap_restore_if_choice_action "${1}" "${2}" "docker pull ${1}" "${3}" 

    return $?
}

# Docker启动执行脚本
# 参数1：镜像名称，例 browserless/chrome
# 参数2：启动版本，例 latest/1673604625
# 参数3：初始启动命令
# 参数4：初始启动参数
# 参数5：启动前运行脚本
#	    参数1：镜像名称
# 参数6：成功启动后运行脚本
#	    参数1：启动后的进程ID
#       参数2：最终启动端口
#	    参数3：最终启动命令
#	    参数4：最终启动参数
function soft_docker_boot_print() 
{
    local _TMP_SOFT_DOCKER_BOOT_PRINT_IMG_MARK_NAME="${1/\//_}"
    local _TMP_SOFT_DOCKER_BOOT_PRINT_VER="${2}"
    local _TMP_SOFT_DOCKER_BOOT_PRINT_CMD="${3}"
    local _TMP_SOFT_DOCKER_BOOT_PRINT_ARGS="${4}"
	
	# -P :是容器内部端口随机映射到主机的端口。
	# -p : 是容器内部端口绑定到指定的主机端口。
    local _TMP_SOFT_DOCKER_BOOT_PRINT_PS_PORT_ARG=$(echo "${_TMP_SOFT_DOCKER_BOOT_PRINT_ARGS}" | grep -oE '\-p [0-9]+:[0-9]+')
    local _TMP_SOFT_DOCKER_BOOT_PRINT_PS_PORT=$(echo "${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_PORT_ARG}" | cut -d' ' -f2 | cut -d':' -f1)
    
	local _TMP_SOFT_DOCKER_BOOT_PRINT_BEFORE_BOOT_SCRIPTS="${5}"
	local _TMP_SOFT_DOCKER_BOOT_PRINT_AFTER_BOOT_SCRIPTS="${6}"

    # 启动前执行
    exec_check_action "${_TMP_SOFT_DOCKER_BOOT_PRINT_BEFORE_BOOT_SCRIPTS}" "${1}"

	# 启动等待
	# 参数1：等待端口
	# 参数2：等待输出
	function _soft_docker_boot_print_wait()
	{
		local _TMP_SOFT_DOCKER_BOOT_PRINT_WAIT_PS_PORT="${1}"
		
		# 指定端口，则等待
		if [ -n "${_TMP_SOFT_DOCKER_BOOT_PRINT_WAIT_PS_PORT}" ]; then
			# 等待执行完毕 产生端口
			exec_sleep_until_not_empty "${2}" "lsof -i:${_TMP_SOFT_DOCKER_BOOT_PRINT_WAIT_PS_PORT}" 180 3
			if [ -z "$(lsof -i:${_TMP_SOFT_DOCKER_BOOT_PRINT_WAIT_PS_PORT})" ]; then
				echo_text_style "Boot failure, please check"
				return -1
			fi
		fi
	}
	
	# 确认版本: 未指定版本则通过选项来启动
	if [ -z "${_TMP_SOFT_DOCKER_BOOT_PRINT_VER}" ]; then
		# v1673604625SRC
		local _TMP_SOFT_DOCKER_BOOT_PRINT_PS_VERS=$(docker ps -a | grep "${1}" | cut -d' ' -f4 | cut -d':' -f2)

		# 排除已启动的运行版本（同一版本限定只能启动一次）
		local _TMP_SOFT_DOCKER_BOOT_PRINT_VERS=$(docker images | grep "^${1}" | cut -d' ' -f4)
		if [ -n "${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_VERS}" ]; then
			function _soft_docker_boot_print_filter_vers()
			{
				_TMP_SOFT_DOCKER_BOOT_PRINT_VERS=$(echo "${_TMP_SOFT_DOCKER_BOOT_PRINT_VERS}" | sed "/${1}/d")
			}
			exec_split_action "${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_VERS}" "_soft_docker_boot_print_filter_vers"
		fi
		
		# 剩余版本提供选择
		local _TMP_SOFT_DOCKER_BOOT_PRINT_VERS_COUNT=$(echo "${_TMP_SOFT_DOCKER_BOOT_PRINT_VERS}" | wc -w)
		if [ ${_TMP_SOFT_DOCKER_BOOT_PRINT_VERS_COUNT} -gt 1 ]; then
			echo "${TMP_SPLITER2}"
			set_if_choice "_TMP_SOFT_DOCKER_BOOT_PRINT_VER" "Please sure 'which version' u want to boot from snapshot <${1}>" "${_TMP_SOFT_DOCKER_BOOT_PRINT_VERS}"
		else
			if [ -n "${_TMP_SOFT_DOCKER_BOOT_PRINT_VERS}" ]; then
				_TMP_SOFT_DOCKER_BOOT_PRINT_VER="${_TMP_SOFT_DOCKER_BOOT_PRINT_VERS}"
			else
				echo_text_style "Checked the image of <${1}> no versions less to boot"
			fi
		fi
	fi
	
	_TMP_SOFT_DOCKER_BOOT_PRINT_VER="${_TMP_SOFT_DOCKER_BOOT_PRINT_VER:="latest"}"
    local _TMP_SOFT_DOCKER_BOOT_PRINT_PS=$(docker ps -a --no-trunc | grep "${1}" | grep "${_TMP_SOFT_DOCKER_BOOT_PRINT_VER}")
    local _TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID=$(echo "${_TMP_SOFT_DOCKER_BOOT_PRINT_PS}" | cut -d' ' -f1)

	# 确认是否构建新容器
	## 容器不存在
    if [ -z "${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}" ]; then
		echo "${TMP_SPLITER2}"
		echo_text_style "Cannot find created container of <${1}>:[${_TMP_SOFT_DOCKER_BOOT_PRINT_VER}], start to build it"

		# 还原容器逻辑，参数优先从此处取
		local _TMP_SOFT_DOCKER_BOOT_PRINT_VER_SRC=$(echo "${_TMP_SOFT_DOCKER_BOOT_PRINT_VER}" | grep -oP "(?<=^v).*(?=SRC$)")
		if [ -n "${_TMP_SOFT_DOCKER_BOOT_PRINT_VER_SRC}" ]; then
			echo_text_style "Checked the image of <${1}>:[${_TMP_SOFT_DOCKER_BOOT_PRINT_VER}] typed 'container', start 'change args'(${_TMP_SOFT_DOCKER_BOOT_PRINT_ARGS}) && cmd(${_TMP_SOFT_DOCKER_BOOT_PRINT_CMD:-"None"})"

			# 如果是容器还原的镜像，启动时需还原依赖缺失部分
			local _TMP_SOFT_DOCKER_BOOT_PRINT_STORE_TYPE=$(find ${MIGRATE_DIR} -name ${_TMP_SOFT_DOCKER_BOOT_PRINT_VER_SRC}.* | cut -d'.' -f1 | uniq | grep -oP "(?<=^${MIGRATE_DIR}/).*(?=/${_TMP_SOFT_DOCKER_BOOT_PRINT_IMG_MARK_NAME}/${_TMP_SOFT_DOCKER_BOOT_PRINT_VER_SRC}$)")
			local _TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH="${MIGRATE_DIR}/${_TMP_SOFT_DOCKER_BOOT_PRINT_STORE_TYPE}/${_TMP_SOFT_DOCKER_BOOT_PRINT_IMG_MARK_NAME}/${_TMP_SOFT_DOCKER_BOOT_PRINT_VER_SRC}"

			# ？？？CMD 是个合并解析的数组，参数多时可能存在bug
			# _TMP_SOFT_DOCKER_BOOT_PRINT_CMD=$(cat ${_TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH}.inspect.json | jq ".[0].Config.Cmd[0]")    
			if [ -a ${_TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH}.cmd ]; then
				_TMP_SOFT_DOCKER_BOOT_PRINT_CMD=$(cat ${_TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH}.cmd)
			fi

			# ？？？需做参数合并。
			# 必须指定工作目录，否则会出现（OCI，no such file or directory）
			# if [ -a ${_TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH}.inspect.ctn.json ]; then
			# 	local _TMP_SOFT_DOCKER_BOOT_PRINT_WORKING_DIR=$(cat ${_TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH}.inspect.ctn.json | jq ".[0].Config.WorkingDir" | grep -oP "(?<=^\").*(?=\"$)")
			
			# 	_TMP_SOFT_DOCKER_BOOT_PRINT_ARGS="${_TMP_SOFT_DOCKER_BOOT_PRINT_ARGS} --workdir=${_TMP_SOFT_DOCKER_BOOT_PRINT_WORKING_DIR}"
			# fi

			# if [ -a ${_TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH}.ctn.env ]; then
			# 	_TMP_SOFT_DOCKER_BOOT_PRINT_ARGS="${_TMP_SOFT_DOCKER_BOOT_PRINT_ARGS} --env-file=${_TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH}.ctn.env"
			# fi
			local _TMP_SOFT_DOCKER_BOOT_PRINT_WORKING_DIR=$(cat ${_TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH}.inspect.ctn.json | jq ".[0].Config.WorkingDir" | grep -oP "(?<=^\").*(?=\"$)")
			_TMP_SOFT_DOCKER_BOOT_PRINT_ARGS="${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_PORT_ARG} --workdir=${_TMP_SOFT_DOCKER_BOOT_PRINT_WORKING_DIR} --env-file=${_TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH}.ctn.env"
			echo_text_style "Changed the image of <${1}>:[${_TMP_SOFT_DOCKER_BOOT_PRINT_VER}] boot param, start use args(${_TMP_SOFT_DOCKER_BOOT_PRINT_ARGS}) && cmd(${_TMP_SOFT_DOCKER_BOOT_PRINT_CMD:-"None"}) to boot it"
		fi

        # docker run -d -p ${TMP_DOCKER_SETUP_TEST_PS_PORT}:5000 training/webapp python app.py
        _TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID=$(docker run -d --restart always ${_TMP_SOFT_DOCKER_BOOT_PRINT_ARGS} ${1}:${_TMP_SOFT_DOCKER_BOOT_PRINT_VER} ${_TMP_SOFT_DOCKER_BOOT_PRINT_CMD})
		if [ -a "${_TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH}.init.depend.sh" ]; then
			# 启动等待一次
			_soft_docker_boot_print_wait "${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_PORT}" "Booting the image <${1}:[${_TMP_SOFT_DOCKER_BOOT_PRINT_VER}]>([${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}])' to port '${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_PORT}', waiting for a moment"

			echo "${TMP_SPLITER2}"
			echo_text_style "View the 'update dependency exec'↓:"
			docker cp ${_TMP_SOFT_DOCKER_BOOT_PRINT_NONE_PATH}.init.depend.sh ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}:/tmp
			docker exec -u root -it ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID} sh -c "apt-get update"
			docker exec -u root -it ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID} sh -c "sh /tmp/${_TMP_SOFT_DOCKER_BOOT_PRINT_VER_SRC}.init.depend.sh"
			
			# 停止，后续再启动，预防依赖生效问题
			echo "${TMP_SPLITER2}"
			echo_text_style "Starting restart the container of <${1}>:[${_TMP_SOFT_DOCKER_BOOT_PRINT_VER}]('${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}')"
			docker stop ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}
			docker start ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}
		fi
    else
        echo_text_style "Checked the container of <${1}>:[${_TMP_SOFT_DOCKER_BOOT_PRINT_VER}]('${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}') exists, ignore args&cmd, start boot it"
        docker start ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}

        # 复原后，端口可能改变
        _TMP_SOFT_DOCKER_BOOT_PRINT_PS_PORT=$(docker port ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID} | cut -d':' -f2 | awk 'NR==1')
    fi

	_soft_docker_boot_print_wait "${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_PORT}" "Booting the image <${1}:[${_TMP_SOFT_DOCKER_BOOT_PRINT_VER}]>([${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}])' to port '${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_PORT}', waiting for a moment"

	# 端口冲突则不往下走
	local _TMP_SOFT_DOCKER_BOOT_PRINT_BOOT_OK=$(docker inspect --format '{{.State.Running}}' ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID})
	if [ "${_TMP_SOFT_DOCKER_BOOT_PRINT_BOOT_OK}" == "false" ]; then
		echo "${TMP_SPLITER2}"
		echo_text_style "Checked the container of <${1}>:[${_TMP_SOFT_DOCKER_BOOT_PRINT_VER}]('${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}') boot failure, please check"
		return
	fi
	
    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container time'↓:"
    docker exec -u root -it ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID} sh -c "date"
	
    path_not_exists_link "${DOCKER_SETUP_DIR}/logs/${_TMP_SOFT_DOCKER_BOOT_PRINT_IMG_MARK_NAME}/${LOCAL_TIMESTAMP}.json.log" "" "${DOCKER_SETUP_DIR}/data/containers/${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}/${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}-json.log"

    # 查看日志（config/image）
    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container inspect'↓:"
    docker container inspect ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID} | jq > ${DOCKER_SETUP_DIR}/logs/${_TMP_SOFT_DOCKER_BOOT_PRINT_IMG_MARK_NAME}/${LOCAL_TIMESTAMP}.ctn.inspect.json
    cat ${DOCKER_SETUP_DIR}/logs/${_TMP_SOFT_DOCKER_BOOT_PRINT_IMG_MARK_NAME}/${LOCAL_TIMESTAMP}.ctn.inspect.json

    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container logs'↓:"
    docker logs ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}

    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container folder /tmp'↓:"
    docker exec -it ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID} sh -c "ls -lia /tmp/"

    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container occupancy rate'↓:"
    docker exec -u root -it ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID} sh -c "ls / | grep -v 'proc' | xargs -I {} du -sh /{}"
	
	# 最后更新一次容器内包
	echo "${TMP_SPLITER2}"
	echo_text_style "View the 'container update'↓:"
	docker exec -u root -w /tmp -it ${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID} sh -c "apt-get update"

    exec_check_action "${_TMP_SOFT_DOCKER_BOOT_PRINT_AFTER_BOOT_SCRIPTS}" "${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}" "${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_PORT}" "${_TMP_SOFT_DOCKER_BOOT_PRINT_CMD}" "${_TMP_SOFT_DOCKER_BOOT_PRINT_ARGS}"
    
    # 备份当前容器，仅在第一次 	
    local TMP_DOCKER_SETUP_CTN_CLEAN_DIR="${MIGRATE_DIR}/clean"
    path_not_exists_action "${TMP_DOCKER_SETUP_CTN_CLEAN_DIR}/${_TMP_SOFT_DOCKER_BOOT_PRINT_IMG_MARK_NAME}" "echo '${TMP_SPLITER2}' && docker_snap_create_action '${_TMP_SOFT_DOCKER_BOOT_PRINT_PS_ID}' '${TMP_DOCKER_SETUP_CTN_CLEAN_DIR}' '${LOCAL_TIMESTAMP}'"

	return $?
}

# 循环检测后YN执行（基于命令检测执行脚本，无备份操作）
# 参数1：循环选项（列表），例如具体的cmd命令、yum包名、npm包名等
# 参数2：命令检测脚本，以该脚本的输出为YN指向执行脚本
# 参数3：检测已存在时执行脚本名称，例如提示、更新
# 参数4：检测不存在时默认的执行脚本，例如安装
# 参数5：选项类型注释，例如command/yum/npm。默认command
# 示例：
# 	 item_check_yn_action "vim,wget" "yum list installed | grep %s" "echo '%s was installed'" "yum -y install %s"
function item_check_yn_action() 
{
	local _TMP_SOFT_CHECK_YN_ACTION_CHECK_ITEMS="${1}"
    local _TMP_SOFT_CHECK_YN_ACTION_CHECK_SCRIPT="${2}"
    local _TMP_SOFT_CHECK_YN_ACTION_Y_SCRIPT="${3}"
	local _TMP_SOFT_CHECK_YN_ACTION_N_SCRIPT="${4}"
    local _TMP_SOFT_CHECK_YN_ACTION_TYPE_ECHO="${5:-command}"

	function _item_check_yn_action()
	{
		local _TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM=${1}
		local _TMP_SOFT_CHECK_YN_ACTION_FINAL_CHECK_SCRIPT=${1}
		exec_text_printf "_TMP_SOFT_CHECK_YN_ACTION_FINAL_CHECK_SCRIPT" "${_TMP_SOFT_CHECK_YN_ACTION_CHECK_SCRIPT}"

		local _TMP_SOFT_CHECK_YN_ACTION_FINAL_Y_SCRIPT=${1}
		exec_text_printf "_TMP_SOFT_CHECK_YN_ACTION_FINAL_Y_SCRIPT" "${_TMP_SOFT_CHECK_YN_ACTION_Y_SCRIPT}"

		local _TMP_SOFT_CHECK_YN_ACTION_FINAL_N_SCRIPT=${1}
		exec_text_printf "_TMP_SOFT_CHECK_YN_ACTION_FINAL_N_SCRIPT" "${_TMP_SOFT_CHECK_YN_ACTION_N_SCRIPT}"
		
		echo ${TMP_SPLITER}
        echo_text_style "Checking the '${_TMP_SOFT_CHECK_YN_ACTION_TYPE_ECHO}' of <${_TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM}>"
        echo ${TMP_SPLITER}
		
		# 获取判断响应
		local _TMP_SOFT_CHECK_YN_ACTION_RES=$(exec_check_action '_TMP_SOFT_CHECK_YN_ACTION_FINAL_CHECK_SCRIPT' ${_TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM})
		
		# 不存在命令时执行
		if [ -z "${_TMP_SOFT_CHECK_YN_ACTION_RES}" ]; then
			exec_check_action "_TMP_SOFT_CHECK_YN_ACTION_FINAL_N_SCRIPT" ${_TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM}
		else
			exec_check_action "_TMP_SOFT_CHECK_YN_ACTION_FINAL_Y_SCRIPT" ${_TMP_SOFT_CHECK_YN_ACTION_CURRENT_ITEM}
		fi

        echo
	}
	
    exec_split_action "${_TMP_SOFT_CHECK_YN_ACTION_CHECK_ITEMS}" "_item_check_yn_action '%s'"

	return $?
}

# 命令检测后执行（基于命令检测执行脚本，无备份操作）
# 参数1：命令名称(列表)
# 参数2：命令不存在时默认的 执行安装/更新脚本
# 参数3：命令已存在时执行脚本名称
# 示例：
# 	 soft_cmd_check_action "vim,wget" "yum -y install %s" "echo '%s was installed'"
function soft_cmd_check_action() 
{
	function _soft_cmd_check_action_echo()
	{
		local _TMP_SOFT_CMD_CHECK_ACTION_ECHO_CMD_TYPE=$(su_bash_env_channel_exec "type -t ${1}")
		local _TMP_SOFT_CMD_CHECK_ACTION_ECHO_CMD_WHERE=$(su_bash_env_channel_exec "whereis ${1}")

		echo "${_TMP_SOFT_CMD_CHECK_ACTION_ECHO_CMD_TYPE}${_TMP_SOFT_CMD_CHECK_ACTION_ECHO_CMD_WHERE/${1}:/}"
	}

	item_check_yn_action "${1}" "_soft_cmd_check_action_echo" "${3}" "${2}"
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
		exec_check_action 'soft_cmd_check_git_down_action' "${1}" "${_TMP_SOFT_CMD_CHECK_GIT_ACTION_PARAMS[@]}"
		echo "${TMP_SPLITER2}"
		echo_text_style "The soft command of <${1}> from [git] has ${_TMP_SOFT_CMD_CHECK_GIT_ACTION_TYPE_DESC}ed"
	}

	# 命令不存在时，执行的默认函数
	function _soft_cmd_check_git_action_echo()
	{
		# 此处如果是取用变量而不是实际值，则split_action中的printf不会进行格式化
		# print "${_SOFT_CMD_CHECK_GIT_ACTION_CMD_STD}" "${_TMP_SOFT_CMD_CHECK_SETUP}"
		echo_text_style "The soft command of <${1}> from [git] was ${_TMP_SOFT_CMD_CHECK_GIT_ACTION_TYPE_DESC}ed"
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
	local _TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_DOWN="${4}"
	local _TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_VER="${4}"
	local _TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_SCRIPT="${4}"

	exec_text_printf "_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_DOWN" "${3}"
	exec_text_printf "_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_SCRIPT" "${5}"

	set_github_soft_releases_newer_version "_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_VER" "${_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_REPO}"
	echo_text_style "Starting execute script <${_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_SCRIPT}>"

	while_wget "--content-disposition ${_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_DOWN}" "${_TMP_SOFT_CMD_CHECK_GIT_DOWN_ACTION_SCRIPT}"
	# echo_text_style '[Command] of <${1}> installed'
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
	local _TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_CMD="${1}"
	local _TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC="${6:-install}"

	local _TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_PARAMS=("${@:2:5}")
	function _soft_cmd_check_confirm_git_action()
	{
		function __soft_cmd_check_confirm_git_action()
		{
			exec_check_action 'soft_cmd_check_git_down_action' "${1}" "${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_PARAMS[@]}"

			echo "${TMP_SPLITER2}"
			echo_text_style "The command of <${1}> from [git] was re${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC}ed"
		}

		local _TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_YN_REINSTALL="N"
		confirm_yn_action "_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_YN_REINSTALL" "Checked the command of <${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_CMD}> from [git] was ${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC}ed, please sure u will exec [re${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC}] 'still or not'" "__soft_cmd_check_confirm_git_action '${1}'" "echo_text_style 'Checked the command of <${1}> from [git] was ${_TMP_SOFT_CMD_CHECK_CONFIRM_GIT_ACTION_TYPE_DESC}ed'"
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
		exec_check_action 'soft_cmd_check_git_down_action' "${1}" "${_TMP_SOFT_CMD_CHECK_GIT_UPGRADE_ACTION_PARAMS[@]}"

		echo_text_style "The command of <${1}> from [git] by upgrade ${2:-"has "}${_TMP_SOFT_CMD_CHECK_GIT_UPGRADE_ACTION_TYPE_DESC}ed"
	}

	exec_check_action 'soft_cmd_check_upgrade_action' "${1}" "_soft_cmd_check_git_upgrade_action" "${6}" "${7}"
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
			confirm_yn_action "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_BACKUP_Y_N" "Please sure the soft command of <${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}> u will 'backup check still or not'"

			# 是否强制删除这里取反，soft_trail_clear参数需要
			local _TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_FORCE_TRAIL_Y_N="${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_BACKUP_Y_N}"
			bind_exchange_yn_val "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_FORCE_TRAIL_Y_N"

			# 卸载包前检测，备份残留或NO
			soft_trail_clear "${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}" "${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_FORCE_TRAIL_Y_N}"
			
			# 执行备份后自定义命令
			exec_check_action "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CUS_SCRIPT" "${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}"

			# 执行安装			
			exec_check_action "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_NE_SCRIPT" "${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}" "was re"
		}
		
		# 提示是否重装的值，默认不重装
		local _TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_REINSTALL_Y_N="N"
		## 检测到软件已安装，确认重装或不重装。
		## 例如：Checked the soft of 'conda' was installed, please sure u will 'reinstall still or not'?
		confirm_yn_action "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_REINSTALL_Y_N" "Checked the soft command of <${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}> was ${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_TYPE_DESC}ed, please sure u will 're${_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_TYPE_DESC} still or not'" "_soft_cmd_check_upgrade_action_exec_remove" "_TMP_SOFT_CMD_CHECK_UPGRADE_ACTION_E_SCRIPT" "${_NTMP_SOFT_CMD_CHECK_UPGRADE_ACTION_CURRENT_SOFT}"
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

    local _TMP_SOFT_RPM_CHECK_ACTION_RPM_FIND_RESULTS=`rpm -qa | grep ${_TMP_SOFT_RPM_CHECK_ACTION_SOFT}`
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
# 	 soft_yum_check_action "vvv" "yum -y install %s" "echo '%s was installed'"
# 	 soft_yum_check_action "sss" "test"
# 	 soft_yum_check_action "wget,vim" "echo '%s setup'"
function soft_yum_check_action() 
{
	local _TMP_SOFT_YUM_CHECK_ACTION_TYPE_DESC="${4:-install}"
	# 用于检测是否存在安装残留，可能文件存在，实际未安装
	# if [ "${FUNCNAME[4]}" != "soft_yum_check_setup" ]; then
	# 	soft_trail_clear "${_TMP_SOFT_YUM_CHECK_ACTION_CURRENT_SOFT_NAME}" "N"
	# fi
    item_check_yn_action "${1}" "yum list installed | grep %s" "${3}" "${2}" "yum ${_TMP_SOFT_YUM_CHECK_ACTION_TYPE_DESC}ed repos"
	return $?
}

# Yum包检测后安装
# 参数1：包名称
# 参数2：包存在时输出信息
# 示例：
#     soft_yum_check_setup "vvv" "%s was installed"
#     soft_yum_check_setup "wget,vim" "%s was installed"
function soft_yum_check_setup() 
{
	local _TMP_SOFT_YUM_CHECK_SETUP_SOFTS=${1}
	local _TMP_SOFT_YUM_CHECK_SETUP_SOFT_STD=${2}
    
	function _soft_yum_check_setup_echo()
	{
		local _TMP_SOFT_YUM_CHECK_SETUP_CURRENT_SOFT_NAME=${1}

		# 此处如果是取用变量而不是实际值，则split_action中的printf不会进行格式化
		# print "${_TMP_SOFT_YUM_CHECK_SETUP_SOFT_STD}" "${_TMP_SOFT_YUM_CHECK_SETUP}"
		echo_text_style "${_TMP_SOFT_YUM_CHECK_SETUP_SOFT_STD:-"The yum repo of <${_TMP_SOFT_YUM_CHECK_SETUP_CURRENT_SOFT_NAME}> was installed"}"
	}

	soft_yum_check_action "${_TMP_SOFT_YUM_CHECK_SETUP_SOFTS}" "yum -y -q install %s && echo_text_style 'The yum repo of <%s> has installed'" "_soft_yum_check_setup_echo"

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

		echo_text_style "Starting remove yum repo of '${_TMP_SOFT_YUM_CHECK_UPGRADE_ACTION_CURRENT_SOFT}'"

		# 清理安装包，删除空行（cut -d可能带来空行）
		yum list installed | grep ${_TMP_SOFT_YUM_CHECK_UPGRADE_ACTION_CURRENT_SOFT} >> ${SETUP_DIR}/yum_remove_list.log
		yum list installed | grep ${_TMP_SOFT_YUM_CHECK_UPGRADE_ACTION_CURRENT_SOFT} | cut -d' ' -f1 | grep -v '^$' | xargs -I {} yum -y remove {}

		echo_text_style "The yum repo of '${_TMP_SOFT_YUM_CHECK_UPGRADE_ACTION_CURRENT_SOFT}' was removed"
		
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

    local _TMP_SOFT_NPM_CHECK_ACTION_FIND_RESULTS=`npm list --depth=0 ${_TMP_SOFT_NPM_CHECK_ACTION_MODE} | grep ${_TMP_SOFT_NPM_CHECK_ACTION_SOFT}`
	if [ -z "${_TMP_SOFT_NPM_CHECK_ACTION_FIND_RESULTS}" ]; then
		${_TMP_SOFT_NPM_CHECK_ACTION_SOFT_SCRIPT}
	else
		echo "${3}"

		return 0
	fi

	return $?
}

# 安装软件下载模式
# 参数1：软件下载地址
# 参数2：软件下载后，需移动的文件夹名
# 参数3：目标文件夹
# 参数4：解包后执行脚本
function wget_unpack_dist() 
{
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_WGET_UNPACK_DIST_PWD=`pwd`
	local _TMP_WGET_UNPACK_DIST_URL=${1}
	local _TMP_WGET_UNPACK_DIST_SOURCE=${2}
	local _TMP_WGET_UNPACK_DIST_PATH=${3}
	local _TMP_WGET_UNPACK_DIST_SCRIPT=${4}

	local _TMP_WGET_UNPACK_FILE_NAME=`echo "${_TMP_WGET_UNPACK_DIST_URL}" | awk -F'/' '{print $NF}'`

	mkdir -pv ${DOWN_DIR} && cd ${DOWN_DIR}

	if [ ! -f "${_TMP_WGET_UNPACK_FILE_NAME}" ]; then
		wget -c --tries=0 --timeout=60 ${_TMP_WGET_UNPACK_DIST_URL}
	fi

	local _TMP_WGET_UNPACK_DIST_FILE_EXT=`echo ${_TMP_WGET_UNPACK_FILE_NAME##*.}`
	if [ "$_TMP_WGET_UNPACK_DIST_FILE_EXT" = "zip" ]; then
		local _TMP_WGET_UNPACK_DIST_PACK_DIR_LINE=`unzip -v ${_TMP_WGET_UNPACK_FILE_NAME} | awk '/----/{print NR}' | awk 'NR==1{print}'`
		local _TMP_WGET_UNPACK_FILE_NAME_NO_EXTS=`unzip -v ${_TMP_WGET_UNPACK_FILE_NAME} | awk 'NR==LINE{print $NF}' LINE=$((_TMP_WGET_UNPACK_DIST_PACK_DIR_LINE+1)) | sed s@/@""@g`
		if [ ! -d "${_TMP_WGET_UNPACK_FILE_NAME_NO_EXTS}" ]; then
			unzip -o ${_TMP_WGET_UNPACK_FILE_NAME}
		fi
	else
		local _TMP_WGET_UNPACK_FILE_NAME_NO_EXTS=`tar -tf ${_TMP_WGET_UNPACK_FILE_NAME} | awk 'NR==1{print}' | sed s@/@""@g`
		if [ ! -d "${_TMP_WGET_UNPACK_FILE_NAME_NO_EXTS}" ]; then
			tar -xvf ${_TMP_WGET_UNPACK_FILE_NAME}
		fi
	fi

	cd ${_TMP_WGET_UNPACK_FILE_NAME_NO_EXTS}

	exec_check_action "${_TMP_WGET_UNPACK_DIST_SCRIPT}"

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
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_WHILE_WGET_URL=${1}
	local _TMP_WHILE_WGET_SCRIPT=${2}
	local _TMP_WHILE_WGET_CURRENT_DIR=`pwd`

	#包含指定参数
	local _TMP_WHILE_WGET_FILE_DEST_NAME=`echo "${_TMP_WHILE_WGET_URL}" | awk -F'-O' '{print $2}' | awk '{sub("^ *","");sub(" *$","");print}' | awk -F' ' '{print $1}'`
	
	#原始链接名
	local _TMP_WHILE_WGET_FILE_SOUR_NAME=`echo "${_TMP_WHILE_WGET_URL}" | awk -F'/' '{print $NF}' | awk -F' ' '{print $NR}'`
	if [ "${_TMP_WHILE_WGET_FILE_SOUR_NAME}" == "download.rpm" ]; then
		_TMP_WHILE_WGET_FILE_SOUR_NAME=`echo "${_TMP_WHILE_WGET_URL}" | awk -F'/' '{print $(NF-1)}'`
	fi

	#提取真实URL链接
	local _TMP_WHILE_WGET_TRUE_URL=`echo "${_TMP_WHILE_WGET_URL}" | grep -oh -E "https?://[a-zA-Z0-9\.\+\/_&=@$%?~#-]*"`

	#最终名
	_TMP_WHILE_WGET_FILE_DEST_NAME=${_TMP_WHILE_WGET_FILE_DEST_NAME:-${_TMP_WHILE_WGET_FILE_SOUR_NAME}}
	# _TMP_WHILE_WGET_FILE_DEST_NAME=$([ -n "$_TMP_WHILE_WGET_FILE_DEST_NAME" ] && echo "$_TMP_WHILE_WGET_FILE_DEST_NAME" || echo ${_TMP_WHILE_WGET_FILE_SOUR_NAME})
	
	echo "-------------------------------------------------------------------------------------------------------------------"
	echo "Start to get file from '${red}${_TMP_WHILE_WGET_TRUE_URL}${reset}' named '${green}${_TMP_WHILE_WGET_FILE_DEST_NAME}${reset}'"
	echo "-------------------------------------------------------------------------------------------------------------------"
	echo "${green}Current Dir${reset}：`pwd`"
	local _TMP_WHILE_WGET_DIST_FILE_EXT=`echo ${_TMP_WHILE_WGET_FILE_DEST_NAME##*.}`	
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

	local _TMP_WHILE_WGET_COMMAND="wget -c --tries=0 --timeout=60 ${_TMP_WHILE_WGET_TRUE_URL} -O ${_TMP_WHILE_WGET_FILE_DEST_NAME}"
	echo "${green}Wget Command${reset}：${_TMP_WHILE_WGET_COMMAND}"
	echo "${green}Wget/Current Dir${reset}：`pwd`"
	echo

	# 循环执行wget命令，直到成功
	while [ ! -f "${_TMP_WHILE_WGET_FILE_DEST_NAME}" ]; do
		#https://wenku.baidu.com/view/64f7d302b52acfc789ebc936.html
		${_TMP_WHILE_WGET_COMMAND}

		# 网络错误大小为0则清空文件
		local _TMP_WHILE_WGET_FILE_SIZE=`ls -l ${_TMP_WHILE_WGET_FILE_DEST_NAME} | awk '{ print $5 }'`
		if [ ${_TMP_WHILE_WGET_FILE_SIZE} -eq 0 ]; then
			rm -rf ${_TMP_WHILE_WGET_FILE_DEST_NAME}
		fi
	done

	# 执行wget后的脚本
	if [ ${#_TMP_WHILE_WGET_SCRIPT} -gt 0 ]; then
		eval "${_TMP_WHILE_WGET_SCRIPT}"
	fi

	# 回到wget之前的目录
	cd ${_TMP_WHILE_WGET_CURRENT_DIR}

	return $?
}

# 无限循环重试下载
# 参数1：软件下载地址
# 参数2：软件下载后执行函数名称
function while_curl()
{
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_WHILE_CURL_URL=${1}
	local _TMP_WHILE_CURL_SCRIPT=${2}
	local _TMP_WHILE_CURL_CURRENT_DIR=`pwd`

	#包含指定参数
	local _TMP_WHILE_CURL_FILE_DEST_NAME=`echo "${_TMP_WHILE_CURL_URL}" | awk -F'-o' '{print $2}' | awk '{sub("^ *","");sub(" *$","");print}' | awk -F' ' '{print $1}'`

	#原始链接名
	local _TMP_WHILE_CURL_FILE_NAME=`echo "${_TMP_WHILE_CURL_URL}" | awk -F'/' '{print $NF}' | awk -F' ' '{print $NR}'`

	#提取真实URL链接
	local _TMP_WHILE_CURL_TRUE_URL=`echo "${_TMP_WHILE_CURL_URL}" | grep -oh -E "https?://[a-zA-Z0-9\.\+\/_&=@$%?~#-]*"`

	#最终名
	_TMP_WHILE_CURL_FILE_DEST_NAME=${_TMP_WHILE_CURL_FILE_DEST_NAME:-${_TMP_WHILE_CURL_FILE_NAME}}
	# _TMP_WHILE_CURL_FILE_DEST_NAME=$([ -n "$_TMP_WHILE_CURL_FILE_DEST_NAME" ] && echo "$_TMP_WHILE_CURL_FILE_DEST_NAME" || echo $_TMP_WHILE_CURL_FILE_NAME)
	
	echo "-------------------------------------------------------------------------------------------------------------------------"
	echo "Start to curl file from '${red}${_TMP_WHILE_CURL_TRUE_URL}${reset}' named '${green}${_TMP_WHILE_CURL_FILE_DEST_NAME}${reset}'"
	echo "-------------------------------------------------------------------------------------------------------------------------"
	echo "${green}Current Dir${reset}：`pwd`"

	cd ${CURL_DIR}
	local _TMP_WHILE_CURL_COMMAND="curl -4sSkL ${_TMP_WHILE_CURL_TRUE_URL} -o ${_TMP_WHILE_CURL_FILE_DEST_NAME}"
	echo "${green}Curl Command${reset}：${_TMP_WHILE_CURL_COMMAND}"
	echo "${green}Curl/Current Dir${reset}：`pwd`"
	echo

	while [ ! -f "${_TMP_WHILE_CURL_FILE_DEST_NAME}" ]; do
		${_TMP_WHILE_CURL_COMMAND}
		
		# 网络错误大小为0则清空文件
		local _TMP_WHILE_CURL_FILE_SIZE=`ls -l ${_TMP_WHILE_CURL_FILE_DEST_NAME} | awk '{ print $5 }'`
		if [ ${_TMP_WHILE_CURL_FILE_SIZE} -eq 0 ]; then
			rm -rf ${_TMP_WHILE_CURL_FILE_DEST_NAME}
		fi
	done

	if [ ${#_TMP_WHILE_CURL_SCRIPT} -gt 0 ]; then
		eval "${_TMP_WHILE_CURL_SCRIPT}"
	fi
	cd ${_TMP_WHILE_CURL_CURRENT_DIR}

	# rm -rf ${_TMP_WHILE_CURL_FILE_DEST_NAME}

	return $?
}

# 无限循环尝试启动程序
# 参数1：程序启动命令
# 参数2：程序检测命令（返回1）
# 参数3：失败后执行
# 例子：TMP=1 && while_exec "TMP=\$((TMP+1))" "[ \$TMP -eq 10 ] && echo 1" "echo \$TMP"
function while_exec()
{
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_WHILE_EXEC_SCRIPT=${1}
	local _TMP_WHILE_EXEC_CHECK_SCRIPT=${2}
	local _TMP_WHILE_EXEC_FAILURE_SCRIPT=${3}

	echo "${TMP_SPLITER}"
	echo "Start to exec check script '${green}${_TMP_WHILE_EXEC_CHECK_SCRIPT}${reset}'"
	local _TMP_WHILE_EXEC_CHECK_RESULT=`eval "${_TMP_WHILE_EXEC_CHECK_SCRIPT}"`
	if [ $I -eq 1 ] && [ "${_TMP_WHILE_EXEC_CHECK_RESULT}" == "1" ]; then
		echo "Script is '${green}running${reset}', exec exit"
		break
	fi

	echo "Start to exec script '${green}$_TMP_WHILE_EXEC_SCRIPT${reset}'"
	echo "${TMP_SPLITER}"

	for I in $(seq 99);
	do
		echo "Execute sequence：'${green}${I}${reset}'"
		echo "${TMP_SPLITER2}"
		eval "$_TMP_WHILE_EXEC_SCRIPT"

		_TMP_WHILE_EXEC_CHECK_RESULT=`eval "${_TMP_WHILE_EXEC_CHECK_SCRIPT}"`

		if [ "${_TMP_WHILE_EXEC_CHECK_RESULT}" != "1" ]; then
			echo "Execute ${red}failure${reset}, the result response '${red}${_TMP_WHILE_EXEC_CHECK_RESULT}${reset}', this will wait for 30s to try again"
			
			path_exists_yn_action "${GUM_PATH}" "gum spin --spinner monkey --title \"Waitting for try again...\" -- sleep 30" "sleep 30"	

			if [ ${#_TMP_WHILE_EXEC_FAILURE_SCRIPT} -gt 0 ]; then
				eval "${_TMP_WHILE_EXEC_FAILURE_SCRIPT}"
				echo "${TMP_SPLITER}"
			fi
		else
			echo "${TMP_SPLITER}"
			echo "Execute ${green}success${reset}"
			echo "${TMP_SPLITER3}"
			break
		fi
	done

	return $?
}

# 通过指定用户，通过管道执行脚本
# 参数1：执行脚本
# 参数2：执行用户，默认`whoami`
# 例：
#   su_bash_channel_exec "source /etc/profile && source ~/.bashrc && conda update -y conda"
function su_bash_channel_exec()
{
	local _TMP_SU_BASH_CHANNEL_EXEC_SCRIPTS=${1:-"echo"}
    local _TMP_SU_BASH_CHANNEL_EXEC_USER=${2:-`whoami`}

	local _TMP_SU_BASH_CHANNEL_EXEC_BASIC_SCRIPT="cd `pwd`"
	su - ${_TMP_SU_BASH_CHANNEL_EXEC_USER} -c "${_TMP_SU_BASH_CHANNEL_EXEC_BASIC_SCRIPT} && ${_TMP_SU_BASH_CHANNEL_EXEC_SCRIPTS}"

	return $?
}

# 通过指定用户，通过管道执行脚本
# 参数1：执行脚本
# 参数2：执行用户，默认`whoami`
# 例：
#   su_bash_env_channel_exec "conda update conda"
function su_bash_env_channel_exec()
{
	local _TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT="source /etc/profile && source ~/.bashrc"
	su_bash_channel_exec "${_TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT} && (${1})" "${2}"

	return $?
}

# 通过指定用户，通过管道执行脚本
# 参数1：执行脚本
# 参数2：执行用户，默认`whoami`
# 例：
#   su_bash_nvm_channel_exec "conda update conda"
function su_bash_nvm_channel_exec()
{
	local _TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT="[[ -a '${NVM_PATH}' ]] && source ${NVM_PATH}"
	su_bash_channel_exec "${_TMP_SU_BASH_ENV_CHANNEL_EXEC_BASIC_SCRIPT} && (${1})" "${2}"

	return $?
}

# 通过指定用户，指定conda环境下，通过管道执行脚本
# 参数1：执行脚本
# 参数2：pyenv环境，默认${PY_ENV}
# 参数3：执行用户，默认`whoami`
# 例：
#	su_bash_channel_conda_exec "cd ${CONDA_PW_SCRIPTS_DIR} && python pw_sync_docker_hub_vers.py 'labring/sealos'"
function su_bash_channel_conda_exec()
{
	local _TMP_SU_BASH_CHANNEL_CONDA_EXEC_SCRIPTS=${1:-"echo"}
    local _TMP_SU_BASH_CHANNEL_CONDA_EXEC_ENV=${2:-"${PY_ENV}"}
    local _TMP_SU_BASH_CHANNEL_CONDA_EXEC_USER=${3:-`whoami`}

	local _TMP_SU_BASH_CHANNEL_CONDA_EXEC_BASIC_SCRIPT="conda activate ${_TMP_SU_BASH_CHANNEL_CONDA_EXEC_ENV}"
	su_bash_channel_exec "${_TMP_SU_BASH_CHANNEL_CONDA_EXEC_BASIC_SCRIPT} && (${_TMP_SU_BASH_CHANNEL_CONDA_EXEC_SCRIPTS})" "${_TMP_SU_BASH_CHANNEL_CONDA_EXEC_USER}"

	return $?
}

# 获取docker-hub仓库发布版本列表
# 参数1：获取docker-hub仓库地址
# 例：
#	fetch_docker_hub_release_vers 'labring/sealos'
function fetch_docker_hub_release_vers()
{
	local _TMP_FETCH_DOCKER_HUB_RELEASE_VERS_REPO="${1}"

	function _fetch_docker_hub_release_vers_by_pw()
	{
		su_bash_channel_conda_exec "cd ${CONDA_PW_SCRIPTS_DIR} && python pw_async_fetch_docker_hub_vers.py ${_TMP_FETCH_DOCKER_HUB_RELEASE_VERS_REPO}"
	}
	
	path_exists_yn_action "${CONDA_PW_SCRIPTS_DIR}/pw_async_fetch_docker_hub_vers.py" "_fetch_docker_hub_release_vers_by_pw" "not implement"
}

# 获取指定URL选择器部分属性
# 参数1：获取URL的地址
# 参数2：内容选择器
# 参数3：获取属性，默认inner_text
# 例：
#	fetch_url_selector_attr 'https://nodejs.org/en/' 'a[class=home-downloadbutton]:has-text("Recommended For Most Users")'
function fetch_url_selector_attr()
{
	local _TMP_FETCH_URL_SELECTOR_ATTR_URL="${1}"
	local _TMP_FETCH_URL_SELECTOR_ATTR_SELECTOR="${2}"
	local _TMP_FETCH_URL_SELECTOR_ATTR_ATTR="${3:-'inner_text'}"

	function _fetch_url_selector_attr_by_pw()
	{
		su_bash_channel_conda_exec "cd ${CONDA_PW_SCRIPTS_DIR} && python pw_async_fetch_url_selector_attr.py '${_TMP_FETCH_URL_SELECTOR_ATTR_URL}' '${_TMP_FETCH_URL_SELECTOR_ATTR_SELECTOR}' '${_TMP_FETCH_URL_SELECTOR_ATTR_ATTR}'"
	}
	
	path_exists_yn_action "${CONDA_PW_SCRIPTS_DIR}/pw_async_fetch_url_selector_attr.py" "_fetch_url_selector_attr_by_pw" "not implement"
}

#安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载地址
# 参数3：软件下载后执行函数名称
# 参数4：软件安装路径（不填入默认识别为 ${SETUP_DIR}）
# 参数5：软件已安装执行函数
function setup_soft_wget() 
{
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_SOFT_WGET_NAME=${1}
	local _TMP_SOFT_WGET_URL=${2}
	local _TMP_SOFT_WGET_SETUP_FUNC=${3}
	local _TMP_SOFT_WGET_SETUP_DIR=$([ -n "${4}" ] && echo "${4}" || echo ${SETUP_DIR})
	local _TMP_SOFT_WGET_INSTALLED_SCRIPTS=${5}
	
	typeset -l TMP_SOFT_LOWER_NAME
	local TMP_SOFT_LOWER_NAME=${_TMP_SOFT_WGET_NAME}

	local TMP_SOFT_SETUP_PATH=${_TMP_SOFT_WGET_SETUP_DIR}/${TMP_SOFT_LOWER_NAME}

    # ls -d ${TMP_SOFT_SETUP_PATH} && $? -ne 0   #ps -fe | grep ${_TMP_SOFT_WGET_NAME} | grep -v grep
	if [ ! -a ${TMP_SOFT_SETUP_PATH} ]; then
		local _TMP_SOFT_WGET_FILE_NAME=
		local _TMP_SOFT_WGET_FILE_DIR="${DOWN_DIR}"
		while_wget "${_TMP_SOFT_WGET_URL}" '_TMP_SOFT_WGET_FILE_DIR=`pwd` && _TMP_SOFT_WGET_FILE_NAME=${_TMP_SOFT_WGET_FILE_DEST_NAME}'
		
		# 回到while_wget下载的目录中去
		cd ${_TMP_SOFT_WGET_FILE_DIR}

		local _TMP_SOFT_WGET_FILE_NAME_NO_EXTS="${DOWN_DIR}/tmp"
		local _TMP_SOFT_WGET_UNPACK_FILE_EXT=`echo ${_TMP_SOFT_WGET_FILE_NAME##*.}`
		if [ "${_TMP_SOFT_WGET_UNPACK_FILE_EXT}" = "zip" ]; then
			_TMP_SOFT_WGET_PACK_DIR_LINE=`unzip -v ${_TMP_SOFT_WGET_FILE_NAME} | awk '/----/{print NR}' | awk 'NR==1{print}'`
			local _TMP_SOFT_WGET_FILE_NAME_UNZIP=`unzip -v ${_TMP_SOFT_WGET_FILE_NAME} | awk 'NR==LINE{print $NF}' LINE=$((_TMP_SOFT_WGET_PACK_DIR_LINE+1))`
			_TMP_SOFT_WGET_FILE_NAME_NO_EXTS=${_TMP_SOFT_WGET_FILE_NAME_UNZIP%/*}
			
			# 没有层级的情况
			local _TMP_SOFT_WGET_FILE_NAME_UNZIP_ARGS=""
			if [ "${_TMP_SOFT_WGET_FILE_NAME_UNZIP}" == "${_TMP_SOFT_WGET_FILE_NAME_NO_EXTS}" ]; then
				_TMP_SOFT_WGET_FILE_NAME_NO_EXTS="${TMP_SOFT_LOWER_NAME}"
				_TMP_SOFT_WGET_FILE_NAME_UNZIP_ARGS="-d ${TMP_SOFT_LOWER_NAME}"
			fi

			# 本地是否存在目录
			if [ ! -d "${_TMP_SOFT_WGET_FILE_NAME_NO_EXTS}" ]; then
				unzip -o ${_TMP_SOFT_WGET_FILE_NAME} ${_TMP_SOFT_WGET_FILE_NAME_UNZIP_ARGS}
			fi
		else
			_TMP_SOFT_WGET_FILE_NAME_NO_EXTS=`tar -tf ${_TMP_SOFT_WGET_FILE_NAME} | grep '/' | awk 'NR==1{print}' | sed s@/.*@""@g`
			if [ ! -d "${_TMP_SOFT_WGET_FILE_NAME_NO_EXTS}" ]; then
				if [ "${_TMP_SOFT_WGET_UNPACK_FILE_EXT}" = "xz" ]; then
					xz -d ${_TMP_SOFT_WGET_FILE_NAME}
					local _TMP_SOFT_WGET_FILE_NAME_TAR=${_TMP_SOFT_WGET_FILE_NAME%%.xz*}
					tar -xvf ${_TMP_SOFT_WGET_FILE_NAME_TAR}
					rm -rf ${_TMP_SOFT_WGET_FILE_NAME_TAR}
				else
					tar -zxvf ${_TMP_SOFT_WGET_FILE_NAME}
				fi
			fi
		fi
		
		cd ${_TMP_SOFT_WGET_FILE_NAME_NO_EXTS}

		#安装函数调用
		${_TMP_SOFT_WGET_SETUP_FUNC} "${TMP_SOFT_SETUP_PATH}"
	
		echo "Complete."
	else
		# 执行安装
		exec_check_action "_TMP_SOFT_WGET_INSTALLED_SCRIPTS" "${_TMP_SOFT_WGET_NAME}"
	fi

	return $?
}

#安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载地址
# 参数3：软件下载后执行函数名称
# 参数4：软件下载附加参数
function setup_soft_git() 
{	
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_SOFT_GIT_NAME=${1}
	local _TMP_SOFT_GIT_URL=${2}
	local _TMP_SOFT_GIT_SETUP_FUNC=${3}
	local _TMP_SOFT_GIT_URL_PARAMS=${4}
	
	typeset -l TMP_SOFT_LOWER_NAME
	local TMP_SOFT_LOWER_NAME=${_TMP_SOFT_GIT_NAME}
	local TMP_SOFT_SETUP_PATH=${SETUP_DIR}/${TMP_SOFT_LOWER_NAME}

    ls -d ${TMP_SOFT_SETUP_PATH}   #ps -fe | grep $_TMP_SOFT_GIT_NAME | grep -v grep
	if [ $? -ne 0 ]; then
		local _TMP_SOFT_GIT_FOLDER_NAME=`echo "${_TMP_SOFT_GIT_URL}" | awk -F'/' '{print $NF}'`

		mkdir -pv ${DOWN_DIR} && cd ${DOWN_DIR}
		if [ ! -f "${_TMP_SOFT_GIT_FOLDER_NAME}" ]; then
			git clone ${_TMP_SOFT_GIT_URL} ${_TMP_SOFT_GIT_URL_PARAMS}
		fi
		
		cd ${_TMP_SOFT_GIT_FOLDER_NAME}

		#安装函数调用
		${_TMP_SOFT_GIT_SETUP_FUNC} "${TMP_SOFT_SETUP_PATH}"
	
		echo "Complete."
	fi

	return $?
}

# PIP安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载后执行函数名称
# 参数3：pip版本，默认2
function setup_soft_pip() 
{
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_SOFT_PIP_NAME=`echo "${1}" | awk -F',' '{print $1}'`
	local _TMP_SOFT_PIP_SETUP_FUNC=${2}
	local _TMP_SOFT_PIP_VERS=${3:-2}
	
	# 版本2为linux系统默认自带，所以未装py3时判断
	if [ ${_TMP_SOFT_PIP_VERS} -eq 2 ] && [ ! -f "/usr/bin/pip" ]; then
		while_curl "https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py" "python get-pip.py && rm -rf get-pip.py"
		pip install --upgrade pip
		pip install --upgrade setuptools
		
		local TMP_PY_DFT_SETUP_PATH=`pip show pip | grep "Location" | awk -F' ' '{print $2}'`
		mv ${TMP_PY_DFT_SETUP_PATH} ${PY_PKGS_SETUP_DIR}
		ln -sf ${PY_PKGS_SETUP_DIR} ${TMP_PY_DFT_SETUP_PATH}
	fi

	typeset -l TMP_SOFT_LOWER_NAME
	local TMP_SOFT_LOWER_NAME=${_TMP_SOFT_PIP_NAME}
	local TMP_SOFT_SETUP_PATH=`pip show ${TMP_SOFT_LOWER_NAME} | grep "Location" | awk -F' ' '{print $2}' | xargs -I {} echo "{}/${TMP_SOFT_LOWER_NAME}"`

	# pip show supervisor
	# pip freeze | grep "supervisor=="
	if [ -z "${TMP_SOFT_SETUP_PATH}" ]; then
		echo_text_style "Pip start to install '${_TMP_SOFT_PIP_NAME}'"
		pip install ${TMP_SOFT_LOWER_NAME}
		echo_text_style "Pip installed '${_TMP_SOFT_PIP_NAME}'"

		#安装后配置函数
		exec_check_action "_TMP_SOFT_PIP_SETUP_FUNC" "${PY_PKGS_SETUP_DIR}/${TMP_SOFT_LOWER_NAME}"
	else
    	ls -d ${TMP_SOFT_SETUP_PATH}   #ps -fe | grep ${_TMP_SOFT_PIP_NAME} | grep -v grep

		return 1
	fi

	return $?
}

# PIP安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件安装后，在管道中执行的脚本
# 参数3：软件安装环境，默认取全局变量${PY_ENV}
# 示例：
#	   setup_soft_conda_pip "playwright" "export DISPLAY=:0 && playwright install"
function setup_soft_conda_pip() 
{
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_SOFT_CONDA_PIP_NAME=${1}
	local _TMP_SOFT_CONDA_PIP_SETUP_SCRIPTS=${2:-"echo"}
	local _TMP_SOFT_CONDA_PIP_ENV=${3:-"${PY_ENV}"}

	local _TMP_SOFT_CONDA_PIP_SETUP_PATH=$(su_bash_channel_conda_exec "pip show ${_TMP_SOFT_CONDA_PIP_NAME} | grep 'Location' | cut -d' ' -f2 | xargs -I {} echo '{}/${_TMP_SOFT_CONDA_PIP_NAME}'")
	
	echo_text_style "Checking the pip package '${_TMP_SOFT_CONDA_PIP_NAME}' from env <${_TMP_SOFT_CONDA_PIP_ENV}>"
	echo ${TMP_SPLITER}
	if [ -z "${_TMP_SOFT_CONDA_PIP_SETUP_PATH}" ]; then
		echo_text_style "Starting install the pip package '${_TMP_SOFT_CONDA_PIP_NAME}' to env <${_TMP_SOFT_CONDA_PIP_ENV}>"
		echo ${TMP_SPLITER2}
		su_bash_channel_conda_exec "pip install ${_TMP_SOFT_CONDA_PIP_NAME} && ${_TMP_SOFT_CONDA_PIP_SETUP_SCRIPTS}"
		echo ${TMP_SPLITER2}
		echo_text_style "Pip package installed '${_TMP_SOFT_CONDA_PIP_NAME}' to env <${_TMP_SOFT_CONDA_PIP_ENV}>"
	else
		echo_text_style "Pip package '${_TMP_SOFT_CONDA_PIP_NAME}' from env <${_TMP_SOFT_CONDA_PIP_ENV}> exists:"
		ls -d ${_TMP_SOFT_CONDA_PIP_SETUP_PATH}
		su_bash_channel_conda_exec "pip list | grep '${_TMP_SOFT_CONDA_PIP_NAME}'"

		return 1
	fi
	
	return $?
}


#安装软件下载模式
# 参数1：软件安装名称
# 参数2：软件下载后执行函数名称
# 参数3：指定node版本（node有兼容性问题）
function setup_soft_npm() 
{
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_SOFT_NPM_SETUP_NAME=`echo "${1}" | awk -F',' '{print $1}'`
	local _TMP_SOFT_NPM_SETUP_PATH=`echo "${1}" | awk -F',' '{print $NF}'`
	local _TMP_SOFT_NPM_SETUP_FUNC=${2}
	local _TMP_SOFT_NPM_NODE_VERS=${3}
	
	typeset -l _TMP_SOFT_NPM_SETUP_NAME_LOWER
	local _TMP_SOFT_NPM_SETUP_NAME_LOWER=${_TMP_SOFT_NPM_SETUP_NAME}

	# 提前检查命令是否存在
	source ${__DIR}/scripts/lang/nodejs.sh

	npm install -g npm@next
	npm audit fix

	# 指定版本
	if [ -n "${_TMP_SOFT_NPM_NODE_VERS}" ]; then
		nvm install ${_TMP_SOFT_NPM_NODE_VERS}
		nvm use ${_TMP_SOFT_NPM_NODE_VERS}
	else
		_TMP_SOFT_NPM_NODE_VERS=`nvm current`
	fi

	local _TMP_SOFT_NPM_SETUP_INFO=`npm list -g --depth 0 | grep -o ${_TMP_SOFT_NPM_SETUP_NAME_LOWER}.*`
	# 在当前指定安装版本的目录下找是否安装
	local _TMP_SOFT_NPM_SETUP_DIR=`dirname $(npm config get prefix)`/${_TMP_SOFT_NPM_NODE_VERS}/lib/node_modules/${_TMP_SOFT_NPM_SETUP_NAME_LOWER}

	if [ -z "${_TMP_SOFT_NPM_SETUP_INFO}" ]; then
		npm update

		echo "Npm start to install ${_TMP_SOFT_NPM_SETUP_NAME}"
	
		# 谨防网速慢的情况，重复安装
		while [ ! -d "${_TMP_SOFT_NPM_SETUP_DIR}" ]; do
			npm cache clean --force
			npm install --verbose -g ${_TMP_SOFT_NPM_SETUP_NAME}
		done
		
		echo "Npm installed ${_TMP_SOFT_NPM_SETUP_NAME}"

		#安装后配置函数
		${_TMP_SOFT_NPM_SETUP_FUNC} "${_TMP_SOFT_NPM_SETUP_DIR}" "${_TMP_SOFT_NPM_NODE_VERS}"
	else
    	echo ${_TMP_SOFT_NPM_SETUP_INFO}

		return 1
	fi

	return $?
}

# #循环执行
# # 参数1：提示标题
# # 参数2：函数名称
# function cycle_exec()
# {
# 	if [ $? -ne 0 ]; then
# 		return $?
# 	fi

# 	return $?
# }

#设置变量值函数如果为空
# 参数1：需要设置的变量名
# 参数2：需要设置的变量值
function set_if_empty()
{
	local _TMP_SET_IF_EMPTY_VAR_NAME=${1}
	local _TMP_SET_IF_EMPTY_VAR_VAL=${2}

	local _TMP_SET_IF_EMPTY_VAR_DFT=`eval echo '$'${_TMP_SET_IF_EMPTY_VAR_NAME}`

	if [ -n "${_TMP_SET_IF_EMPTY_VAR_VAL}" ]; then
		eval ${1}='$_TMP_SET_IF_EMPTY_VAR_DFT'
	fi

	return $?
}

#设置变量值函数如果相同
# 参数1：需要对比的原始变量名
# 参数2：需要对比的变量名/值
# 参数3：需要对比的变量值
function set_if_equals()
{
	local _TMP_SET_IF_EQS_SOURCE_VAR_NAME=${1}
	local _TMP_SET_IF_EQS_COMPARE_VAR_NAME=${2}
	local _TMP_SET_IF_EQS_SET_VAR_VAL=${3}

	local _TMP_SET_IF_EQS_SOURCE_VAR_VAL=`eval echo '$'${_TMP_SET_IF_EQS_SOURCE_VAR_NAME}`
	local _TMP_SET_IF_EQS_COMPARE_VAR_VAL=`eval echo '$'${_TMP_SET_IF_EQS_COMPARE_VAR_NAME}`

	if [ -z "${_TMP_SET_IF_EQS_COMPARE_VAR_VAL}" ]; then
		_TMP_SET_IF_EQS_COMPARE_VAR_VAL="${_TMP_SET_IF_EQS_COMPARE_VAR_NAME}"
	fi

	if [ "${_TMP_SET_IF_EQS_SOURCE_VAR_VAL}" = "${_TMP_SET_IF_EQS_COMPARE_VAR_VAL}" ]; then
		eval ${1}='$_TMP_SET_IF_EQS_SET_VAR_VAL'
	fi

	return $?
}

#是否类型的弹出动态设置变量值函数
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：是否内容加密（默认：不显示，y/Y：密文）
function input_if_empty()
{
	local _TMP_INPUT_IF_EMPTY_VAR_NAME=${1}
	local _TMP_INPUT_IF_EMPTY_NOTICE=${2}
	local _TMP_INPUT_IF_EMPTY_VAR_SEC=${3}
	local _TMP_INPUT_IF_EMPTY_DFT_VAL=`eval echo '$'$_TMP_INPUT_IF_EMPTY_VAR_NAME`
	
	# 自动样式化消息前缀 
	exec_text_style "_TMP_INPUT_IF_EMPTY_NOTICE"
	
	local _TMP_INPUT_IF_EMPTY_INPUT_CURRENT=""
	function _TMP_INPUT_IF_EMPTY_NORMAL_FUNC() {
		echo "${_TMP_INPUT_IF_EMPTY_NOTICE}, default '${green}`eval echo ${_TMP_INPUT_IF_EMPTY_DFT_VAL}`${reset}'"
		read -e _TMP_INPUT_IF_EMPTY_INPUT_CURRENT
		echo ""
	}
	
	function _TMP_INPUT_IF_EMPTY_GUM_FUNC()	{
		# gum input --prompt "Please sure your country code，default：" --placeholder "HK"
		# 必须转义，否则带样式的前提下会解析冲突
		_TMP_INPUT_IF_EMPTY_NOTICE=${_TMP_INPUT_IF_EMPTY_NOTICE//\"/\\\"}
		local _TMP_INPUT_IF_EMPTY_GUM_PARAMS="--placeholder '${_TMP_INPUT_IF_EMPTY_DFT_VAL}' --prompt \"${_TMP_INPUT_IF_EMPTY_NOTICE}, default: \" --value '${_TMP_INPUT_IF_EMPTY_DFT_VAL}'"
		
		case ${_TMP_INPUT_IF_EMPTY_VAR_SEC} in
			"y" | "Y")
			_TMP_INPUT_IF_EMPTY_GUM_PARAMS="${_TMP_INPUT_IF_EMPTY_GUM_PARAMS} --password"
			;;
			*)
			#
		esac

		_TMP_INPUT_IF_EMPTY_INPUT_CURRENT=`eval gum input ${_TMP_INPUT_IF_EMPTY_GUM_PARAMS}`

		return $?
	}
	
	# path_exists_yn_action "${GUM_PATH}" "_${FUNCNAME[0]}_gum \"${1}\" \"${2}\"" "_TMP_INPUT_IF_EMPTY_NORMAL_FUNC"
	path_exists_yn_action "${GUM_PATH}" "_TMP_INPUT_IF_EMPTY_GUM_FUNC" "_TMP_INPUT_IF_EMPTY_NORMAL_FUNC"

	if [ -n "${_TMP_INPUT_IF_EMPTY_INPUT_CURRENT}" ]; then
		eval ${1}='${_TMP_INPUT_IF_EMPTY_INPUT_CURRENT}'
	fi

	return $?
}

#是否类型的弹出动态设置变量值函数
# 参数1：需要设置的变量名
# 参数2：提示信息

#查找网页文件列表中，最新的文件名
#描述：本函数先获取关键字最新的发布日期，再找对应行的文件名，最后提取href，适合比较通用型的文件列表
# 参数1：需要设置的变量名
# 参数2：需要找寻的URL路径
# 参数3：查找关键字
#示例：
# 	set_newer_by_url_list_link_date "TMP_NEWER_LINK" "http://repo.yandex.ru/clickhouse/rpm/stable/x86_64/" "clickhouse-common-static-dbg-.*.x86_64.rpm"
function set_newer_by_url_list_link_date()
{
	local _TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_NAME=${1}
	local _TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL=${2}
	local _TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_KEY_WORDS=${3}

	local _TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_VERS_VAR_YET_VAL=`eval echo '$'${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_NAME}`

    echo ${TMP_SPLITER}
    echo "Checking the soft version by link date in url of '${red}${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL}${reset}'， default val is '${green}${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_VERS_VAR_YET_VAL}${reset}'"    
	#  | awk '{if (NR>2) {print}}' ，缺失无效行去除的判断
    local _TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE=`curl -s -A Mozilla ${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL} | grep "${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_KEY_WORDS}" | awk -F'</a>' '{print $2}' | awk '{sub("^ *","");sub(" *$","");print}' | sed '/^$/d' | awk -F' ' '{print $1}' | awk 'function t_f(t){"date -d \""t"\" +%s" | getline ft; return ft}{print t_f(${1})}' | awk 'BEGIN {max = 0} {if (${1}+0 > max+0) {max=${1} ;content=$0} } END {print content}' | xargs -I {} env LC_ALL=en_US.en date -d@{} "+%d-%h-%Y"`
    local _TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT=`curl -s -A Mozilla ${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL} | grep "${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_KEY_WORDS}" | grep "${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE}" | sed 's/\(.*\)href="\([^"\n]*\)"\(.*\)/\2/g'`

	if [ -n "${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT}" ]; then
		echo "Upgrade the soft version by link date in url of '${red}${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL}${reset}'， release newer version to '${green}${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT}${reset}'"

		input_if_empty "_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT" "Please sure the checked soft version by link date newer ${green}${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT}${reset}，if u want to change"

		eval ${1}='$_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE_TEXT'
	else
		echo "Can't check the soft version by link date in url of '${red}${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_VAR_FIND_URL}${reset}'，Some part info"
		echo "${_TMP_SET_NEWER_BY_URL_LIST_LINK_DATE_NEWER_LINK_DATE}"
	fi

    echo ${TMP_SPLITER}

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
	local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_NAME=${1}
	local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL=${2}
	local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS=$(echo ${3} | sed 's@()@[0-9.-]*@g')  #‘gradle-()-bin.zip’ -> 'gradle-.*-bin.zip'
	
	# 零宽断言，参考两篇即明白：https://segmentfault.com/q/1010000009346369，https://blog.csdn.net/iteye_5616/article/details/81855906
	local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_LEFT=$(echo ${3} | grep -o ".*(" | sed 's@\(.*\)(@\1@g')
	local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_RIGHT=$(echo ${3} | grep -o ").*" | sed 's@)\(.*\)@\1@g')
	local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_ZREG="(?<=${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_LEFT:-^})\d.*(?=${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_RIGHT:-$})"
	
	local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS_VAR_YET_VAL=`eval echo '$'${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_NAME}`

    echo ${TMP_SPLITER}
    echo "Checking the soft version by link text in url of '${red}${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL}${reset}'， default val is '${green}${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS_VAR_YET_VAL}${reset}'"
	# 清除字母开头： | tr -d "a-zA-Z-"
    local _TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS=`curl -s -A Mozilla ${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL} | grep "href=" | grep -v "Parent Directory" | sed 's@\(.*\)href="\([^"\n]*\)"\(.*\)@\2@g' | grep "${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS}" | grep -oP "${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS_ZREG}" | sort -rV | awk 'NR==1'`
	# local TMP_NEWER_FILENAME=$(echo ${3} | sed "s@()@${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS}.*@g")
    # local TMP_NEWER_HREF_LINK_FILENAME=`curl -s -A Mozilla ${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL} | grep "href=" | grep -v "Parent Directory" | sed 's@\(.*\)href="\([^"\n]*\)"\(.*\)@\2@g' | grep "${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_KEY_WORDS}" | grep "${TMP_NEWER_FILENAME}\$" | awk 'NR==1' | sed 's@.*/@@g'`

	if [ -n "${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS}" ]; then
		echo "Upgrade the soft version by link text in url of '${red}${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL}${reset}'， release newer version to '${green}${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS}${reset}'"
		
		input_if_empty "_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS" "Please sure the checked soft version by link text newer ${green}${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS}${reset}，if u want to change"

		eval ${1}='$_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS'
	else
		echo "Can't check the soft version by link text in url of '${red}${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_VAR_FIND_URL}${reset}'，Some part info"
		echo "${_TMP_SET_NEWER_BY_URL_LIST_LINK_TEXT_NEWER_VERS}"
	fi

    echo ${TMP_SPLITER}

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
	local _TMP_GITHUB_SOFT_NEWER_VERS_VAR_NAME=${1}
	local _TMP_GITHUB_SOFT_NEWER_VERS_PATH=${2}

	local _TMP_GITHUB_SOFT_NEWER_VERS_HTTPS_PATH="https://github.com/${_TMP_GITHUB_SOFT_NEWER_VERS_PATH}/releases"
	local _TMP_GITHUB_SOFT_NEWER_VERS_TAG_PATH="${_TMP_GITHUB_SOFT_NEWER_VERS_PATH}/releases/tag/"

	# 提取href中值，如需提取标签内值，则使用： sed 's/="[^"]*[><][^"]*"//g;s/<[^>]*>//g' | awk '{sub("^ *","");sub(" *$","");print}' | awk NR==1
	
	local _TMP_GITHUB_SOFT_NEWER_VERS_VAR_YET_VAL=`eval echo '$'${_TMP_GITHUB_SOFT_NEWER_VERS_VAR_NAME}`

    echo ${TMP_SPLITER}
    echo "Checking the soft in github repos of '${red}${_TMP_GITHUB_SOFT_NEWER_VERS_PATH}${reset}'， default val is '${green}${_TMP_GITHUB_SOFT_NEWER_VERS_VAR_YET_VAL}${reset}'"
	# local _TMP_GITHUB_SOFT_NEWER_VERS=`curl -s -A Mozilla ${_TMP_GITHUB_SOFT_NEWER_VERS_HTTPS_PATH} | grep "${_TMP_GITHUB_SOFT_NEWER_VERS_TAG_PATH}" | awk '{sub("^ *","");sub(" *$","");sub("<a href=\".*/tag/v", "");sub("<a href=\".*/tag/", "");sub("\">.*", "");print}' | awk NR==1`
	local _TMP_GITHUB_SOFT_NEWER_VERS=`curl -s -A Mozilla "${_TMP_GITHUB_SOFT_NEWER_VERS_HTTPS_PATH}" | grep -o "<a href=\"/${_TMP_GITHUB_SOFT_NEWER_VERS_TAG_PATH}.*<\/a>" | awk '(NR==1){sub("^ *","");sub(" *$","");sub("<a href=\".*/tag/v", "");sub("<a href=\".*/tag/", "");sub("\".*", "");print}'`

	if [ -n "${_TMP_GITHUB_SOFT_NEWER_VERS}" ]; then
		echo "Upgrade the soft in github repos of '${red}${_TMP_GITHUB_SOFT_NEWER_VERS_PATH}${reset}'， release newer version to '${green}${_TMP_GITHUB_SOFT_NEWER_VERS}${reset}'"

		input_if_empty "_TMP_GITHUB_SOFT_NEWER_VERS" "Please sure the checked soft in github repos newer ${green}${_TMP_GITHUB_SOFT_NEWER_VERS}${reset}，if u want to change"

		eval ${1}='$_TMP_GITHUB_SOFT_NEWER_VERS'
	else
		echo "Can't check the soft in github repos of '${red}${_TMP_GITHUB_SOFT_NEWER_VERS_PATH}${reset}'，Some part info"
		echo "${_TMP_GITHUB_SOFT_NEWER_VERS}"
	fi
    echo ${TMP_SPLITER}
	
	return $?
}

#查找列表中，获取关键字首行
# 参数1：需要设置的变量名
# 参数2：需要查找的内容
# 参数3：查找关键字
function find_content_list_first_line()
{
	local _TMP_FIND_CONTENT_LIST_FIRST_LINE_VAR_NAME=${1}
	local _TMP_FIND_CONTENT_LIST_FIRST_LINE_VAR_FIND_CONTENT=${2}
	local _TMP_FIND_CONTENT_LIST_FIRST_LINE_VAR_KEY_WORDS=${3}

    local _TMP_FIND_CONTENT_LIST_FIRST_LINE_MATCH_CONTENT_FIRST_LINE=`echo ${_TMP_FIND_CONTENT_LIST_FIRST_LINE_VAR_FIND_CONTENT} | grep "${_TMP_FIND_CONTENT_LIST_FIRST_LINE_VAR_KEY_WORDS}" | awk 'NR==1'`

	if [ -n "${_TMP_FIND_CONTENT_LIST_FIRST_LINE_MATCH_CONTENT_FIRST_LINE}" ]; then
		eval ${1}='${_TMP_FIND_CONTENT_LIST_FIRST_LINE_MATCH_CONTENT_FIRST_LINE}'
	fi

	return $?
}

#填充右处
# 参数1：需要设置的变量名
# 参数2：填充字符
# 参数3：总长度
# 参数4：格式化字符
function fill_right()
{
	local _TMP_FILL_RIGHT_VAR_NAME=${1}
	local _TMP_FILL_RIGHT_VAR_VAL=`eval echo '$'${_TMP_FILL_RIGHT_VAR_NAME}`
	local _TMP_FILL_RIGHT_FILL_CHR=${2}
	local _TMP_FILL_RIGHT_TOTAL_LEN=${3}

	local _TMP_FILL_RIGHT_ITEM_LEN=${#_TMP_FILL_RIGHT_VAR_VAL}
	local _TMP_FILL_RIGHT_OUTPUT_SPACE_COUNT=$((_TMP_FILL_RIGHT_TOTAL_LEN-_TMP_FILL_RIGHT_ITEM_LEN))	
	local _TMP_FILL_RIGHT_SPACE_STR=`eval printf %.s'${_TMP_FILL_RIGHT_FILL_CHR}' {1..$_TMP_FILL_RIGHT_OUTPUT_SPACE_COUNT}`
	
	local _TMP_FILL_RIGHT_FINAL_STR="${_TMP_FILL_RIGHT_VAR_VAL}${_TMP_FILL_RIGHT_SPACE_STR}"
	
	if [ -n "${4}" ]; then
		_TMP_FILL_RIGHT_FINAL_STR=`echo "${4}" | sed s@%@"${_TMP_FILL_RIGHT_FINAL_STR}"@g`
	fi
	
	eval ${_TMP_FILL_RIGHT_VAR_NAME}='${_TMP_FILL_RIGHT_FINAL_STR}'
	
	return $?
}

#按键选择类型的弹出动态设置变量值函数
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：选项参数
# 参数4：自定义的Spliter
function set_if_choice()
{
	local _TMP_SET_IF_CHOICE_VAR_NAME=${1}
	local _TMP_SET_IF_CHOICE_NOTICE=${2}
	local _TMP_SET_IF_CHOICE_CHOICE=${3}
	
	exec_text_style "_TMP_SET_IF_CHOICE_NOTICE"

	local _TMP_CHOICE_SPLITER=$([ -n "${TMP_SPLITER}" ] && echo "${TMP_SPLITER}" || echo "------------------------------------------------------")
	set_if_empty "_TMP_CHOICE_SPLITER" "${4}"
	local _TMP_CHOICE_SPLITER_LEN=${#_TMP_CHOICE_SPLITER}
	
	local _TMP_SET_IF_CHOICE_ARR=(${_TMP_SET_IF_CHOICE_CHOICE//,/ })
	local _TMP_SET_IF_CHOICE_ARR_LEN=${#_TMP_SET_IF_CHOICE_ARR[@]}
	
	# 编号前坠
	local _TMP_SET_IF_CHOICE_TMP_SQ_PREFIX=""

	# X退出字符前缀
	local _TMP_SET_IF_CHOICE_TMP_SQ_EXIT_SIGN="X"
	
	if [ ${_TMP_SET_IF_CHOICE_ARR_LEN} -gt 10 ]; then
		_TMP_SET_IF_CHOICE_TMP_SQ_PREFIX=`eval printf %.s'' {1..$((${#_TMP_SET_IF_CHOICE_ARR_LEN}-1))}`
		_TMP_SET_IF_CHOICE_TMP_SQ_EXIT_SIGN=`eval printf %.s'X' {1..${#_TMP_SET_IF_CHOICE_ARR_LEN}}`
	fi

	function _TMP_SET_IF_CHOICE_NORMAL_FUNC() {
		echo ${_TMP_CHOICE_SPLITER}

		for I in ${!_TMP_SET_IF_CHOICE_ARR[@]};  
		do
			local _TMP_SET_IF_CHOICE_NORMAL_FUNC_TMP_COLOR="${red}"
			if [ $(($I%2)) -eq 0 ]; then
				_TMP_SET_IF_CHOICE_NORMAL_FUNC_TMP_COLOR="${green}"
			fi

			local _TMP_SET_IF_CHOICE_NORMAL_FUNC_SIGN=$((I+1))
			local _TMP_SET_IF_CHOICE_ITEM=${_TMP_SET_IF_CHOICE_ARR[$I]}
			if [ `echo "${_TMP_SET_IF_CHOICE_ITEM}" | tr 'A-Z' 'a-z'` == "exit" ]; then
				echo ${_TMP_CHOICE_SPLITER}
				_TMP_SET_IF_CHOICE_NORMAL_FUNC_SIGN=${_TMP_SET_IF_CHOICE_TMP_SQ_EXIT_SIGN}
			else
				if [ ${I} -ge 9 ]; then
					_TMP_SET_IF_CHOICE_TMP_SQ_PREFIX=""
				fi
			fi
			
			fill_right "_TMP_SET_IF_CHOICE_ITEM" "" $((${_TMP_CHOICE_SPLITER_LEN}-${#_TMP_SET_IF_CHOICE_TMP_SQ_EXIT_SIGN}-10)) "|     [${_TMP_SET_IF_CHOICE_NORMAL_FUNC_SIGN}]${_TMP_SET_IF_CHOICE_TMP_SQ_PREFIX}${_TMP_SET_IF_CHOICE_NORMAL_FUNC_TMP_COLOR}%${reset}|"
			
			echo "${_TMP_SET_IF_CHOICE_ITEM}"
		done
		
		echo ${_TMP_CHOICE_SPLITER}

		if [ -n "${_TMP_SET_IF_CHOICE_NOTICE}" ]; then
			echo "${_TMP_SET_IF_CHOICE_NOTICE}, by above keys, then enter it"
		fi
		
		if [ ${_TMP_SET_IF_CHOICE_ARR_LEN} -le 10 ]; then
			read -n 1 KEY
		else
			read KEY
		fi

		_TMP_SET_IF_CHOICE_NEW_VAL=${_TMP_SET_IF_CHOICE_ARR[$((KEY-1))]}

		echo

		return $?
	}
	
	function _TMP_SET_IF_CHOICE_GUM_FUNC() {		
		for I in ${!_TMP_SET_IF_CHOICE_ARR[@]};  
		do
			local _TMP_SET_IF_CHOICE_NORMAL_FUNC_TMP_COLOR=1
			if [ $(($I%2)) -eq 0 ]; then
				_TMP_SET_IF_CHOICE_NORMAL_FUNC_TMP_COLOR=2
			fi

			local _TMP_SET_IF_CHOICE_GUM_FUNC_SIGN=$((I+1))
						
			local _TMP_SET_IF_CHOICE_ITEM=${_TMP_SET_IF_CHOICE_ARR[$I]}
			if [ `echo "${_TMP_SET_IF_CHOICE_ITEM}" | tr 'A-Z' 'a-z'` == "exit" ]; then
				_TMP_SET_IF_CHOICE_GUM_FUNC_SIGN=${_TMP_SET_IF_CHOICE_TMP_SQ_EXIT_SIGN}
			else
				if [ ${I} -ge 9 ]; then
					_TMP_SET_IF_CHOICE_TMP_SQ_PREFIX=""
				fi
			fi

			fill_right "_TMP_SET_IF_CHOICE_ITEM" "" $((_TMP_CHOICE_SPLITER_LEN-11)) "[${_TMP_SET_IF_CHOICE_GUM_FUNC_SIGN}]${_TMP_SET_IF_CHOICE_TMP_SQ_PREFIX}$(gum style --foreground ${_TMP_SET_IF_CHOICE_NORMAL_FUNC_TMP_COLOR} \"%\")"
			_TMP_SET_IF_CHOICE_ARR[$I]="\"${_TMP_SET_IF_CHOICE_ITEM}\""
		done

		local _TMP_SET_IF_CHOICE_ARR_STR=$(IFS=' '; echo "${_TMP_SET_IF_CHOICE_ARR[*]}")
		if [ -z "${_TMP_SET_IF_CHOICE_ARR_STR}" ]; then
			echo
			echo_text_style "'No choice' set, please check your 'str arr'"

			return 0
		fi
		local _TMP_SET_IF_CHOICE_GUM_CHOICE_SCRIPT="gum choose --cursor='|>' --selected-prefix '[✓] ' ${_TMP_SET_IF_CHOICE_ARR_STR} | tr -d '' | cut -d ']' -f 2"
		
		if [ -n "${_TMP_SET_IF_CHOICE_NOTICE}" ]; then
			echo_text_style "${_TMP_SET_IF_CHOICE_NOTICE}, by 'follow keys', then enter it"
		fi
		
		_TMP_SET_IF_CHOICE_NEW_VAL=`eval ${_TMP_SET_IF_CHOICE_GUM_CHOICE_SCRIPT}`

		return $?
	}

	local _TMP_SET_IF_CHOICE_NEW_VAL=""
	
	path_exists_yn_action "${GUM_PATH}" "_TMP_SET_IF_CHOICE_GUM_FUNC" "_TMP_SET_IF_CHOICE_NORMAL_FUNC"	
	
	echo "Choice of '${_TMP_SET_IF_CHOICE_NEW_VAL}' checked"

	eval ${_TMP_SET_IF_CHOICE_VAR_NAME}=`echo "${_TMP_SET_IF_CHOICE_NEW_VAL}" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"`

	return $?
}

#按键选择类型的弹出动态设置变量值函数
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：选项参数
# 参数4：自定义的Spliter
# 参数5：脚本路径/前缀
# 参数6：执行脚本后的操作
function exec_if_choice_custom()
{
	# 非首次运行时，清理命令台
	if [ "${1}" == "TMP_CHOICE_CTX" ] && [ -n "`eval echo '$'${1}`" ]; then
		clear
	fi

	set_if_choice "${1}" "${2}" ${3} "${4}"

	typeset -l _TMP_EXEC_IF_CHOICE_NEW_VAL
	local _TMP_EXEC_IF_CHOICE_NEW_VAL=`eval echo '$'${1}`
	if [ -n "${_TMP_EXEC_IF_CHOICE_NEW_VAL}" ]; then
		if [ "${_TMP_EXEC_IF_CHOICE_NEW_VAL}" = "exit" ]; then
			exit 1
		fi

		if [ "${_TMP_EXEC_IF_CHOICE_NEW_VAL}" = "..." ]; then
			return $?
		fi

		if [ -n "$5" ]; then
			local _TMP_EXEC_IF_CHOICE_SCRIPT_PATH="${5}/${_TMP_EXEC_IF_CHOICE_NEW_VAL}"
			local _TMP_EXEC_IF_CHOICE_SCRIPT_PATH_ARR=(${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH})
			_TMP_EXEC_IF_CHOICE_SCRIPT_PATH_ARR[1]=`echo "${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}" | sed "s@-@.@g"`
			_TMP_EXEC_IF_CHOICE_SCRIPT_PATH_ARR[2]=`echo "${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}" | sed "s@-@_@g"`
			_TMP_EXEC_IF_CHOICE_SCRIPT_PATH_ARR[3]=`echo "${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}" | sed "s@_@-@g"`
			_TMP_EXEC_IF_CHOICE_SCRIPT_PATH_ARR[4]=`echo "${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}" | sed "s@_@.@g"`
			_TMP_EXEC_IF_CHOICE_SCRIPT_PATH_ARR[5]=`echo "${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}" | sed "s@\.@-@g"`
			_TMP_EXEC_IF_CHOICE_SCRIPT_PATH_ARR[6]=`echo "${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}" | sed "s@\.@_@g"`
			_TMP_EXEC_IF_CHOICE_SCRIPT_PATH_ARR[7]=`echo "${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}" | sed "s@ @-@g"`
			_TMP_EXEC_IF_CHOICE_SCRIPT_PATH_ARR[8]=`echo "${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}" | sed "s@ @_@g"`
			_TMP_EXEC_IF_CHOICE_SCRIPT_PATH_ARR[9]=`echo "${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}" | sed "s@ @.@g"`

			# 识别文件转换
			for _TMP_EXEC_IF_CHOICE_SCRIPT_PATH in ${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH_ARR[@]}; do
				if [ -f "${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}.sh" ]; then
					_TMP_EXEC_IF_CHOICE_SCRIPT_PATH="${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}.sh"
					break
				fi
			done

			if [ ! -f "${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}" ];then
				exec_check_action "${5}${_TMP_EXEC_IF_CHOICE_NEW_VAL}"
			else
				source ${_TMP_EXEC_IF_CHOICE_SCRIPT_PATH}
			fi
		else
			exec_check_action "${_TMP_EXEC_IF_CHOICE_NEW_VAL}"
		fi
		
		local _TMP_EXEC_IF_CHOICE_TMP_RETURN=$?
		#返回非0，跳出循环，指导后续请求不再进行
		if [ ${_TMP_EXEC_IF_CHOICE_TMP_RETURN} != 0 ]; then
			return ${_TMP_EXEC_IF_CHOICE_TMP_RETURN}
		fi

		# if [ "${_TMP_EXEC_IF_CHOICE_NEW_VAL}" != "..." ]; then
		# 	read -n 1 -p "Press <Enter> go on..."
		# fi

		if [ -n "${6}" ]; then
			eval "${6}"
		fi
	fi


	return $?
}

#按键选择类型的弹出动态设置变量值函数
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：选项参数
# 参数4：自定义的Spliter
# 参数5：脚本路径/前缀
function exec_if_choice()
{
	exec_if_choice_custom "${1}" "${2}" ${3} "${4}" "$5" 'exec_if_choice "${1}" "${2}" ${3} "${4}" "$5"'
}

#按键选择类型的弹出动态设置变量值函数
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：选项参数
# 参数4：自定义的Spliter
# 参数5：脚本路径/前缀
function exec_if_choice_onece()
{
	exec_if_choice_custom "${1}" "${2}" ${3} "${4}" "$5"
}

# 在管道内运行函数执行此方法
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
#      docker container ls -a | cut -d' ' -f1 | grep -v "CONTAINER" | grep -v "^$" | eval "exec_channel_action funca 123"
#      输出：
#			074c3737df15
#			123
#			b
function exec_channel_action()
{
	local _TMP_EXEC_CHANNEL_ACTION_FUNC=${1}

	shift
	while read _TMP_EXEC_CHANNEL_TEXT_LINE
	do
		${_TMP_EXEC_CHANNEL_ACTION_FUNC} "${_TMP_EXEC_CHANNEL_TEXT_LINE}" $@
	done
}

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
#     exec_check_action "test_func" "1" "2" "3"
#     local test_func_var="test_func"
#     exec_check_action "test_func_var" "1" "2" "3"
#     exec_check_action "echo 'hello test_func'"
function exec_check_action() {
	local _TMP_EXEC_CHECK_ACTION_SCRIPT=${1}

	# 为空则不执行
	if [ ${#_TMP_EXEC_CHECK_ACTION_SCRIPT} -eq 0 ]; then
		return $?
	fi
	
	# 空格数等于0的情况，可能是函数名或变量名。
	# local _TMP_EXEC_CHECK_ACTION_SPACE_COUNT=`echo "${1}" | grep -o ' ' | wc -l`
	# if [ ${_TMP_EXEC_CHECK_ACTION_SPACE_COUNT} -eq 0 ]; then
	# 	# 函数名优先
	# 	if [ "$(type -t ${_TMP_EXEC_CHECK_ACTION_SCRIPT})" != "function" ] ; then
	# 		_TMP_EXEC_CHECK_ACTION_SCRIPT=`eval echo '$'${1}`
	# 	fi
	# fi
	
	# 空格数等于0的情况，可能是函数名或变量名。
	# 循环获取到最终的值，有可能是变量名嵌套传递。
	while [ `echo "${_TMP_EXEC_CHECK_ACTION_SCRIPT}" | grep -o ' ' | wc -l` -eq 0 ]; do
		# 函数名优先
		if [ "$(type -t ${_TMP_EXEC_CHECK_ACTION_SCRIPT})" != "function" ] ; then
			_TMP_EXEC_CHECK_ACTION_SCRIPT=`eval echo '$'${_TMP_EXEC_CHECK_ACTION_SCRIPT}`
			
			# 变量解析后可能为空，为空则不执行
			if [ ${#_TMP_EXEC_CHECK_ACTION_SCRIPT} -eq 0 ]; then
				return $?
			fi
		else
			break
		fi
	done
	
	# 变量传递脚本，有可能变量读取完以后，是执行脚本而非函数，所以此处再判断
	if [ "$(type -t ${_TMP_EXEC_CHECK_ACTION_SCRIPT})" = "function" ] ; then
		# 移除第一位选择器
		shift

		# path_not_exists_link "/opt/docker/bin/docker" "" "/usr/bin/docker" 这种也会被判别为function
		if [ `echo "${_TMP_EXEC_CHECK_ACTION_SCRIPT}" | grep -o ' ' | wc -l` -eq 0 ]; then
			${_TMP_EXEC_CHECK_ACTION_SCRIPT} "${@}"
		else
			eval "${_TMP_EXEC_CHECK_ACTION_SCRIPT}"
		fi
	else
		# local _TMP_EXEC_CHECK_ACTION_FINAL_SCRIPT=${1}
		# exec_text_printf "_TMP_EXEC_CHECK_ACTION_FINAL_SCRIPT" "${_TMP_EXEC_CHECK_ACTION_SCRIPT}"
		eval "${_TMP_EXEC_CHECK_ACTION_SCRIPT}"
	fi

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
		shift
		exec_check_action "${@}"
		return 1
	fi

	return $?
}

#分割并执行动作
# 参数1：用于分割的字符串
# 参数2：对分割字符串执行脚本
#例子：TMP=1 && while_exec "TMP=\$((TMP+1))" "[ \$TMP -eq 10 ] && echo 1" "echo \$TMP"
function exec_split_action()
{
	local _TMP_EXEC_SPLIT_ACTION_SPLIT_ARR=(${1//,/ })
	local _TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT=${2}
	local _TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT_FORMAT_COUNT=$(echo "${2}" | grep -o "%s" | wc -l)
	
	for _TMP_EXEC_SPLIT_ACTION_SPLIT_ITEM in ${_TMP_EXEC_SPLIT_ACTION_SPLIT_ARR[@]}; do
		# 附加动态参数
		local _TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT_FORMAT_PARAMS="${_TMP_EXEC_SPLIT_ACTION_SPLIT_ITEM}"
		for ((_TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT_FORMAT_PATAMS_COUNT_INDEX=1;_TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT_FORMAT_PATAMS_COUNT_INDEX<${_TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT_FORMAT_COUNT};_TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT_FORMAT_PATAMS_COUNT_INDEX++)); do
			_TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT_FORMAT_PARAMS=$(printf "${_TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT_FORMAT_PARAMS} %s" "${_TMP_EXEC_SPLIT_ACTION_SPLIT_ITEM}")
		done
		
		# 格式化运行动态脚本
        local _TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT_CURRENT=`printf "${_TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT}" ${_TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT_FORMAT_PARAMS}`
		exec_check_action "_TMP_EXEC_SPLIT_ACTION_EXEC_SCRIPT_CURRENT" "${_TMP_EXEC_SPLIT_ACTION_SPLIT_ITEM}"
    done

	return $?
}

#执行需要判断的Y/N逻辑函数
# 参数1：并行逻辑执行参数/脚本
# 参数2：提示信息
function exec_yn_action()
{
	local _TMP_EXEC_YN_ACTION_FUNCS_OR_SCRIPTS_Y=${1}
	local _TMP_EXEC_YN_ACTION_NOTICE=${2}
		
	function _TMP_EXEC_YN_ACTION_EXEC_FUNC() {
		local _TMP_EXEC_YN_ACTION_ARR_FUNCS_OR_SCRIPTS=(${_TMP_EXEC_YN_ACTION_FUNCS_OR_SCRIPTS_Y//,/ })
		#echo ${#_TMP_ARR_FUNCS_OR_SCRIPTS[@]} 
		for _TMP_EXEC_YN_ACTION_FUNC_ON_Y in ${_TMP_EXEC_YN_ACTION_ARR_FUNCS_OR_SCRIPTS[@]}; do
			exec_check_action "${_TMP_EXEC_YN_ACTION_FUNC_ON_Y}"
			local _TMP_EXEC_YN_ACTION_RETURN=$?
			#返回非0，跳出循环，指导后续请求不再进行
			if [ ${_TMP_EXEC_YN_ACTION_RETURN} != 0 ]; then
				return ${_TMP_EXEC_YN_ACTION_RETURN}
			fi
		done

		return $?
	}

	confirm_yn_action "" "${_TMP_EXEC_YN_ACTION_NOTICE}" "_TMP_EXEC_YN_ACTION_EXEC_FUNC"

	return $?
}

#执行需要判断的Y/N逻辑函数
# 参数1：需要针对存放的变量名
# 参数2：提示信息
# 参数3：执行Y时脚本
# 参数4：执行N时脚本
# 参数5：动态参数传递
function confirm_yn_action()
{
	local _TMP_CONFIRM_YN_ACTION_VAR_NAME=${1}
	typeset -u _TMP_CONFIRM_YN_ACTION_VAR_VAL
	local _TMP_CONFIRM_YN_ACTION_VAR_VAL=`eval expr '$'${_TMP_CONFIRM_YN_ACTION_VAR_NAME}`
	local _TMP_CONFIRM_YN_ACTION_NOTICE=${2}
	local _TMP_CONFIRM_YN_ACTION_FUNCS_OR_SCRIPTS_Y=${3}
	local _TMP_CONFIRM_YN_ACTION_FUNCS_OR_SCRIPTS_N=${4}
	local _TMP_CONFIRM_YN_ACTION_RET=$?
	
	exec_text_style "_TMP_CONFIRM_YN_ACTION_NOTICE"

	local _TMP_CONFIRM_YN_ACTION_Y_N=""
	function _TMP_CONFIRM_YN_ACTION_NORMAL_FUNC() {
		echo_text_style "${_TMP_CONFIRM_YN_ACTION_NOTICE}, by follow key ('${red}yes(y) or enter key/no(n) or else${reset}')?"
		read -n 1 _TMP_CONFIRM_YN_ACTION_Y_N
		echo ""

		if [ -z "${_TMP_CONFIRM_YN_ACTION_Y_N}" ] && [ -n "${_TMP_CONFIRM_YN_ACTION_VAR_VAL}" ]; then
			echo_text_style "Can't find sure val, set confirm val to '${_TMP_CONFIRM_YN_ACTION_VAR_VAL}'"
			_TMP_CONFIRM_YN_ACTION_Y_N="${_TMP_CONFIRM_YN_ACTION_VAR_VAL}"
		fi

		return $?
	}
	
	function _TMP_CONFIRM_YN_ACTION_GUM_FUNC() {
		local _TMP_CONFIRM_YN_ACTION_VAR_GUM_DEFAULT=$([[ ${_TMP_CONFIRM_YN_ACTION_VAR_VAL} == "Y" ]] && echo "true" || echo "false")
		_TMP_CONFIRM_YN_ACTION_Y_N=`gum confirm --default=${_TMP_CONFIRM_YN_ACTION_VAR_GUM_DEFAULT} "${_TMP_CONFIRM_YN_ACTION_NOTICE}?" && echo 'Y' || echo 'N'`

		return $?
	}
	
	path_exists_yn_action "${GUM_PATH}" "_TMP_CONFIRM_YN_ACTION_GUM_FUNC" "_TMP_CONFIRM_YN_ACTION_NORMAL_FUNC"

	# 移除前面4个参数 
	shift 4

	case "${_TMP_CONFIRM_YN_ACTION_Y_N}" in
	"y" | "Y")
		if [ -n "${_TMP_CONFIRM_YN_ACTION_FUNCS_OR_SCRIPTS_Y}" ]; then
			exec_check_action "${_TMP_CONFIRM_YN_ACTION_FUNCS_OR_SCRIPTS_Y}" "${@}"
		fi
	;;
	*)
		if [ -n "${_TMP_CONFIRM_YN_ACTION_FUNCS_OR_SCRIPTS_N}" ]; then
			exec_check_action "${_TMP_CONFIRM_YN_ACTION_FUNCS_OR_SCRIPTS_N}" "${@}"
		fi

		# 修复错误，否则选择N时，值无法赋上
		# return 1
		_TMP_CONFIRM_YN_ACTION_RET=1
	esac

	if [ -n "${_TMP_CONFIRM_YN_ACTION_VAR_NAME}" ]; then
		eval ${_TMP_CONFIRM_YN_ACTION_VAR_NAME}=`echo "${_TMP_CONFIRM_YN_ACTION_Y_N:-N}"`
	fi
	
	# exec_text_style "Checked [${_TMP_CONFIRM_YN_ACTION_Y_N:-'N'}]"

	return ${_TMP_CONFIRM_YN_ACTION_RET}
}

#检测是否值
function check_yn_action() {
	local _TMP_CHECK_YN_ACTION_VAR_NAME=${1}
	local _TMP_CHECK_YN_ACTION_YN_VAL=`eval expr '$'${_TMP_CHECK_YN_ACTION_VAR_NAME}`
	
	if [ "${_TMP_CHECK_YN_ACTION_YN_VAL_YN_VAL}" = false ] || [ "${_TMP_CHECK_YN_ACTION_YN_VAL_YN_VAL}" = 0 ]; then
		return $?
	fi

	return 1
}

#按数组循环执行函数
# 参数1：需要针对存放的变量名
# 参数2：循环数组
# 参数3：循环执行脚本函数
#exec_repeat_funcs "TMP_EXEC_REPS_RESULT" "1000,2000" "num_sum"
function exec_repeat_funcs()
{
	if [ $? -ne 0 ]; then
		return $?
	fi

	local _TMP_EXEC_REPEAT_FUNCS_VAR_NAME=${1}
	local _TMP_EXEC_REPEAT_FUNCS_ARRAY_STR=${2}
	local _TMP_EXEC_REPEAT_FUNCS_FORMAT_FUNC=${3}
	
	local _TMP_EXEC_REPEAT_FUNCS_ARR=(${_TMP_EXEC_REPEAT_FUNCS_ARRAY_STR//,/ })
	for I in ${!_TMP_EXEC_REPEAT_FUNCS_ARR[@]};  
	do
		local _TMP_EXEC_REPEAT_FUNCS_OUTPUT=`$_TMP_EXEC_REPEAT_FUNCS_FORMAT_FUNC "${_TMP_EXEC_REPEAT_FUNCS_ARR[$I]}"`

		if [ ${I} -gt 0 ]; then
			eval ${1}=`eval expr '$'$_TMP_EXEC_REPEAT_FUNCS_VAR_NAME,$_TMP_EXEC_REPEAT_FUNCS_OUTPUT`
		else
			eval ${1}='$_TMP_EXEC_REPEAT_FUNCS_OUTPUT'
		fi
	done

	return $?
}

#循环执行函数，执行true时终止(函数的入参列表必须一致)
# 参数1：需要针对存放的变量名
# 参数2：循环函数数组
# 参数3：函数入参(不定长)
#exec_funcs_repeat_until_output "TMP_EXEC_FUNCS_REPS_UNTIL_OUTPUT_RESULT" "funa,funb" "_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_CURRENT_FUNCa" "paramc" ...
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
			_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_FUNC_PARAMS[${_I}-2]="\"$_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_CURRENT_FUNC\""
		fi
		
	    let _I++
	done
	
	local _TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_ARR=(${_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_ARR_FUNCS//,/ })
	for I in ${!_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_ARR[@]};  
	do
		local _TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_EXEC="${_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_ARR[$I]} ${_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_FUNC_PARAMS[*]}"
		local _TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_OUTPUT=`eval ${_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_EXEC}`
		if [ -n "${_TMP_EXEC_FUNCS_REPEAT_UNTIL_OUTPUT_OUTPUT}" ]; then
			break
		fi
	done

	return $?
}

#执行文本格式化
# 参数1：需要格式化的变量名
# 参数2：格式化字符串规格
#示例：
#	TMP_TEST_FORMATED_TEXT="World"
#	exec_text_printf "TMP_TEST_FORMATED_TEXT" "Hello %s"
#	echo "The formated text is ‘$TMP_TEST_FORMATED_TEXT’"
function exec_text_printf()
{
	local _TMP_EXEC_TEXT_FORMAT_VAR_NAME=${1}
	local _TMP_EXEC_TEXT_FORMAT_VAR_FORMAT=${2}
	local _TMP_EXEC_TEXT_FORMAT_VAR_VAL=`eval echo '$'${_TMP_EXEC_TEXT_FORMAT_VAR_NAME}`
	
	# 判断格式化模板是否为空，为空不继续执行
	if [ -z "${_TMP_EXEC_TEXT_FORMAT_VAR_FORMAT}" ]; then
		return $?
	fi
	
	# 附加动态参数
	local _TMP_EXEC_TEXT_FORMAT_COUNT=$(echo "${_TMP_EXEC_TEXT_FORMAT_VAR_FORMAT}" | grep -o "%" | wc -l)
	local _TMP_EXEC_TEXT_FORMATED_VAL=`seq -s "{}" $((_TMP_EXEC_TEXT_FORMAT_COUNT+1)) | sed 's@[0-9]@ @g' | sed "s@{}@${_TMP_EXEC_TEXT_FORMAT_VAR_VAL}@g"`
	local _TMP_EXEC_TEXT_FORMAT_FORMATED_VAL=`printf "${_TMP_EXEC_TEXT_FORMAT_VAR_FORMAT}" ${_TMP_EXEC_TEXT_FORMATED_VAL}`

	eval ${1}='${_TMP_EXEC_TEXT_FORMAT_FORMATED_VAL:-${_TMP_EXEC_TEXT_FORMAT_VAR_VAL}}'

	return $?
}

# 在yaml-list中执行
# 参数1：加载的URL
# 参数2：key的特征
# 参数3：执行的脚本 
# 示例：
# exec_in_yml_list "http://${_TMP_GITLAB_ADDRESS}/network-security/office/-/raw/main/cust_filter/cust_filter_internal.list" "^- '" "_compare_ag_increase_cust_filter" "${_TMP_AG_API_PIPELINE_REGEX}" "_submit_ag_increase_cust_filter"
function exec_in_yml_list()
{
    local _TMP_EXEC_IN_YML_LIST_LOAD_URL=${1}
    local _TMP_EXEC_IN_YML_LIST_ITEM_FEATURE=${2}
    local _TMP_EXEC_IN_YML_LIST_ACTION=${3}
    local _TMP_EXEC_IN_YML_LIST_ITEM_PIPILINE=${4:-"awk -F':' '{print \$NF}'"}
    local _TMP_EXEC_IN_YML_LIST_AFTER_ACTION=$5
    
    local _TMP_EXEC_IN_YML_LIST_YML_CONTENT=`curl -s -A Mozilla ${_TMP_EXEC_IN_YML_LIST_LOAD_URL}`
    while read line
    do
        local _TMP_EXEC_IN_YML_LIST_ITEM_MATCH_LINE=`echo "${_TMP_EXEC_IN_YML_LIST_YML_CONTENT}" | grep "^${line}$" -n | awk -F':' '{print $1}' | awk 'NR==1'`
        local _TMP_EXEC_IN_YML_LIST_ITEM=`eval "echo \"${_TMP_EXEC_IN_YML_LIST_YML_CONTENT}\" | sed -n \"${_TMP_EXEC_IN_YML_LIST_ITEM_MATCH_LINE}p\" | ${_TMP_EXEC_IN_YML_LIST_ITEM_PIPILINE} | awk '{sub(\"^ *\",\"\");sub(\" *$\",\"\");print}'"`
        
        exec_check_action "${_TMP_EXEC_IN_YML_LIST_ACTION}"
    done < <(echo "${_TMP_EXEC_IN_YML_LIST_YML_CONTENT}" | grep -E "${_TMP_EXEC_IN_YML_LIST_ITEM_FEATURE}")

    if [ -n "${_TMP_EXEC_IN_YML_LIST_AFTER_ACTION}" ]; then
        exec_check_action "${_TMP_EXEC_IN_YML_LIST_AFTER_ACTION}"
    fi

    return $?
}

#循环读取值
# 参数1：需要设置的变量名（即是默认值，也是逗号分隔的数组字符串）
# 参数2：提示信息
# 参数3：格式化字符串
# 参数4：需执行的脚本
function exec_while_read() 
{
	local _TMP_EXEC_WHILE_READ_VAR_NAME=${1}
	local _TMP_EXEC_WHILE_READ_NOTICE=${2}
	local _TMP_EXEC_WHILE_READ_FORMAT=${3}
	local _TMP_EXEC_WHILE_READ_SCRIPTS=${4}
	local _TMP_EXEC_WHILE_READ_DFT=`eval echo '$'${_TMP_EXEC_WHILE_READ_VAR_NAME}`

	local I=1
	for I in $(seq 99);
	do
		local _TMP_EXEC_WHILE_READ_CURRENT_NOTICE=`eval echo "${_TMP_EXEC_WHILE_READ_NOTICE}"`
		echo "${_TMP_EXEC_WHILE_READ_CURRENT_NOTICE} Or '${red}enter key${reset}' To Quit"
		read -e _TMP_EXEC_WHILE_READ_CURRENT

		echo "Item of '${red}${_TMP_EXEC_WHILE_READ_CURRENT}${reset}' inputed"
		
		if [ -z "${_TMP_EXEC_WHILE_READ_CURRENT}" ]; then
			if [ $I -eq 1 ] && [ -n "${_TMP_EXEC_WHILE_READ_DFT}" ]; then
				echo "No input, set value to default '${_TMP_EXEC_WHILE_READ_DFT}'"
				_TMP_EXEC_WHILE_READ_CURRENT="${_TMP_EXEC_WHILE_READ_DFT}"
			else
				_TMP_EXEC_WHILE_READ_BREAK_ACTION=true
			fi
		fi

		local _TMP_EXEC_WHILE_READ_FORMAT_CURRENT="${_TMP_EXEC_WHILE_READ_CURRENT}"
	
		exec_text_printf "_TMP_EXEC_WHILE_READ_FORMAT_CURRENT" "${_TMP_EXEC_WHILE_READ_FORMAT}"

		if [ -n "${_TMP_EXEC_WHILE_READ_CURRENT}" ]; then
			if [ $I -gt 1 ]; then
				eval ${_TMP_EXEC_WHILE_READ_VAR_NAME}=`eval echo '$'${_TMP_EXEC_WHILE_READ_VAR_NAME},${_TMP_EXEC_WHILE_READ_FORMAT_CURRENT}`
			else
				eval ${_TMP_EXEC_WHILE_READ_VAR_NAME}="${_TMP_EXEC_WHILE_READ_FORMAT_CURRENT}"
			fi
			
			exec_check_action "${_TMP_EXEC_WHILE_READ_SCRIPTS}"
			echo
		fi

		if [ ${_TMP_EXEC_WHILE_READ_BREAK_ACTION} ]; then
			break
		fi
	done

	# TMP_FORMAT_VAL="$TMP_WRAP_CHAR${_TMP_EXEC_WHILE_READ_CURRENT}$TMP_WRAP_CHAR"
	local _TMP_EXEC_WHILE_READ_NEW_VAL=`eval echo '$'${_TMP_EXEC_WHILE_READ_VAR_NAME}`
	_TMP_EXEC_WHILE_READ_NEW_VAL=`echo "${_TMP_EXEC_WHILE_READ_NEW_VAL}" | sed "s/^[,]\{1,\}//g;s/[,]\{1,\}$//g"`
	eval ${1}='${_TMP_EXEC_WHILE_READ_NEW_VAL}'
	
	if [ -z "${_TMP_EXEC_WHILE_READ_NEW_VAL}" ]; then
		echo "${red}Items not set${reset}"
		# exit 1
	fi

	# eval ${1}=`echo "${1}" | sed "s/^[,]\{1,\}//g;s/[,]\{1,\}$//g"`
	echo "Final value is '${_TMP_EXEC_WHILE_READ_NEW_VAL}'"

	return $?
}

#循环读取JSON值
# 参数1：需要设置的变量名
# 参数2：提示信息
# 参数3：选项参数
function exec_while_read_json() 
{
	local _TMP_EXEC_WHILE_READ_JSON_VAR_NAME=${1}
	local _TMP_EXEC_WHILE_READ_JSON_NOTICE=${2}
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
			echo ${_TMP_EXEC_WHILE_READ_JSON_NOTICE} | sed 's@\$i@'$i'@g' | sed 's@\$@'\'${_TMP_EXEC_WHILE_READ_JSON_KEY}\''@g'
			read -e _TMP_EXEC_WHILE_READ_JSON_CURRENT

			_TMP_EXEC_WHILE_READ_JSON_ITEM="${_TMP_EXEC_WHILE_READ_JSON_ITEM}\"${_TMP_EXEC_WHILE_READ_JSON_KEY}\": \"${_TMP_EXEC_WHILE_READ_JSON_CURRENT}\""
			if [ $((I+1)) -ne ${_TMP_EXEC_WHILE_READ_JSON_ITEM}S_LEN ]; then
				_TMP_EXEC_WHILE_READ_JSON_ITEM="${_TMP_EXEC_WHILE_READ_JSON_ITEM}, "
			fi
		done
		_TMP_EXEC_WHILE_READ_JSON_ITEM="${_TMP_EXEC_WHILE_READ_JSON_ITEM} }"

		eval ${1}='$_TMP_EXEC_WHILE_READ_JSON_ITEM'
		echo "Item of '${red}${_TMP_EXEC_WHILE_READ_JSON_ITEM}${reset}' inputed"
	done

	local _TMP_EXEC_WHILE_READ_JSON_NEW_VAL=`echo "${_TMP_EXEC_WHILE_READ_JSON_ITEM}" | sed 's@}{@}, {@g'`
	eval ${1}='$_TMP_EXEC_WHILE_READ_JSON_NEW_VAL'
	
	if [ -z "${_TMP_EXEC_WHILE_READ_JSON_NEW_VAL}" ]; then
		echo "${red}Items not set, script exit${reset}"
		exit 1
	fi

	# eval ${1}=`echo "${1}" | sed "s/^[,]\{1,\}//g;s/[,]\{1,\}$//g"`
	echo "Final value is: "
	echo "${_TMP_EXEC_WHILE_READ_JSON_NEW_VAL}" | jq
}

#生成启动配置文件
# 参数1：程序命名
# 参数2：程序启动的目录
# 参数3：程序启动的命令
# 参数4：程序启动的环境
# 参数5：优先级序号
# 参数6：运行环境，默认/etc/profile
# 参数7：运行所需的用户，默认root
function echo_startup_config()
{
	set_if_empty "SUPERVISOR_ATT_DIR" "${ATT_DIR}/supervisor"

	local _TMP_STARTUP_SUPERVISOR_NAME=${1}
	local _TMP_STARTUP_SUPERVISOR_FILENAME=${_TMP_STARTUP_SUPERVISOR_NAME}.conf
	local _TMP_STARTUP_SUPERVISOR_BOOT_DIR=${2}
	local _TMP_STARTUP_SUPERVISOR_COMMAND=${3}
	local _TMP_STARTUP_SUPERVISOR_ENV=${4}
	local _TMP_STARTUP_SUPERVISOR_PRIORITY=${5:-99}
	local _TMP_STARTUP_SUPERVISOR_SOURCE=${6}
	local _TMP_STARTUP_SUPERVISOR_USER=${7:-root}

	local _TMP_STARTUP_SUPERVISOR_DFT_ENV="/usr/bin:/usr/local/bin:"
    # 设置默认的源环境，并检测是否为NPM启动方式
	if [ -z "${_TMP_STARTUP_SUPERVISOR_SOURCE}" ]; then
		_TMP_STARTUP_SUPERVISOR_SOURCE="/etc/profile"

		# 因konga的关系，此处启动暂时注释自动修改环境的操作（建议可自动修改环境变量至当前的npm版本，并取消原始bin环境）
		# local _TMP_STARTUP_BY_NPM_CHECK=`echo "${_TMP_STARTUP_SUPERVISOR_COMMAND}" | sed "s@^sudo@@g" | awk '{sub("^ *","");sub(" *$","");print}' | grep -o "^npm"`
		# if [ "${_TMP_STARTUP_BY_NPM_CHECK}" == "npm" ]; then
		# 	_TMP_STARTUP_SUPERVISOR_SOURCE=`dirname ${NVM_PATH}`
		# fi

		# 上述调整后，解决环境冲突问题
		local _TMP_STARTUP_BY_NPM_CHECK=`echo "${_TMP_STARTUP_SUPERVISOR_COMMAND}" | sed "s@^sudo@@g" | awk '{sub("^ *","");sub(" *$","");print}' | grep -o "^npm"`
		if [ "${_TMP_STARTUP_BY_NPM_CHECK}" == "npm" ]; then
			_TMP_STARTUP_SUPERVISOR_DFT_ENV=""
		fi
	fi

	if [ -n "${_TMP_STARTUP_SUPERVISOR_BOOT_DIR}" ]; then
		_TMP_STARTUP_SUPERVISOR_BOOT_DIR="directory = ${_TMP_STARTUP_SUPERVISOR_BOOT_DIR}  ; 程序的启动目录"
	fi

	if [ -n "${_TMP_STARTUP_SUPERVISOR_ENV}" ]; then
		_TMP_STARTUP_SUPERVISOR_ENV="${_TMP_STARTUP_SUPERVISOR_ENV}:"
	fi

	# 类似的：environment = ANDROID_HOME="/opt/android-sdk-linux",PATH="/usr/bin:/usr/local/bin:%(ENV_ANDROID_HOME)s/tools:%(ENV_ANDROID_HOME)s/tools/bin:%(ENV_ANDROID_HOME)s/platform-tools:%(ENV_PATH)s"
	_TMP_STARTUP_SUPERVISOR_ENV="environment = PATH=\"${_TMP_STARTUP_SUPERVISOR_DFT_ENV}${_TMP_STARTUP_SUPERVISOR_ENV}%(ENV_PATH)s\"  ; 程序启动的环境变量信息"

	_TMP_STARTUP_SUPERVISOR_PRIORITY="priority = ${_TMP_STARTUP_SUPERVISOR_PRIORITY}"
	
	local _TMP_STARTUP_SUPERVISOR_CONF_DIR=${SUPERVISOR_ATT_DIR}/conf
	local _TMP_STARTUP_SUPERVISOR_CONF_CURRENT_OUTPUT_PATH=${_TMP_STARTUP_SUPERVISOR_CONF_DIR}/${_TMP_STARTUP_SUPERVISOR_FILENAME}
    local _TMP_STARTUP_SUPERVISOR_LNK_LOGS_DIR=${LOGS_DIR}/supervisor
	
	path_not_exists_create `dirname ${_TMP_STARTUP_SUPERVISOR_CONF_CURRENT_OUTPUT_PATH}`

	path_not_exists_create "${_TMP_STARTUP_SUPERVISOR_LNK_LOGS_DIR}"

	echo
    echo ${TMP_SPLITER}
	if [ ! -f "${_TMP_STARTUP_SUPERVISOR_CONF_CURRENT_OUTPUT_PATH}" ]; then
		echo "Supervisor：Gen startup config of '${green}${_TMP_STARTUP_SUPERVISOR_CONF_CURRENT_OUTPUT_PATH}${reset}'"
		echo
		tee ${_TMP_STARTUP_SUPERVISOR_CONF_CURRENT_OUTPUT_PATH} <<-EOF
[program:${_TMP_STARTUP_SUPERVISOR_NAME}]
command = /bin/bash -c 'source "\$0" && exec "\$@"' ${_TMP_STARTUP_SUPERVISOR_SOURCE} ${_TMP_STARTUP_SUPERVISOR_COMMAND} ; 启动命令，可以看出与手动在命令行启动的命令是一样的
autostart = true                                                                     ; 在 supervisord 启动的时候也自动启动
startsecs = 240                                                                      ; 启动 60 秒后没有异常退出，就当作已经正常启动了
autorestart = true                                                                   ; 程序异常退出后自动重启
startretries = 10                                                                    ; 启动失败自动重试次数，默认是 3
user = ${_TMP_STARTUP_SUPERVISOR_USER}                                                ; 用哪个用户启动
redirect_stderr = true                                                               ; 把 stderr 重定向到 stdout，默认 false
stdout_logfile_maxbytes = 20MB                                                       ; stdout 日志文件大小，默认 50MB
stdout_logfile_backups = 20                                                          ; stdout 日志文件备份数

${_TMP_STARTUP_SUPERVISOR_PRIORITY}                                                     ; 启动优先级，默认999
${_TMP_STARTUP_SUPERVISOR_BOOT_DIR}                                                        

${_TMP_STARTUP_SUPERVISOR_ENV}                                                        

stdout_logfile = ${_TMP_STARTUP_SUPERVISOR_LNK_LOGS_DIR}/${_TMP_STARTUP_SUPERVISOR_NAME}_stdout.log  ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动创建目录（supervisord 会自动创建日志文件）
numprocs = 1                                                                           ;
EOF
	else
		echo "Supervisor：The startup config of '${red}${_TMP_STARTUP_SUPERVISOR_CONF_CURRENT_OUTPUT_PATH}${reset}' created"
		echo
		cat ${_TMP_STARTUP_SUPERVISOR_CONF_CURRENT_OUTPUT_PATH}
	fi

    echo ${TMP_SPLITER}
	echo

	return $?
}

# 输出WEB映射生成脚本（必须在KONG所在机器下运行）
# 参数1：WEB命名
# 参数2：WEB域名
# 参数3：WEB端口
# 参数4：WEB地址
# 参数5：Kong地址
# 参数6：Caddy地址
function echo_web_service_init_scripts()
{
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_NAME=${1}
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME=`echo ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_NAME} | sed 's/[a-z]/\u&/g'`
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN=${2}
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT=${3}
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST=${4:-"${LOCAL_HOST}"}
	
	local TMP_KNG_SETUP_API_HTTP_PORT_DEFAULT=18000
	local TMP_KNG_SETUP_CHAR_PORT_SPLIT=":"
	
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST_PAIR=${5:-"127.0.0.1"}
	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST_PAIR=$([[ ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST_PAIR} == *${TMP_KNG_SETUP_CHAR_PORT_SPLIT}* ]]  && echo ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST_PAIR} || echo "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST_PAIR}:${TMP_KNG_SETUP_API_HTTP_PORT_DEFAULT}" )

	local _TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_CDY_HOST=${6}

	# 开放端口给kong所在服务器
	if [ -n "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST_PAIR}" ]; then
		echo_soft_port ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT} "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST_PAIR}"
	fi

	path_not_exists_create "${WWW_INIT_DIR}"
    echo ${TMP_SPLITER}
	tee ${WWW_INIT_DIR}/init_web_service_for_${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME}_by_caddy_webhook.sh <<-EOF
#!/bin/sh
#----------------------------------------------------
#  Project init script - for web service or autohttps
#----------------------------------------------------
TMP_INIT_WEB_SERVICE_CDY_HOST="${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_CDY_HOST}"
TMP_INIT_WEB_SERVICE_LOCAL_HOST=\`ip a | grep inet | grep -v inet6 | grep -v 127 | grep -v docker | awk '{print $2}' | awk -F'/' '{print $1}' | awk 'END {print}'\`
[ -z \${TMP_INIT_WEB_SERVICE_LOCAL_HOST} ] && TMP_INIT_WEB_SERVICE_LOCAL_HOST=\`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1\`

# 本机未有kong_api直接退出执行
if [ ! -f "/usr/bin/kong_api" ]; then
	echo "Can't find 'kong_api' command in '/usr/bin/kong_api'，please sure u exec at 'kong host'"
	return
fi

# 未定义caddy-host	
if [ -z "\${TMP_INIT_WEB_SERVICE_CDY_HOST}" ]; then	
	echo "Can't find 'caddy host' in var defined，please sure which your caddy host"
	return
fi

# 先添加域名，避免被caddy-webhook的autohttps解析覆盖
kong_api "upstream" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST_PAIR}" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME}" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST}:${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT}" "" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN}"

# 添加防火墙授权许可
echo "${TMP_SPLITER}"
echo "Please allow your iptables or cloud firewall for port '${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT}' on host '${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST}'"
echo "${TMP_SPLITER}"
echo "iptables："
echo "          sed -i "11a-A INPUT -s \${TMP_INIT_WEB_SERVICE_LOCAL_HOST} -p tcp -m state --state NEW -m tcp --dport ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT} -j ACCEPT" /etc/sysconfig/iptables"
echo "          sed -i "11a-A INPUT -s \${TMP_INIT_WEB_SERVICE_LOCAL_HOST} -p udp -m state --state NEW -m udp --dport ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT} -j ACCEPT" /etc/sysconfig/iptables"
echo "          systemctl restart iptables.service"
echo "firewall-cmd："
echo "              firewall-cmd --permanent --add-port=${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT}/tcp"
echo "              firewall-cmd --permanent --add-port=${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT}/udp"
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
    echo ${TMP_SPLITER}
	tee ${WWW_INIT_DIR}/init_web_service_for_${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME}_by_acme_plugin.sh <<-EOF
#!/bin/sh
#----------------------------------------------------
#  Project init script - for web service or autohttps
#----------------------------------------------------
TMP_INIT_WEB_SERVICE_LOCAL_HOST=\`ip a | grep inet | grep -v inet6 | grep -v 127 | grep -v docker | awk '{print \$2}' | awk -F'/' '{print \$1}' | awk 'END {print}'\`
[ -z \${TMP_INIT_WEB_SERVICE_LOCAL_HOST} ] && TMP_INIT_WEB_SERVICE_LOCAL_HOST=\`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1\`

# 本机未有kong_api直接退出执行
if [ ! -f "/usr/bin/kong_api" ]; then
	echo "Can't find 'kong_api' command in '/usr/bin/kong_api'，please sure u exec at 'kong host'"
	return
fi

# 先添加域名
kong_api "upstream" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_KONG_HOST_PAIR}" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_UPPER_NAME}" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST}:${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT}" "" "${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_DOMAIN}"

# 添加防火墙授权许可
echo "${TMP_SPLITER}"
echo "Please allow your iptables or cloud firewall for port '${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT}' on host '${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST}'"
echo "${TMP_SPLITER}"
echo "iptables："
echo "          sed -i "11a-A INPUT -s \${TMP_INIT_WEB_SERVICE_LOCAL_HOST} -p tcp -m state --state NEW -m tcp --dport ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT} -j ACCEPT" /etc/sysconfig/iptables"
echo "          sed -i "11a-A INPUT -s \${TMP_INIT_WEB_SERVICE_LOCAL_HOST} -p udp -m state --state NEW -m udp --dport ${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT} -j ACCEPT" /etc/sysconfig/iptables"
echo "          systemctl restart iptables.service"
echo "firewall-cmd："
echo "              firewall-cmd --permanent --add-port=${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT}/tcp"
echo "              firewall-cmd --permanent --add-port=${_TMP_ECHO_WEB_SERVICE_INIT_SCRIPTS_HOST_PORT}/udp"
echo "              firewall-cmd --reload"
echo "${TMP_SPLITER}"
EOF
    echo ${TMP_SPLITER}
	echo
	
	chmod +x ${WWW_INIT_DIR}/*.sh

	return $?
}

# 新增一个授权端口
# 参数1：需放开端口
# 参数2：授权IP
# 参数3：ALL/TCP/UDP
function echo_soft_port()
{
	local _TMP_ECHO_SOFT_PORT=${1}
	local _TMP_ECHO_SOFT_PORT_IP=${2}
	local _TMP_ECHO_SOFT_PORT_TYPE=${3}

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
			
			echo_startup_config "iptables" "/usr/bin" "systemctl restart iptables.service" "" "999"
		fi
	fi

	# 判断是否加端口类型
	local _TMP_ECHO_SOFT_PORT_GREP_TYPE="-p ${_TMP_ECHO_SOFT_PORT_TYPE}"

	#cat /etc/sysconfig/iptables | grep "\-A INPUT -p" | awk -F' ' '{print $(NF-2)}' | awk '{for (i=1;i<=NF;i++) {if ($i=="801") {print i}}}'
	local _TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS="cat /etc/sysconfig/iptables | grep \"\-A INPUT ${_TMP_ECHO_SOFT_PORT_GREP_TYPE}\" | grep \"\-\-dport ${_TMP_ECHO_SOFT_PORT}\""

	if [ -n "${_TMP_ECHO_SOFT_PORT_IP}" ]; then
		_TMP_ECHO_SOFT_PORT_IP="-s ${_TMP_ECHO_SOFT_PORT_IP} "
		_TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS="${_TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS} | grep '\\${_TMP_ECHO_SOFT_PORT_IP}'"
	fi

	local _TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS_RESULT=$(eval ${_TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS})
	if [ -n "${_TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS_RESULT}" ]; then
		echo -e "Port ${_TMP_ECHO_SOFT_PORT} for '${_TMP_ECHO_SOFT_PORT_IP:-"all"}' exists。\nGet data \"${red}${_TMP_ECHO_SOFT_PORT_QUERY_IPTABLES_EXISTS_RESULT}${reset}\""
		return $?
	fi
	
	# firewall-cmd --zone=public --add-port=80/tcp --permanent  # nginx 端口
	# firewall-cmd --zone=public --add-port=2222/tcp --permanent  # 用户SSH登录端口 coco
	sed -i "11a-A INPUT ${_TMP_ECHO_SOFT_PORT_IP}-p tcp -m state --state NEW -m tcp --dport ${_TMP_ECHO_SOFT_PORT} -j ACCEPT" /etc/sysconfig/iptables

	# firewall-cmd --reload  # 重新载入规则
	if [ "${DMIDECODE_MANUFACTURER}" == "VMware, Inc." ] && [ "${DMIDECODE_MANUFACTURER}" != "QEMU" ]; then	
		service iptables restart
	fi

	# local TMP_FIREWALL_STATE=`firewall-cmd --state`
	
	# firewall-cmd --permanent --add-port=${_TMP_ECHO_SOFT_PORT}/tcp
	# firewall-cmd --permanent --add-port=${_TMP_ECHO_SOFT_PORT}/udp
	# firewall-cmd --reload

	path_exists_yn_action "${GUM_PATH}" "gum spin --spinner monkey --title \"Echoing port to cross firewall...\" -- sleep 3" "sleep 3"	

	lsof -i:${_TMP_ECHO_SOFT_PORT}

	return $?
}

# 输出文本至/etc/profile，避免重复项
# 参数1：需要输出的内容
function echo_etc_profile()
{
	local _TMP_ECHO_ETC_PROFILE_INPUT="${1}"
	local _TMP_ECHO_ETC_PROFILE_GREP=$(cat /etc/profile | grep "^${_TMP_ECHO_ETC_PROFILE_INPUT}$")

	if [ -z "${_TMP_ECHO_ETC_PROFILE_GREP}" ]; then
		echo "${_TMP_ECHO_ETC_PROFILE_INPUT}" >> /etc/profile
	fi

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
	local _TMP_PROXY_BY_SS_IS_WANT_CROSS_FIREWALL=`curl -I -m 10 -o /dev/null -s -w %{http_code} https://www.facebook.com`
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

	if [ ${#_TMP_PROXY_BY_SS_MODE} -eq 0 ] || [ "$_TMP_PROXY_BY_SS_MODE" == "${_TMP_PROXY_BY_SS_MODE_NECESSARY_CHECK}" ]; then
		boot_shadowsocks_${_TMP_PROXY_BY_SS_MODE_NECESSARY_CHECK}
	fi

	return $?
}