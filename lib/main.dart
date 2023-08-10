import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uikit_demo/pages/ContactPage/contacts/contact_info_page.dart';
import 'package:flutter_uikit_demo/pages/ContactPage/contacts/contact_search_page.dart';
import 'package:flutter_uikit_demo/pages/ContactPage/groups/group_info_page.dart';
import 'package:flutter_uikit_demo/pages/ConversationPage/MessagesPage/messages_page.dart';
import 'package:flutter_uikit_demo/tools/demo_data_store.dart';
import 'pages/ContactPage/contacts/contacts_select_page.dart';
import 'pages/ContactPage/groups/group_members_page.dart';
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
      theme: ThemeData(
        iconTheme: const IconThemeData(color: Colors.black),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleSpacing: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        listTileTheme: const ListTileThemeData(
          titleTextStyle: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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
            return GroupInfoPage(group);
          } else if (settings.name == '/group_members') {
            ChatGroup group = settings.arguments as ChatGroup;
            return GroupMembersPage(group);
          } else if (settings.name == '/contact_info') {
            ChatUserInfo userInfo = settings.arguments as ChatUserInfo;
            return ContactInfoPage(userInfo);
          } else if (settings.name == '/contact_search') {
            return const ContactSearchPage();
          } else if (settings.name == '/message_page') {
            Map map = settings.arguments as Map;
            ChatConversation conversation = map['conversation'];
            ChatUserInfo? userInfo = map['userInfo'];
            return MessagesPage(conversation: conversation, userInfo: userInfo);
          } else if (settings.name == '/contacts_select') {
            return const ContactsSelectPage();
          } else {
            return Container();
          }
        }));
      },
    );
  }

  void test() async {
    String msgId = "";
    String reaction = "";

    try {
      // msgId: The message ID
      // reaction: Reaction ID
      // Adds a reaction to the specified message
      ChatClient.getInstance.chatManager.addReaction(
        messageId: msgId,
        reaction: reaction,
      );
    } on ChatError catch (e) {}

    try {
      // msgId: The message ID
      // reaction: Reaction ID
      // Removes a reaction from the specified message
      ChatClient.getInstance.chatManager.removeReaction(
        messageId: msgId,
        reaction: reaction,
      );
    } on ChatError catch (e) {}
  }
}
