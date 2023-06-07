import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/highlight_list_tile.dart';
import '../../../widgets/number_list_tile.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo(this.group, {super.key});
  final ChatGroup group;
  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  late ChatGroup _group;
  bool _mute = false;
  @override
  void initState() {
    super.initState();
    _group = widget.group;
    fetchGroupInfo();
  }

  @override
  Widget build(BuildContext context) {
    Widget buttons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        inviteBtn(),
        const SizedBox(width: 36),
        chatBtn(),
      ],
    );

    List<Widget> list = [];
    list.add(const Icon(Icons.group, size: 80));
    list.add(const Divider(height: 8, color: Colors.transparent));
    Widget texts = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _group.name ?? _group.groupId,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const Divider(height: 8, color: Colors.transparent),
        Text(
          'Group ID: ${_group.groupId}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const Divider(height: 8, color: Colors.transparent),
        ...() {
          List<Widget> list = [];
          if ((_group.description ?? '').isNotEmpty) {
            list.add(
              Text(
                _group.description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            );
            list.add(const Divider(height: 20, color: Colors.transparent));
          } else {
            list.add(const Divider(height: 12, color: Colors.transparent));
          }
          return list;
        }(),
      ],
    );
    texts = Container(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: texts,
    );
    list.add(texts);

    list.add(buttons);
    list.add(const Divider(height: 20, color: Colors.transparent));
    list.addAll([
      memberWidget(),
      muteNotificationWidget(),
      () {
        if ((_group.permissionType ?? ChatGroupPermissionType.Member) ==
            ChatGroupPermissionType.Owner) {
          return destroyGroupWidget();
        } else {
          return leaveGroupWidget();
        }
      }(),
    ]);

    Widget content = ListView(
      children: list,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(
              Icons.navigate_before,
              color: Color.fromRGBO(51, 51, 51, 1),
              size: 40,
            ),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: content,
    );
  }

  Widget inviteBtn() {
    return CustomButton(
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: const Color.fromRGBO(228, 228, 228, 1),
        ),
        child: const Icon(Icons.group_add),
      ),
      title: 'Invite',
      onTap: () {
        Navigator.pushNamed(context, '/contacts_select').then((value) {
          if (value != null) {
            List<ChatUserInfo> users = value as List<ChatUserInfo>;
            List<String> userIds = users.map((e) => e.userId).toList();
            inviteUsers(userIds);
          }
        });
      },
    );
  }

  Widget chatBtn() {
    return CustomButton(
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: const Color.fromRGBO(228, 228, 228, 1),
          ),
          child: const Icon(Icons.chat),
        ),
        title: 'Chat', onTap: () async {
      ChatConversation? conversation =
          await ChatClient.getInstance.chatManager.getConversation(
        _group.groupId,
        type: ChatConversationType.GroupChat,
      );
      pushToMessagePage(conversation!);
    });
  }

  Widget memberWidget() {
    return NumberListTile(
      'Members',
      number: _group.memberCount ?? 0,
      onTap: () {},
    );
  }

  Widget muteNotificationWidget() {
    return SwitchListTile.adaptive(
      title: const Text('Mute Notification'),
      value: _mute,
      onChanged: (value) async {
        if (mounted) {
          setState(() => _mute = value);
        }
        await ChatClient.getInstance.pushManager.setConversationSilentMode(
          conversationId: _group.groupId,
          type: ChatConversationType.GroupChat,
          param: ChatSilentModeParam.remindType(
            value ? ChatPushRemindType.NONE : ChatPushRemindType.ALL,
          ),
        );
      },
    );
  }

  Widget leaveGroupWidget() {
    return HighlightListTile(
      'Leave Group',
      onTap: () {
        debugPrint('onTap');
      },
    );
  }

  Widget destroyGroupWidget() {
    return HighlightListTile(
      'Destroy Group',
      onTap: () {
        debugPrint('onTap');
      },
    );
  }

  void fetchGroupInfo() async {
    try {
      _group = await ChatClient.getInstance.groupManager
          .fetchGroupInfoFromServer(_group.groupId);

      ChatSilentModeResult result = await ChatClient.getInstance.pushManager
          .fetchConversationSilentMode(
              conversationId: _group.groupId,
              type: ChatConversationType.GroupChat);
      if (mounted) {
        setState(() {
          _mute = result.remindType == ChatPushRemindType.NONE;
        });
      }
    } on ChatError catch (e) {
      EasyLoading.showError(e.description);
    }
  }

  void pushToMessagePage(ChatConversation conversation) {
    Map map = {};
    map['conversation'] = conversation;
    Navigator.pushNamed(context, '/message_page', arguments: map).then((value) {
      AgoraChatUIKit.of(context).conversationsController.loadAllConversations();
    });
  }

  void inviteUsers(List<String> userIds) async {
    try {
      EasyLoading.show(status: 'inviting...');
      await ChatClient.getInstance.groupManager
          .inviterUser(_group.groupId, userIds);
      EasyLoading.showSuccess('invite success');
    } on ChatError catch (e) {
      EasyLoading.showError(e.description);
    } finally {
      EasyLoading.dismiss();
    }
  }
}
