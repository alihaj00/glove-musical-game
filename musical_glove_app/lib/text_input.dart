import 'package:flutter/material.dart';

class InputFields extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final bool hasError;

  const InputFields({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  _InputFieldsState createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.hasError ? Colors.red : Colors.grey,
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
        ),
        style: TextStyle(
          color: widget.hasError ? Colors.red : null,
        ),
      ),
    );
  }
}
