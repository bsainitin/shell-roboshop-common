#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Added Mongo repo" 

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabled MongoDB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Started MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "Allowing remote connections to MongoDB"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarted MongoDB"

print_total_time