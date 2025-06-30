#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER=$(sudo mkdir -p /var/log/expense-logs)
LOG_FILE=$(echo $0|cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -eq 0 ]
        then
            echo -e "$2.... is $G SUCCESS $N"
        else
            echo -e "$2.... is $R FAILED $N"
            exit 1
    fi
}

#Delete 14days older files

DIR="/home/ec2-user/app-logs"
OLD=$(find $DIR -name "*.log" -mtime +14)
echo -e "$R Files to be deleted are $N: $OLD"

FILE=$(file.txt < $OLD)
while read -r line
do 
    echo "$line"
done < "$FILE"

 