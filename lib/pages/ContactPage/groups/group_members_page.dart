import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uikit_demo/extensions/chat_user_info_extension.dart';
import 'package:flutter_uikit_demo/widgets/contact_list_widget.dart';

class GroupMembersPage extends StatefulWidget {
  const GroupMembersPage(this.group, {super.key});

  final ChatGroup group;

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  late ChatGroup _group;

  List<String> memberList = [];

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members(${_group.memberCount})'),
      ),
      body: ContactListWidget(
        trailing: (userId) {
          if (userId == _group.owner) {
            return Text(
              'Group Owner',
              style: TextStyle(color: Colors.grey[400]),
            );
          }
          return null;
        },
        onRefresh: refresh,
        userIds: memberList,
        onUserTap: (context, info) async {
          List<AgoraBottomSheetItem> list = [];
          list.add(
            AgoraBottomSheetItem.normal(
              'Add Contact',
              onTap: () async {
                return Navigator.of(context).pop(true);
              },
            ),
          );
          list.add(
            AgoraBottomSheetItem.destructive(
              'Remove from Group',
              onTap: () async {
                return Navigator.of(context).pop(false);
              },
            ),
          );
          bool ret = await showAgoraBottomSheet(
            title: info.showName,
            context: context,
            items: list,
          );
          debugPrint('ret: $ret');
        },
      ),
    );
  }

  Future<void> refresh() async {
    try {
      String cursor = '';
      List<String> list = [];
      do {
        ChatCursorResult<String> result = await ChatClient
            .getInstance.groupManager
            .fetchMemberListFromServer(_group.groupId,
                cursor: cursor, pageSize: 100);
        cursor = result.cursor ?? '';
        list.addAll(result.data);
      } while (cursor.isNotEmpty);
      list.addAll(_group.adminList ?? []);
      if (_group.owner != null) list.add(_group.owner!);
      memberList.clear();
      memberList.addAll(list);
      if (mounted) setState(() {});
    } on ChatError catch (e) {
      EasyLoading.showToast(e.toString());
    }
  }
}
