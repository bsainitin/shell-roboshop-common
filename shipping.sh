#!/bin/bash

source ./common.sh
app_name=shipping

check_root
system_user
app_setup 
java_setup
systemd_setup

dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Installing MySQL"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>> $LOG_FILE
if [ $? -ne 0 ]; then 
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOG_FILE
    VALIDATE $? "Loading schema"

    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOG_FILE
    VALIDATE $? "Loading app user"

    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOG_FILE
    VALIDATE $? "Loading master data"
else 
    echo -e "Shipping data is already loaded ... ${Y} SKIPPING ${N}" | tee -a $LOG_FILE
fi

app_restart
print_total_time