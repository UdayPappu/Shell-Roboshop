#!/bin/bash

source ./common.ch
app_name=mysql
check_root

echo "Please enter root password to setup"
read -d MYSQL_ROOT_PASSWORD

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mqsql server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling mqsql server"

systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "Starting mqsql server"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "Setting MYSQL root password"

print_time