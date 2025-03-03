import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String hintText;
  final bool isDispose;
  final ValueChanged<String>? onTextChanged;
  final TextEditingController? controller; // Add the controller parameter

  const AppTextField({
    super.key,
    this.hintText = '',
    this.isDispose = true,
    this.onTextChanged,
    this.controller, // Initialize the controller parameter
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _showSuffixIcon = false;

  // No longer create _controller here, use the one passed in from widget
  // final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    // Do NOT dispose the controller here if it's passed from outside
    // if (widget.isDispose) {
    //   _controller.dispose();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller, // Use the controller from widget parameter
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        suffixIcon:
            widget.isDispose && _showSuffixIcon
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller
                        ?.clear(); // Clear the controller from widget
                    setState(() {
                      _showSuffixIcon = false;
                    });
                  },
                )
                : null,
      ),
      onChanged: (text) {
        setState(() {
          _showSuffixIcon = text.isNotEmpty;
        });
        if (widget.onTextChanged != null) {
          widget.onTextChanged!(text);
        }
      },
    );
  }
}
