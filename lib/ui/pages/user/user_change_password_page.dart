import 'dart:async';

import 'package:campus_benefit_app/core/nets/handler.dart';
import 'package:campus_benefit_app/core/nets/net_message.dart';
import 'package:campus_benefit_app/providers/provider_widget.dart';
import 'package:campus_benefit_app/service/user_repository.dart';
import 'package:campus_benefit_app/ui/pages/login/login_common_widgets.dart';
import 'package:campus_benefit_app/view_models/base/login_model.dart';
import 'package:campus_benefit_app/view_models/base/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

class UserChangePasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserChangePasswordPageState();
}

class UserChangePasswordPageState extends State<UserChangePasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: Text("修改密码"),
        ),
        body: Container(
          color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    color: Theme.of(context).primaryColor,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ChangePasswordPanel()
                        ],
                      ),
                    ),
                  )
                ])));
  }
}


class ChangePasswordPanel extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChangePasswordPanelState();
}

class _ChangePasswordPanelState extends State<ChangePasswordPanel> {
  TextEditingController _passwordController;
  TextEditingController _newPasswordController;
  TextEditingController _codeController;
  final _pwdFocus = FocusNode();
  final _newPwdFocus = FocusNode();
  final _codeFocus = FocusNode();
  var isSent = false;
  var _seconds = 60;
  Timer _timer;
  var _verifyStr = "获取验证码";

  @override
  void initState() {
    _passwordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _codeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _codeController.dispose();
    _cancelTimer();
    super.dispose();
  }

  void _startTimer() {
    // 计时器（`Timer`）组件的定期（`periodic`）构造函数，创建一个新的重复计时器。
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _cancelTimer();
        _seconds = 60;
        setState(() {
          isSent = false;
        });
        return;
      }
      _seconds--;
      setState(() {
        _verifyStr = '已发送$_seconds秒';
      });
      setState(() {});
      if (_seconds == 0) {
        _verifyStr = '重新发送';
        isSent = false;
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var userModel = Provider.of<UserModel>(context);
    return ProviderWidget<LoginModel>(
      model: LoginModel(Provider.of(context)),
      onModelReady: (model){},
      builder: (context, model, child) {
        return Form(
          onWillPop: () async {
            return !model.busy;
          },
          child: child,
        );
      },
      child: Column(
        children: <Widget>[
          LoginPanelForm(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: LoginTextField(
                          controller: _codeController,
                          label: "验证码",
                          icon: Icons.vpn_key,
                          maxLength: 6,
                          inputType: TextInputType.number,
                          focusNode: _codeFocus,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 9,vertical: 2),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_verifyStr,style: TextStyle(color: Colors.white),),
                          onPressed: isSent
                              ? null
                              : () {
                            UserRepository.getCode(userModel.user.userinfo.phone).then((result){
                              showToast("验证码已发送。");
                              setState(() {
                                isSent = true;
                              });
                              _startTimer();
                            }).catchError((e){
                              Future.microtask(() {
                                showToast(ResponseMessage(Handler.errorHandleFunction(e.response.statusCode),e.response.data).message, context: context);
                              });
                            });
                          },
                          elevation: 0,
                          focusElevation: 0,
                          color: Theme.of(context).primaryColor.withOpacity(0.9),
                          textColor: Colors.white,
                          disabledColor: Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                      )
                    ],
                  ),
                  LoginTextField(
                    controller: _passwordController,
                    label: "新密码",
                    icon: Icons.lock_outline,
                    obscureText: true,
                    focusNode: _pwdFocus,
                    textInputAction: TextInputAction.done,
                  ),
                  LoginTextField(
                    controller: _newPasswordController,
                    label: "确认新密码",
                    icon: Icons.lock_outline,
                    obscureText: true,
                    focusNode: _newPwdFocus,
                    textInputAction: TextInputAction.done,
                  ),
                  ChangePasswordButton(_codeController, _passwordController, _newPasswordController),
                ]),
          )
        ],
      ),
    );
  }
}