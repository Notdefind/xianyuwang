---
title: 聊聊es6
date: 2017-12-10 00:08:27
tags: 前端
---

遵循2/8法则, 80%常用es6方法只占es6中新特性的20%;

## let const
和es5 var 区别在于
```javascript
for (var i = 0; i< 5; i++) {
  console.log(i) // 1 2 3 4 5
}
console.log(i) // 5
```
let 只在块级作用域中有效 而 var 会污染全局变量
```javascript
for (let i = 0; i< 5; i++) {
  console.log(i) // 1 2 3 4 5
}
console.log(i) // i is not defined
```
let const 一个是可修改变量 一个为常量定义后不可修改
```javascript
let sex = 'male'
sex = 'female'
console.log(female) // b
```

```javascript
const sex = 'male'
sex = 'female' // Assignment to constant variable.
```

```javascript
const a = {sex: 'male'}
a.sex = 'female'
console.log(a) // {sex: 'female'}
//定义对象时 对象中的键是可修改的
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
() => {}

```
