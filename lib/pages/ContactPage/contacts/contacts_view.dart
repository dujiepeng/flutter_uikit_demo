import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

import 'contact_list_view.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({
    super.key,
  });

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ContactListView(
      onUserTap: (ctx, info) => _contactInfo(info),
    );
  }

  void _contactInfo(ChatUserInfo userInfo) {
    Navigator.pushNamed(context, '/contact_info', arguments: userInfo);
  }

  @override
  bool get wantKeepAlive => true;
}
