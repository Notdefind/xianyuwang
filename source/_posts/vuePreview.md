---
title: vue图片预览插件
date: 2018-8-3 14:08:30
---

### vue图片预览插件 
### 基于 [PhotoSwipe](https://github.com/dimsemenov/PhotoSwipe)
### 参考 [vue-preview](https://github.com/LS1231/vue-preview) 基于PhotoSwipe提供的API的vue插件

### 移动端图片预览查看
### 借鉴vue-preview的源代码，在此基础上根据自己业务进行了大部分修改。
### 实现功能点：
### 1 可点击图片列表预览图片
### 2 可自定义点击元素预览图片（feature）
### 3 实现图片预览自适应处理 （feature）
### 4 修复了部分BUG （hotfix）


#### index.js
```javascript
import PreviewComponent from './preview.vue'
import PhotoSwipe from 'photoswipe/dist/photoswipe'
import PhotoSwipeUIDefault from 'photoswipe/dist/photoswipe-ui-default'

const VuePreview = {
  install (Vue, options) {
    Vue.component('VuePreview', {
      mixins: [PreviewComponent],
      props: {
        slides: Array
      },
      methods: {
        // index galleryElement disableAnimation
        // 打开图片的索引 选择的元素节点 是否开启打开动画
        openPhotoSwipe (index, galleryElement, disableAnimation) {
          return new Promise((resolve, reject) => {
            let pswpElement = document.querySelectorAll('.pswp')[0]
            let gallery
            let photoSwipeOptions
            let items
            // 获取items 再打开插件
            this.parseThumbnailElements(galleryElement).then(items => {
              items = items;
              // 默认配置项
              photoSwipeOptions = {
                // 关闭hash模式 hash模式可通过URL连接获取打开图片索引 hash模式下微信端出现底部URL导航按钮
                history: false,
                getThumbBoundsFn: function (index) {
                  // x（X位置，相对于文档），y（Y位置，相对于文档），w（元素的宽度）。
                  // 高度将根据大图像的大小自动计算。例如，如果您返回{x:0,y:0,w:50}缩放动画将从页面的左上角开始。
                  let thumbnail = items[index].el.getElementsByTagName('img')[0];
                  let pageYScroll = window.pageYOffset || document.documentElement.scrollTop;
                  let rect = thumbnail.getBoundingClientRect();
                  return {x: rect.left, y: rect.top + pageYScroll, w: rect.width};

                },
                // vue.use中的可选项
                ...options
              }

              // 设置打开index
              photoSwipeOptions.index = parseInt(index, 10)
              // 判断下标是否存在
              if (isNaN(photoSwipeOptions.index)) {
                return;
              }
              // 是否开启放大效果
              if (disableAnimation) {
                // 初始放大转换持续时间（以毫秒为单位）
                photoSwipeOptions.showAnimationDuration = 0
              }
              // http://photoswipe.com/documentation/options.html
              // pswpElement, PhotoSwipeUIDefault, items, photoSwipeOptions
              // 节点元素  photoswipe默认样式 处理好的items 配置项
              gallery = new PhotoSwipe(pswpElement, PhotoSwipeUIDefault, items, photoSwipeOptions)

              gallery.init();
              resolve('success');
            }).catch(error => {
              console.log(error)
              reject(error);
            })
          });
        },
        // 处理dome节点的自定义属性
        // parse slide data (url, title, size ...) from DOM elements
        parseThumbnailElements (el) {
          // 全部图片加载完再打开图片插件
          return new Promise((resolve, reject) => {
            let thumbElements = el.childNodes;
            let numNodes = thumbElements.length;
            let disposeItems = [];
            let originalItems = [];
            let resultList = [];
            let successCount = 0;
            let errorCount = 0;

            for (let i = 0; i < numNodes; i++) {
              let size
              let imageItem
              let figureEl
              let linkEl
              figureEl = thumbElements[i] // <figure> element
              // include only element nodes
              if (figureEl.nodeType !== 1) {
                continue
              }

              linkEl = figureEl.children[0] // <a> element
              const image = new Image();
              // 进行自适应处理
              image.src = linkEl.href;
              originalItems.push({src: linkEl.href})
              image.onload = () => {
                size = [image.naturalWidth, image.naturalHeight];
                imageItem = {
                  src: linkEl.getAttribute('href'),
                  w: parseInt(size[0], 10),
                  h: parseInt(size[1], 10)
                }
                if (figureEl.children.length > 1) {
                  // <figcaption> content
                  imageItem.title = figureEl.children[1].innerHTML
                }
                if (linkEl.children.length > 0) {
                  // <img> thumbnail element, retrieving thumbnail url
                  imageItem.msrc = linkEl.children[0].getAttribute('src')
                }
                imageItem.el = figureEl // save link to element for getThumbBoundsFn
                disposeItems.push(imageItem)

                successCount ++;
                // 全部加载成功
                if (successCount == numNodes) {
                  // 处理加载顺序不同问题
                  // 加载后数组 与原数组对比 最终返回一个排序之后的数组
                  originalItems.map((originalItme, index) => {
                    if (originalItme.src === disposeItems[index].src) {
                      resultList.push(disposeItems[index]);
                    } else {
                      const item = disposeItems.find(item => {
                        return item.src === originalItme.src;
                      });
                      resultList.push(item);
                    }
                  })
                  resolve(resultList);
                }
              }
              // 某些图片加载失败 只打开加载成功的图片
              image.onerror = () => {
                errorCount ++;
                if (successCount + errorCount == numNodes) {
                  resolve(disposeItems);
                } else if (errorCount == numNodes) {
                  reject('图片加载失败')
                }
              }
            }
          })
        },
        // 初始化插件 每张图片绑定点击事件
        initPhotoSwipeFromDOM (gallerySelector) {
          // loop through all gallery elements and bind events 每张图片绑定单独事件
          const galleryElements = document.querySelectorAll(gallerySelector);
          [].map.call(galleryElements, (galleryItem) => {
            galleryItem.onclick = this.onThumbnailsClick;
          })
        },
        // 点击图片打开插件
        onThumbnailsClick (e) {
          e = e || window.event
          e.preventDefault ? e.preventDefault() : e.returnValue = false
          let eTarget = e.target || e.srcElement;
           // find nearest parent element
          const closest = function closest (el, fn) {
            return el && (fn(el) ? el : closest(el.parentNode, fn))
          }
          // find root element of slide
          let clickedListItem = closest(eTarget, function (el) {
            return (el.tagName && el.tagName.toUpperCase() === 'FIGURE')
          })
          if (!clickedListItem) {
            return
          }
          // find index of clicked item by looping through all child nodes
          // alternatively, you may define index via data- attribute
          let clickedGallery = clickedListItem.parentNode
          let childNodes = clickedListItem.parentNode.childNodes
          let numChildNodes = childNodes.length
          let nodeIndex = 0
          let index
          for (let i = 0; i < numChildNodes; i++) {
            if (childNodes[i].nodeType !== 1) {
              continue
            }
            if (childNodes[i] === clickedListItem) {
              index = nodeIndex
              break
            }
            nodeIndex++
          }

          if (index >= 0) {
            // open PhotoSwipe if valid index found
            this.openPhotoSwipe(index, clickedGallery)
          }
          return false
        }
      },
      mounted () {
        this.initPhotoSwipeFromDOM('.my-gallery')
      }
    })
  }
}

if (typeof window !== 'undefined' && window.Vue) {
  window.Vue.use(VuePreview)
}

export default VuePreview


```
#### preview.vue
```javascript
<template>
  <div>
    <div class="my-gallery" itemscope itemtype="http://schema.org/ImageGallery">
      <template v-for="item in slides">
        <figure
          itemprop="associatedMedia"
          itemscope
          itemtype="http://schema.org/ImageObject">
          <a :href="item.src" itemprop="contentUrl" :data-size="'' + item.w + 'x' + item.h">
            <img :src="item.msrc || item.src" :alt="item.alt" itemprop="thumbnail"/>
          </a>
          <figcaption style="display: none" itemprop="caption description">{{item.title}}</figcaption>
        </figure>
      </template>
    </div>
    <div class="pswp" tabindex="-1" role="dialog" aria-hidden="true">
      <div class="pswp__bg"></div>
      <div class="pswp__scroll-wrap">
        <div class="pswp__container">
          <div class="pswp__item"></div>
          <div class="pswp__item"></div>
          <div class="pswp__item"></div>
        </div>
        <div class="pswp__ui pswp__ui--hidden">

          <div class="pswp__top-bar">
            <!-- 避免图片长度为1时不显示图片下标 -->
            <div style="display: block;" class="pswp__counter"></div>
            <button class="pswp__button pswp__button--close" title="Close (Esc)"></button>
            <button class="pswp__button pswp__button--share" title="Share"></button>
            <button class="pswp__button pswp__button--fs" title="Toggle fullscreen"></button>
            <button class="pswp__button pswp__button--zoom" title="Zoom in/out"></button>
            <div class="pswp__preloader">
              <div class="pswp__preloader__icn">
                <div class="pswp__preloader__cut">
                  <div class="pswp__preloader__donut"></div>
                </div>
              </div>
            </div>
          </div>
          <div class="pswp__share-modal pswp__share-modal--hidden pswp__single-tap">
            <div class="pswp__share-tooltip"></div>
          </div>
          <button class="pswp__button pswp__button--arrow--left" title="Previous (arrow left)">
          </button>
          <button class="pswp__button pswp__button--arrow--right" title="Next (arrow right)">
          </button>
          <div class="pswp__caption">
            <div class="pswp__caption__center"></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style>
  @import "~photoswipe/dist/photoswipe.css";
  @import "~photoswipe/dist/default-skin/default-skin.css";
</style>
<style lang="less">
<!-- 自定义样式 -->
.pswp__ui {
  .pswp__top-bar {
    background-color: #000;
  }
}
.pswp__zoom-wrap {
  .pswp__img {
    padding-top: 5px;
  }
}
@media screen and (min-width: 762px) {
  .pswp__zoom-wrap {
    .pswp__img {
      padding-top: 44px;
    }
  }
}

</style>

```
#### 示例
```javascript
<template>
  <div id="course-demand">
    <div id="image-list" class="image-list image-lists">
      <vue-preview :slides="remarkOutImage"></vue-preview>
    </div>

    <div class="public-music" id="public-music">
      <vue-preview ref="preview" :slides="publicImage"></vue-preview>
    </div>
    <button @click="openImage">打开图片</button>
  </div>
</template>
<script>
import Vue from 'vue';
import preview from '../../components/vuePreview';
import { Indicator, Toast } from 'mint-ui';

// 配置自定义options
Vue.use(preview, {
  mainClass: 'pswp--minimal--dark',
  barsSize: {top: 0, bottom: 0},
  captionEl: false,
  fullscreenEl: false,
  shareEl: false,
  bgOpacity: 1,
  tapToClose: false,
  tapToToggleControls: false,
  pinchToClose: false,
});
export default {
  data () {
    return {
      remarkOutImage: [
         {
            src: 'https://farm2.staticflickr.com/1043/5186867718_06b2e9e551_b.jpg',
        },
      ],
      publicImage: [

      ]
    }
  },
  created () {

  },
  watch: {

  },
  methods: {
    openImage () {
      Indicator.open({
        text: 'Loading...',
        spinnerType: 'fading-circle'
      });


      this.publicImage = [
        {
            src: 'https://farm6.staticflickr.com/5591/15008867125_68a8ed88cc_b.jpg',
        },
        {
            src: 'https://farm6.staticflickr.com/5591/15008867125_68a8ed88cc_b.jpg',
        }
      ],
      this.$nextTick(() => {
        this.$refs['preview'].openPhotoSwipe(0, document.querySelectorAll('.my-gallery')[1]).then(res => {
          // 成功回调
          Indicator.close();
        }).catch(error => {
          // 错误回调
        })
      })
    }
  }
}
</script>
```


