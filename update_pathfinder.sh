#!/bin/bash
##########################################################################
# Société : OnlyDust
# Author : Samuel Kerchouni
# Date : 21/06/2022
# Version : 1.0
# Description : Update pathfinder / starknet node as a service
##########################################################################

# Stop your service
sudo systemctl stop starknet.service

# remove pathfinder folder
rm -rf $HOME/starknet-node/pathfinder

# virtal env 
source $HOME/.cargo/env

# Check rust version / check version
rustc --version
# Force Update
rustup update stable --force

# go to folder
cd $HOME/starknet-node

# git clone pathfinder with last version
git clone https://github.com/eqlabs/pathfinder.git

# create venv
sudo apt install -y python3.8-venv

# chmod
echo "set right"
sudo chown -R $(whoami) $HOME

# create folder
cd $HOME/starknet-node/pathfinder/py

# create venv
python3 -m venv .venv

# active venv
source .venv/bin/activate

# tools upgrade & install requirements
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt

# Build with cargo
cargo build --release --bin pathfinder

# Start your service
sudo systemctl start starknet.service

# Check if update of pathfinder is success
echo "==================================================="
echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service starknet status | grep active` =~ "running" ]]; then
  echo -e "Your StarkNet node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice starknet status\e[0m"
else
  echo -e "Your StarkNet node \e[31mwas not installed correctly\e[39m, please reinstall."
fi