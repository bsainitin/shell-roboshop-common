#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
system_user
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB client"

INDEX=$(mongosh --host $MONGODB_HOST --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ "$INDEX" -eq -1 ]; then
    mongosh --host  $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading $app_name products"
else
    echo -e "$app_name products already loaded ... ${Y} SKIPPING ${N}" | tee -a $LOG_FILE
fi

app_restart
print_total_time