### 问题点&新功能点：

#### 1 hash模式下微信新版本会显示出底部导航
![问题图片](/images/rotateImages/1531454559129751.png)
* 问题原因 预览插件打开hash模式后在url上会带上pid gid 记录打打开图片的索引
* 由于url变化触发了微信内置浏览器导航机制，所以右下角显示出导航栏
* 解决方案，关闭hash模式


#### 2 点击按钮打开图片功能
* PhotoSwipe提供内置方法
* 创建PhotoSwipe实例 并执行内部方法
* gallery = new PhotoSwipe( pswpElement, PhotoSwipeUI_Default, items, options);
* gallery.init();
* 通过内部封装，暴露出openPhotoSwipe方法
* 通过promise 提供打开成功或者失败的回调
* 外部通过 ref 直接调用传参

#### 3 点击按钮打开图片预览偶发性黑屏
* 问题原因 图片未加载完成，打开插件后图片没有显示出来，导致只显示底部黑色遮罩层。
* 通过Network中设置3G模拟网络差可必现此BUG。
* 解决方案 点击按钮打开图片时，必须等图片全部加载完成之后再打开图片预览。
* 此方案存在缺陷,若图片过多或过大可能导致打开速度较慢。

#### 4 图片自适应
* [社区提供的hack方法](https://github.com/LS1231/vue-preview/issues/39) 
* 在预览前根据图片原始尺寸设置data-size属性,插件内部通过获取data-size属性进行自适应。
* 上述3中所提到的,由于打开图片必须等图片加载完成再打开。所以可以在插件内部实现图片自适应，
* 通过获取naturalWidth naturalHeight 进行处理。

#### 5 提供PhotoSwipe options 自定义配置
* [PhotoSwipe提供选项](http://photoswipe.com/documentation/options.html) 

###最终效果
![](/images/rotateImages/WechatIMG112.jpeg)





