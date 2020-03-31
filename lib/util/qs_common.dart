

import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class QSCommon {
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

  /// 把图片ByteData写入File，并触发微信分享
  static Future<File> writeAsImageBytes(ByteData data) async {
    ByteData sourceByteData = data;
    Uint8List sourceBytes = sourceByteData.buffer.asUint8List();
    Directory tempDir = await getTemporaryDirectory();

    String storagePath = tempDir.path;
    File file = new File('$storagePath/海报截图.png');

    if (!file.existsSync()) {
      file.createSync();
    }
    file.writeAsBytesSync(sourceBytes);
    return file;
  }

  /// 图片存储权限处理
  static Future<Null> handlePhotosPermission() async {
    // 判断是否有权限
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.camera]);
    Future<PermissionStatus> permission =
        PermissionHandler().checkPermissionStatus(PermissionGroup.photos);
    if (permission == PermissionStatus.denied) {
      // 无权限的话就显示设置页面
      bool isOpened = await PermissionHandler().openAppSettings();
      debugPrint('无权限');
    }
    PermissionHandler().requestPermissions(<PermissionGroup>[
      PermissionGroup.storage, // 在这里添加需要的权限
    ]);
  }

  /// 保存图片到相册
  static Future<File> saveImageToCamera(ByteData byteData) async {
    await handlePhotosPermission();
    
    Uint8List sourceBytes = byteData.buffer.asUint8List();
    String path = await ImagePickers.saveByteDataImageToGallery(sourceBytes);
    return File(path);
  }
}


/// 复制类 剪贴板
@immutable
class ClipboardData {
  final String text;
  const ClipboardData({this.text});
}

class Clipboard {
  Clipboard._();

  static const String kTextPlain = 'text/plain';

  /// Stores the given clipboard data on the clipboard.
  ///将ClipboardData中的内容复制的粘贴板
  static Future<void> setData(ClipboardData data) async {
    await SystemChannels.platform.invokeMethod<void>(
      'Clipboard.setData',
      <String, dynamic>{
        'text': data.text,
      },
    );
  }
}

class YBSise {
  //YBSise _instance;
  static const int defaultWidth = 1080;
  static const int defaultHeight = 1920;

  /// UI设计中手机尺寸 , px
  /// Size of the phone in UI Design , px
  num uiWidthPx;
  num uiHeightPx;

  /// 控制字体是否要根据系统的“字体大小”辅助选项来进行缩放。默认值为false。
  /// allowFontScaling Specifies whether fonts should scale to respect Text Size accessibility settings. The default is false.
  bool allowFontScaling;

  MediaQueryData _mediaQueryData;
  double screenW;
  double screenH;
  double _pixelRatio;
  double top;
  double bottom;
  double _textScaleFactor;

  //YBSise._();

  /*factory YBSise() {
    return _instance;
  }*/

  YBSise(BuildContext context,
      {num width = defaultWidth,
        num height = defaultHeight,
        this.allowFontScaling = false}) {
    uiWidthPx = width;
    uiHeightPx = height;
    allowFontScaling = allowFontScaling;

    MediaQueryData mediaQuery = MediaQuery.of(context);
    _mediaQueryData = mediaQuery;
    _pixelRatio = mediaQuery.devicePixelRatio;
    screenW = mediaQuery.size.width;
    screenH = mediaQuery.size.height;
    top = mediaQuery.padding.top;
    bottom = _mediaQueryData.padding.bottom;
    _textScaleFactor = mediaQuery.textScaleFactor;

    setSize(screenW, screenH);
  }

  /*  void init(BuildContext context,
      {num width = defaultWidth,
        num height = defaultHeight,
        bool allowFontScaling = false}) {
    if (_instance == null) {
      _instance = YBSise._();
      _instance.uiWidthPx = width;
      _instance.uiHeightPx = height;
      _instance.allowFontScaling = allowFontScaling;

      MediaQueryData mediaQuery = MediaQuery.of(context);
      _mediaQueryData = mediaQuery;
      _pixelRatio = mediaQuery.devicePixelRatio;
      _screenWidth = mediaQuery.size.width;
      _screenHeight = mediaQuery.size.height;
      _statusBarHeight = mediaQuery.padding.top;
      _bottomBarHeight = _mediaQueryData.padding.bottom;
      _textScaleFactor = mediaQuery.textScaleFactor;

      _instance.setSize(_screenWidth,_screenHeight);

    }

  }
*/


