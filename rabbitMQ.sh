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
read -s RABBITMQ_PASSWORD

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

cd $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Validating rabbitmq repo"

dnf install rabbitmq-server -y
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server
VALIDATE $? "Enabling rabbitmq"

systemctl start rabbitmq-server
VALIDATE $? "Starting rabbitmq"

rabbitmqctl add_user roboshop $RABBITMQ_PASSWORD
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

END_TIME=$(date +%)
TOTAL_TIME=$(( $END_TIME - $START_TIME )) 
echo -e "Script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE