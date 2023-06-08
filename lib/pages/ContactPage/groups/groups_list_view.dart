import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uikit_demo/tools/image_loader.dart';

class GroupsListView extends StatefulWidget {
  const GroupsListView({super.key});

  @override
  State<GroupsListView> createState() => _GroupsListViewState();
}

class _GroupsListViewState extends State<GroupsListView>
    with AutomaticKeepAliveClientMixin {
  List<ChatGroup> groups = [];

  @override
  void initState() {
    super.initState();
    addListener();
    fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget content = ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(top: 4, bottom: 4),
          child: ListTile(
            onTap: () {
              Navigator.pushNamed(context, '/group_info',
                      arguments: groups[index])
                  .then((value) => reloadGroups());
            },
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.grey[300],
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                ImageLoader.getImg('avatar0.png'),
              ),
            ),
            title: Text(
              groups[index].name ?? groups[index].groupId,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
      itemCount: groups.length,
      separatorBuilder: (context, index) => const Divider(
        height: 0.1,
        color: Colors.grey,
      ),
    );

    content = RefreshIndicator(
      onRefresh: fetchGroups,
      child: content,
    );
    return content;
  }

  Future<void> fetchGroups() async {
    try {
      groups = await ChatClient.getInstance.groupManager
          .fetchJoinedGroupsFromServer();
      setState(() {});
    } on ChatError catch (e) {
      EasyLoading.showError(e.description,
          duration: const Duration(seconds: 2));
    }
  }

  void reloadGroups() async {
    try {
      groups = await ChatClient.getInstance.groupManager.getJoinedGroups();
      setState(() {});
    } on ChatError {}
  }

  void addListener() {
    ChatClient.getInstance.groupManager.addEventHandler(
      'groupListenerKey',
      ChatGroupEventHandler(
        onGroupDestroyed: (groupId, groupName) {},
      ),
    );
  }

  @override
  void dispose() {
    ChatClient.getInstance.groupManager.removeEventHandler('groupListenerKey');
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
