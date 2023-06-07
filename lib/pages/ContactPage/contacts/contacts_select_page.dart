import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uikit_demo/pages/ContactPage/contacts/contact_list.dart';

class ContactsSelectPage extends StatefulWidget {
  const ContactsSelectPage({super.key});

  @override
  State<ContactsSelectPage> createState() => _ContactsSelectPageState();
}

class _ContactsSelectPageState extends State<ContactsSelectPage> {
  List<ChatUserInfo> selectList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contacts'),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop(selectList);
            },
            child: UnconstrainedBox(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Builder(builder: (ctx) {
                  String text = "Invite";
                  if (selectList.isNotEmpty) {
                    text += "(${selectList.length})";
                  }
                  return Text(text,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14));
                }),
              ),
            ),
          )
        ],
      ),
      body: ContactList(
        enableSelect: true,
        onSelect: (list) {
          setState(() {
            selectList = list;
          });
        },
      ),
    );
  }
}
