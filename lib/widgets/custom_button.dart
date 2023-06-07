import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
    this.child, {
    this.title,
    this.titleStyle = const TextStyle(color: Color.fromRGBO(102, 102, 102, 1)),
    this.onTap,
    super.key,
  });
  final Widget child;
  final String? title;
  final TextStyle? titleStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    list.add(child);

    if (title != null) {
      list.add(const Divider(height: 8, color: Colors.transparent));
      list.add(Text(title!, style: titleStyle));
    }

    Widget content = InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    );

    return content;
  }
}
