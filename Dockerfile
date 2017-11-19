# Dockerfile to build tapiriik

# Begin Ubuntu
FROM ubuntu:16.04

# File maintainer
MAINTAINER tlmason@gmail.com

# Update ubuntu
RUN apt-get update
RUN apt-get upgrade

# Add app resources URL
RUN apt-get install lsb-release -y
RUN echo "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc) main universe" >> /etc/apt/sources.list
RUN apt-get update

# install basic applications
RUN apt-get install -y tar git curl nano wget dialog net-tools build-essential

# install python and basic python tools
RUN apt-get install -y python3
RUN apt-get install -y python3-dev
RUN apt-get install -y git
RUN apt-get install -y mongodb
RUN apt-get install -y redis-server
RUN apt-get install -y rabbitmq-server
RUN apt-get install -y libxslt-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y python3-lxml
RUN apt-get install -y python3-crypto
RUN apt-get install -y python3-pip

# Clone tapiriik from github
RUN git clone https://github.com/cpfair/tapiriik.git

# upgrade pip
RUN pip3 install --upgrade pip

# Get pip to install reqs
RUN pip3 install -r /tapiriik/requirements.txt
RUN mkdir /tapiriik/logs

# setup tapiriik
RUN cp /tapiriik/tapiriik/local_settings.py.example /tapiriik/tapiriik/local_settings.py
RUN python3 /tapiriik/credentialstore_keygen.py >> /tapiriik/tapiriik/local_settings.py

# expose ports
EXPOSE 80

# set the default working directory
WORKDIR /tapiriik

# start mongod
RUN mongod --fork --logpath /tapiriik/logs/mongod.log --logappend&

# start redis-server
RUN redis-server --daemonize yes&

# start rabbitmq
RUN rabbitmq-server -detached&

# start tapiriik
RUN python3 /tapiriik/manage.py runserver&
RUN python3 /tapiriik/sync_worker.py&
RUN python3 /tapiriik/sync_scheduler.py&
