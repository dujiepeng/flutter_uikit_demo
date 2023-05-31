import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uikit_demo/widgets/input_text_widget.dart';

import '../tools/image_loader.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  bool _showErr = false;
  bool _canPress = false;
  bool _showPwd = false;
  bool _showConfirmPwd = false;
  String _errText = '';
  String _pwd = '';
  String _confirmPwd = '';
  @override
  Widget build(BuildContext context) {
    Widget content = const Text.rich(
      TextSpan(children: [
        TextSpan(
            text: "AgoraChat ",
            style: TextStyle(
                color: Color.fromRGBO(17, 78, 255, 1),
                fontSize: 30,
                fontWeight: FontWeight.w900)),
        TextSpan(
          text: "Register",
          style: TextStyle(
              fontSize: 24,
              color: Color.fromRGBO(102, 102, 102, 1),
              fontWeight: FontWeight.w500),
        )
      ]),
    );
    content = Center(
      child: content,
    );

    Widget inputContent = Column(
      children: [
        InputTextWidget(
          controller: _usernameController,
          hideText: 'Enter a Username',
          onChanged: (text) => judgmentBtnCallPress(),
          suffixIcon: IconButton(
            onPressed: () {
              _usernameController.text = "";
              judgmentBtnCallPress();
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.grey,
            ),
          ),
        ),
        const Divider(height: 15, color: Colors.transparent),
        InputTextWidget(
          onChanged: (text) {
            _pwd = text;
            judgmentBtnCallPress();
          },
          suffixIcon: IconButton(
            onPressed: () => setState(() => _showPwd = !_showPwd),
            icon: const Icon(
              Icons.remove_red_eye_sharp,
              color: Colors.grey,
            ),
          ),
          obscureText: !_showPwd,
          hideText: 'Enter a Password',
        ),
        const Divider(height: 15, color: Colors.transparent),
        InputTextWidget(
          onChanged: (text) {
            _confirmPwd = text;
            judgmentBtnCallPress();
          },
          suffixIcon: IconButton(
            onPressed: () => setState(() => _showConfirmPwd = !_showConfirmPwd),
            icon: const Icon(
              Icons.remove_red_eye_sharp,
              color: Colors.grey,
            ),
          ),
          obscureText: !_showConfirmPwd,
          hideText: 'Confirm Password',
        ),
        const Divider(height: 15, color: Colors.transparent),
        ElevatedButton(
          style: ButtonStyle(
            // 设置圆角
            shape: MaterialStateProperty.all(
              const StadiumBorder(
                side: BorderSide(style: BorderStyle.none),
              ),
            ),
          ),
          onPressed: _canPress ? register : null,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: const Text(
              "Sign Up",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const Divider(height: 15, color: Colors.transparent),
        TextButton(
          onPressed: pop,
          child: const Text(
            'Back to login',
            style: TextStyle(
                color: Color.fromRGBO(17, 78, 255, 1),
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
        ),
      ],
    );

    inputContent = Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: inputContent,
    );

    Widget errWidget = AnimatedOpacity(
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
    );

    content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          ImageLoader.getImg("icon_log.png"),
          width: 144,
        ),
        content,
        const Divider(height: 20, color: Colors.transparent),
        errWidget,
        const Divider(height: 15, color: Colors.transparent),
        inputContent,
      ],
    );

    content = ListView(
      children: [
        const Divider(height: 80),
        content,
      ],
    );

    content = Center(
      child: content,
    );

    return Scaffold(
      body: content,
    );
  }

  void judgmentBtnCallPress() {
    if (_usernameController.text.isNotEmpty &&
        _pwd.isNotEmpty &&
        _confirmPwd.isNotEmpty) {
      if (_canPress == false) {
        setState(() {
          _canPress = true;
        });
      }
    } else {
      if (_canPress == true) {
        setState(() {
          _canPress = false;
        });
      }
    }
  }

  void register() async {
    if (_pwd != _confirmPwd) {
      showError('Password does not match');
      return;
    }

    try {
      EasyLoading.show(status: 'Register...');
      await ChatClient.getInstance.createAccount(
        _usernameController.text,
        _pwd,
      );
      EasyLoading.showSuccess('Register success').then((value) => pop());
    } on ChatError catch (e) {
      showError(e.description);
    } catch (e) {
      showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  void showError(String str) {
    setState(() {
      _errText = str;
      _showErr = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showErr = false;
      });
    });
  }

  void showSuccess() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(24, 21, 24, 21),
            titlePadding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            actionsOverflowAlignment: OverflowBarAlignment.center,
            actionsPadding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Registration Success",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Divider(height: 32, color: Colors.transparent),
                InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color.fromRGBO(17, 78, 255, 1),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  void pop() {
    Navigator.of(context).pop();
  }
}
