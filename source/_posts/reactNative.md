## reactNative

### reactNative 于react的区别

#### 运行环境： 
##### react 运行在web端基于浏览器，通过浏览器引擎解析HTML CSS JS等渲染view。
##### reactNative 运行在APP端，通过brieg 传递至native端，native端根据不同的数据属性渲染不同的view。

#### 开发环境
##### react node webpack等打包成build文件，运行在浏览器。
##### reactNative 通过native端开发软件 Xcode AndroidStudio，再基于node运行本地服务，native端连接至本地服务运行。
##### reactNative 端自带打包功能，最终编译为index.xxxx.budle.js。
##### iso Android 端通过运行解释index.xxxx.budle.js 运行渲染出对应native端的view。
[reactNative安装环境](https://reactnative.cn/docs/getting-started.html)

#### 语法差异

##### 视图层
##### react div span img 等标签
##### reactNative View Text Image 等(必须首字母大写)。

``` javascript 
   // example

   <img src="xxxx" />

   <Image source={{uri:"xxxx"}} /> // 引入网络资源
   <Image source={require('/react-native/img/favicon.png')/> // 导入本地资源
   <Image source={{uri: 'data:image/png;base64,iVBxxx'}} />
   // base64 资源    
```

##### 样式层
##### react float flex position Grids 等
##### reactNative flexbox position

### flex 布局
``` javascript 
    <div class="box">box</div>
    .box {
        dispaly: flex;
        background-color: '#fff'
    }

    import { View, Text, StyleSheet } from 'react-native';
    render() {
        const { checkStep } = this.state;

        return (
        <View style={styles.box}>
           <Text>box</Text>
        </View>
        );
    }
    const styles = StyleSheet.create({
        box: {
            backgroundColor: '#fff',
            flex: 1,
            flexDirection: 'row'
        }
    })
    
```
##### reactNative中style以对象的形式存在，并且遵循驼峰命名方式。
##### border-color -- > borderColor
##### background-color -- > backgroundColor

### React Native 中的 Flexbox 的工作原理和 web 上的 CSS 基本一致，当然也存在少许差异。首先是默认值不同：flexDirection的默认值是column而不是row，而flex也只能指定一个数字值。

### position 布局

##### position relative
##### 相对布局。这个和html的position有很大的不同，他的相对布局不是相对于父容器，而是相对于兄弟节点。

##### position absolute
##### 绝对布局。这个是相对于父容器进行据对布局。绝对布局是脱离文档流的，不过奇怪的是依旧在文档层次结构里面，这个和html的position也很大不一样。另外还有一个和html不一样的是，html中position:absolute要求父容器的position必须是absolute或者relative，如果第一层父容器position不是absolute或者relative，在html会依次向上递归查询直到找到为止，然后居于找到的父容器绝对定位。

##### 表现层

##### react 基于browser 具有特有对象 window document 等。
##### React Native 不具有window等对象。

``` javascript
<div id="box"></div>

document.getElementById('id').onclick = funciton () {
    // do something
}


import { Button } from 'react-native';

<Button
  onPress={onPressLearnMore}
/>

onPressLearnMore () {
    // do something
}

```
##### 或者添加点击元素
``` javascript
import { TouchableOpacity } from 'react-native'; 

<TouchableOpacity onPress={this._onPressButton}>
    <Image
    style={styles.button}
    source={require('./myButton.png')}
    />
</TouchableOpacity>
```

### 导航 Navigator
```javascript
export default class ListView extends Component { 
    static navigationOptions = ({ navigation }) => {
        return {
            headerTitle: (<Text>标题</Text>),
            headerLeft: (<Text>左边</Text>),
        };
    };
}

```
#### ios andriod 有不同的导航特性。
### iso标题居中 andriod 标题居左等 
[下面这个库提供了在两个平台都适用的原生导航](https://github.com/wix/react-native-navigation)

### 路由 router

```javascript
const { navigate } = this.props.navigation;

const params = {
    id: 123,
    query: 'xxxx',
};

navigate('details', params);
```
[reactNative navigation](https://reactnative.cn/docs/navigatorios/#push)
#### details 对应router中定义的组件。

### 网络请求

#### React Native 提供了和 web 标准一致的Fetch API，用于满足开发者访问网络的需求。

``` javascript 
fetch("https://mywebsite.com/mydata.json");
// Fetch 还有可选的第二个参数，可以用来定制 HTTP 请求一些参数。你可以指定 header 参数，或是指定使用 POST 方法，又或是提交数据等等
fetch("https://mywebsite.com/endpoint/", {
  method: "POST",
  headers: {
    Accept: "application/json",
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    firstParam: "yourValue",
    secondParam: "yourOtherValue"
  })
});
```

### 热更新方案
#### 每当客户端打开时询问服务器端是否有新bundle，有则下载。
#### 更新机制，什么时候需要热更新,什么时候需要更新APP。 
#### 当APP配置修改时需要重新发版，若只修改JS budle中的文件则只需要热更新。
![示意图](/images/1545295282188.jpg)

### 打包发布
#### ios xcode
#### android androidStudio





