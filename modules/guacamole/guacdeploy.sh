#!/bin/bash -xe

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
cat /etc/os-release | grep PRETTY_NAME
echo "Hello from user-data!"
#snap install docker
# Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl zip postgresql postgresql-client -y
apt install apt-transport-https curl software-properties-common -y
#apt install -m 0755 -d /etc/apt/keyrings -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
chmod a+r /etc/apt/keyrings/docker.asc
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
mkdir ./guacamole-docker-compose
#aws s3 sync ./guacamole-docker-compose ${s3_bucket_uri}
aws s3 cp ${s3_bucket_uri} ./guacamole-docker-compose/ --recursive
#git clone "https://github.com/boschkundendienst/guacamole-docker-compose.git"
cd guacamole-docker-compose
echo "Preparing folder init and creating ./init/initdb.sql"
mkdir ./init >/dev/null 2>&1
python3 guacamole_hash.py ${guac_admin_pass} --sql ${guac_admin_username} >>./init/initdb.sql
chmod -R +x ./init
chmod +x ./prepare.sh
./prepare.sh
aws s3 cp ./init/initdb.sql ${s3_bucket_uri}
export PGPASSWORD="${psql_password}"
export PGHOSTNAME="${psql_hostname}"
export PGUSERNAME="${psql_username}"
export PGDBNAME="${psql_dbname}"
if [ ${use_rds} = 'true' ]; then
  psql -h ${psql_hostname} -p 5432 -U ${psql_username} -d ${psql_dbname} -f ./init/initdb.sql
fi
docker compose up -d
echo "done"