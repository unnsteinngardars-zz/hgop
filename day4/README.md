# How it was implemented

## docker-compose.yaml
We added a db service in the docker-compose.yaml file
There we referenced the image to be postgres and added the DB, USER and PASSWORD variables

## Dockerfile
We added a COPY command for database.js

## database.js
Callback functions exported for querying database

## app.js
database object created from database.js file
database object use callback functions within get and post calls

## .env
environment variable set as image tag which is then used within the application

## running instance
This is the same instance as in day3
http://ec2-18-216-73-43.us-east-2.compute.amazonaws.com/
