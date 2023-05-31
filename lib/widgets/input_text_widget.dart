import 'package:flutter/material.dart';

class InputTextWidget extends StatefulWidget {
  const InputTextWidget({
    super.key,
    this.obscureText = false,
    this.controller,
    this.onChanged,
    this.suffixIcon,
    this.hideText,
  });

  final bool obscureText;
  final TextEditingController? controller;
  final void Function(String text)? onChanged;
  final Widget? suffixIcon;
  final String? hideText;

  @override
  State<InputTextWidget> createState() => _InputTextWidgetState();
}

class _InputTextWidgetState extends State<InputTextWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      cursorColor: Colors.blue,
      onChanged: (text) => widget.onChanged?.call(text),
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
          filled: true,
          fillColor: const Color.fromRGBO(242, 242, 242, 1),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          suffixIcon: widget.suffixIcon,
          hintText: widget.hideText,
          hintStyle: const TextStyle(color: Colors.grey)),
      obscureText: widget.obscureText,
    );
  }
}
