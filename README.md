# pleroma-docker
Docker config for Pleroma OTP releases

## Requirements:
* docker
* docker-compose
* openssl

## Setup:
```
./pleroma.sh setup
```
You'll be prompted to answer the Pleroma config questions as part of setup.
Two questions are particularly important to answer correctly.

> What is the hostname of your database?

Make sure to answer "db" instead of the default "localhost":

> What ip will the app listen to (leave it if you are using the default setup with nginx)?

Make sure to answer "0.0.0.0" instead of the default "127.0.0.1":

Setup will generate a self-signed certificate for nginx to use.

If you want to change the certificate, hostname, or ports, you will need to edit:
* `volumes/config/nginx/pleroma.conf` (after setup generates the initial config)

If you want to change ports or your host's listen addresses, you will also need to edit:
* `docker-compose.yml`

## Starting the server
```
./pleroma.sh start
```
Browse to https://localhost

## Stopping the server
```
./pleroma.sh stop
```

## Cleaning up
```
# Remove containers and images
sudo docker-compose down --rmi all

# Delete DB and all config
# Make sure you don't want your data!
# Make sure you're in the correct directory!
# sudo rm -r volumes/
```
