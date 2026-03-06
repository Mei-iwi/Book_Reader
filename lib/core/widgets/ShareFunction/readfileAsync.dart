import 'package:book_reader/core/widgets/ShareFunction/file.dart';
import 'package:flutter/material.dart';

Widget readFileWidget({required String filename}) {
  return FutureBuilder<String>(
    future: readfile(fileName: filename),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Text("Lỗi ${snapshot.error}");
      }
      return Text((snapshot.data ?? 'Không có dữ liệu'));
    },
  );
}
