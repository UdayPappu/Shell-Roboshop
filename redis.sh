#!/bin/bash

source ./redis
app_name=redis

check_root


dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling default redis function"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis:7"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/ptotected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Edited redis.conf to accept remote communications"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling redis" 

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting redis"

print_time