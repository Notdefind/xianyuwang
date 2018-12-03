---
title: redux connect用法
date: 2018-12-3 17:22:55
tags: 前端
---

## connect用法介绍
### connect方法声明：

```javascript
connect([mapStateToProps], [mapDispatchToProps], [mergeProps],[options])
```
### 作用：连接React组件与 Redux store。

## 参数说明：


```javascript
mapStateToProps(state, ownProps) : stateProps
```

### 这个函数允许我们将 store 中的数据作为 props 绑定到组件上。
```javascript
const mapStateToProps = (state) => {
  return {
    count: state.count
  }
}
```


（1）这个函数的第一个参数就是 Redux 的 store，我们从中摘取了 count 属性。你不必将 state 中的数据原封不动地传入组件，可以根据 state 中的数据，动态地输出组件需要的（最小）属性。
（2）函数的第二个参数 ownProps，是组件自己的 props。有的时候，ownProps 也会对其产生影响。
当 state 变化，或者 ownProps 变化的时候，mapStateToProps 都会被调用，计算出一个新的 stateProps，（在与 ownProps merge 后）更新给组件。

```javascript
mapDispatchToProps(dispatch, ownProps): dispatchProps
```

connect 的第二个参数是 mapDispatchToProps，它的功能是，将 action 作为 props 绑定到组件上，也会成为 MyComp 的 props。

```javascript
[mergeProps],[options]
```

不管是 stateProps 还是 dispatchProps，都需要和 ownProps merge 之后才会被赋给组件。connect 的第三个参数就是用来做这件事。通常情况下，你可以不传这个参数，connect 就会使用 Object.assign 替代该方法。
[options] (Object) 如果指定这个参数，可以定制 connector 的行为。一般不用


## 原理解析
首先connect之所以会成功，是因为Provider组件：

在原应用组件上包裹一层，使原来整个应用成为Provider的子组件
接收Redux的store作为props，通过context对象传递给子孙组件上的connect

## 那connect做了些什么呢？
它真正连接 Redux 和 React，它包在我们的容器组件的外一层，它接收上面 Provider 提供的 store 里面的 state 和 dispatch，传给一个构造函数，返回一个对象，以属性形式传给我们的容器组件。


## 关于源码

connect是一个高阶函数，首先传入mapStateToProps、mapDispatchToProps，然后返回一个生产Component的函数(wrapWithConnect)，然后再将真正的Component作为参数传入wrapWithConnect，这样就生产出一个经过包裹的Connect组件，该组件具有如下特点:

通过props.store获取祖先Component的store
props包括stateProps、dispatchProps、parentProps,合并在一起得到nextState，作为props传给真正的Component
componentDidMount时，添加事件this.store.subscribe(this.handleChange)，实现页面交互
shouldComponentUpdate时判断是否有避免进行渲染，提升页面性能，并得到nextState
componentWillUnmount时移除注册的事件this.handleChange

```javascript
export default function connect(mapStateToProps, mapDispatchToProps, mergeProps, options = {}) {
  return function wrapWithConnect(WrappedComponent) {
    class Connect extends Component {
      constructor(props, context) {
        // 从祖先Component处获得store
        this.store = props.store || context.store
        this.stateProps = computeStateProps(this.store, props)
        this.dispatchProps = computeDispatchProps(this.store, props)
        this.state = { storeState: null }
        // 对stateProps、dispatchProps、parentProps进行合并
        this.updateState()
      }
      shouldComponentUpdate(nextProps, nextState) {
        // 进行判断，当数据发生改变时，Component重新渲染
        if (propsChanged || mapStateProducedChange || dispatchPropsChanged) {
          this.updateState(nextProps)
            return true
          }
        }
        componentDidMount() {
          // 改变Component的state
          this.store.subscribe(() = {
            this.setState({
              storeState: this.store.getState()
            })
          })
        }
        render() {
          // 生成包裹组件Connect
          return (
            <WrappedComponent {...this.nextState} />
          )
        }
      }
      Connect.contextTypes = {
        store: storeShape
      }
      return Connect;
    }
  }
```



