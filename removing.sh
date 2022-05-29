#!/bin/bash
set -e



if [ -e "$1/bin/magento" ]
then
    cd "$1"
    eng=$(bin/magento config:show  catalog/search/engine)
    serv=$(bin/magento config:show "catalog/search/${eng}_server_hostname")
    serv_port=$(bin/magento config:show catalog/search/"${eng}"_server_port)
    serv_prefix=$(bin/magento config:show catalog/search/"${eng}"_index_prefix)

    host=$(awk '/host/ {print $3}' app/etc/env.php | cut -c 2- | rev | cut -c3- | rev)
    dbname=$(awk '/dbname/ {print $3}' app/etc/env.php | cut -c 2- | rev | cut -c3- | rev)
    dbusername=$(awk '/username/ {print $3}' app/etc/env.php | cut -c 2- | rev | cut -c3- | rev)
    dbpassword=$(awk '/password/ {print $3}' app/etc/env.php | cut -c 2- | rev | cut -c3- | rev)

    curl -XDELETE "$serv":"$serv_port"/"$serv_prefix"*
    
    echo "indexes removed"
    export MYSQL_PWD="${dbpassword}"
    echo "sql server is ${host}"
    mysql -h "${host}" -u "${dbusername}" -e "DROP DATABASE ${dbname};"
    echo "database removed"
    rm -rf /var/www/vhosts/"$(whoami)"/"$1"/
    echo "folder removed"
else
    exit
fi