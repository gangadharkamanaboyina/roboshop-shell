#!/bin/bash

R="\e[31m"
G="\e[32m"
W="\e[0m"
Y="\e[33m"

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

dnf list installed mongodb-org &>>$Log_File
     if(($?!=0)); then
      cp mongodb.repo /etc/yum.repos.d/mongo.repo &>>$Log_File
      Validate $? "Adding Mongo repo"
      dnf install mongodb-org -y &>>$Log_File
      Validate $? "Installing Mongodb"
     else
       echo -e "$Y $package already installed $W" 
     fi


systemctl enable mongod &>>$Log_File
Validate $? "Enable Mongodb" 
systemctl start mongod &>>$Log_File
Validate $? "Start Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$Log_File

systemctl restart mongod &>>$Log_File
Validate $? "Restart Mongodb"