#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER=$(sudo mkdir -p /var/log/expense-logs)
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
            exit 1
    fi
}

CHECKROOT

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf

systemctl restart nginx
VALIDATE $? "Restarting Nginx"
