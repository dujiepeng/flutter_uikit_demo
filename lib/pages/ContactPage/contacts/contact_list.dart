import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uikit_demo/extensions/chat_user_info_extension.dart';

import '../../../demo_default.dart';
import '../../../tools/user_info_manager.dart';
import '../../../widgets/scroll_index_bar.dart';

class ContactList extends StatefulWidget {
  const ContactList({
    super.key,
    this.enableSelect = false,
    this.onSelect,
    this.onUserTap,
  });
  final bool enableSelect;
  final void Function(List<ChatUserInfo> list)? onSelect;
  final void Function(ChatUserInfo info)? onUserTap;
  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  List<ChatUserInfo> userInfos = [];
  final double _withoutIndexHeight = 60;
  final double _includeIndexHeight = 90;
  final Map<String, int> _groupOffsetMap = {};
  final List<ChatUserInfo> selectList = [];
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

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemBuilder: (ctx, index) {
        bool showHeader = (index == 0 ||
            (index > 0 &&
                userInfos[index].firstLetter !=
                    userInfos[index - 1].firstLetter));
        ChatUserInfo info = userInfos[index];
        bool selected = selectList.contains(info);
        return InkWell(
          onTap: () {
            if (widget.enableSelect) {
              setState(() {
                if (selected) {
                  selectList.remove(info);
                } else {
                  selectList.add(info);
                }
                widget.onSelect?.call(selectList);
              });
            } else {
              widget.onUserTap?.call(info);
            }
          },
          child: ContactCell(
            info,
            selected: selected,
            showHeader: showHeader,
            enableSelect: widget.enableSelect,
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

  @override
  void dispose() {
    ChatClient.getInstance.contactManager.removeEventHandler("handlerKey");
    super.dispose();
  }

  void _addContact(String userId) async {
    Map<String, ChatUserInfo> infoMap = await ChatClient
        .getInstance.userInfoManager
        .fetchUserInfoById([userId]);
    userInfos.add(infoMap.values.first);
    setState(() {});
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
}

class ContactCell extends StatelessWidget {
  final ChatUserInfo contact;
  final bool showHeader;
  final bool selected;
  final bool enableSelect;
  const ContactCell(
    this.contact, {
    this.selected = false,
    this.showHeader = false,
    this.enableSelect = false,
    super.key,
  });

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
        enableSelect
            ? Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? const Color.fromRGBO(0, 95, 255, 1)
                    : Colors.grey[300])
            : Container(),
        const SizedBox(width: 20)
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
