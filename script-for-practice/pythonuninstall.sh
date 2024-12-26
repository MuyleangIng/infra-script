#!/bin/bash

# Remove the deadsnakes PPA entry
sudo add-apt-repository -r ppa:deadsnakes/ppa

# Update the package list after removing the repository entry
sudo apt-get update

# Remove software-properties-common, python3-pip, and ansible
sudo apt-get remove -y software-properties-common python3-pip ansible

# Optionally, autoremove to remove any dependencies that are no longer needed
sudo apt-get autoremove -y
