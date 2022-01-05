https://tomgregory.com/using-jenkins-configuration-as-code-to-setup-aws-slave-agents-automatically/

## Jenkins master with automatic cloud configuration setup 
1. To setup Jenkins with the configuration needed to run slaves in ECS, we need to create our own Docker image for Jenkins

2. Using Docker, we'll be able to
   1. Install all the plugins we need 
   2. Include the required Jenkins configuration files 

3. Let us create `Dockerfile` with the following content 
```shell
FROM jenkins/jenkins:2.327-jdk11

COPY jenkins-resources/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY jenkins-resources/initialConfig.groovy /usr/share/jenkins/ref/init.groovy.d/initialConfigs.groovy
COPY jenkins-resources/jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml
COPY jenkins-resources/slaveTestJob.yaml /usr/share/jenkins/ref/jobs/slave-test/config.yaml

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

```
4. We are copying a file `plugins.txt` into the image, and running a script which installs the plugins 
   1. The file includes only this minimum set of plugins we require
      1. amazon-ecs:1.37 - allow Jenkins to run jobs on slave agents in AWS ECS 
      2. configuration-as-code:1.43 - applies Jenkins configuration from a template file 
      3. workflow-aggregator:2.6 - allows the creation of pipeline jobs
   2. Content of the `jenkins-resources/plugins.txt` file as shown below
      ```text
      amazon-ecs:1.37
      configuration-as-code:1.47
      workflow-aggregator:2.6
      ```
   3. Content of the `jenkins-resources/jenkins.yaml` file is as shown below
   4. Content of the `jenkins-resources/initialConfig.groovy` file is as shown below
   5. Content of the `jenkins-resources/slaveTestJob.xml` file is as shown below
   6. 