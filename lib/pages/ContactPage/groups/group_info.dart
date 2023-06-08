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
    list.add(InkWell(
      onTap: () {
        _group.permissionType == ChatGroupPermissionType.Owner
            ? showOwnerActionSheet()
            : showMemberActionSheet();
      },
      child: const Icon(Icons.group, size: 80),
    ));
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
      leaveOrDestroyGroupWidget(
          (_group.permissionType ?? ChatGroupPermissionType.Member) ==
              ChatGroupPermissionType.Owner),
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

  Widget leaveOrDestroyGroupWidget(bool destroy) {
    return HighlightListTile(destroy ? 'Destroy Group' : 'Leave Group',
        onTap: () {
      Widget content = AgoraDialog.normal(
        title: destroy ? "Destroy Group?" : "Leave Group?",
        subTitle: destroy
            ? "This action will destroy the group and cannot be undone."
            : "This action will leave.",
        items: [
          AgoraDialogItem.cancel(onTap: Navigator.of(context).pop),
          AgoraDialogItem.confirm(
            onTap: (_) async {
              Navigator.of(context).pop();
              try {
                EasyLoading.show();
                if (destroy) {
                  await ChatClient.getInstance.groupManager
                      .destroyGroup(_group.groupId);
                } else {
                  await ChatClient.getInstance.groupManager
                      .leaveGroup(_group.groupId);
                }
                dismiss();
              } on ChatError catch (e) {
                EasyLoading.showError(e.description);
              } finally {
                EasyLoading.dismiss();
              }
            },
          ),
        ],
      );
      showDialog(context: context, builder: (_) => content);
    });
  }

  void dismiss() {
    Navigator.of(context).pop();
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

  void showOwnerActionSheet() {
    AgoraBottomSheet(items: [
      AgoraBottomSheetItem(
        'Change Group Name',
        onTap: () {
          Navigator.of(context).pop();
          showChangeInfo(true);
        },
      ),
      AgoraBottomSheetItem(
        'Change Group Description',
        onTap: () {
          Navigator.of(context).pop();
          showChangeInfo(false);
        },
      ),
      AgoraBottomSheetItem(
        'Copy Group ID',
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    ]).show(context);
  }

  void showMemberActionSheet() {
    AgoraBottomSheet(items: [
      AgoraBottomSheetItem(
        'Copy Group ID',
        onTap: () {},
      ),
    ]).show(context);
  }

  void showChangeInfo(bool isGroupName) {
    Widget content = AgoraDialog.input(
      hiddenList: isGroupName ? const ['Group Name'] : ['Group Description'],
      title: isGroupName ? 'Change group name' : 'Change group description',
      items: [
        AgoraDialogItem.cancel(
          onTap: Navigator.of(context).pop,
        ),
        AgoraDialogItem.confirm(
          onTap: (labels) async {
            Navigator.of(context).pop();
            try {
              EasyLoading.show(status: 'Changing...');
              if (isGroupName) {
                await ChatClient.getInstance.groupManager
                    .changeGroupName(_group.groupId, labels![0]);
              } else {
                await ChatClient.getInstance.groupManager
                    .changeGroupDescription(_group.groupId, labels![0]);
              }
              ChatGroup? group = await ChatClient.getInstance.groupManager
                  .getGroupWithId(_group.groupId);
              _group = group!;
              setState(() {});
            } on ChatError catch (e) {
              EasyLoading.showError(e.description);
            } finally {
              EasyLoading.dismiss();
            }
          },
        ),
      ],
    );

    showDialog(context: context, builder: (_) => content);
  }
}
