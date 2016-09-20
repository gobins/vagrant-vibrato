# vagrant vm with elasticsearch in a docker container

## Description
1. Runs bootstrap script to update base image
2. Runs puppet
   - Install docker
   - Runs Elasticsearch container
   - Downloads and loads NSW ICT data into ES using a python script
   - Starts a python SimpleHTTPServer on port 80 and serves app directory
3. Exposes elasticsearch ports


## How to run
1. vagrant up
2. Open browser with address http://192.168.0.42 
