---
title: 聊聊es6
date: 2017-12-10 00:08:27
tags: 前端
---

遵循2/8法则, 80%常用es6方法只占es6中新特性的20%; 下面说说个人比较常用的一些es6新特性吧。

## 变量定义
和es5 `var` 区别在于
```javascript
for (var i = 0; i< 5; i++) {
  console.log(i) // 1 2 3 4 5
}
console.log(i) // 5
```
`let` 只在块级作用域中有效 而 `var` 会污染全局变量
```javascript
for (let i = 0; i< 5; i++) {
  console.log(i) // 1 2 3 4 5
}
console.log(i) // i is not defined
```
`let const` 一个是可修改变量 一个为常量定义后不可修改
```javascript
let sex = 'male'
sex = 'female'
console.log(sex) // female
```

```javascript
const sex = 'male'
sex = 'female' // Assignment to constant variable.
```

```javascript
const a = {sex: 'male'}
a.sex = 'female'
console.log(a) // {sex: 'female'}
//定义对象时 对象中的键是可修改的 不可修改变量本身
```

## 字符串模板

```javascript
// es5
var name = 'Your name is ' + first + ' ' + last + '.';

// es6
var name = `Your name is ${first} ${last}. `;
```

## Arrow Functions (箭头函数)
```javascript
// es5
function (x) {
    return x * x;
}

// es6 
x => x * x
```

箭头函数相当于匿名函数，并且简化了函数定义。箭头函数有两种格式，一种像上面的，只包含一个表达式，连`{ ... }`和`return`都省略掉了。还有一种可以包含多条语句，这时候就不能省略`{ ... }`和`return`：

```javascript
x => {
    if (x > 0) {
        return x * x;
    }
    else {
        return - x * x;
    }
}
```

如果参数不是一个，就需要用括号`()` 括起来：

除此之外个人认为箭头函数最大的一个好处在于 完全修复了`this`的指向，`this`总是指向词法作用域，也就是外层调用者`obj`


### 普通函数中的this:
> 1.this总是代表它的直接调用者, 例如 obj.func ,那么func中的this就是obj

> 2.在默认情况(非严格模式下,未使用 'use strict'),没找到直接调用者,则this指的是 window

> 3.在严格模式下,没有直接调用者的函数中的this是 undefined

> 4.使用call,apply,bind(ES5新增)绑定的,this指的是 绑定的对象

### 箭头函数中的this:

> 箭头函数没有自己的this, 它的this是继承而来; 默认指向在定义它时,它所处的对象(宿主对象),而不是执行时的对象。 (一句话总结,箭头函数中的this在哪里调用不重要,重要的是在哪里定义)

## 函数参数

### 默认值 Default

```javascript
// es5 
function a(str) {
  var str = str || 'str'
  console.log(str)
}

a () // str

// es6 
function b(str ='str') {
  console.log(str)
}

b () // str
```

## 赋值解析

```javascript
// es5
var a = 'a'
var obj = {a: a}
console.log(a) // {a: 'a'}

// es6
const a = 'a'
const obj = {a}
console.log(a) // {a: 'a'}

```

## Class 类的继承

> 基本用法
``` javascript 
class Point { 
  constructor(x = 0, y = 0) { 
    this.x = x; 
    this.y = y; 
  } 
  
  toString() { 
    return this.x + ':' + this.y; 
  } 
}
```
[详细介绍](http://es6.ruanyifeng.com/#docs/class-extends)

## Modules 
> 在ES6以前JavaScript并不支持本地的模块。人们想出了AMD，RequireJS，CommonJS以及其它解决方法。现在ES6中可以用模块import 和export 操作了。

``` javascript 
// es5
module.exports = {
  port: 3000,
  getAccounts: function() {
    ...
  }
}

var service = require('module.js');
console.log(service.port); // 3000
// es6

export var port = 3000;
export function getAccounts(url) {
  ...
}

import {port, getAccounts} from 'module';
console.log(port); // 3000

// 或者我们可以在main.js中把整个模块导入, 并命名为 service：

import * as service from 'module';
console.log(service.port); // 3000

```

## 数组扩展

### 查找find()与findIndex()
数组实例的find方法，用于找出第一个符合条件的数组成员。它的参数是一个回调函数，所有数组成员依次执行该回调函数，直到找出第一个返回值为true的成员，然后返回该成员。如果没有符合条件的成员，则返回undefined。
``` javascript
let arr = [10, 20, 30, 40, 50];
console.log(arr.find(function(value, index, arr){
    return value > 25;
}));// 30
console.log(arr.findIndex(function(value, index, arr){
    return value > 25;
}));// 2
```

### 包含includes()

``` javascript
let arr = [1, 'a', true, null, NaN];

console.log(arr.includes(NaN));          //true
console.log(arr.includes(undefined));    //false
```

### 数组合并

```javascript
// ES5
[1, 2].concat(more)
// ES6
[1, 2, ...more]
```