
##########################################################################################################
__CURR_DIR="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"
__CURR_FILE="${__CURR_DIR}/$(basename ${BASH_SOURCE[0]})"
cd ${__CURR_DIR}

# 安装主体
exec_if_choice "TMP_PSQL_SETUP_CHOICE" "Please choice which <postgresql> [type] you want to setup" "...,PostgresQL,Conf,Exit" "${TMP_SPLITER}" "postgresql" 