  MediaQueryData get mediaQueryData => _mediaQueryData;

  /// 每个逻辑像素的字体像素数，字体的缩放比例
  /// The number of font pixels for each logical pixel.
  double get textScaleFactor => _textScaleFactor;

  /// 设备的像素密度
  /// The size of the media in logical pixels (e.g, the size of the screen).
  double get pixelRatio => _pixelRatio;

  /// 当前设备宽度 dp
  /// The horizontal extent of this size.
  double get screenWidthDp => screenW;

  ///当前设备高度 dp
  ///The vertical extent of this size. dp
  double get screenHeightDp => screenH;

  /// 当前设备宽度 px
  /// The vertical extent of this size. px
  double get screenWidth => screenW * _pixelRatio;

  /// 当前设备高度 px
  /// The vertical extent of this size. px
  double get screenHeight => screenH * _pixelRatio;

  /// 状态栏高度 dp 刘海屏会更高
  /// The offset from the top
  double get statusBarHeight => top;

  /// 底部安全区距离 dp
  /// The offset from the bottom.
  double get bottomBarHeight => bottom;

  /// 实际的dp与UI设计px的比例
  /// The ratio of the actual dp to the design draft px
  double get scaleWidth => screenW / uiWidthPx;

  double get scaleHeight => screenH / uiHeightPx;

  double get scaleText => scaleWidth > scaleHeight ? scaleWidth : scaleHeight;

  /// 根据UI设计的设备宽度适配
  /// 高度也可以根据这个来做适配可以保证不变形,比如你先要一个正方形的时候.
  /// Adapted to the device width of the UI Design.
  /// Height can also be adapted according to this to ensure no deformation ,
  /// if you want a square
  num setWidth(num width) => width * scaleWidth;

  /// 根据UI设计的设备高度适配
  /// 当发现UI设计中的一屏显示的与当前样式效果不符合时,
  /// 或者形状有差异时,建议使用此方法实现高度适配.
  /// 高度适配主要针对想根据UI设计的一屏展示一样的效果
  /// Highly adaptable to the device according to UI Design
  /// It is recommended to use this method to achieve a high degree of adaptation
  /// when it is found that one screen in the UI design
  /// does not match the current style effect, or if there is a difference in shape.
  num setHeight(num height) => height * scaleHeight;

  ///字体大小适配方法
  ///@param [fontSize] UI设计上字体的大小,单位px.
  ///Font size adaptation method
  ///@param [fontSize] The size of the font on the UI design, in px.
  ///@param [allowFontScaling]
  num setSp(num fontSize, {bool allowFontScalingSelf}) =>
      allowFontScalingSelf == null
          ? (allowFontScaling
          ? (fontSize * scaleText)
          : ((fontSize * scaleText) / _textScaleFactor))
          : (allowFontScalingSelf
          ? (fontSize * scaleText)
          : ((fontSize * scaleText) / _textScaleFactor));

  //预设转换单位
  double padding = 15;
  double small_padding = 5;
  double backMargin = 19;
  double appBarHeight = 50;

  double biglarerTextSiez = 38.0;
  double lagerTextSize = 30.0;
  double bigTextSize = 21.0;
  double middleTextWhiteSize = 17.0;
  double normalTextSize = 16.0;
  double smallTextSize = 13.5;
  double minTextSize = 12.0;


  //和设计图等比例的尺寸  重复避免计算
  List SH = [];
  List SW = [];

  void setSize(width, height) {
    SW = List.generate((width + 1).toInt(), (int index) {
      return setWidth(index);
    });
    SH = List.generate((height + 1).toInt(), (int index) {
      return setHeight(index);
    });
    padding = setHeight(15);
    small_padding = setHeight(5);
    backMargin = setHeight(19);
    appBarHeight = setHeight(50);

    biglarerTextSiez = setSp(38);
    lagerTextSize = setSp(30);


    bigTextSize = setSp(21.0);
    middleTextWhiteSize = setSp(17.0);
    normalTextSize = setSp(15.0);
    smallTextSize = setSp(13.5);
    minTextSize = setSp(12.0);
  }
}
