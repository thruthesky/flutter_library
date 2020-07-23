import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Returns true if [obj] is one of null, false, empty string, or 0.
bool isEmpty(obj) {
  return obj == null ||
      obj == '' ||
      obj == false ||
      obj == 0 ||
      (obj is List && obj.length == 0);
}

/// 이 함수는 Get Snackbar 를 표시하는 것으로 범용적이지 못하다.
/// - 그러므로 다른 곳으로 이동한다.
Map<String, String> getErorrInfo(e) {
  print('====> handleError($e)');
  if (isEmpty(e)) return null;

  if (e is PlatformException) {
    print('======> Platform Exception');
    print(e);
    print(e.code);
    print(e.message);
    print(e.details);
    return {'title': 'PlatformException', 'content': e.details};
  } else if (e is String) {
    print('e is string');
    return {
      'title': 'Error',
      'content': e,
    };
  } else {
    print('=================> Warning: What is it? ${e.runtimeType}');
    return {
      'title': 'Error: ${e.runtimeType}',
      'content': e.toString(),
    };
  }
}

/// README 참고
///
/// 이 함수는 Get Snackbar 를 표시하는 것으로 범용적이지 못하다.
/// - 그러므로 다른 곳으로 이동한다.
// handleError(e) {
//   var error = getErorrInfo(e);
//   snackBar(error['title'], error['content']);
//   return null;
// }

// /// 이 함수는 Get Snackbar 를 표시하는 것으로 범용적이지 못하다.
// /// - 그러므로 다른 곳으로 이동한다.
// snackBar(title, body) {
//   Get.snackbar(
//     title,
//     body,
//     instantInit: true,
//   );
// }

// /// SharedPreferences 에 저장
// Future<bool> setSharedString(String key, dynamic value) async {
//   if (value is String && value == null) {
//     // do nothing
//   } else {
//     value = value.toString();
//   }
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.setString(key, value);
// }

// /// SharedPreferences 에서 정보 가져오기
// Future<String> getSharedString(String key) async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString(key);
// }

dynamic routerArguments(context) {
  return ModalRoute.of(context).settings.arguments;
}

/// 하나의 배열(List)를 여러개의 작은 배열로 나누는 함수
/// ```dart
/// List<dynamic> chunks = chunk(files, batch);
/// for (List<String> c in chunks) print(c);
/// ```
List<T> chunk<T>(List list, int chunkSize) {
  List<dynamic> chunks = [];
  int len = list.length;
  for (var i = 0; i < len; i += chunkSize) {
    int size = i + chunkSize;
    chunks.add(list.sublist(i, size > len ? len : size));
  }
  return chunks;
}

/// 문자 열 중에서 마지막에 나타나는 문자열을 특정 문자열로 변경한다.
///
/// 예) replaceLast('abcdefg abcdefg', 'abc', 'ABC'); // 결과 abcdefg ABCefg
///
/// dart 문자열 함수에는 [replaceAll] 과 [replaceFrist] 는 있는데 replaceLast 가 없다.
String replaceLast(String string, String from, String to) {
  int lastIndex = string.lastIndexOf(from);
  if (lastIndex < 0) return string;
  String tail = string.substring(lastIndex).replaceFirst(from, to);
  return string.substring(0, lastIndex) + tail;
}

/// 오늘 날짜이면 시/분을 리턴하고, 어제 이전의 날짜면 년/월/일을 리턴한다.
/// Display short date
/// If it is today, then it dispays YYYY-MM-DD HH:II AP
/// If not, YY-MM-DD will be returned.
/// @param stamp unix timestamp
String shortDate(int stamp) {
  var _today = DateTime.now();

  /// 오늘 날짜
  var _date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);

  /// 입력된 날짜
  var _dt = _date.toString();

  /// 입력된 날짜를 문자열로 변경

  /// 입력된 날짜가 오늘 날짜이면, 시/분을 리턴
  if (_date.year == _today.year &&
      _date.month == _today.month &&
      _date.day == _today.day) {
    return _dt.substring(11, 16);
  } else {
    /// 아니면, 년/월/일을 리턴
    return _dt.substring(0, 10);
  }
}

