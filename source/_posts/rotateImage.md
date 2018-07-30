---
title: 关于旋转图片调整角度及自适应问题
date: 2018-7-30 12:08:27
---

#### 问题情景：TMS后台乐谱课后单等图片，有时出现图片旋转显示问题
![问题图片](/images/rotateImages/1532929671685.jpg)

#### 图一和图二拍摄为同一张图，图一做了一个小标记。
#### 图一为正常比例，图二为旋转后原图。
#### 右键新窗口打开图片，图二显示正常。

![问题图片](/images/rotateImages/1532929881012.jpg)

### 解决思路: 找到图片旋转角度，对应的调整图片旋转角度， 处理图片宽高比例。

#### 通过查阅资料发现图片旋转角度与image 的Orientation属性有关，在HTML中IMG 标签不会自动调整img的旋转角度,新窗口打开图片 浏览器会自动根据图片的旋转角度及比例自适应调整。

#### 以下是实现代码, 具体思路:
#### 1 首先获取图片旋转角度Orientation [通过EXIF.js](https://github.com/exif-js/exif-js/)。
### 可以通过此库获取到图片的一些原始属性，拍照位置 曝光度 旋转度等[具体文档](http://code.ciaoca.com/javascript/exif-js//)
### 2 通过获取到旋转角度进行调整，用canvas进行重绘，并且输出base64图片
### 代码注释中包含 踩坑的经历以及解决方法

```javascript
import rotateImage from '@/util/rotateImage';

reviseImages () {
  const imgs = document.querySelectorAll('.item-content img');

  [].forEach.call(imgs, (i) => {
    let newImage = new Image();
    // 此处必须设置图片跨域头信息，否则canvas toDataURL会报错
    newImage.setAttribute('crossOrigin', 'anonymous');
    newImage.src = i.src;
    // 必须等图片加载完成之后进行canvas进行处理
    newImage.onload = () => {
      rotateImage(newImage).then(base64 => {
        if (base64) {
          i.src = base64;
        }
      })
    }
  })
}
```

![问题图片](/images/rotateImages/1532931474567.jpg)
[问题描述](https://stackoverflow.com/questions/20424279/canvas-todataurl-securityerror)。

```javascript
import EXIF from 'exif-js';

// 处理图片旋转问题

 const rotateImage =  (image) => {
   // 记录原始宽高 创建canvas
  const width = image.width;
  const height = image.height;
  const canvas = document.createElement("canvas")
  const ctx = canvas.getContext('2d');
  let base64 = '';
  
  // 图片处理并非同步操作，用Promise进行异步操作，处理完后返回base64
  const rotateImage = new Promise(function (resolve, reject) {
      EXIF.getData(image, function () {
        const orientation = EXIF.getTag(this,'Orientation');
        // Orientation 1 默认 3 旋转 180 6 旋转 90 8 旋转-90 undefind 不旋转
        // 根据不同旋转角度 调整图片宽高
        // 此处用canvas 而不是transform调整旋转。
        // transform 只能调整图片旋转角度，并不能调整图片宽高比例，当图片旋转90度 或者270度时 图片宽高需要调换，通过canvas进行重新绘制能解决这个问题
        switch (orientation){
          //旋转90度
          case 6:
              canvas.height = width;
              canvas.width = height;
              ctx.rotate(Math.PI / 2);
              ctx.translate(0, - height);
              ctx.drawImage(image, 0, 0)

              base64 = canvas.toDataURL('Image/jpeg',1);
              resolve(base64)
              break;
          //旋转180°
          case 3:
              canvas.height = height;
              canvas.width = width;
              ctx.rotate(Math.PI);
              ctx.translate(-width, -height);

              ctx.drawImage(image, 0, 0)
              base64 = canvas.toDataURL('Image/jpeg',1);
              resolve(base64)
              break;
          //旋转270°
          case 8:
              canvas.height = width;
              canvas.width = height;
              ctx.rotate(-Math.PI / 2);
              ctx.translate(-height, 0);

              ctx.drawImage(image, 0, 0)

              base64 = canvas.toDataURL('Image/jpeg',1);
              resolve(base64)
              break;
          default :
            resolve('');
          break;
        }
      }
    );
  });

  return rotateImage;
}

export default rotateImage;
```
![最终显示](/images/rotateImages/1532932553937.jpg)
