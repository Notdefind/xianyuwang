---
title: node项目搭建
date: 2020-04-02 15:48:30
tags:
---

### 目录结构

```javascript
  ├── config  // 数据库连接配置                             
  ├── controllers  // 数据控制模块  
  ├── public  // 视图层
  ├── routes // 路由可配置视图路由 api接口路由
  ├── services  // 全局公共服务
  ├── utils // 工具类函数
  ├── app.js // 入口文件
```


### 入口文件
```javascript
import express from 'express';
import bodyParser from 'body-parser'
import history from 'connect-history-api-fallback';
import config from './config/mysqlConfig';
import routes from './routes'
const app = express();


routes(app);
// 获取不同环境变量 
app.get('env') === 'production'

app.use(history());
app.use(express.static('public'));
app.use(bodyParser.urlencoded({ extended: false }))


app.listen(config.port, function () {
    console.log(`Listening on port ${config.port}...`);
});

```

### 路由文件
设置静态页面
```javascript
import express from 'express'

const router = express.Router()

router.get("/", (req, res) => {
    
  res.sendFile(process.cwd() + '/public/index.html');
});


export default router;
```

设置接口地址
```javascript
import express from 'express'

import userServer from '../../controllers/star';

const router = express.Router()
const { info, list } = userServer;

router.get("/info", info);
router.get("/list", list);

export default router;

```

### 数据模块
数据查询用的knex 这样可以省去写sql
```javascript
import restful from '../services/restful'
const { mysql } = require('../config/mysql');

class starServer {
  constructor () {
    this.info = this.info.bind(this);
  }

  // 获取明星信息
  async info(req, res) {
    const { id } = req.query;

    let data;
    if (!id) {
      data = restful.err("缺少参数", data, '400');
      res.json(data);
      return;
    }

    data = await mysql("star_heart").where({
      id
    }).select()
    data = data[0] || {};
    data = restful.success("成功", data);
    res.json(data);
	}

	// 获取明星列表
  async list(req, res) {
    const { page, pageSize } = req.query; 
    let data = {};
    
    if (!page || !pageSize 
      || page <= 0) {
      data = restful.err("参数错误", data, '400');
      res.json(data);
      return;
    }

    let count = await mysql("star_heart")
    .count('id', {as: 'count'});
    let list  = await mysql("star_heart").select()
    .limit(pageSize).offset((page - 1) * pageSize);
    count = count[0].count
    data.list = list;
    data.pageInfo = {
      count,
      pageSize,
      toalPage: Math.ceil(count / pageSize)
    };
		data = restful.success("成功", data);

        res.json(data);
	}
}

export default new starServer();
```

### config 配置数据库地址
npm mysql库进行连接数据库

```javascript
const CONF = {
    //开启服务的端口
    port: '8888',
    /**
     * MySQL 配置
     */
    mysql: {
        host: '服务器地址',
        port: 3306,
        user: 'root',
        db: '数据库名称',
        pass: '*******',
        char: 'utf8mb4'
    }
}

module.exports = CONF


// 获取基础配置
const configs = require('./mysqlConfig')

var knex = require('knex')({
    client: 'mysql',
    connection: {
        host: configs.mysql.host,
        port: configs.mysql.port,
        user: configs.mysql.user,
        password: configs.mysql.pass,
        database: configs.mysql.db
    }
});
// 初始化 SDK
// 将基础配置和 sdk.config 合并传入 SDK 并导出初始化完成的 SDK
module.exports = { mysql: knex }
```


