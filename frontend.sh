#!/bin/bash

R="\e[31m"
G="\e[32m"
W="\e[0m"
Y="\e[33m"
Script_Direc=$PWD
Log_Folder="/var/log/roboshop"
File_Name=$(basename $0 .sh)
Log_File="$Log_Folder/$File_Name.log"

mkdir -p $Log_Folder

if (( UID != 0 )); then
    echo -e "$R Need root access to install $W"
    exit 1
fi

Validate() {
    if (( $1 == 0 )); then
        echo -e "$G $2 Success $W"
    else
        echo -e "$R $2 Failed $W"
        exit 1
    fi
}

# Install Nginx
dnf module disable nginx -y &>>$Log_File
dnf module enable nginx:1.24 -y &>>$Log_File
dnf install nginx -y &>>$Log_File
Validate $? "Nginx Installation"

systemctl enable --now nginx &>>$Log_File
Validate $? "Nginx Service Start"

# Deploy frontend
rm -rf /usr/share/nginx/html/* &>>$Log_File
curl -s -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$Log_File
Validate $? "Download Frontend"

# Unzip and move files to correct location
unzip -q /tmp/frontend.zip -d /usr/share/nginx/html &>>$Log_File
# Check if files are inside a subfolder
if [ -d /usr/share/nginx/html/frontend ]; then
    mv /usr/share/nginx/html/frontend/* /usr/share/nginx/html/
    rmdir /usr/share/nginx/html/frontend
fi
Validate $? "Extract Frontend Content"

# Copy nginx config
cp "$Script_Direc/nginx.conf" /etc/nginx/nginx.conf &>>$Log_File
Validate $? "Copy Nginx Config"

# Restart nginx to apply config
systemctl restart nginx &>>$Log_File
Validate $? "Restart Nginx"
