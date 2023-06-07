import 'package:flutter/material.dart';

class NumberListTile extends StatelessWidget {
  const NumberListTile(
    this.title, {
    this.number = 0,
    this.onTap,
    super.key,
  });

  final String title;
  final int number;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (number > 0) {
      content = ListTile(
          title: Text(title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$number',
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(60, 66, 103, 1),
                ),
              ),
              const Icon(Icons.navigate_next, color: Colors.grey),
            ],
          ));
    } else {
      content = ListTile(title: Text(title));
    }

    content = InkWell(onTap: onTap, child: content);

    content = MergeSemantics(child: content);
    return content;
  }
}
