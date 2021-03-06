import 'dart:async';
import 'dart:ui';
import 'package:campus_benefit_app/core/routers/app_router.dart';
import 'package:campus_benefit_app/core/utils/image_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AnimationController _logoController;
  Animation<double> _animation;
  AnimationController _countdownController;

  @override
  void initState() {
    _logoController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    _animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(curve: Curves.easeInOutBack, parent: _logoController));

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _logoController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _logoController.forward();
      }
    });
    _logoController.forward();

    _countdownController =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    _countdownController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () => Future.value(false),
        child: Stack(fit: StackFit.expand, children: <Widget>[
          Image.asset(
              ImageHelper.wrapAssets(
                  'splash_bg_none.png'
                      ),
//              colorBlendMode: BlendMode.srcOver,//colorBlendMode方式在android等机器上有些延迟,导致有些闪屏,故采用两套图片的方式
//              color: Colors.black.withOpacity(
//                  Theme.of(context).brightness == Brightness.light ? 0 : 0.65),
              fit: BoxFit.fill),
          AnimatedFlutterLogo(
            animation: _animation,
          ),
          Align(
            alignment: Alignment(0.0, -0.4),
            child: Opacity(
              opacity: 0.7,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Image.asset(
                    ImageHelper.wrapAssets('splash_circle.png'),
//              colorBlendMode: BlendMode.srcOver,//colorBlendMode方式在android等机器上有些延迟,导致有些闪屏,故采用两套图片的方式
//              color: Colors.black.withOpacity(
//                  Theme.of(context).brightness == Brightness.light ? 0 : 0.65),
                    fit: BoxFit.contain),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.0, -0.355),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.14,
              child: Image.asset(
                  ImageHelper.wrapAssets('splash_icon.png'),
//              colorBlendMode: BlendMode.srcOver,//colorBlendMode方式在android等机器上有些延迟,导致有些闪屏,故采用两套图片的方式
//              color: Colors.black.withOpacity(
//                  Theme.of(context).brightness == Brightness.light ? 0 : 0.65),
                  fit: BoxFit.contain),
            ),
          ),
          Align(
            alignment: Alignment(0.0, 0.34),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.22,
              child: Image.asset(ImageHelper.wrapAssets('splash_title.png'),
                  fit: BoxFit.contain),
            ),
          ),
          Align(
            alignment: Alignment(0.0, 0.44),
            child: Opacity(
              opacity: 0.7,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Image.asset(ImageHelper.wrapAssets('splash_title_desc.png'),
                    fit: BoxFit.contain),
              ),
            )
          ),
//          Align(
//            alignment: Alignment(0.0, 0.7),
//            child: Container(
//              width: MediaQuery.of(context).size.width * 0.26,
//              child: Image.asset(ImageHelper.wrapAssets('splash_bg_brief.png'),
//                  fit: BoxFit.contain),
//            ),
//          ),
          Align(
            alignment: Alignment(0.0, 0.7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                AnimatedAndroidLogo(
                  animation: _animation,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SafeArea(
              child: InkWell(
                onTap: () {
                  nextPage(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  margin: EdgeInsets.only(right: 20, bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.black.withAlpha(100),
                  ),
                  child: AnimatedCountdown(
                    context: context,
                    animation: StepTween(begin: 3, end: 0)
                        .animate(_countdownController),
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class AnimatedCountdown extends AnimatedWidget {
  final Animation<int> animation;

  AnimatedCountdown({key, this.animation, context})
      : super(key: key, listenable: animation) {
    this.animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        nextPage(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var value = animation.value + 1;
    return Text(
      (value == 0 ? '' : '$value | ') + '跳过',
      style: TextStyle(color: Colors.white),
    );
  }
}

class AnimatedFlutterLogo extends AnimatedWidget {
  AnimatedFlutterLogo({
    Key key,
    Animation<double> animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Container();
    return AnimatedAlign(
      duration: Duration(milliseconds: 10),
      alignment: Alignment(0, 0.2 + animation.value * 0.3),
      curve: Curves.bounceOut,
      child: Image.asset(
        ImageHelper.wrapAssets('splash_flutter.png'),
        width: 280,
        height: 120,
      ),
    );
  }
}

class AnimatedAndroidLogo extends AnimatedWidget {
  AnimatedAndroidLogo({
    Key key,
    Animation<double> animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
//        Image.asset(
//          ImageHelper.wrapAssets('splash_fun.png'),
//          width: 140 * animation.value,
//          height: 80 * animation.value,
//        ),
//        Image.asset(
//          ImageHelper.wrapAssets('splash_android.png'),
//          width: 200 * (1 - animation.value),
//          height: 80 * (1 - animation.value),
//        ),
      ],
    );
  }
}

Future<void> nextPage(context) async {
  Navigator.pushNamed(context, RouteName.tab);
}
