import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uikit_demo/pages/ContactPage/contacts/contact_info.dart';
import 'package:flutter_uikit_demo/pages/ContactPage/groups/group_info.dart';
import 'package:flutter_uikit_demo/pages/ConversationPage/MessagesPage/messages_page.dart';
import 'package:flutter_uikit_demo/tools/tool.dart';
import 'pages/ContactPage/contacts/contacts_select_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var options = ChatOptions(appKey: "easemob-demo#flutter", debugModel: true);
  await ChatClient.getInstance.init(options);
  await DemoDataStore.shared.init();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgoraChatDemo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: EasyLoading.init(
        builder: (context, child) {
          return AgoraChatUIKit(child: child!);
        },
      ),
      home: FutureBuilder<bool>(
        future: ChatClient.getInstance.isLoginBefore(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: Colors.orange,
            );
          }
          if (snapshot.data == false) {
            return const LoginPage();
          } else {
            return const HomePage();
          }
        },
      ),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: ((context) {
          if (settings.name == 'login') {
            return const LoginPage();
          } else if (settings.name == 'home') {
            return const HomePage();
          } else if (settings.name == 'register') {
            return const RegisterPage();
          } else if (settings.name == '/group_info') {
            ChatGroup group = settings.arguments as ChatGroup;
            return GroupInfo(group);
          } else if (settings.name == '/contact_info') {
            ChatUserInfo userInfo = settings.arguments as ChatUserInfo;
            return ContactInfo(userInfo);
          } else if (settings.name == '/message_page') {
            Map map = settings.arguments as Map;
            ChatConversation conversation = map['conversation'];
            ChatUserInfo? userInfo = map['userInfo'];
            return MessagePage(conversation: conversation, userInfo: userInfo);
          } else if (settings.name == '/contacts_select') {
            return const ContactsSelectPage();
          } else {
            return Container();
          }
        }));
      },
    );
  }
}
