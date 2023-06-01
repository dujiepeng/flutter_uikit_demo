import 'dart:math' as math;
import 'package:flutter/material.dart';

const indexWords = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '#',
];

class ScrollIndexWidget extends StatefulWidget {
  final void Function(String str)? indexBarCallBack;
  final Color floatLetterBgColor;
  final Color bgColor;

  const ScrollIndexWidget(
      {this.indexBarCallBack,
      this.bgColor = Colors.black26,
      this.floatLetterBgColor = Colors.grey,
      super.key});

  @override
  State<ScrollIndexWidget> createState() => _ScrollIndexWidgetState();
}

class _ScrollIndexWidgetState extends State<ScrollIndexWidget> {
  final _letterExtent = 1.14 + 1.21;
  Color _bgColor = Colors.transparent;
  Color _textColor = Colors.black;

  double _letterOffset = 0.0;
  String _letter = 'A';
  bool _floatLetterHide = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> indexList = [];
    for (var i = 0; i < indexWords.length; i++) {
      indexList.add(Expanded(
        child: Text(
          indexWords[i],
          style: TextStyle(fontSize: 10, color: _textColor),
        ),
      ));
    }

    double screenHeigh = MediaQuery.of(context).size.height;

    Widget content = Container(
      width: 25,
      color: _bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: indexList,
      ),
    );

    content = GestureDetector(
      child: content,
      onVerticalDragUpdate: (details) {
        int index = getIndex(details.localPosition);
        String str = indexWords[index];
        if (_letter == str) {
          return;
        }
        _letter = str;
        setState(() {
          _letterOffset = _letterExtent / indexWords.length * index - 1.14;
        });
        widget.indexBarCallBack?.call(str);
      },
      onVerticalDragDown: (details) {
        int index = getIndex(details.localPosition);
        String str = indexWords[index];
        _letter = str;
        widget.indexBarCallBack?.call(str);
        _floatLetterHide = false;
        setState(() {
          _letterOffset = _letterExtent / indexWords.length * index - 1.14;
          _bgColor = widget.bgColor;
          _textColor = Colors.white;
        });
      },
      onTapUp: (details) {
        cancelTap();
      },
      onLongPressEnd: (details) {
        cancelTap();
      },
      onVerticalDragEnd: (details) {
        cancelTap();
      },
    );

    Widget floatLetterWidget = _floatLetterHide
        ? Container()
        : Stack(
            alignment: const Alignment(-0.2, 0),
            children: [
              Container(
                color: widget.floatLetterBgColor,
                width: 30,
                height: 20,
              ),
              Transform.rotate(
                angle: -math.pi / 2,
                child: Icon(
                  Icons.place,
                  size: 60,
                  color: widget.floatLetterBgColor,
                ),
              ),
              Text(
                _letter,
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),
            ],
          );

    floatLetterWidget = Container(
      alignment: Alignment(0, _letterOffset),
      width: 80,
      child: floatLetterWidget,
    );

    content = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        floatLetterWidget,
        content,
      ],
    );

    content = Positioned(
      width: 125,
      top: screenHeigh / 8,
      height: screenHeigh / 2,
      right: 0,
      child: content,
    );

    return content;
  }

  int getIndex(Offset localPosition) {
    double y = localPosition.dy;
    var itemHeight = MediaQuery.of(context).size.height / 2 / indexWords.length;
    return (y ~/ itemHeight).clamp(0, indexWords.length - 1);
  }

  void cancelTap() {
    _floatLetterHide = true;
    _letter = '';
    _letterOffset = 0;
    setState(() {
      _bgColor = Colors.transparent;
      _textColor = Colors.black;
    });
  }
}
