## How To Create or Provide Public Snapshot

```bash
sudo apt install lz4
cd $HOME/.planqd
sudo systemctl stop planqd
tar -cf - data | lz4 > /var/www/snapshot/planq/planq-snapshot-$(date +%Y%m%d).tar.lz4
sudo systemctl start planqd
```


## Config Your Web Server

### Create Directory First
```bash
mkdir -p /var/www/snapshot/planq
```

```bash
server {

        # SSL configuration
        #
        # listen 443 ssl default_server;
        # listen [::]:443 ssl default_server;
        #
        # Note: You should disable gzip for SSL traffic.
        # See: https://bugs.debian.org/773332
        #
        # Read up on ssl_ciphers to ensure a secure configuration.
        # See: https://bugs.debian.org/765782
        #
        # Self signed certs generated by the ssl-cert package
        # Don't use them in a production server!
        #
        # include snippets/snakeoil.conf;

        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;
        server_name NAMA_DOMAIN_KAMU; 


        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                # try_files $uri $uri/ =404;
                root /var/www/snapshot/;
                autoindex on;
        }
```
## Restart Your Web Server Servces
```bash
service nginx restart
```