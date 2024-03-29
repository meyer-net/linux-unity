#!/bin/bash
#------------------------------------------------
#      Linux softs install scripts by env
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------

function reset_passwd()
{
    local _TMP_RESET_PASSWD_USR=$(whoami)
    local _TMP_RESET_PASSWD_STR=""
	bind_if_input "_TMP_RESET_PASSWD_USR" "[${FUNCNAME[0]}] Please sure 'which user' if u want to change password"
	bind_if_input "_TMP_RESET_PASSWD_STR" "[${FUNCNAME[0]}] Please sure 'the new password of user@${_TMP_RESET_PASSWD_USR}', if u want to change" "y"

    if [ -n "${_TMP_RESET_PASSWD_STR}" ]; then
        echo "${_TMP_RESET_PASSWD_STR}" | passwd ${_TMP_RESET_PASSWD_USR} --stdin > /dev/null 2>&1
    fi

	return $?
}

function reset_dns()
{
    cp /etc/resolv.conf /etc/resolv.${LOCAL_TIMESTAMP}.conf

	bind_if_input "COUNTRY_CODE" "[${FUNCNAME[0]}] Please sure 'your country code'"

	echo_style_text "The final checked country code is '${COUNTRY_CODE}'"

	if [ "${COUNTRY_CODE}" == "CN" ]; then
		cat >/etc/resolv.conf<<EOF
# Generated by linux-unity/scripts/reset.sh
search ${SYS_NAME}
nameserver 223.5.5.5
nameserver 180.76.76.76
EOF
	else
		cat >/etc/resolv.conf<<EOF
# Generated by linux-unity/scripts/reset.sh
search ${SYS_NAME}
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
    fi

    cat /etc/resolv.conf

	return $?
}

function reset_ip()
{
    local _TMP_RESET_IP_FILES=$(ls /etc/sysconfig/network-scripts/ifcfg-en*)
    local _TMP_RESET_IP_NETWORK_FILE=""
    set_if_choice "_TMP_RESET_IP_NETWORK_FILE" "[${FUNCNAME[0]}] Please choice your network card too reset" "${_TMP_RESET_IP_FILES//  /,}"

    if [ -n "${_TMP_RESET_IP_NETWORK_FILE}" ]; then
        local _TMP_RESET_IP_ADDR="${LOCAL_HOST}"
        bind_if_input "_TMP_RESET_IP_ADDR" "[${FUNCNAME[0]}] Please ender new ip address like '${LOCAL_HOST}' or else"

        if [ -n "${_TMP_RESET_IP_ADDR}" ]; then
            sed -i "s@^IPADDR=.*@IPADDR=\"${_TMP_RESET_IP_ADDR}\"@g" ${_TMP_RESET_IP_NETWORK_FILE}
            cat ${_TMP_RESET_IP_NETWORK_FILE}
            service network restart
        fi
    fi

    source /etc/profile

	return $?
}

function reset_os()
{
    bind_if_input "SYS_NEW_NAME" "[${FUNCNAME[0]}] Please ender 'system name' like '${SYS_NEW_NAME}' or else"

    if [ -n "${SYS_NEW_NAME}" ]; then
        hostnamectl set-hostname ${SYS_NEW_NAME}
    fi

    confirm_y_action "N" "[${FUNCNAME[0]}] Please sure if you want to 'change Password'" "reset_passwd"
    confirm_y_action "Y" "[${FUNCNAME[0]}] Please sure if you want to 'change DNS'" "reset_dns"
    confirm_y_action "Y" "[${FUNCNAME[0]}] Please sure if you want to 'change local ip'" "reset_ip"

	return $?
}

reset_os