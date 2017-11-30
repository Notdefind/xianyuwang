---
title: 浅谈react
tags: 前端
---

`
耍react已有半年之余,时常能在某乎看到react与angular Vue的对比贴。
在此说下作为底层码农我的感受吧,以前一直耍的Vue,非常喜欢里面的数据绑定 v-if v-for ...
视图层 控制层 数据层 分离的非常清楚。

刚上手react时感觉JSX写法非常蛋疼,JS HTML揉在一起, 各种return () ,没有Vue那样简洁明了。

写了一段时间后, 从数据请求 页面渲染, 公共UI组件, redux数据共享, 提取共同函数方法,不经感叹react的优雅,
一个fetch操作必须拆分成action、reducer、connect。

阮一峰在博客中提到过,在小项目中是不推荐使用redux,这样只会使简单的项目更复杂,开发效率慢,
而在相对复杂的项目中redux确实解决了很多问题。

``
1: 在react native中二级页面返回至一级页面,需要修改一级页面的数据。
不使用redux的情况下,一般会考虑回调,在二级页面返回时调用一级页面中传入的回调,以此来修改一级页面。
(在APP中返回一级页面,并不会重新执行一级页面的react生命周期方法, componentWillMount 中的数据请求方法也不会执行, 而网页端返回是会重新执行一遍。 此处有待研究)
``

``
2: 当多个页面有相同重复功能时,可将使用的数据提取成公共state 将action reducer 以及 function 提取出。 提高可读性, 可维护性。
``

``
3: 可用于页面之间传参,react native中可以通过 navigation.state.params, H5中可以通过 url localStorage 等方式传参。
通过redux传参好处在于更加简洁 明了,web端相对来说更加安全,不会被修改。
(之前公司项目是由外包做的,订单相关通过localStorage方式传参,订单金额后端又木有做验证。结果我在localStorage中修改订单总价为0.01元后竟然可以成功支付  逃)
当页面刷新后参数将会消失,由于redux存储的数据不是本地储存，而是存在内存中 所以当页面刷新,redux中的参数数据将不存在。
``
`

![](/images/react_stage.png)
