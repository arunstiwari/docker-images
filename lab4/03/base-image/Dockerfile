# Start with alpine base image
FROM alpine

# Set labels
LABEL maintainer=arunstiwari
LABEL version=1.0

RUN apk update && apk add wget curl

RUN wget -O test.txt https://github.com/arunstiwari/aws-iot-chat-app/blob/master/README.md
