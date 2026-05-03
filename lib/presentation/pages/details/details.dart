import 'package:book_reader/core/widgets/ShareFunction/checkImage.dart';
import 'package:book_reader/presentation/pages/reader/reader.dart';
import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final String title;
  final String url;
  final int value;
  final int total;
  final String assetPath;
  final String author;
  final int views;

  const Details({
    super.key,
    required this.title,
    required this.url,
    required this.value,
    required this.total,
    required this.assetPath,
    required this.author,
    required this.views,
  });

  @override
  State<StatefulWidget> createState() => _Details();
}

class _Details extends State<Details> {
  bool like = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Book Details",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                like = !like;
              });
            },
            icon: Icon(
              like ? Icons.favorite_sharp : Icons.favorite_border_sharp,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(strokeAlign: 1),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: (checkSourceImage(urlImage: widget.url)
                          ? AssetImage(widget.url)
                          : NetworkImage(
                              widget.url.replaceFirst('http://', 'https://'),
                            )),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.title,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Author: ${widget.author}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  More(
                    icon: Icons.star,
                    color: Colors.amber,
                    number: 5.0,
                    content: 'RATING',
                  ),
                  More(
                    icon: Icons.remove_red_eye,
                    color: Colors.grey,
                    number: 72,
                    content: 'Views',
                  ),
                  More(
                    icon: Icons.file_download_outlined,
                    color: Colors.grey,
                    number: 10,
                    content: 'DOWNLOADED',
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Reader(
                        value: 1,
                        total: 3636,
                        title: widget.title,
                        assetPath:
                            'assets/sample_data/templatecontentbooks/hoang_tu_be_demo.txt',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(10),
                  backgroundColor: Colors.blue,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book, size: 30, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'READ BOOK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                      ),
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

Widget More({
  required IconData icon,
  required Color color,
  required double number,
  required String content,
}) {
  return Row(
    children: [
      Row(children: [Icon(icon, color: color)]),
      SizedBox(width: 5),
      Column(
        children: [
          Text(
            number.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(content, style: TextStyle(color: Colors.grey)),
        ],
      ),
    ],
  );
}
