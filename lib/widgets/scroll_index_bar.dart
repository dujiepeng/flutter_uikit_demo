import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  const ScrollIndexWidget({
    this.indexBarCallBack,
    this.bgColor = Colors.transparent,
    this.floatLetterBgColor = const Color.fromRGBO(0, 95, 255, 1),
    super.key,
  });

  @override
  State<ScrollIndexWidget> createState() => _ScrollIndexWidgetState();
}

const topAlignment = 1.13;
const bottomAlignment = 1.21;

class _ScrollIndexWidgetState extends State<ScrollIndexWidget> {
  final _letterExtent = topAlignment + bottomAlignment;

  Color _textColor = Colors.black;

  double _letterOffset = 0.0;
  String _letter = '';
  bool _floatLetterHide = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> indexList = [];

    for (var i = 0; i < indexWords.length; i++) {
      bool isSelected = _letter == indexWords[i];
      indexList.add(
        Expanded(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? widget.floatLetterBgColor : widget.bgColor,
            ),
            child: Text(
              indexWords[i],
              style: TextStyle(
                  fontSize: 10, color: isSelected ? _textColor : Colors.black),
            ),
          ),
        ),
      );
    }

    double screenHeigh = MediaQuery.of(context).size.height;

    Widget content = SizedBox(
      width: 25,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: indexList,
      ),
    );

    content = GestureDetector(
      child: content,
      onVerticalDragUpdate: (details) => selectedChanged(details.localPosition),
      onVerticalDragDown: (details) => selectedChanged(details.localPosition),
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
      _textColor = Colors.black;
    });
  }

  void selectedChanged(Offset localPosition) {
    int index = getIndex(localPosition);
    String str = indexWords[index];
    if (_letter != str) {
      widget.indexBarCallBack?.call(str);
      _floatLetterHide = false;
      setState(() {
        _letterOffset =
            _letterExtent / indexWords.length * index - topAlignment;
        _textColor = Colors.white;
      });
      vibrate();
      _letter = str;
    }
  }

  Future<void> vibrate() async {
    await HapticFeedback.selectionClick();
    // await HapticFeedback.vibrate();
  }
}
