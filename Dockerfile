FROM ubuntu:16.04
MAINTAINER Jared Kosanovic, kosanovj@oregonstate.edu

ENV LAST_UPDATE=2017-04-27

#####################################################################################
# Current version is aws-cli/1.10.53 Python/2.7.12
#####################################################################################

RUN apt-get update && \
    apt-get upgrade -y

# Install tzdata and locales
RUN apt-get install tzdata locales

ARG timezone="America/Los_Angeles"

# Set the timezone
RUN echo $timezone | tee /etc/timezone && \
    ln -fs /usr/share/zoneinfo/${timezone} /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Set the locale for UTF-8 support
RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && \
    locale-gen && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# AWS CLI needs the PYTHONIOENCODING environment varialbe to handle UTF-8 correctly:
ENV PYTHONIOENCODING=UTF-8

# man and less are needed to view 'aws <command> help'
# ssh allows us to log in to new instances
# vim is useful to write shell scripts
# python* is needed to install aws cli using pip install

RUN apt-get install -y \
    less \
    man \
    ssh \
    python \
    python-pip \
    python-virtualenv \
    vim

RUN adduser --disabled-login --gecos '' aws
WORKDIR /home/aws

USER aws

RUN \
    mkdir aws && \
    virtualenv aws/env && \
    ./aws/env/bin/pip install awscli && \
    echo 'source $HOME/aws/env/bin/activate' >> .bashrc && \
    echo 'complete -C aws_completer aws' >> .bashrc