/// 문자열의 일부를 리턴한다.
///
/// [str] 원본 문자열
/// [startIndex] 리턴 할 시작 점
/// [len] 글 길이
///
/// Dart 의 [String.substring] 은 글자 수가 끝 길이 보다 크면, 에러가 난다.
///
/// 리턴 할 값이 없으면 빈 문자열을 리턴한다.
String substr(String str, int startIndex, [int len = 0]) {
  if (str == null || str.length == 0) return '';
  if (startIndex >= str.length) return '';
  int endIndex = 0;
  if (len == 0) {
    endIndex = str.length;
  } else {
    endIndex = startIndex + len;
  }
  if (endIndex >= str.length) endIndex = str.length;
  // print('str.lenth: ${str.length}, len: $len, endINdex: $endIndex');
  return str.substring(startIndex, endIndex);
}

/// 문자열에서 URL 을 추출하여 Set 으로 리턴
///
/// Return urls in a string
///
///   - ignores url inside of an html tag.
///
/// returns - set of string
///   - empty set if `str` is null or an empty string.
///   - set of urls with no duplicates.
///
///
Set<String> getUrls(String str) {
  if (str == null || str.isEmpty) return {};
  final urlRegEx = RegExp(
    r'''(?<!=")(\bhttps?:\/\/[\w-?&;#~=\.\/\@]+[\w\/])''',
    multiLine: true,
    caseSensitive: true,
  );
  var matches = urlRegEx.allMatches(str);
  return matches.map((m) => m.group(0)).toSet();
}

/// 입력된 문자열 [url] 이 Youtube URL 인지 판단한다.
///
bool isYoutubeUrl(String uri) {
  final url = Uri.tryParse(uri);
  if (url == null) {
    return false;
  } else {
    return url.origin.contains(RegExp(r'youtu.?be'));
  }
}

/// [url] 에서 유튜브 동영상 ID 를 추출하여 리턴한다.
///
/// - 이 함수의 코드는 [YoutubePlayer.convertUrlToId] 에서 사용되는 것이다.
/// - [url] 은 http 로 시작을 해야 한다. http 다음에는 어떤 값이 들어가더라도 상관이 업속, url 뿐만아니라 기타 값이 들어가도 된다.
///
///
///
///
/// Converts fully qualified YouTube Url to video id.
///
/// @return
///     - null 매치되는 동영상 아이디가 없으면 null 이 리턴된다.
///     - 유튜브 ID
///
/// @example
///
/// ``` dart
/// for (var p in posts) { // 글 목록에서, 각 글을 추출
///   if (p.content.indexOf('http') == -1) continue; // 내용에 http 가 없으면 패스
///   if (p.content.indexOf('youtu') == -1) continue; // 내용에 youtu 가 없으면 패스
///   final String url = 'http' + p.content.split('http').last; // 내용 중에서 http 로 시작하는 부분을 골라 남
///   final videoId = convertUrlToId(url); // 유튜브 ID 를 가져 옴
String getYoutubeIdFromUrl(String url, {bool trimWhitespaces = true}) {
  assert(url?.isNotEmpty ?? false, 'Url cannot be empty');
  if (!url.contains("http") && (url.length == 11)) return url;
  if (trimWhitespaces) url = url.trim();

  for (var exp in [
    RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
  ]) {
    Match match = exp.firstMatch(url);
    if (match != null && match.groupCount >= 1) return match.group(1);
  }

  return null;
}

/// 숫자 문자열에서 천 단위로 콤마를 찍는다.
/// 10억 이상 지원 한다.
/// 숫자열에는 콤마나 쉼표가 들어 있으면 안된다.
String numberFormat(String str) {
  if (str == null) return null;
  return str.replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}

