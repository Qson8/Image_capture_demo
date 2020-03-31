import 'package:flutter/material.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_capture_demo/util/qs_common.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'qs_home_model.dart';

class QSHomePage extends StatefulWidget {
  @override
  _QSHomePageState createState() => _QSHomePageState();
}

class _QSHomePageState extends State<QSHomePage> {
  MineInviteModel _model;
  YBSise size;
  @override
  Widget build(BuildContext context) {
    _config(context);

    return Scaffold(
      appBar: AppBar(title: Text('图片截取并保持相册')),
      body: _bodyWidget(),
      backgroundColor: Color(0xfff1f1f1),
    );
  }

  _config(BuildContext context) {
    size = YBSise(context, width: 360, height: 780);
    _model = Provider.of<MineInviteModel>(context)..setContext(context);
  }

  _bodyWidget() {
    double itemHeight = size.screenHeightDp * 0.6;
    double itemWidht = 289.0 * itemHeight / 491.0;
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          _headWidget(),
          SizedBox(
            height: 5,
          ),
          Container(
            width: size.screenWidthDp,
            height: itemHeight + 50,
            child: (_model.list != null && _model.list.length > 1)
                ? Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      Map data = _model.list[index];
                      return _middleWidget(data,
                          width: itemWidht, height: itemHeight, index: index);
                    },
                    onIndexChanged: (index) {
                      _model.currentIndex = index;
                    },
                    index: 0,
                    loop: false,
                    viewportFraction: 0.8,
                    itemCount: _model.list.length,
                    itemWidth: itemWidht,
                    itemHeight: itemHeight,
                    pagination: SwiperPagination(
                      margin: EdgeInsets.only(top: 20),
                      builder: DotSwiperPaginationBuilder(
                        color: Color(0xFFEDA484),
                        activeSize: size.setWidth(8),
                        size: size.setWidth(8),
                        activeColor: Colors.white,
                      ),
                    ),
                  )
                : _middleWidget(_model.list.length > 0 ? _model.list.first : {},
                    width: itemWidht, height: itemHeight, index: 0),
          ),
          SizedBox(
            height: 5,
          ),
          _bottomWidget(),
          Container(
            padding: EdgeInsets.only(top:30),
            child: Center(
              child: Text('By Qson',style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/invite_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  _headWidget() {
    double width = size.screenWidthDp - 2 * size.setWidth(60);
    return clipRRectWidget(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        width: width,
        color: Color(0xffFFDBB3),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            '邀请码 ${_model.code}',
            style: TextStyle(color: Color(0xff666666), fontSize: 14),
          ),
          SizedBox(width: 30),
          Container(
            height: 30,
            child: _roundButton('复制',
                style: TextStyle(color: Colors.white, fontSize: 14),
                bgColor: Theme.of(context).accentColor,
                circula: 15.0, onTap: () {
              // 复制
              Clipboard.setData(ClipboardData(text: _model.code));
              Fluttertoast.showToast(msg: '复制成功');
            }),
          ),
        ]),
      ),
    );
  }

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

  _bottomWidget() {
    Map currData = _model.currData;
    String link = currData['page'] ?? '';
    String inviteLink = link + "?idCode=${_model.code}";
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // 复制
              Clipboard.setData(ClipboardData(text: inviteLink));
              Fluttertoast.showToast(msg: '复制成功');
            },
            child: clipRRectWidget(
              circular: 22,
              child: Container(
                color: Color(0xffFFA63B),
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Center(
                  child: Text(
                    '复制邀请链接',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // 分享
              _model.logic.saveImage();
            },
            child: Container(
              height: 44,
              child: clipRRectWidget(
                circular: 22,
                child: Container(
                  color: Color(0xffFF1B1B),
                  height: 44,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: Text(
                      '保存到相册',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _roundButton(title,
      {TextStyle style, Function onTap, Color bgColor, double circula}) {
    return FlatButton(
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title, style: style),
        ],
      ),
      color: bgColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(circula))),
    );
  }

  Widget clipRRectWidget({Widget child, double circular = 10}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(circular),
      child: child,
    );
  }
}
