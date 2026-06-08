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
    return SizedBox(
      height: 42,
      child: TextFormField(
        controller: widget.controller,
        textInputAction: TextInputAction.search,
        onFieldSubmitted: (_) => widget.func(),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1000),
            borderSide: BorderSide(color: Colors.grey.shade500),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1000),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          hintText: widget.text,
          suffixIcon: IconButton(
            onPressed: widget.func,
            icon: const Icon(Icons.search, color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
