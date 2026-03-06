import 'package:book_reader/config/routes.dart';
import 'package:flutter/material.dart';

class Reader extends StatefulWidget {
  final int value;
  final int total;
  const Reader({super.key, required this.value, required this.total});

  @override
  State<StatefulWidget> createState() => _Reader();
}

class _Reader extends State<Reader> {
  late int newvalue = widget.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            final parentContext = context;
            showDialog(
              context: parentContext,
              builder: (dialogContext) => AlertDialog(
                title: Text(
                  "Rời khỏi trang",
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text("Bạn có muốn rời khỏi trang hiện tại"),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      await Future.delayed(const Duration(seconds: 1));

                      if (!mounted) return;

                      // ignore: use_build_context_synchronously
                      Navigator.of(parentContext, rootNavigator: true).pop();

                      Navigator.pushReplacementNamed(
                        // ignore: use_build_context_synchronously
                        parentContext,
                        AppRoute.home,
                      );
                    },
                    child: Text("Rời khỏi"),
                  ),

                  TextButton(
                    onPressed: () {
                      //Xử lý lưu bookmark ở đây
                    },
                    child: Text("Lưu bookmark rời khỏi"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Ở lại trang"),
                  ),
                ],
              ),
            );
          },
          icon: Icon(
            Icons.keyboard_arrow_down_outlined,
            size: 30,
            color: Colors.blue,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: Colors.blue),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(0),
        child: Stack(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text("Dữ liệu sách sẽ được tải lên ở đây"),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 13),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    bottomLeft: Radius.circular(100),
                  ),
                ),
                child: Text(
                  "Page $newvalue",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 0,
              child: Container(
                padding: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(100),
                            bottomRight: Radius.circular(100),
                          ),
                        ),
                        child: Icon(Icons.menu, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 5),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.circular(100),
                        ),

                        child: Icon(Icons.text_format, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              right: 20,
              child: InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(Icons.remove_red_eye, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          return Container(
            height: 70,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      (newvalue - 1 <= 0)
                          ? newvalue = widget.total
                          : newvalue -= 1;
                    });
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "Page $newvalue of ${widget.total}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      (newvalue + 1 == widget.total)
                          ? newvalue = 1
                          : newvalue += 1;
                    });
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_right,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
