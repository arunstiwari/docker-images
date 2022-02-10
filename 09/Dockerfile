FROM alpine:3.11
ARG user=root
ARG AGENT_WORKDIR=/home/${user}/agent
ENV LANG="en_GB.UTF-8"
ENV LANGUAGE="en_GB.UTF-8"
ENV LC_ALL=
ENV LC_CTYPE="en_GB.UTF-8"
ENV LC_COLLATE="en_GB.UTF-8"
ENV LC_MESSAGES="en_GB.UTF-8"
ENV LC_MONETARY="en_GB.UTF-8"
ENV LC_NUMERIC="en_GB.UTF-8"
ENV LC_TIME="en_GB.UTF-8"
ARG VERSION=4.11.2
ENV MUSL_LOCALE_DEPS cmake make musl-dev gcc gettext-dev libintl 
ENV MUSL_LOCPATH /usr/share/i18n/locales/musl

RUN apk add --no-cache \
    $MUSL_LOCALE_DEPS \
    && wget https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip \
    && unzip musl-locales-master.zip \
      && cd musl-locales-master \
      && cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install \
      && cd .. && rm -r musl-locales-master

RUN apk add --update --no-cache curl bash git git-lfs  openjdk8-jre-base openssh-client openssl procps

WORKDIR /home/${user}
COPY agent.jar /home/${user}/

ENV secret=""
ENV jnlpUrl=""
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN   mkdir -p ${AGENT_WORKDIR}
ENV JAVA_HOME "/usr/lib/jvm/java-1.8-openjdk/"
VOLUME ${AGENT_WORKDIR}

#CMD [ "java","-jar","agent.jar","-jnlpUrl",${jnlpUrl},"-workDir",${AGENT_WORKDIR},"-secret",${secret} ]
CMD ${JAVA_HOME}/bin/java -jar agent.jar -jnlpUrl ${jnlpUrl} -workDir ${AGENT_WORKDIR} -secret ${secret}
