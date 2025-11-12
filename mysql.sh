#!/bin/bash
START_TIME=(date +%s)
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
echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mqsql server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling mqsql server"

systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "Starting mqsql server"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "Setting MYSQL root password"

END_TIME=$(date +%)
TOTAL_TIME=$(( $END_TIME - $START_TIME )) 
echo -e "Script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE