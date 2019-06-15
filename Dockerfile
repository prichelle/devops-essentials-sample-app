FROM node:carbon
WORKDIR /usr/src/app
COPY ./src/hello.js ./
EXPOSE 8080
CMD [ "node", "hello.js" ]
