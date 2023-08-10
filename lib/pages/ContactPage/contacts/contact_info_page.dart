import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../demo_default.dart';
import '../../../widgets/custom_button.dart';

class ContactInfoPage extends StatefulWidget {
  const ContactInfoPage(this.userInfo, {super.key});

  final ChatUserInfo userInfo;

  @override
  State<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends State<ContactInfoPage> {
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
            iconTheme: IconThemeData(color: Colors.grey[800]),
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
                  Widget dialog = AgoraDialog.normal(
                    title: 'Delete Contact',
                    subTitle: 'Are you sure you want to delete this contact?',
                    items: [
                      AgoraDialogItem.cancel(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      AgoraDialogItem.confirm(
                        onTap: (_) async {
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
                        },
                      )
                    ],
                  );
                  showDialog(
                    context: context,
                    builder: (context) {
                      return dialog;
                    },
                  );
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
    try {
      Map<String, ChatUserInfo> map = await ChatClient
          .getInstance.userInfoManager
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
    } catch (e) {
      debugPrint(e.toString());
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
