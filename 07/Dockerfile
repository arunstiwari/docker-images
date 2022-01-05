# ONBUILD example
# Start with Ubuntu base image
FROM ubuntu:18.04

# Set labels
LABEL maintainer=arunstiwari
LABEL version=1.0

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache, PHP, and other packages
RUN apt-get update && \
    apt-get -y install apache2 \
    php \
    curl

# Copy all php files to the Docker image
ONBUILD COPY *.html /var/www/html
EXPOSE 80

# Start Apache
ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]