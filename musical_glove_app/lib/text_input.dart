import 'package:flutter/material.dart';

class InputFields extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final bool hasError;
  final TextEditingController? controller;
  final bool obscureText; // Add this property

  const InputFields({
    Key? key,
    required this.hintText,
    required this.onChanged,
    this.hasError = false,
    this.controller,
    this.obscureText = false, // Provide default value
  }) : super(key: key);

  @override
  _InputFieldsState createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(115, 115, 115, 0.16),
            Color.fromRGBO(217, 217, 217, 0.21),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        obscureText: widget.obscureText, // Use obscureText property
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        style: TextStyle(
          fontSize: 16,
          color: widget.hasError ? Colors.red : Color.fromRGBO(15, 15, 15, 1),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
