import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uikit_demo/demo_default.dart';

import 'show_image_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({
    super.key,
    required this.conversation,
    this.userInfo,
  });

  final ChatConversation conversation;
  final ChatUserInfo? userInfo;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final Map<String, ChatUserInfo?> _infoMap = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ChatUserInfo? _judgmentUserInfoAndUpdate(String userId) {
    if (!_infoMap.keys.contains(userId)) {
      ChatClient.getInstance.userInfoManager
          .fetchUserInfoById([userId]).then((value) {
        _infoMap[userId] = value.entries.first.value;
        setState(() {});
      }).catchError((e) {
        _infoMap.remove(userId);
      });
      return null;
    }
    return _infoMap[userId];
  }

  @override
  Widget build(BuildContext context) {
    String showName = widget.userInfo?.nickName ?? "";
    if (showName.isEmpty) showName = widget.conversation.id;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            userInfoAvatar(widget.userInfo),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                showName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color.fromRGBO(51, 51, 51, 1),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 30)
          ],
        ),
      ),
      body: SafeArea(
        child: AgoraMessagesView(
          conversation: widget.conversation,
          nicknameBuilder: (context, userId) {
            ChatUserInfo? info = _judgmentUserInfoAndUpdate(userId);
            String? nickname = info?.nickName;
            return Text(nickname ?? userId);
          },
          avatarBuilder: (context, userId) {
            ChatUserInfo? info = _judgmentUserInfoAndUpdate(userId);
            if (info == null) {
              return AgoraImageLoader.defaultAvatar();
            } else {
              return userInfoAvatar(info);
            }
          },
          onTap: (ctx, message) {
            if (message.body.type == MessageType.IMAGE) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ShowImagePage(message)));
              return true;
            } else if (message.body.type == MessageType.FILE) {
              EasyLoading.showError("No support show");
              return true;
            }
            return false;
          },
          onBubbleDoubleTap: (context, message) {
            return false;
          },
          onBubbleLongPress: (context, message) {
            return false;
          },
        ),
      ),
    );
  }
}
