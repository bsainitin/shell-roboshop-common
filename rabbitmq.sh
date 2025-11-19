#!/bin/bash

source ./common.sh

check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOG_FILE
VALIDATE $? "Adding RabbitMQ repo"

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "Installing RabbitMQ"

systemctl enable rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Enabling RabbitMQ server"

systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Starting RabbitMQ server"

rabbitmqctl list_users | grep roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then 
    rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
    VALIDATE $? "Adding username and password"
else
    echo -e "User 'roboshop' already exists ... ${Y}SKIPPING${N}" | tee -a $LOG_FILE
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
VALIDATE $? "Setting up permissions" 

print_total_time