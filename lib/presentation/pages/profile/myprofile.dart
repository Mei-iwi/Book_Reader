import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/core/widgets/ShareWidgetProfile/historyreading.dart';
import 'package:book_reader/core/widgets/ShareWidgetProfile/item.dart';
import 'package:book_reader/core/widgets/ShareWidgetProfile/wbook.dart';
import 'package:flutter/material.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<StatefulWidget> createState() => _Myprofile();
}

class _Myprofile extends State<Myprofile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: SizedBox(
                        width: 110,
                        height: 110,
                        child: CircleAvatar(
                          backgroundImage: AssetImage(Templateimage.avatar),
                        ),
                      ),
                    ),
                    SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Dữ liệu họ và tên
                        Text(
                          "Mai Nhật Cường",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        //Dữ liệu mail hoặc số điện thoại
                        Text(
                          "c2005vn@gmail.com",
                          style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 5),
                        //Xử lý chỉnh sửa
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE8F1F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Color(0xFF313F58),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    //Dữ liệu số sách đã đọc xong
                    Item(value: 0, text: "Read Books"),
                    //Dữ liệu số sách đang đọc
                    Item(value: 2, text: "Reading"),

                    //Dữ liệu số sách đã download
                    Item(value: 2, text: "Downloads"),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Favourite",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Builder(
                    builder: (context) {
                      return Row(
                        children: [
                          //Dữ liệu mẫu cho hiện thị
                          wbook(
                            context: context,
                            url: Templateimage.book1,
                            title: "HarryPotter",
                            author: 'Unknow',
                            func: () {},
                            rateFavourite: 12,
                          ),
                          wbook(
                            context: context,
                            url: Templateimage.book2,
                            title: 'Unknow',
                            author: 'Unknow',
                            func: () {},
                            rateFavourite: 14,
                          ),
                          wbook(
                            context: context,
                            url: Templateimage.book3,
                            title: 'Unknow',
                            author: 'Unknow',
                            func: () {},
                            rateFavourite: 11,
                          ),
                          wbook(
                            context: context,
                            url: Templateimage.book4,
                            title: 'Unknow',
                            author: 'Unknow',
                            func: () {},
                            rateFavourite: 900,
                          ),
                          wbook(
                            context: context,
                            url: Templateimage.book5,
                            title: 'Unknow',
                            author: 'Unknow',
                            func: () {},
                            rateFavourite: 30,
                          ),
                          wbook(
                            context: context,
                            url: Templateimage.book1,
                            title: 'Unknow',
                            author: 'Unknow',
                            func: () {},
                            rateFavourite: 25,
                          ),
                          wbook(
                            context: context,
                            url: Templateimage.book2,
                            title: 'Unknow',
                            author: 'Unknow',
                            func: () {},
                            rateFavourite: 5,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Reading History",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                SizedBox(height: 10),
                //Dữ liệu lịch sử đọc 5 sách mới nhất
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      bookReading(
                        url: Templateimage.book1,
                        name: "HarryPotter",
                        percent: 50,
                      ),
                      bookReading(
                        url: Templateimage.book4,
                        name: "Nhà giả kim",
                        percent: 90,
                      ),
                      bookReading(
                        url: Templateimage.book1,
                        name: "Hoàng tử bé",
                        percent: 40,
                      ),
                      bookReading(
                        url: Templateimage.book1,
                        name: "Điểu nhân",
                        percent: 8,
                      ),
                      bookReading(
                        url: Templateimage.book1,
                        name: "Chúa tể chiếc nhẫn",
                        percent: 75,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
