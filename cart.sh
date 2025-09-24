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

dnf module disable nodejs -y &>>$Log_File
dnf module enable nodejs:20 -y &>>$Log_File
dnf install nodejs -y &>>$Log_File
Validate $? "Nodejs Installation"
id roboshop
if [ $? -ne 0 ]; then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
   echo -e "$Y User already Exist $W"
fi
mkdir -p /app 
curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
cd /app 
rm -rf /app/*
unzip /tmp/cart.zip
npm install &>>$Log_File
cp $Script_Direc/cart.service /etc/systemd/system/cart.service
systemctl daemon-reload
systemctl enable cart 
systemctl restart cart
systemctl status cart