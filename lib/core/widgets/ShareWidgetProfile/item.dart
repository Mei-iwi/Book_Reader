import 'package:flutter/material.dart';

class Item extends StatefulWidget {
  final int value;
  final String text;
  const Item({super.key, required this.value, required this.text});

  @override
  State<StatefulWidget> createState() => _item();
}

// ignore: camel_case_types
class _item extends State<Item> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (value) {
        setState(() => isHover = value);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width * 0.3,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.4),
              offset: Offset(2, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              widget.value.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              widget.text,
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
