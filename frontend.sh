#!/bin/bash

source ./common.sh

check_root
system_user

dnf module disable nginx -y &>> $LOG_FILE
VALIDATE $? "Disabling Nginx"

dnf module enable nginx:1.24 -y &>> $LOG_FILE
VALIDATE $? "Enabling Nginx 1.24 version"

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "Enabling Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
VALIDATE $? "Removing default files"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE
VALIDATE $? "Downloading Frontend Application"

cd /usr/share/nginx/html/
unzip /tmp/frontend.zip &>> $LOG_FILE
VALIDATE $? "Unzipping Frontend Application"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>> $LOG_FILE
VALIDATE $? "Copying Nginx configuration"

app_restart
print_total_time