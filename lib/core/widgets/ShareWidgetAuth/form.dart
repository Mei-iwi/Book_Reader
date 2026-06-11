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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            style: TextStyle(color: theme.colorScheme.onSurface),
            textInputAction: widget.isPassword
                ? TextInputAction.done
                : TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: Icon(widget.icon, color: Colors.blue),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              errorMaxLines: 2,
              labelText: widget.text,
              labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              floatingLabelStyle: const TextStyle(color: Colors.blue),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      onPressed: () => setState(() {
                        _isHide = !_isHide;
                      }),
                      icon: Icon(
                        _isHide ? Icons.visibility : Icons.visibility_off,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
            ),
            obscureText: widget.isPassword && _isHide,
          ),
        ),
      ),
    );
  }
}
