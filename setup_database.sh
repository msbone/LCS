#!/bin/bash
require "config.pm";

db_name = $nms::config::db_name;
db_user = $nms::config::db_user;
db_password =$(date +%s | sha256sum | base64 | head -c 32)
root_password = $nms::config::db_root_password;


Q1="CREATE DATABASE IF NOT EXISTS $db_name;"
Q2="GRANT ALL ON $db_name.* TO '$db_user'@'localhost' IDENTIFIED BY '$db_password';"
Q3="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}"

mysql -uroot -p$root_password  -e "$SQL"
echo "our \$db_password = \"$db_password\";"
