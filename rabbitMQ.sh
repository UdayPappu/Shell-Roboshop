#!/bin/bash

source ./common.sh
app_name=rabbitmq
check_root
echo "Please enter rabbitmq password to setup"
read -s RABBITMQ_PASSWD

cd rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo  $>>$LOG_FILE
VALIDATE $? "Validating rabbitmq repo"

dnf install rabbitmq-server -y  $>>$LOG_FILE
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server  $>>$LOG_FILE
VALIDATE $? "Enabling rabbitmq"

systemctl start rabbitmq-server  $>>$LOG_FILE
VALIDATE $? "Starting rabbitmq"

rabbitmqctl add_user roboshop $RABBITMQ_PASSWORD
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

print_time