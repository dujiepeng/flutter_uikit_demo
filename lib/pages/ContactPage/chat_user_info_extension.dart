import 'package:agora_chat_uikit/agora_chat_uikit.dart';

extension FirstLetter on ChatUserInfo {
  String get firstLetter {
    String first = '';
    if (nickName != null && nickName!.isNotEmpty) {
      first = nickName!.substring(0, 1).toUpperCase();
    } else {
      first = userId.substring(0, 1).toUpperCase();
    }
    if (first.codeUnitAt(0) < 65 || first.codeUnitAt(0) > 90) {
      return '#';
    }
    return first;
  }

  String get showName {
    if (nickName != null && nickName!.isNotEmpty) {
      return nickName!;
    } else {
      return userId;
    }
  }
}
