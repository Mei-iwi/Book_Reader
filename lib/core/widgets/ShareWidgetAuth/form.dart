import 'package:flutter/material.dart';

class FormInput extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const FormInput({
    super.key,
    required this.text,
    required this.icon,
    required this.isPassword,
    required this.controller,
    required this.validator,
  });

  @override
  State<StatefulWidget> createState() => _FormInput();
}

class _FormInput extends State<FormInput> {
  bool _isHide = true;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: TextFormField(
              controller: widget.controller,
              validator: widget.validator,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                prefixIcon: Icon(widget.icon, color: Colors.blue),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                label: Text(
                  widget.text,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),

                suffixIcon: (widget.isPassword
                    ? IconButton(
                        onPressed: () => setState(() {
                          _isHide = !_isHide;
                        }),
                        icon: (_isHide
                            ? Icon(
                                Icons.remove_red_eye,
                                color: theme.colorScheme.onSurfaceVariant,
                              )
                            : Icon(
                                Icons.visibility_off,
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
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
