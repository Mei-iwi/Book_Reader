import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

Future<String> readfile({required String fileName}) async {
  try {
    String content = await rootBundle.loadString(fileName);
    return content;
  } catch (e) {
    debugPrint(e as String?);
    return e.toString();
  }
}

//Cần có cấu trúc dữ liệu json để phân chia tiêu đề, số content
Future<Map<String, dynamic>> readfileJson({required String filename}) async {
  try {
    String content = await rootBundle.loadString(filename);
    return jsonDecode(content) as Map<String, dynamic>;
  } catch (e) {
    throw Exception("Can't read file json $e");
  }
}
