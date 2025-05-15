#!/bin/bash

# Set the hostname
sudo hostnamectl set-hostname linux-controller

# Update package list
sudo apt update -y

# Install dependencies
sudo apt install -y software-properties-common

# Add Ansible PPA and install Ansible
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Verify installation
ansible --version
