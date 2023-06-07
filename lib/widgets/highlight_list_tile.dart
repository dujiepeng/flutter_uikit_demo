import 'package:flutter/material.dart';

class HighlightListTile extends StatelessWidget {
  const HighlightListTile(this.title, {this.onTap, super.key});
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Color.fromRGBO(255, 20, 204, 1)),
      ),
      onTap: onTap,
    );
  }
}
