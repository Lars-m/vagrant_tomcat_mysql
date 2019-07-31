#!/usr/bin/env bash

echo "############ Installing nginx  ############"
sudo apt-get install -y nginx

#allow for updates of large WAR-files
str='client_max_body_size 50M;'
#Remove line first if script has already been executed once
sudo sed -i "/$str/d" /etc/nginx/nginx.conf

sudo sed -i "/http {/ a\       $str" /etc/nginx/nginx.conf;


sudo rm /etc/nginx/sites-enabled/default

sudo cat <<- EOF_NGINX > /etc/nginx/sites-enabled/default
upstream tomcat {
    server 127.0.0.1:8080 fail_timeout=0;
}

server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /var/www/html;
        index index.html index.htm

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                #try_files $uri $uri/ =404;
                #The line above is commented out to let Tomcat handle 404 scenarios. Put it back if you don't use Tomcat

                include proxy_params;
                proxy_pass http://tomcat/;
        }

}
EOF_NGINX

sudo systemctl restart nginx

echo "Provisioning Complete"
