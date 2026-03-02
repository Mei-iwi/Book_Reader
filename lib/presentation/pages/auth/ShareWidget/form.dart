import 'package:flutter/material.dart';

class formInput extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isPassword;
  //final TextEditingController item;

  const formInput({
    super.key,
    required this.text,
    required this.icon,
    required this.isPassword,
    //required this.item,
  });

  @override
  State<StatefulWidget> createState() => _formInput();
}

class _formInput extends State<formInput> {
  bool _isHide = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: TextFormField(
              //controller: widget.item,
              decoration: InputDecoration(
                prefixIcon: Icon(widget.icon, color: Colors.blue),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                label: Text(widget.text),

                suffixIcon: (widget.isPassword
                    ? IconButton(
                        onPressed: () => setState(() {
                          _isHide = !_isHide;
                        }),
                        icon: (_isHide
                            ? Icon(Icons.remove_red_eye)
                            : Icon(Icons.visibility_off)),
                      )
                    : null),
              ),
              obscureText: ((widget.isPassword && _isHide) ? true : false),
            ),
          ),
        ],
      ),
    );
  }
}
