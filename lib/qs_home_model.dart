import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_capture_demo/util/qs_common.dart';

class MineInviteModel with ChangeNotifier {
  // 截屏
  List<GlobalKey> repaintKey = [];

  MineInviteLogic logic;
  BuildContext context;
  Map userInfo = {};

  String code = '888888';
  List list = [];
  int currentIndex = 0;

  MineInviteModel() {
    logic = MineInviteLogic(this);
  }

  void setContext(BuildContext context) {
    if (this.context == null) {
      this.context = context;
    }

    logic.loadPosterList();
  }

  setList(list) {
    this.list = list;

    repaintKey = new List<GlobalKey>.generate(
        list.length, (i) => new GlobalKey(debugLabel: ' repaintKey'));
  }

  Map get currData {
    if (list.length > 0 && list.length > currentIndex) {
      return list[currentIndex];
    } else {
      return {};
    }
  }

  void refresh() {
    try {
      if (context.size.width > 0) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('抛异常');
    }
  }
}

class MineInviteLogic {
  final MineInviteModel _model;
  MineInviteLogic(this._model);

  void loadPosterList() async {
    _model.setList([
      {
        "path":
            "http://yundou.wolkercloud.com/image/default/B3777198D3A24206B0FEFACAC02B26FD-6-2.png",
        "page": "https://www.baidu.com",
      },
      {
        "path": "https://asset.bixjf.com/avatar222/20191217/DY78763076237.jpg",
        "page": "http://www.blog.qson.com",
      }
    ]);
    _model.refresh();
  }

  /// 保存图片
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

  /// 分享

}
