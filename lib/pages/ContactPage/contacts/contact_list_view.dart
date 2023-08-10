import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uikit_demo/widgets/contact_list_widget.dart';

class ContactListView extends StatefulWidget {
  const ContactListView({
    super.key,
    this.enableSelect = false,
    this.onSelect,
    this.onUserTap,
    this.trailing,
  });

  final bool enableSelect;
  final void Function(List<ChatUserInfo> list)? onSelect;
  final void Function(BuildContext ctx, ChatUserInfo info)? onUserTap;
  final Widget? Function(String userId)? trailing;

  @override
  State<ContactListView> createState() => _ContactListViewState();
}

class _ContactListViewState extends State<ContactListView> {
  List<String> userIds = [];
  @override
  void initState() {
    super.initState();
    ChatClient.getInstance.contactManager.addEventHandler(
      "handlerKey",
      ContactEventHandler(
        onContactAdded: (userId) {
          setState(() {
            userIds.add(userId);
          });
        },
        onContactDeleted: (userId) {
          setState(() {
            userIds.removeWhere((element) => element == userId);
          });
        },
      ),
    );
    _loadContacts();
  }

  @override
  void dispose() {
    ChatClient.getInstance.contactManager.removeEventHandler("handlerKey");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContactListWidget(
      onSelect: widget.onSelect,
      userIds: userIds,
      onUserTap: widget.onUserTap,
      enableSelect: widget.enableSelect,
      onRefresh: _loadContacts,
      trailing: widget.trailing,
    );
  }

  Future<void> _loadContacts() async {
    try {
      List<String> users = await ChatClient.getInstance.contactManager
          .getAllContactsFromServer();
      userIds = users;
      if (mounted) setState(() => userIds = users);
    } on ChatError catch (e) {
      EasyLoading.showError(e.description);
    }
  }
}
