#!/bin/bash

R="\e[31m"
G="\e[32m"
W="\e[0m"
Y="\e[33m"

Log_Folder="/var/log/shell-prac"
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

cp mongodb.repo /etc/yum.repos.d/mongo.repo
Validate $? "Adding Mongo repo"
dnf install mongodb-org -y 
Validate $? "Installing Mongodb"
systemctl enable mongod 
Validate $? "Enable Mongodb"
systemctl start mongod 
Validate $? "Start Mongodb"