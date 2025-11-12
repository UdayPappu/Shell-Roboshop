#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

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

END_TIME=$(date +%)
TOTAL_TIME=$(( $END_TIME - $START_TIME )) 
echo -e "Script execution completed successfully, $Y time taken: $TOTAL_TIME" | tee -a $LOG_FILE