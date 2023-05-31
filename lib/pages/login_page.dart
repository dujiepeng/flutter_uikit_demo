import 'package:agora_chat_uikit/agora_chat_uikit.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uikit_demo/tools/image_loader.dart';

import '../widgets/input_text_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _password = '';

  bool _showPwd = false;
  bool _canLogin = false;
  String _errText = '';
  bool _showErr = false;
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            children: [
              const Divider(height: 80),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      ImageLoader.getImg("icon_log.png"),
                      width: 144,
                    ),
                    const Text(
                      "AgoraChat",
                      style: TextStyle(
                          color: Color.fromRGBO(17, 78, 255, 1),
                          fontSize: 30,
                          fontWeight: FontWeight.w900),
                    ),
                    const Divider(height: 20, color: Colors.transparent),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInCirc,
                      opacity: _showErr ? 1 : 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error,
                            color: Color.fromRGBO(255, 20, 204, 1),
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(_errText, style: const TextStyle(fontSize: 16))
                        ],
                      ),
                    ),
                    const Divider(height: 10, color: Colors.transparent),
                    InputTextWidget(
                      onChanged: (text) {
                        judgmentLoginBtnCallPress();
                      },
                      controller: _usernameController,
                      suffixIcon: IconButton(
                        onPressed: () {
                          _usernameController.text = "";
                          judgmentLoginBtnCallPress();
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.grey,
                        ),
                      ),
                      hideText: "Username",
                    ),
                    const Divider(height: 18, color: Colors.transparent),
                    InputTextWidget(
                      onChanged: (text) {
                        _password = text;
                        judgmentLoginBtnCallPress();
                      },
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _showPwd = !_showPwd),
                        icon: const Icon(
                          Icons.remove_red_eye_sharp,
                          color: Colors.grey,
                        ),
                      ),
                      hideText: 'Password',
                      obscureText: !_showPwd,
                    ),
                    const Divider(height: 18, color: Colors.transparent),
                    ElevatedButton(
                      style: ButtonStyle(
                        // 设置圆角
                        shape: MaterialStateProperty.all(
                          const StadiumBorder(
                            side: BorderSide(style: BorderStyle.none),
                          ),
                        ),
                      ),
                      onPressed: _canLogin ? loginAction : null,
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: const Text(
                          "Log in",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const Divider(height: 34, color: Colors.transparent),
                    Text.rich(
                      TextSpan(children: [
                        const TextSpan(
                            text: "No account? ",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600)),
                        TextSpan(
                            text: "Register",
                            recognizer: TapGestureRecognizer()
                              ..onTap = registerAction,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(17, 78, 255, 1),
                                fontWeight: FontWeight.w700))
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void judgmentLoginBtnCallPress() {
    if (_usernameController.text.isNotEmpty && _password.isNotEmpty) {
      if (_canLogin == false) {
        setState(() {
          _canLogin = true;
        });
      }
    } else {
      if (_canLogin == true) {
        setState(() {
          _canLogin = false;
        });
      }
    }
  }

  void loginAction() {
    EasyLoading.show(status: 'login...');
    ChatClient.getInstance
        .login(_usernameController.text, _password)
        .then((value) {
      EasyLoading.dismiss();
      Navigator.of(context).pushReplacementNamed("home");
    }).catchError((error) {
      EasyLoading.dismiss();
      _errText = (error as ChatError).description;
      setState(() {
        _showErr = true;
      });
      Future.delayed(const Duration(milliseconds: 2000), () {
        setState(() {
          _showErr = false;
        });
      });
    });
  }

  void registerAction() {
    debugPrint('registerAction');
    Navigator.of(context).pushNamed("register");
  }
}
