
---
title: redux
date: 2018-12-3 17:22:55
tags: 前端
---

## redux
常用API及使用方法

1 createStore

创建一个 Redux store 来以存放应用中所有的 state。
应用中应有且仅有一个 store。

2 combineReducers
拆分不同的reducer，不同reducer处理不同store中的数据。

3 applyMiddleware
使用包含自定义功能的 middleware 来扩展 Redux。

4 compose 
从右到左把接收到的函数合成后的最终函数。

```javascript
import { createStore, combineReducers, applyMiddleware, compose } from 'redux'
import thunk from 'redux-thunk'
import DevTools from './containers/DevTools'
import reducer from '../reducers/index'

const store = createStore(
  reducer,
  compose(
    // 加入redux中间件
    applyMiddleware(thunk),
    DevTools.instrument()
  )
)
```

5 Action 
定义事件函数

```javascript
import { GET_DATA } from './constants';

export function getData(params) {
  dispatch({
    type: GET_DATA,
    data: { msg: '这是数据' }
  });
}
```

6 Reducer
应用状态的变化响应 actions 并发送到 store,通过Reducer改变store的值。


```javascript
import createReducer from 'store/creatReducer'

import {
  GET_DATA
} from './constants'
// store msg 默认初始数据为''
export const initialState = {
  msg: '',
}
// 通过监听Action 派发的GET_DATA方法改变 store 中msg的数据
const actionHandler = {
  [GET_DATA]: (state, action) => {
    const { msg } = action.data;

    return { msg }
  },
};

export default createReducer(initialState, actionHandler)
```

7 connect
通过connect函数将store action 注入进react组件

```javascript
import { connect } from 'react-redux';
// 导入定义的action事件
import {
  getData
} from '../redux/actions'
import Home from './Home'

const mapStateToProps = (state, ownProps) => {
  return {
    msg: '',
  }
}

const mapDispatchToProps = {
  getData,
}

export default connect(mapStateToProps, mapDispatchToProps)(Home)

```

Home.jsx
```javascript

import React, { Component } from 'react'
export default class Home extends Component {
  constructor (props) {
    super(props)
  }

  componentWillMount () {
    const { getData } = this.props

    getData()
  }
  render () {
    const { msg } = this.props;

    return (
      <div>{msg}</div> // 这是数据
    )
  }
}

```

![](/images/redux/redux.jpeg)
