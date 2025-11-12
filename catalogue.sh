#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup
systemd_setup


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y
VALIDATE $? "Installing Mongodb Client"

STATUS=$(mongosh --host mongodb.udaypappu.fun --eval 'db.getmongo().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.udaypappu.fun </app/db/master-data.js $>>$LOG_FILE
    VALIDATE $? "Loading data into Mongodb"
else
    echo -e "Date is already loaded ... $Y SKIPPING $N"
fi

print_time