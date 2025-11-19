#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing MySQL server"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "Enabling MySQL server"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "Starting MySQL server"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE
VALIDATE $? "Setting up root password"

print_total_time



