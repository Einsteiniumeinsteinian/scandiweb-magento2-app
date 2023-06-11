apt update
apt-get install -y openjdk-11-jdk

# Download and install Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
apt update
apt install -y elasticsearch=7.10.0
systemctl enable elasticsearch.service
systemctl start elasticsearch.service
curl 127.0.0.1:9200
service elasticsearch status