import 'package:flutter/material.dart';

class formSearch extends StatefulWidget {
  final String text;
  final TextEditingController? controller;
  final VoidCallback func;

  const formSearch({
    super.key,
    required this.text,
    required this.controller,
    required this.func,
  });

  @override
  State<StatefulWidget> createState() => _formSearch();
}

class _formSearch extends State<formSearch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 40,
            child: TextFormField(
              controller: widget.controller,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(1000),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(1000),

                  borderSide: BorderSide(color: Colors.grey),
                ),
                label: Text(widget.text),
                suffixIcon: IconButton(
                  onPressed: widget.func,
                  icon: Icon(Icons.search, color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
