import 'package:flutter/material.dart';

TextStyle stylebutton({
  required double size,
  required bool fontWeight,
  required Color color,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: (fontWeight ? FontWeight.bold : FontWeight.normal),
    color: color,
    fontStyle: FontStyle.italic,
  );
}

Widget button({required String text, required VoidCallback func}) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: func,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(color: Colors.blue, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  maxLines: 1,
                  style: stylebutton(
                    size: 20,
                    fontWeight: true,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget buttonFull({required String text, required VoidCallback func}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: func,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              maxLines: 1,
              style: stylebutton(
                size: 20,
                fontWeight: true,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
