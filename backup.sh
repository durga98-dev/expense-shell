#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER=$(mkdir -p "/var/log/expense-logs")
LOG_FILE=$(echo $0|cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -eq 0 ]
        then
            echo -e "$2.... is $G SUCCESS $N"
        else
            echo -e "$2.... is $R FAILED $N"
    fi
}

SOURCE_DIR=$1
DEST_DIR=$2
PARAMETER=${3: -14}

USAGE(){
    echo -e "$R USAGE::$N $0 <SOURCE_DIR> <DEST_DIR> <DAYS(optional)>"
}

if [$# -lt 2 ]
then
    USAGE
    exit 1
fi