# Start with alpine base image
FROM basic-base

# Set labels
LABEL maintainer=arunstiwari
LABEL version=1.0

CMD mkdir -p /var/www/html/

WORKDIR /var/www/html/

ADD  Dockerfile.tar.gz /var/www/html/

RUN cat Dockerfile
