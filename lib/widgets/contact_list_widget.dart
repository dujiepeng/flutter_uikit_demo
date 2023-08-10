import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uikit_demo/extensions/chat_user_info_extension.dart';

import '../demo_default.dart';
import '../tools/user_info_manager.dart';
import 'scroll_index_bar.dart';

class ContactListWidget extends StatefulWidget {
  const ContactListWidget({
    super.key,
    required this.userIds,
    this.onRefresh,
    this.onLoadMore,
    this.enableSelect = false,
    this.onSelect,
    this.onUserTap,
    this.trailing,
  });
  final bool enableSelect;
  final void Function(List<ChatUserInfo> list)? onSelect;
  final void Function(BuildContext context, ChatUserInfo info)? onUserTap;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoadMore;
  final Widget? Function(String userId)? trailing;

  final List<String> userIds;

  @override
  State<ContactListWidget> createState() => _ContactListWidgetState();
}

class _ContactListWidgetState extends State<ContactListWidget> {
  List<ChatUserInfo> userInfos = [];
  final double _withoutIndexHeight = 60;
  final double _includeIndexHeight = 90;
  final Map<String, int> _groupOffsetMap = {};
  final List<ChatUserInfo> selectList = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        widget.onLoadMore?.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ContactListWidget oldWidget) {
    _fetchInfo();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              widget.onUserTap?.call(context, info);
            }
          },
          child: ContactCell(
            info,
            selected: selected,
            showHeader: showHeader,
            enableSelect: widget.enableSelect,
            trailing: widget.trailing?.call(info.userId),
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

    if (widget.onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: content,
      );
    }

    return content;
  }

  Future<void> _fetchInfo() async {
    try {
      Map<String, ChatUserInfo> userMap =
          await UserInfoManager.getUserInfoList(widget.userIds);

      userInfos.clear();
      userInfos.addAll(userMap.values);
      userInfos.sort((a, b) => a.showName.compareTo(b.showName));
      // 得到是字母的列表。
      List<ChatUserInfo> alphabetList =
          userInfos.where((element) => element.isAlphabet()).toList();
      // 得到非字母列表。
      userInfos.removeWhere((element) => element.isAlphabet());
      // 将字母列表插入到非字母列表中。
      userInfos.insertAll(0, alphabetList);
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
  final Widget? trailing;
  const ContactCell(
    this.contact, {
    this.selected = false,
    this.showHeader = false,
    this.enableSelect = false,
    this.trailing,
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
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        trailing ?? Container(),
        const SizedBox(width: 10),
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
