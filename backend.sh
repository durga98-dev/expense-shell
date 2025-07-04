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

dnf module disable nodejs -y &>> $LOG_FILE_NAME
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE_NAME
VALIDATE $? "Enabling Nodejs"

dnf install nodejs -y &>> $LOG_FILE_NAME
VALIDATE $? "Installation of Nodejs"

id expense &>> $LOG_FILE_NAME
if [ $? -ne 0 ]
then
    echo "Adding expense user"
    useradd expense &>> $LOG_FILE_NAME
    VALIDATE $? "Addition of user Expense"
else
    echo -e "Expense user already exists...$Y SKIPPING....$N"
fi

mkdir -p /app &>> $LOG_FILE_NAME
VALIDATE $? "Creation of App directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOG_FILE_NAME
VALIDATE $? "Downloading backend"

cd /app &>> $LOG_FILE_NAME
VALIDATE $? "Changing the directory"

rm -rf /app/* 

unzip /tmp/backend.zip &>> $LOG_FILE_NAME
VALIDATE $? "Unzipping backend"

npm install &>> $LOG_FILE_NAME
VALIDATE $? "Installing dependices"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>> $LOG_FILE_NAME
VALIDATE $? "Copy of backend service file"

systemctl daemon-reload &>> $LOG_FILE_NAME
VALIDATE $? "Daemon reload"

systemctl start backend &>> $LOG_FILE_NAME
VALIDATE $? "Started backend service"

systemctl enable backend &>> $LOG_FILE_NAME
VALIDATE $? "Enabling backend service"

#Installing MYSQL client and loading the data

dnf install mysql -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing mysql client"

mysql -h 54.204.168.32 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> $LOG_FILE_NAME
VALIDATE $? "Loading data into DB"

systemctl restart backend &>> $LOG_FILE_NAME
VALIDATE $? "Restarting the backend service"