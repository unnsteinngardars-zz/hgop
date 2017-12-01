#use carbon as parent image
FROM node:carbon
#set working directory to /code
WORKDIR /code
#copy package.json to /code directory
COPY package.json package.json
#copy app.js to /code directory
COPY app.js app.js
#copy database.js
COPY database.js database.js
#runs npm install to get all dependencies
RUN npm install
#starts the node.js server
CMD node app.js
