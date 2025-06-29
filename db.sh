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

CHECKROOT

dnf install mysql-server -y  &>> $LOG_FILE_NAME
VALIDATE $? "Installing MYSQL server"

systemctl enable mysqld &>> $LOG_FILE_NAME
VALIDATE $? "Enabling MYSQL server"

systemctl start mysqld &>> $LOG_FILE_NAME
VALIDATE $? "Starting MYSQL server"

mysql -h 54.204.168.32 -u root -pExpenseApp@1 -e "show databases;" $LOG_FILE_NAME #to check if root password is already set

if [ $? -ne 0 ]
then
    echo "setup the root password"
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting of root password"
else
    echo "Root password already set"
fi

# netstat -lntp, systemctl status mysqld, ps -ef | grep mysqld - to verify