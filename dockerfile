# base image, ideally to pick up from own docker repository to avoid rate limiting
FROM node:20.18.0-alpine3.20

# create app directory & make it current
WORKDIR /usr/src/app

# ensure both package.json AND package-lock.json are copied
COPY src/package*.json ./

RUN npm ci --only=production

COPY src .

# Use a non-root user with an explicit linux UID (not to run from the root) and add permission to access the /usr/src/app folder 
RUN adduser -u 55555 -D appuser && chown -R appuser /usr/src/app

# Change to non-root privilege
USER appuser

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run your app using CMD which defines your runtime
CMD [ "node", "index.js" ]