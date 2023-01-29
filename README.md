# image_capture_demo

#### 截取图片并保存

相信大家见过这种使用场景，就是生成属于自己的二维码海报，可以保存到相册，分享出去。在社交电商类的App中比较常见。
这种懂原生知道，用原生实现简单，但Flutter中实现这种功能,没接触过的,就会无从下手。下面我们就来通过代码交流下。

* Demo涉及技术点
`状态管理Provider`
`生成二维码`
`图片保存`

* Demo涉及的插件
```dart
  fluttertoast: 3.1.3 # toast提示框
  provider: ^3.0.0+1 # 状态管理

  permission_handler: ^4.3.0 # 权限处理
  image_pickers: ^1.0.7+1 # 图片保存，选取等
  path_provider: ^1.6.1 # 获取文件路径

  qr_flutter: ^3.0.1 #二维码
  flutter_swiper: ^1.1.6 # 轮播
```

* 截取图片代码
把需要截取的widget，外层包上RepaintBoundary，并设置好key(出现多个key不能重复)

![效果图](https://img.520lee.com/Fk4JlkAShmJMp5jhlkjhmsgn7mnV)
    搭建并关联widget截取区域 代码
```java
_middleWidget(Map data, {double width, double height, int index}) {
    if (data == null || data.length == 0) return Container();

    String image = data['path'] ?? '';
    String link = data['page'] ?? '';
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: RepaintBoundary(
            key: _model.repaintKey[index],
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Positioned(
                    bottom: size.setWidth(30),
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(size.setSp(20) * 0.5),
                            child: Container(
                              color: Color(0x88000000),
                              height: size.setSp(20),
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.setSp(12)),
                              child: Center(
                                child: Text(
                                  '邀请码 ${_model.code}',
                                  style: TextStyle(
                                      fontSize: size.setSp(9),
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.setWidth(5),
                          ),
                          QrImage(
                            padding: EdgeInsets.all(size.setWidth(7)),
                            backgroundColor: Colors.white,
                            data: (link != null && link.length > 0)
                                ? link + "?idCode=${_model.code}"
                                : '',
                            size: size.setWidth(96),
                          ),
                          SizedBox(
                            height: size.setWidth(15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
```

   UI转成图片
```java
  // 截屏图片生成图片流ByteData
  void saveImage() async {
    // 截屏
    ByteData byteData = await QSCommon.capturePngToByteData(
        _model.repaintKey[_model.currentIndex]);
    // 保存
    File file = await QSCommon.saveImageToCamera(byteData);
    debugPrint('$file');
    if (file.path.length > 0) {
      Fluttertoast.showToast(msg: '保存成功');
    } else {
      Fluttertoast.showToast(msg: '保存失败');
    }
  }
```

`capturePngToByteData`生成图片具体实现
```java
/// 截屏图片生成图片流ByteData
  static Future<ByteData> capturePngToByteData(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
      double dpr = ui.window.devicePixelRatio; // 获取当前设备的像素比
      ui.Image image = await boundary.toImage(pixelRatio: dpr);
      ByteData _byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return _byteData;
    } catch (e) {
      debugPrint(e);
    }
    return null;
  }
```

`saveImageToCamera`保存到相册具体实现
```java
/// 保存图片到相册
  static Future<File> saveImageToCamera(ByteData byteData) async {
    await handlePhotosPermission();
    
    Uint8List sourceBytes = byteData.buffer.asUint8List();
    String path = await ImagePickers.saveByteDataImageToGallery(sourceBytes);
    return File(path);
  }
```

本文demo地址：https://github.com/Qson8/Image_capture_demo.git

>微信公众号：西江悦

问题或建议，请公众号留言。
![](http://img.520lee.com/FmckB4obGGl4NTOjn-WDoNu6GYbl)

