# USER directive example
ARG TAG=latest
FROM ubuntu:$TAG
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install apache2 -y
WORKDIR /var/www/html/
USER www-data
CMD ["whoami"]