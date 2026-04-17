// 注: sqflite/flutter_local_notifications など native plugin に依存する部分は
// 単体 widget test では動作しないため、ここでは main() の import 健全性のみ確認する。
import 'package:flutter_test/flutter_test.dart';

import 'package:justtime/main.dart';

void main() {
  test('JustTimeApp class is available', () {
    expect(JustTimeApp, isNotNull);
  });
}
