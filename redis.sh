#!/bin/bash

R="\e[31m"
G="\e[32m"
W="\e[0m"
Y="\e[33m"
Script_Direc=$PWD
Log_Folder="/var/log/roboshop"
File_Name=$( echo $0 | cut -d "." -f1 )
Log_File="$Log_Folder/$File_Name.log"

mkdir -p $Log_Folder

if((UID!=0)); then
    echo -e "$R Need root access to install $W"
    exit 1
fi

Validate(){

    if(($1==0)); then
       echo -e "$G $2 Success $W"
    else
       echo -e "$R $2 Failed $W"
       exit 1
    fi
}

dnf module disable redis -y &>>$Log_File
dnf module enable redis:7 -y &>>$Log_File
dnf install redis -y &>>$Log_File
Validate $? "redis Installation"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$Log_File
systemctl enable redis 
systemctl start redis 
Validate $? "Redis Started"