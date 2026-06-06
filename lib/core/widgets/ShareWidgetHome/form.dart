import 'package:flutter/material.dart';

class FormSearch extends StatefulWidget {
  final String text;
  final TextEditingController? controller;
  final VoidCallback func;

  const FormSearch({
    super.key,
    required this.text,
    required this.controller,
    required this.func,
  });

  @override
  State<StatefulWidget> createState() => _FormSearch();
}

class _FormSearch extends State<FormSearch> {
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
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => widget.func(),
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
