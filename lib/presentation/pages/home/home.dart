import 'package:book_reader/core/constants/templateImage.dart';
import 'package:book_reader/core/widgets/ShareWidgetHome/form.dart';
import 'package:book_reader/core/widgets/ShareWidgetHome/wbook.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: formSearch(
          text: 'Search',
          controller: search,
          func: () {
            debugPrint(search.text.trim());
          },
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {},
            child: CircleAvatar(
              backgroundImage: AssetImage(Templateimage.avatar),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: ListView(children: [ListTile(title: Text("Menu"))]),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Continue...', style: style()),
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
                        ),
                        wbook(
                          context: context,
                          url: Templateimage.book2,
                          title: 'Unknow',
                          author: 'Unknow',
                          func: () {},
                        ),
                        wbook(
                          context: context,
                          url: Templateimage.book3,
                          title: 'Unknow',
                          author: 'Unknow',
                          func: () {},
                        ),
                        wbook(
                          context: context,
                          url: Templateimage.book4,
                          title: 'Unknow',
                          author: 'Unknow',
                          func: () {},
                        ),
                        wbook(
                          context: context,
                          url: Templateimage.book5,
                          title: 'Unknow',
                          author: 'Unknow',
                          func: () {},
                        ),
                        wbook(
                          context: context,
                          url: Templateimage.book1,
                          title: 'Unknow',
                          author: 'Unknow',
                          func: () {},
                        ),
                        wbook(
                          context: context,
                          url: Templateimage.book2,
                          title: 'Unknow',
                          author: 'Unknow',
                          func: () {},
                        ),
                      ],
                    );
                  },
                ),
              ),
              Text('From Library', style: style()),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    //Dữ liệu mẫu cho hiện thị
                    wbook(
                      context: context,
                      url: Templateimage.book5,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book4,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book2,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book1,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book5,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book3,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book4,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                  ],
                ),
              ),
              Text('Recommendations', style: style()),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    //Dữ liệu mẫu cho hiện thị
                    wbook(
                      context: context,
                      url: Templateimage.book2,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book4,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book1,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book5,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book5,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book3,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                    wbook(
                      context: context,
                      url: Templateimage.book4,
                      title: 'Unknow',
                      author: 'Unknow',
                      func: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

TextStyle style() {
  return TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
}
