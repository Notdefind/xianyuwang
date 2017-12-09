---
title: 浅谈react
tags: 前端
---

`
耍react技术盏快一年了,
在此说下作为底层打字员的感受吧,以前一直耍的Vue,非常喜欢里面的数据绑定 v-if v-for ...
简洁优雅。

刚上手react时感觉JSX写法非常蛋疼,JS HTML揉在一起, 各种return (),渲染方法 内部函数,再加上redux。 (其实是有点懵逼的)

一段时间后,从数据请求 页面渲染, 编写公共UI组件, redux数据共享,算是能够熟练掌握了。

阮一峰在博客中提到过,在小项目中是不推荐使用redux,
一个fetch操作须拆分成action、reducer、connect。
这样只会使简单的项目更复杂,开发效率慢,
而在相对复杂的项目中redux确实解决了开发中很多问题。

## react
以下为react生命周期表
![](/images/react_stage.png)
在不同生命周期内可以调用不同的方法,
一个React组件的生命周期分为三个部分：实例化、存在期和销毁时。

首次实例化

- getDefaultProps
- getInitialState
- componentWillMount
- render
- componentDidMount

实例化完成后的更新

* getInitialState
* componentWillMount
* render
* componentDidMount


1.getDefaultProps

作用于组件类，只调用一次，返回对象用于设置默认的props，对于引用值，会在实例中共享。

2.getInitialState

作用于组件的实例，在实例创建时调用一次，用于初始化每个实例的state，此时可以访问this.props。

3.componentWillMount

在完成首次渲染之前调用，此时仍可以修改组件的state。

4.render

必选的方法，创建虚拟DOM，该方法具有特殊的规则：

只能通过this.props和this.state访问数据
可以返回null、false或任何React组件
只能出现一个顶级组件（不能返回数组）
不能改变组件的状态
不能修改DOM的输出

5.componentDidMount

真实的DOM被渲染出来后调用，在该方法中可通过this.getDOMNode()访问到真实的DOM元素。此时已可以使用其他类库来操作这个DOM。

在服务端中，该方法不会被调用。

6.componentWillReceiveProps

组件接收到新的props时调用，并将其作为参数nextProps使用，此时可以更改组件props及state。

7.shouldComponentUpdate

组件是否应当渲染新的props或state，返回false表示跳过后续的生命周期方法，通常不需要使用以避免出现bug。在出现应用的瓶颈时，可通过该方法进行适当的优化。

在首次渲染期间或者调用了forceUpdate方法后，该方法不会被调用

8.componentWillUpdate

接收到新的props或者state后，进行渲染之前调用，此时不允许更新props或state。

9.componentDidUpdate

完成渲染新的props或者state后调用，此时可以访问到新的DOM元素。

10.componentWillUnmount

组件被移除之前被调用，可以用于做一些清理工作，在componentDidMount方法中添加的所有任务都需要在该方法中撤销，比如创建的定时器或添加的事件监听器。(react native 中定时器必须在此方法中清除)

## react router
1.路由跳转
- push router加入盏
- replace  替换router中当前盏
- goBack 替换router中当前盏

2.获取url地址栏参数等

- detail/:id 通过 this.props.location.params 获取参数
- detail?id=1 通过 this.props.location.query 获取参数
- (和express中路由模式相似)

## redux
个人理解redux 其实可以想象为前端本地的一个临时数据库。
它将前端项目中所需要的数据存在于内存之中,
每一个store的数据就是一张表, store中包含各个键值对 对应的就是数据库中的每一个字段。
不同页面也可以共用同一个stroe,因此实现数据共享。

那么是如何更改项目中的stroe呢？

UI -> action -> dispatch -> reducer -> stroe -> UI

用户操作通过 action 派发事件 通知reducer 修改stroe stroe更新后 UI自动会更新

## 实践


1: 在react native中二级页面返回至一级页面,需要修改一级页面的数据。
不使用redux的情况下,一般会使用callback,在二级页面返回时调用一级页面中传入的callback,以此来更新数据。
- 在APP中返回一级页面,并不会重新实例化组件,因此componentWillMount 中的数据请求方法也不会执行, 而网页端返回是会重新实例化。

2: 当多个页面有相同重复功能时,可将使用的数据存放于一个公共stroe。 对应配置对应的action dispatch,提高复用性, 可维护性。

3: 可用于页面之间传值,react native中可以通过 navigation.state.params, H5中可以通过 url localStorage 等方式传值。

公司项目之前是由外包做的,订单相关通过localStorage方式传值,订单金额后端又木有做验证。结果我在localStorage中修改订单总价为0.01元后竟然可以成功支付  逃

使用redux则不会出现此类问题,相对较为安全,带来的困恼则是由于redux数据存在于内存中,
由于单页应用的原因,当页面刷新后内存被释放,所有stroe中数据将被清空。
有些数据依赖于stroe,会导致报错。(react native端木有直接刷新的概念,则不会出现此类问题)

4: 在reducer中更新stroe的问题

在stroe中更新一个对象有些时候会诡异的失效:

```javascript
// 之前的数据是 list: {count: 1}
[ADD_COUNT]:  (state, action) => {
  const list = state.list.count ++
  console.log(state.list) // 2
  return { list }
}

<div>{list}</div> // 1
```
在更新完后stroe中的数据变化了,但是UI并没有改变?
这是因为UI更新并不是对比stroe中的数据修改,而是对比stroe中数据内存地址的修改。
内存地址没变,所以UI并不会更新。

JS中对象和字符数字类型有一个地方不同,就是内存地址问题。

类似于
```javascript
var a = {a: 'a'};
var b = a;
b.a = 'b'
console.log(a) // {a: 'b'}

var str1 = '1';
var str2 = str1;
str2 = '2'
console.log(str1) // 1

```
这属于对象引用,a 和 b 引用的都是内存中的同一个地址,所以 修改b时 a也会被修改。

对象clone 分为深度clone,和浅clone。 浅clone会复制对象的内容和同一个内存地址,深clone 则是复制内容,和重新开辟一个新内存。
(有点扯远了。。。)
在reducer中要可以使用{...Object}来解决。
