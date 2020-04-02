---
title: node服务部署
date: 2020-02-02 15:13:20
tags:
---
## node服务部署流程


### 阿里云购买服务器 安全组设置端口号（根据项目端口设置）
![](https://static.notdefind.com/blog_assets/images/image2019-11-11_13-43-9.png)


### 根据安装镜像手册添加虚拟主机 
https://oneinstack.com/docs/lnmpstack-image-guide/

### 域名解析 指向服务器ip
![](https://static.notdefind.com/blog_assets/images/1585812221177.jpg)

### 进入/usr/local/nginx/conf/vhost 修改nginx配置 并且重启nginx
systemctl restart nginx.service
```javascript
server {
        listen 80;
        server_name server.notdefind.com;
        index index.html index.htm index.php default.html default.htm default.php;
        location / {
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_set_header X-NginX-Proxy true;
                proxy_pass http://127.0.0.1:8888/; // 步骤1设置的端口号
                proxy_redirect off;
        }
}

// 配置https 
server {
        listen 443;
        server_name server.notdefind.com;
        index index.html index.htm index.php default.html default.htm default.php;
        location / {
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_set_header X-NginX-Proxy true;
                proxy_pass http://127.0.0.1:8888/;
                proxy_redirect off;
        }
        ssl on;
        ssl_certificate   /etc/nginx/ssl/server.notdefind.com/3362903_server.notdefind.com.pem; // 配置证书
        ssl_certificate_key  /etc/nginx/ssl/server.notdefind.com/3362903_server.notdefind.com.key; // 配置证书
        ssl_session_timeout 5m;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;

    }
```


### 进入服务器node项目目录 node app.js
netstat -tpln 查看进程
![](https://static.notdefind.com/blog_assets/images/1585813025360.jpg)

### 访问 server.notdefind.com




