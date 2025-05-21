#!/bin/bash


USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
M="\e[35m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)       #It will split the scriptName and gives only 10-logs which is field 1
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo -e "$M Script executing at : $N $(date)"  | tee -a $LOG_FILE

if [ $USERID -eq 0 ]   
then
    echo -e "$M Running with sudo user... $N" | tee -a $LOG_FILE
else
    echo -e "$R Error:: Run with sudo user to install packages $N" | tee -a $LOG_FILE
    exit 1
fi

#function to validate package installed succesfully or not
VALIDATE(){

    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb"

systemctl enable mongod &>>$LOG_FILE
systemctl start mongod  &>>$LOG_FILE
VALIDATE $? "Starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "Editing mongodb conf to update remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restarting mongodb"







