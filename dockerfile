FROM node:20-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY src/package.json ./

RUN npm install

COPY src .

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run your app using CMD which defines your runtime
CMD [ "node", "index.js" ]