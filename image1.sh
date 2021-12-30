#!/bin/sh

# Set proxy in YUM
echo "proxy=http://proxy-endpoint.vpclocal:8000" >> /etc/yum.conf

# Set proxy in Env
export http_proxy=http://proxy-endpoint.vpclocal:8000
export https_proxy=http://proxy-endpoint.vpclocal:8000
export no_proxy=169.254, localhost, *.amazon.com, bitbucket.bip.uk.fid-intl.com

# Install GIT
yum install -y git

# Install Java
yum install -y java

echo '-----------------------------------------------------------'
echo 'jq'
echo '-----------------------------------------------------------'
yum install -y jq
echo '-----------------------------------------------------------'
yum install -y unzip
echo '-----------------------------------------------------------'
echo 'python-pip'
echo '-----------------------------------------------------------'
yum install -y python-pip
pip install --upgrade pip
echo '-----------------------------------------------------------'
echo 'aws cli'
echo '-----------------------------------------------------------'
pip install awscli
echo '-----------------------------------------------------------'
echo 'Download and install awscli'
echo '-----------------------------------------------------------'
curl -o amazon-ssm-agent.rpm https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
yum install -y amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo '-----------------------------------------------------------'

# Adding nexus certificate to docker

echo '-----------------------------------------------------------'
echo '**************************Setting up Nexus Connection *******************'
echo '-----------------------------------------------------------'

sudo mkdir -p /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000
sudo curl -o /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000/ca.crt https://bitbucket.bip.uk.fid-intl.com/projects/SPSAWS/repos/containerpilot/raw/ecs-worker/ca.crt?at=refs%22Fmaster --insecure -s

sudo ls -ltr /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000/

cat <<EOF | sudo tee -a /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000/openssl.cnf
[ req ]
prompt = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C = GB
ST = Test State
L = Test Locality
O = Org Name
OU = Org Unit Name
CN = Common Name
emailAddress = test@gmail.com

EOF

sudo openssl genrsa -out /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000/client.key 4096
sudo openssl req -new -x509 -text -key /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000/client.key -out /etc/docker/certs.d/nexus-nprod.bip-np.uk.com:5000/client.cert -config /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000/openssl.cnf

sudo ls -ltr /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000/

sudo cp -r /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000 /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5002
sudo cp -r /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000 /etc/docker/certs.d/ftl.uk.fid-intl.com:5002
sudo cp -r /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000 /etc/docker/certs.d/ftl.uk.fid-intl.com:5000

sudo cp -r /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000 /etc/docker/certs.d/nexus-prod.bip.uk.fid-intl.com:5002
sudo cp -r /etc/docker/certs.d/nexus-nprod.bip-np.uk.fid-intl.com:5000 /etc/docker/certs.d/nexus-prod.bip.uk.fid-intl.com:5000

echo '---------------------------------------------------------------------------------'
echo '*********************Registering Docker******************************************'
echo '---------------------------------------------------------------------------------'
sudo systemctl daemon-reload;
sudo systemctl enable docker
sudo systemctl restart docker;

if [ ! -f /var/lib/cloud/instance/sem/config_ssm_http_proxy ]; then
   mkdir -p /etc/systemd/system/amazon-ssm-agent.service.d

cat <<EOF > /etc/systemd/system/amazon-ssm-agent.service.d/override.conf
[Service]
Environment="http_proxy=http://$ProxyHost:$ProxyPort"
Environment="https_proxy=http://$ProxyHost:$ProxyPort"
Environment="no_proxy=169.254,localhost,*.amazon.com,bitbucket.bip.uk.fid-intl.com,nexus-prod.bip.uk.fid-intl.com"
EOF
  systemctl daemon-reload
  systemctl restart amazon-ssm-agent

  echo "$$: $(date +%s.%N | cut -b1-13)" > /var/lib/cloud/instance/sem/config_ssm_http_proxy
fi

sudo echo | openssl s_client -servername jenkins-prod.uk.fid-intl.com -connect jenkins-prod.uk.fid-intl.com:8443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /home/ec2-user/certificate.crt
keytoolpath=$(find /usr/lib/jvm/ -name keytool|head -1)
echo $keytoolpath
sudo $keytoolpath -import -keystore keytool -import -keystore /etc/pki/ca-trust/extracted/java/cacerts -alias jenkins_prod -file /home/ec2-user/certificate.crt -storepaas changeit -noprompt
sudo curl -o /home/ec2-user/agent.jar https://jenkins-prod.uk.fid-intl.com:8443/jnlpjars/agent.jar --insecure
sudo chmod 755 /home/ec2-user/agent.jar
sudo ls -latr /home/ec2-user

sudo sh -c "echo sudo -u ec2-user 'nohup java -jar /home/ec2-user/agent.jar -jnlpUrl https://jenkins-prod.uk.fid-intl.com:8443/computer/${JenkinsSlaveNodeName}/slave-agent.jnlp -secret ${JenkinsSlaveSecret} -noCertificateCheck -workDir /home/ec2-user &' >> /etc/rc.d/rc.local"



