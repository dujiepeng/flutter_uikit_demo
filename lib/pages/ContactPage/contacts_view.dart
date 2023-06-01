import 'package:agora_chat_uikit/agora_chat_uikit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uikit_demo/pages/ContactPage/chat_user_info_extension.dart';
import 'package:flutter_uikit_demo/widgets/scroll_index_bar.dart';
import 'package:flutter_uikit_demo/tools/user_info_manager.dart';

import '../../demo_default.dart';
import 'contact_info.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView>
    with AutomaticKeepAliveClientMixin {
  List<ChatUserInfo> userInfos = [];
  final double _withoutIndexHeight = 60;
  final double _includeIndexHeight = 90;
  final Map<String, int> _groupOffsetMap = {};

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    ChatClient.getInstance.contactManager.addEventHandler(
        "handlerKey",
        ContactEventHandler(
          onContactAdded: (userId) {
            _addContact(userId);
          },
          onContactDeleted: (userId) {
            userInfos.removeWhere((element) => element.userId == userId);
            setState(() {});
          },
        ));
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      List<String> list = await ChatClient.getInstance.contactManager
          .getAllContactsFromServer();
      Map<String, ChatUserInfo> userMap =
          await UserInfoManager.getUserInfoList(list);

      userInfos.clear();
      userInfos.addAll(userMap.values);

      userInfos.sort((a, b) => a.showName.compareTo(b.showName));

      _groupOffsetMap.clear();
      var groupOffset = 0;
      for (var i = 0; i < userInfos.length; i++) {
        bool showIndex = (i == 0 ||
            (i > 0 &&
                userInfos[i].firstLetter != userInfos[i - 1].firstLetter));
        if (showIndex) {
          _groupOffsetMap[userInfos[i].firstLetter] = groupOffset;
          groupOffset = groupOffset + _includeIndexHeight.toInt();
        } else {
          groupOffset = groupOffset + _withoutIndexHeight.toInt();
        }
      }
      setState(() {});
    } on ChatError catch (e) {
      EasyLoading.showError(e.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget content = ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemBuilder: (ctx, index) {
        bool showHeader = (index == 0 ||
            (index > 0 &&
                userInfos[index].firstLetter !=
                    userInfos[index - 1].firstLetter));
        ChatUserInfo info = userInfos[index];
        return InkWell(
          onTap: () => _contactInfo.call(ctx, info),
          child: ContactCell(
            info,
            showHeader: showHeader,
          ),
        );
      },
      itemCount: userInfos.length,
    );

    content = Stack(
      children: [
        content,
        ScrollIndexWidget(
          indexBarCallBack: (str) {
            debugPrint("indexBarCallBack $str");
            if (_groupOffsetMap.containsKey(str)) {
              double offset = _groupOffsetMap[str]!.toDouble();
              if (offset > _scrollController.position.maxScrollExtent) {
                offset = _scrollController.position.maxScrollExtent;
              }
              _scrollController.jumpTo(offset);
            }
          },
        ),
      ],
    );

    content = RefreshIndicator(
      onRefresh: _loadContacts,
      child: content,
    );

    return content;
  }

  void _contactInfo(BuildContext ctx, ChatUserInfo userInfo) {
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (ctx) {
        return ContactInfo(userInfo);
      },
    )).then((value) {
      if (value is Map) {
        String userId = value.keys.first as String;
        String str = value[userId];
        if (str == "delete") {
          userInfos.remove(userInfo);
          setState(() {});
        }
      }
    });
  }

  void _addContact(String userId) async {
    Map<String, ChatUserInfo> infoMap = await ChatClient
        .getInstance.userInfoManager
        .fetchUserInfoById([userId]);
    userInfos.add(infoMap.values.first);
    setState(() {});
  }

  @override
  void dispose() {
    ChatClient.getInstance.contactManager.removeEventHandler("handlerKey");
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class ContactCell extends StatelessWidget {
  final ChatUserInfo contact;
  final bool showHeader;
  const ContactCell(this.contact, {this.showHeader = false, super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      children: [
        Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.only(left: 10),
          child: userInfoAvatar(contact),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              contact.showName,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );

    if (showHeader) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20,
            color: Colors.grey[300],
            alignment: Alignment.centerLeft,
            child: Text(
              ' ${contact.firstLetter}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Divider(height: 10, color: Colors.transparent),
          content,
          const Divider(height: 10),
        ],
      );
    } else {
      content = Column(
        children: [
          content,
          const Divider(height: 10),
        ],
      );
    }

    return content;
  }
}
