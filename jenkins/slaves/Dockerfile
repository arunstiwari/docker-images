FROM alpine:latest
ARG no_proxy=169.254,bitbucket.bip.uk.fid-intl.com
RUN apk update all
RUN apk add py-pip openjdk11-jdk jq git zip unzip curl maven coreutils openssl
RUN pip install boto3
RUN pip install awscli
RUN pip install --upgrade setuptools
RUN pip install cfn-lint
RUN apk add --no-cache bash && apk add --update sed
RUN mkdir /.aws
RUN chmod -R 777 /.aws
RUN git config --global http.sslVerify false
ENTRYPOINT ["/bin/sh"]