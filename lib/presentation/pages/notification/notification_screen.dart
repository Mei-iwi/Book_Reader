import 'package:flutter/material.dart';

class NotificationItem {
  final String userName;
  final String time;
  final String bookName;
  final String chapter;
  final String content;

  NotificationItem({
    required this.userName,
    required this.time,
    required this.bookName,
    required this.chapter,
    required this.content,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {

  List<NotificationItem> notifications = [

    NotificationItem(

      userName: "Mai Nhật Cường",

      time: "2 minutes ago",

      bookName: "Harry Potter",

      chapter: "Chapter 31",

      content:
          "The author should release more chapters, this is taking too long! I can't wait to see what happens next in the tournament arc. The pacing is a bit slow right now but the buildup is great.",
    ),

    NotificationItem(

      userName: "Nguyễn Minh Khôi",

      time: "10 minutes ago",

      bookName: "Solo Leveling",

      chapter: "Chapter 201",

      content:
          "Sung Jin-Woo was absolutely insane in this chapter 🔥 The shadow army scene gave me goosebumps. Definitely one of the best chapters recently.",
    ),

    NotificationItem(

      userName: "Trần Gia Huy",

      time: "1 hour ago",

      bookName: "One Piece",

      chapter: "Chapter 1115",

      content:
          "The world building in One Piece never disappoints. Oda really knows how to connect old mysteries together.",
    ),
  ];

  // XÓA THÔNG BÁO
  void deleteNotification(int index) {

    setState(() {

      notifications.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text(
          "Notification deleted 🗑️",
        ),
      ),
    );
  }

  // ĐÁNH DẤU ĐÃ ĐỌC
  void markAllAsRead() {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text(
          "All notifications marked as read ✅",
        ),
      ),
    );
  }

  // HIỆN CHI TIẾT
  void showDetail(NotificationItem item) {

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),

          title: Text(
            item.bookName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SingleChildScrollView(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisSize: MainAxisSize.min,

              children: [

                Text(
                  item.chapter,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  item.content,
                  style: const TextStyle(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Close",
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(

        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(

          icon: const Icon(
            Icons.chevron_left,
            color: Colors.black,
            size: 30,
          ),

          onPressed: () =>
              Navigator.pop(context),
        ),

        title: const Text(

          "Notification",

          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [

          IconButton(

            icon: const Icon(
              Icons.check,
              color: Colors.black,
              size: 28,
            ),

            onPressed: markAllAsRead,
          ),
        ],
      ),

      body: notifications.isEmpty

          ? const Center(
              child: Text(
                "No notifications 🔔",
              ),
            )

          : ListView.builder(

              padding: const EdgeInsets.all(16),

              itemCount: notifications.length,

              itemBuilder: (context, index) {

                final item =
                    notifications[index];

                return GestureDetector(

                  onTap: () {

                    showDetail(item);
                  },

                  child: Container(

                    margin:
                        const EdgeInsets.only(
                      bottom: 16,
                    ),

                    padding:
                        const EdgeInsets.all(16),

                    decoration: BoxDecoration(

                      color: const Color(
                        0xFFE0F7FA,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),

                      border: Border.all(
                        color:
                            Colors.cyan.shade100,
                      ),

                      boxShadow: [

                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.05),

                          blurRadius: 10,

                          offset:
                              const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        // HEADER
                        Row(

                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,

                          children: [

                            Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(

                                  item.userName,

                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                Text(

                                  item.time,

                                  style:
                                      TextStyle(
                                    fontSize: 14,
                                    color: Colors
                                        .grey
                                        .shade600,
                                  ),
                                ),
                              ],
                            ),

                            IconButton(

                              icon: const Icon(
                                Icons
                                    .delete_outline,
                                color: Colors.red,
                              ),

                              onPressed: () {

                                deleteNotification(
                                  index,
                                );
                              },
                            ),
                          ],
                        ),

                        const Divider(
                          height: 24,
                        ),

                        // BOOK INFO
                        Text(

                          item.bookName,

                          style: const TextStyle(
                            fontSize: 18,
                            color:
                                Color(0xFF00838F),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        Text(

                          item.chapter,

                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // CONTENT
                        Text(

                          item.content,

                          maxLines: 3,
                          overflow:
                              TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // REPLY ICON
                        const Align(

                          alignment:
                              Alignment.centerRight,

                          child: Icon(
                            Icons.reply,
                            color: Color(
                              0xFF69F0AE,
                            ),
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}