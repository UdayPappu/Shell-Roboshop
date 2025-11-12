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

app_setup (){
    id roboshop
if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "Roboshop system user" roboshop $>>$LOG_FILE
        VALIDATE $? " Creating roboshop system user"
    else
        echo -e "System user roboshop already created ... $Y SKIPPING $N "
    fi

    mkdir -p /app 
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip $>>$LOG_FILE
    VALIDATE $? "Downloading $app_name"

    rm -rf /app/*
    cd /app
    unzip /tmp/$app_name.zip $>>$LOG_FILE
    VALIDATE $? "Unzipping $app_name"

}

nodejs_setup (){
    dnf module disable nodejs -y $>>$LOG_FILE
    VALIDATE $? "Diabling default nodejs"

    dnf module enable nodejs:20 -y $>>$LOG_FILE
    VALIDATE $? "Enabling node js:20"

    dnf install nodejs -y $>>$LOG_FILE
    VALIDATE $? "Installing nodejs:20"

    npm install $>>$LOG_FILE
    VALIDATE $? "Installing Dependencies"
}

systemd_setup (){
        cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Copying $app_name service"

    systemctl daemon-reload $>>$LOG_FILE
    systemctl enable $app_name $>>$LOG_FILE
    systemctl start $app_name
    VALIDATE $? "Starting $app_name"
    }

#check user has root privilages or not
check_root (){
    if [ $USERID -ne 0 ]
    then 
        echo -e "$R ERROR: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$G you are running with root accesss $N" | tee -a $LOG_FILE
    fi

}

maven_setup (){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven and java"
    mvn clean package &>>$LOG_FILE
    VALIDATE $? "Packaging the shipping application"

    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "Moving and renaming jar file"

}

python_setup (){
    dnf install python3 gcc python3-devel -y
    VALIDATE $? "Installing Python"
        pip3 install -r requirements.txt  $>>$LOG_FILE
    VALIDATE $? "Installing dependencies"

    cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service  $>>$LOG_FILE
    VALIDATE $? "Copying payment service"
}

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

print_time (){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME))
    echo -e "Script executed successfully, $Y Time taken: $TOTAL_TIME seconds $N "
}

