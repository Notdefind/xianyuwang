---
title: nginx
date: 2019-04-02 14:17:59
tags:
---
## proxyTable配置跨域代理问题
一、 vue-cli3脚手架项目为例（若是vue-cli2X，在项目目录中找到根目录下config文件夹下的index.js文件）
1、由于3.x的默认配置都转移到了CLI service里，所以生成的项目中并没有配置项，我们如果需要自定义一些项目配置，则需要自己在项目的根目录(root)创建一个vue.config.js。并且在这里配置。
2、我们在.env.development文件下设置变量VUE_APP_BASE_API=/api即可将devServer的proxy重写的url赋值给VUE_APP_BASE_API，我们仅需在axios的封装方案上使用VUE_APP_BASE_API这个变量，就可以对应上devServer设置的变量。


```javascript
  //vue.config.js
 
 
module.exports = {
  devServer: {
    proxy: {
      '/apis': {  //这里记得要将后台接口地址改为对应的变量apis
        target: 'http://47.97.173.155:8999', //后台接口地址，你要跨的域
        changeOrigin: true,
        ws: true,
        pathRewrite: {
          '^/apis': '' //ajax的url为/apis/user的请求将会访问http://106.13.58.64:8080/user
        }
      }
    }
  }
}
 
 
 
 
// .env.development
VUE_APP_BASE_API=/apis
```

二、配置完成后，访问前端项目，即可看到跨域成功

附录：
vue-cli是采用的http-proxy-middleware来做的代理配置，一些自定义配置可以移步到官网去进行参考
http-proxy-middleware详情地址：https://github.com/chimurai/http-proxy-middleware#proxycontext-config

### nginx代理解决跨域问题
一、nginx安装

此处省略—

二、找到nginx.conf文件

找到nginx配置文件
1、Mac上打开nginx.conf文件，可通过点击桌面–前往-前往文件夹–输入/usr/local/etc/nginx/nginx.conf

2、通过终端打开nginx.conf文件

```javascript
//进入文件目录
cd /usr/local/etc/nginx/
 
 
//查看nginx下有哪些文档
 ls
 
 
// ok，这里操作配置文件了
vim nginx.conf
```
三、配置nginx.conf的文件

下面是nginx.conf文件里的serve部分（我们只需要配置这些）

```javascript
server {
    # 配置服务地址
 
    listen       3000;
    server_name  localhost;
    
    # 访问根路径，返回前端静态资源页面
 
    location / {
        # 前端代码服务地址
 
        proxy_pass http://localhost:8000/;  #前端项目开发模式下，开启的服务器地址
        proxy_redirect default;
 
    }
    
    # 需要更改rewrite 请求路径的配置
 
    location /apis/ {   #在项目的环境配置中，需要将请求后端接口地址由http://www.serverA.com改为apis
        rewrite ^/apis/(.*)$ /$1 break;  #所有对后端的请求加一个apis前缀方便区分，真正访问的时候移除这个前缀
        # API Server
        proxy_pass http://www.serverA.com;  #将真正的请求代理到serverA,即真实的服务器地址，ajax的url为/apis/user/1的请求将会访问http://www.serverA.com/user/1
    }
 
 
    # redirect server error pages to the static page /50x.html
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   html;
    }
}
```

四、执行几个nginx命令（终端执行）

1、启动nginx服务

```javascript
sudo brew services start nginx
 
 
//若提示文件找不到，可以先执行以下命令
nginx -c /usr/local/etc/nginx/nginx.conf
```

2、修改 nginx.conf 后，重载配置文件

```javascript

sudo nginx -s reload

```

3、停止 nginx
```javascript
//终端输入ps -ef|grep nginx获取到nginx的进程号, 注意：是找到“nginx:master”的那个进程号。
 
kill -QUIT 15800   //正常停止，即不会立刻停止
Kill -TERM 15800  // 快速停止
Kill -INT 15800   // 快速停止

```

4、停止 nginx 服务器

```javascript

sudo nginx -s stop

```

5、查看nginx是否启动成功
Nginx 根据配置端口，比如3000端口，访问localhost:3000，若出现欢迎界面，说明成功安装和启动

五、前端项目启动之后（loaclhost:8081），访问loaclhost：3000，即可看到前端项目跨域成功

注意：
1、nginx服务：loaclhost：3000； 前端项目服务：loaclhost:8081 ；后台接口服务：http://www.serverA.com
2、启动nginx，前端项目启动之后（loaclhost:8081），访问loaclhost：3000，即可看到前端项目跨域成功
3、在项目的环境配置中，需要将请求后端接口地址由http://www.serverA.com改为apis，如下
VUE_APP_BASE_API=/apis //.env.development

