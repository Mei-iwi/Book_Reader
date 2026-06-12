import 'package:flutter/material.dart';

Widget myBanner({required String urlBanner, required String text}) {
  return Builder(
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      final screenHeight = mediaQuery.size.height;
      final screenWidth = mediaQuery.size.width;
      final keyboardVisible = mediaQuery.viewInsets.bottom > 0;
      final bannerHeight = (screenHeight * (keyboardVisible ? 0.22 : 0.32))
          .clamp(150.0, 280.0);
      final titleSize = (screenWidth * 0.075).clamp(22.0, 30.0);

      return SizedBox(
        width: double.infinity,
        height: bannerHeight,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
