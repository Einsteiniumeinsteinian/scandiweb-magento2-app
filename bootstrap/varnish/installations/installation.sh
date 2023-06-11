apt update
apt install varnish
echo "backing up default varnish file"
mkdir /tmp/varnishbkp && cp /etc/varnish/default.vcl /tmp/varnishbkp
cp /tmp/varnish/config/default.vcl /etc/varnish/default.vcl
systemctl start varnish
systemctl enable varnish
