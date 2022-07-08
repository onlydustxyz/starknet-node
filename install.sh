#!/bin/bash
##########################################################################
# Société : OnlyDust
# Author : Samuel Kerchouni
# Date : 04/06/2022
# Version : 1.O
# Description : Install starknet node as a service
##########################################################################

# Ask endpoint interactive part
read -p 'Past Endpoint Generated on Infura or Alchemy: ' endpoint

# Update package
sudo apt update && sudo apt upgrade -y

# install lib
sudo apt install -y pkg-config curl git build-essential libssl-dev

# Install python pip
sudo apt install -y python3-pip

# Install other tools with pip
sudo apt install -y build-essential libssl-dev libffi-dev python3-dev

# Install libgmp-dev
sudo apt-get install -y libgmp-dev

# install fastecdsa
pip3 install fastecdsa

# install pkg config
sudo apt-get install -y pkg-config

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# virtal env 
source $HOME/.cargo/env

# Check rust version
rustc --version
# Force Update
rustup update stable --force

# git clone pathfinder https://github.com/eqlabs/pathfinder/releases # check release actually v0.2.4-alpha
git clone --branch v0.2.4-alpha https://github.com/eqlabs/pathfinder.git

# create venv
sudo apt install -y python3.8-venv

# chmod
echo "set right"
sudo chown -R $(whoami) /home/ubuntu/

# create folder
cd /home/ubuntu/starknet-node/pathfinder/py

# create venv
python3 -m venv .venv

# active venv
source .venv/bin/activate

# tools upgrade & install requirements
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt

# Build with cargo
cargo build --release --bin pathfinder

cd /home/ubuntu/starknet-node

echo "
[Unit]
Description=<node starknet services>

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/starknet-node
ExecStart=/bin/bash -c 'source /home/ubuntu/starknet-node/pathfinder/py/.venv/bin/activate && /home/ubuntu/starknet-node/pathfinder/target/release/pathfinder --http-rpc 0.0.0.0:9545 --ethereum.url $endpoint'

[Install]
WantedBy=multi-user.target" >> starknet.service

# move Service
sudo mv starknet.service /etc/systemd/system/starknet.service

# Reload the service files to include the new service.
sudo systemctl daemon-reload

# Start your service
sudo systemctl start starknet.service

# enable your service on every reboot
sudo systemctl enable starknet.service