#!/bin/bash
#------------------------------------------------
#      Linux softs install scripts by env
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# Mark：启动
#------------------------------------------------

#---------- DIR ---------- {
# Set magic variables for current file & dir
__DIR="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"
__FILE="${__DIR}/$(basename ${BASH_SOURCE[0]})"
__CONF="$(cd; pwd)"
readonly __DIR __FILE __CONF
#---------- DIR ---------- }

function choice_type()
{
	echo_title

	exec_if_choice "TMP_CHOICE_CTX" "Please choice your setup type" "Update_Libs,From_Clean,From_Bak,Mount_Unmount_Disks,Gen_Ngx_Conf,Gen_Sup_Conf,Share_Dir,SSH_Transfer,Proxy_By_SS,Exit" "${TMP_SPLITER}"

	return $?
}

function from_clean()
{
    exec_if_choice "TMP_CHOICE_TYPE" "Please choice your setup your setup type" "...,Lang,DevOps,Cluster,ELK,BI,ServiceMesh,Database,Web,Ha,Network,Softs,Exit" "${TMP_SPLITER}"

	return $?
}

function lang()
{
    # ,Scala
    exec_if_choice "TMP_CHOICE_LANG" "Please choice which env lang you need to setup" "...,Python,Java,ERLang,Php,NodeJs,Exit" "${TMP_SPLITER}" "scripts/lang"

	return $?
}

function devops()
{
    exec_if_choice "TMP_CHOICE_DEVOPS" "Please choice which devops compoment you want to setup" "...,Git,Jenkins,Exit" "${TMP_SPLITER}" "scripts/devops"

	return $?
}

function cluster()
{
    exec_if_choice "TMP_CHOICE_CLUSTER" "Please choice which cluster compoment you want to setup" "...,JumpServer,STF,Exit" "${TMP_SPLITER}" "scripts/cluster"

	return $?
}

function elk()
{
    # ,Flume
    exec_if_choice "TMP_CHOICE_ELK" "Please choice which ELK compoment you want to setup" "...,ElasticSearch,LogStash,Kibana,FileBeat,Exit" "${TMP_SPLITER}" "scripts/elk"
	
    return $?
}

function bi()
{
    exec_if_choice "TMP_CHOICE_BI" "Please choice which bi compoment you want to setup" "...,Redis,RabbitMQ,Kafka,ZeroMQ,Flink,Exit" "${TMP_SPLITER}" "scripts/bi"
	
    return $?
}

function servicemesh()
{
    exec_if_choice "TMP_CHOICE_SERVICEMESH" "Please choice which service-mesh compoment you want to setup" "...,Docker,MiniKube,Kubernetes,Istio,Exit" "${TMP_SPLITER}" "scripts/servicemesh"
	
    return $?
}

function database()
{
	exec_if_choice "TMP_CHOICE_DATABASE" "Please choice which database compoment you want to setup" "...,MySql,PostgresQL,ClickHouse,MongoDB,RethinkDB,Exit" "${TMP_SPLITER}" "scripts/database"
	
    return $?
}

function web()
{
	exec_if_choice "TMP_CHOICE_WEB" "Please choice which web compoment you want to setup" "...,OpenResty,Kong,Caddy,Webhook,Exit" "${TMP_SPLITER}" "scripts/web"
	
    return $?
}

function ha()
{
	exec_if_choice "TMP_CHOICE_HA" "Please choice which ha compoment you want to setup" "...,Zookeeper,Hadoop,Consul,Exit" "${TMP_SPLITER}" "scripts/ha"
	
    return $?
}

function network()
{
	exec_if_choice "TMP_CHOICE_NETWORK" "Please choice which network compoment you want to setup" "...,Frp,N2N,OpenClash,Shadowsocks,Exit" "${TMP_SPLITER}" "scripts/network"
	
    return $?
}

function softs()
{
	exec_if_choice "TMP_CHOICE_SOFTS" "Please choice which soft you want to setup" "...,Supervisor,Rocket.Chat,Exit" "${TMP_SPLITER}" "scripts/softs"
	
    return $?
}

# function tools()
# {
# 	exec_if_choice "TMP_CHOICE_TOOLS" "Please choice which soft you want to setup" "...,Yasm,Graphics-Magick,Pkg-Config,Protocol-Buffers,Exit" "${TMP_SPLITER}" "scripts/tools"
	
#     return $?
# }

function from_bak()
{
    source common/${MAJOR_OS_LOWER}/reset_os.sh

	return $?
}

# 初始基本参数启动目录
function bootstrap() {
    cd ${__DIR}

    # 全部给予执行权限
    chmod +x -R scripts/*.sh
    chmod +x -R common/*.sh
    source common/common_vars.sh
    source common/${MAJOR_OS_LOWER}/common.sh
    source common/${MAJOR_OS_LOWER}/${MAJOR_VERS}/overwrite_vars.sh
    source common/${MAJOR_OS_LOWER}/bind_vars.sh

    source common/requirements.sh
    source common/${MAJOR_OS_LOWER}/functions.sh
    
    #---------- BASE ---------- {
    # 迁移packages
    if [ -d packages ]; then
        yes | cp packages/* ${DOWN_DIR}
    fi
    #}
 
    choice_type
}

if [ "${BASH_SOURCE[0]:-}" != "${0}" ]; then
    export -f bootstrap
else
    bootstrap ${@}
    exit $?
fi