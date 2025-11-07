#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "Script started executing at:$(date)" | tee -a $LOG_FILE

#check user has root privilages or not
if [ $USERID -ne 0 ]
then 
echo -e "$R ERROR: Please run this script with root access $N" | tee -a $LOG_FILE
exit 1
else 
echo -e "$G you are running with root accesss $N" | tee -a $LOG_FILE
fi

#validate functions take input as exit status , what command they tried to install
VALIDATE (){
if [ $1 -eq 0 ]
then 
echo -e " $2 is ... $G Success $N" | tee -a $LOG_FILE
else
echo -e " $2 ... $R Failed $N" | tee -a $LOG_FILE
exit 1
fi 
}

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



