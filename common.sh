#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.theawsdevops.space
MYSQL_HOST=mysql.theawsdevops.space
START_TIME=$(date +%s)

mkdir -p $LOG_FOLDER
echo "This script execution started at $(date)" | tee -a $LOG_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
    echo -e "${R}ERROR ${N}: Please run this script as root or using sudo."
    exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "${2} ... ${R} FAILURE ${N}" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "${2} ... ${G} SUCCESS ${N}" | tee -a $LOG_FILE
    fi
}

system_user(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then 
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop 
        VALIDATE $? "Creating system user"
    else
        echo -e "user already exists ... ${Y} SKIPPING ${N}"
    fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling NodeJS modules"
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling NodeJS version 20"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing NodeJS"
    npm install &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"
}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing maven"
    mvn clean package &>> $LOG_FILE
    VALIDATE $? "Building Maven package"
    mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE
    VALIDATE $? "Moving shipping file" 
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>> $LOG_FILE
    VALIDATE $? "Installing Python3"
    pip3 install -r requirements.txt &>> $LOG_FILE
    VALIDATE $? "Installing dependencies"
}

app_setup(){
    mkdir -p /app
    VALIDATE $? "Creating app directory"
    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name application"
    cd /app 
    VALIDATE $? "Changing to app directory" 
    rm -rf /app/*
    VALIDATE $? "Removing existing code"
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping $app_name"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
    VALIDATE $? "Copying systemctl services"
    systemctl daemon-reload
    VALIDATE $? "Reloading "
    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enabling $app_name"
}

app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarting $app_name"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Script execution completed in: ${Y}$TOTAL_TIME ${N}" | tee -a $LOG_FILE
}