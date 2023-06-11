apt update
apt install varnish
echo "backing up default varnish file
mkdir ~/varnish && cp /etc/varnish/default.vcl ~/varnish 
cp /tmp/varnish/default.vcl /etc/varnish/default.vcl
systemctl start varnish
systemctl enable varnish
