#!/bin/bash

source ./common.sh
app_name=mongndb

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing Mongodb repo"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling Mongodb repo"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting Mongodb repo"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing Mongodb file for connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Retarting Mongodb repo"

print_time


