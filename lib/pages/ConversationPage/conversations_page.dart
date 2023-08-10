import 'package:agora_chat_uikit/agora_chat_uikit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_uikit_demo/demo_default.dart';

import 'package:flutter_uikit_demo/tools/user_info_manager.dart';

import 'MessagesPage/messages_page.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key, this.onUnreadCountChanged});
  final void Function(int)? onUnreadCountChanged;
  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void unreadCountChanged() {
    widget.onUnreadCountChanged?.call(
        AgoraChatUIKit.of(context).conversationsController.totalUnreadCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Chats',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Color.fromRGBO(0, 95, 255, 1))),
        actions: [
          TextButton(
              onPressed: showMenu,
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 40,
              )),
        ],
      ),
      body: AgoraConversationsView(
        avatarBuilder: (context, conversation) {
          if (conversation.type == ChatConversationType.Chat) {
            ChatUserInfo? info = UserInfoManager.getUserInfo(
                conversation.id, () => setState(() {}));
            return userInfoAvatar(info, size: 40);
          }
          return null;
        },
        onItemTap: (conversation) {
          ChatUserInfo? info = UserInfoManager.getUserInfo(
              conversation.id, () => setState(() {}));
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return MessagesPage(
                conversation: conversation,
                userInfo: info,
              );
            },
          )).then((value) async {
            await AgoraChatUIKit.of(context)
                .conversationsController
                .markConversationAsRead(conversation.id);
          });
        },
      ),
    );
  }

  void showMenu() async {
    showAgoraBottomSheet(context: context, items: [
      AgoraBottomSheetItem.normal(
        "Add contact",
        onTap: () async {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("/contact_search");
        },
      )
    ]);
  }
}