/// 문자열에 있는 HTML 태그를 모두 없앤다.
String stripTags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
  return htmlText.replaceAll(exp, '');
}

/// 밑에서 올라오�� 선택 박���
///
/// 주의) Bottom Sheet 위젯을 사용하는 것이 아니���, ListTile 로 직접 만든 것이다.
///
/// 각 항목마다 onTap 콜백이 호출된다.
///
/// 예제)
/// ``` dart
///   bottomSheet(context, [
///     {
///       'icon': Icons.photo_camera,
///       'text': t('Take photo from camera'),
///       'onTap': () => upload(context, ImageSource.camera.index),
///     },
///     {
///       'icon': Icons.photo_album,
///       'text': t('Take photo from Gallary'),
///       'onTap': () => upload(context, ImageSource.gallery.index),
///     },
///     {
///       'icon': Icons.close,
///       'text': t('cancel'),
///       'onTap': () {
///         Navigator.pop();
///        }
///     },
///   ]);
/// ```
bottomSheet(context, List<Map<String, dynamic>> items) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Container(
          child: Wrap(
            children: <Widget>[
              for (var item in items)
                new ListTile(
                  leading: new Icon(item['icon']),
                  title: new Text(item['text']),
                  onTap: item['onTap'],
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// `Generate Random Strings`
///
/// 랜덤 문자열을 생성한다.
String randomString({int len = 8, String prefix}) {
  const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
  var t = '';
  for (var i = 0; i < len; i++) {
    t += charset[(Random().nextInt(charset.length))];
  }
  if (prefix != null && prefix.isNotEmpty) t = prefix + t;
  return t;
}

/// Generates a positive random integer uniformly distributed on the range
/// from [min], inclusive, to [max], exclusive.
int randomInt(int min, int max) {
  final _random = new Random();
  return min + _random.nextInt(max - min);
}

/// 플러터의 맵은 배열을 루프하는 경우, 인덱스를 알 수 없다.
/// 아래 함수는 핸들러에 인덱스와 값을 리턴한다.
List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }
  return result;
}

/// 특정 시간에 한번 만 실행하는 함수
/// 예를 들어
///   - 1분에 한 번 만 실행하려는 경우,
///   - 12시 정각에 한 번 실행 하려고 하는데, 11시 59분 59초에 실행하려고 했다면,
///   - 12시 정각에 실행되지 않고, 12시 0분 59초에 실행되는 것으로 바뀐다.
///   - 또 12시 0분 59초가 되기 전인, 12시 0분 30초에 실행 하려고 했다면,
///   - 12시 1분 30초로 실행 시간이 바뀐다.
///   - 즉, 특정 시간까지 실행을 기다리는데, 그 전에 실행하려고 한다면, 실행하려는 시간을 늦춘다.
/// 참고: https://docs.google.com/document/d/148Vk8NX_RoyNKFrQZFR0lZsBzRARUljWH4kZMb4FI7M/edit#heading=h.cjnqi31f6urg
class Debouncer {
  final Duration delay;
  Timer _timer;

  Debouncer({this.delay});

  run(Function action, {dynamic seed}) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      action(seed);
    });
  }
}

/// 단어에서 첫 문자만 대문자로 변경한다.
/// 예) word -> Word
String fcUpperCase(String str) {
  return (str ?? '').length < 1 ? '' : str[0].toUpperCase() + str.substring(1);
}

/// 특정 local 임시 폴더에 있는 모든 파일을 읽어 들인다.
Future<List<String>> loadFiles(String folderName) async {
  List<String> files = [];
  var directory = await getTemporaryDirectory();
  var dir = Directory(p.join(directory.path, folderName));
  try {
    var dirList = dir.list();
    await for (FileSystemEntity f in dirList) {
      if (f is File) {
        files.add(f.path);
      } else if (f is Directory) {}
    }
  } catch (e) {
    // print(e.toString());
  }
  return files;
}
