#!/bin/bash

source ./common.sh
app_name=shipping
check_root

echo "Please enter root password to setup"
read -d MYSQL_ROOT_PASSWORD

app_setup
maven_setup
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Install Mysql"

mssql -h mysql.udaypappu.fun -u root -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]
then
    mysql -h mysql.udaypappu.fun -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.udaypappu.fun -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h mysql.udaypappu.fun -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading data into Mysql"
else 
    echo -e "Date is already loaded into mysql .. $Y Skipping $N"

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restart shipping" 


print_time

