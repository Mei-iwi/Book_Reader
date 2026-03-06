import 'package:flutter/material.dart';

Widget myBanner({required String urlBanner, required String text}) {
  return Builder(
    builder: (context) {
      return SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                image: DecorationImage(
                  image: AssetImage(urlBanner),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () async {
                  final overlay =
                      Overlay.of(context).context.findRenderObject()
                          as RenderBox;
                  //final box = context.findRenderObject() as RenderBox;

                  final selected = await showMenu<String>(
                    context: context,
                    position: RelativeRect.fromSize(
                      const Rect.fromLTWH(9999, 50, 0, 0),
                      overlay.size,
                    ),
                    items: const [
                      PopupMenuItem(
                        value: 'about',
                        child: Row(
                          children: [
                            Icon(Icons.people_alt),
                            SizedBox(width: 5),
                            Text("Về chúng tôi"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'contact',
                        child: Row(
                          children: [
                            Icon(Icons.contact_mail),
                            SizedBox(width: 5),
                            Text("Liên hệ"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'support',
                        child: Row(
                          children: [
                            Icon(Icons.support),
                            SizedBox(width: 5),
                            Text("Hỗ trợ"),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (selected == null) return;
                  if (selected == 'about') {
                    //Xử lý chuyển hướng sang about
                    debugPrint("Đã chọn $selected");
                  } else if (selected == 'contact') {
                    //Xử lý chuyển hướng sang contact
                    debugPrint("Đã chọn $selected");
                  }
                  if (selected == 'support') {
                    //Xử lý chuyển hướng sang support
                    debugPrint("Đã chọn $selected");
                  }
                },

                icon: Icon(Icons.more_horiz, color: Colors.white),
              ),
            ),
            Center(
              child: Text(
                text,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    },
  );
}
