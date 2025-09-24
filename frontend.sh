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

dnf module disable nginx -y &>>$Log_File
dnf module enable nginx:1.24 -y &>>$Log_File
dnf install nginx -y &>>$Log_File
Validate $? "Nginx Installation"
systemctl enable nginx 
systemctl start nginx 
rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
cp $Script_Direc\nginx.conf /etc/nginx/nginx.conf
systemctl restart nginx 