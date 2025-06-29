#!/bin/bash

#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0|cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"

id=$(id -u)

CHECKROOT(){
    if [ $id -ne 0 ]
    then 
        echo -e "$R Error: Must be root user to install the packages"
        exit 1 # other than 0 as 0 indicates it is success
    fi
}

VALIDATE(){
    if [ $1 -eq 0 ]
        then
            echo -e "$2.... is $G SUCCESS $N"
        else
            echo -e "$2.... is $R FAILED $N"
    fi
}

CHECKROOT()

dnf install mysql-server -y &>>LOG_FILE_NAME
VALIDATE() $? "Installing MYSQL server"

systemctl enable mysqld
VALIDATE() $? "Enabling MYSQL server"

systemctl start mysqld 
VALIDATE() $? "Starting MYSQL server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE() $? "Setting of root password"