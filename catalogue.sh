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

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y &>>$Log_File
Validate $? "Nodejs Installation"
id roboshop
if [ $? -ne 0 ]; then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
   echo -e "$Y User already Exist $W"
fi
mkdir -p /app 
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
cd /app 
rm -rf /app/*
unzip /tmp/catalogue.zip
npm install &>>$Log_File
cp $Script_Direc/catalogue.service /etc/systemd/system/catalogue.service
systemctl daemon-reload
systemctl enable catalogue 

dnf list installed mongodb-org &>>$Log_File
     if(($?!=0)); then
         cp $Script_Direc/mongodb.repo /etc/yum.repos.d/mongo.repo &>>$Log_File
         Validate $? "Adding Mongo repo"
         dnf install mongodb-mongosh -y &>>$Log_File
         Validate $? "Installing Mongodb"
     else
         echo -e "$Y Mongodb already installed $W" 
     fi

mongosh --host mongodb.gangu.fun </app/db/master-data.js
