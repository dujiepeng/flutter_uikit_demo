import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../demo_default.dart';
import '../../../widgets/custom_button.dart';

class ContactInfo extends StatefulWidget {
  const ContactInfo(this.userInfo, {super.key});

  final ChatUserInfo userInfo;

  @override
  State<ContactInfo> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {
  bool _mute = false;
  ChatUserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _userInfo = widget.userInfo;
    _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    String showName = _userInfo?.nickName ?? widget.userInfo.userId;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
            expandedHeight: 320,
            floating: true,
            pinned: true,
            snap: true,
            centerTitle: true,
            leading: IconButton(
                icon: const Icon(
                  Icons.navigate_before,
                  color: Color.fromRGBO(51, 51, 51, 1),
                  size: 40,
                ),
                onPressed: () => Navigator.of(context).pop()),
            flexibleSpace: FlexibleSpaceBar(
                background: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 90, color: Colors.transparent),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: userInfoAvatar(_userInfo),
                  ),
                  const Divider(height: 12, color: Colors.transparent),
                  Text(
                    showName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Divider(height: 8, color: Colors.transparent),
                  Text(
                    "AgoraID: ${widget.userInfo.userId}",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                  const Divider(height: 20, color: Colors.transparent),
                  CustomButton(
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: const Color.fromRGBO(228, 228, 228, 1),
                      ),
                      child: const Icon(Icons.chat),
                    ),
                    title: 'Chat',
                    onTap: () async {
                      var conversation = await ChatClient
                          .getInstance.chatManager
                          .getConversation(widget.userInfo.userId);
                      pushToMessagePage(conversation!);
                    },
                  ),
                ],
              ),
            )),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SwitchListTile.adaptive(
                title: const Text('Mute Notifications'),
                value: _mute,
                onChanged: (value) async {
                  if (mounted) {
                    setState(() => _mute = value);
                  }
                  await ChatClient.getInstance.pushManager
                      .setConversationSilentMode(
                    conversationId: widget.userInfo.userId,
                    type: ChatConversationType.Chat,
                    param: ChatSilentModeParam.remindType(value
                        ? ChatPushRemindType.NONE
                        : ChatPushRemindType.ALL),
                  );
                },
              ),
              const Divider(height: 8),
              InkWell(
                onTap: () {
                  AgoraDialog(
                    titleLabel: showName,
                    content: const Text(
                      "Delete this contact.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    items: [
                      AgoraDialogItem(
                          label: "Cancel",
                          onTap: () => Navigator.of(context).pop()),
                      AgoraDialogItem(
                          label: "Confirm",
                          labelStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                          backgroundColor: const Color.fromRGBO(17, 78, 255, 1),
                          onTap: () async {
                            Navigator.of(context).pop();
                            ChatClient.getInstance.contactManager
                                .deleteContact(widget.userInfo.userId)
                                .then((value) {
                              Navigator.of(context)
                                  .pop({widget.userInfo.userId: "delete"});
                            }).catchError((e) {
                              String str = (e as ChatError).description;
                              EasyLoading.showError(str);
                            });
                          })
                    ],
                  ).show(context);
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 13, 20, 13),
                  child: Row(
                    children: [
                      Center(
                          child: Text(
                        "Delete Contact",
                        style: TextStyle(
                            color: Color.fromRGBO(255, 20, 204, 1),
                            fontWeight: FontWeight.w600),
                      )),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _loadUserInfo() async {
    Map<String, ChatUserInfo> map = await ChatClient.getInstance.userInfoManager
        .fetchUserInfoById([widget.userInfo.userId], expireTime: 0);
    if (map.isNotEmpty) {
      _userInfo = map.values.first;
    }
    ChatSilentModeResult result = await ChatClient.getInstance.pushManager
        .fetchConversationSilentMode(
            conversationId: widget.userInfo.userId,
            type: ChatConversationType.Chat);

    if (mounted) {
      setState(() {
        _mute = result.remindType == ChatPushRemindType.NONE;
      });
    }
  }

  void pushToMessagePage(ChatConversation conversation) {
    Map map = {};
    map['conversation'] = conversation;
    if (_userInfo != null) {
      map['userInfo'] = _userInfo;
    }
    Navigator.pushNamed(context, '/message_page', arguments: map).then((value) {
      AgoraChatUIKit.of(context).conversationsController.loadAllConversations();
    });
  }
}
