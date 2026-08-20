import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.helperText,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    Widget? activeSuffixIcon = widget.suffixIcon;
    
    // Auto-toggle eye icon for password inputs if suffixIcon is not provided
    if (widget.obscureText && widget.suffixIcon == null) {
      activeSuffixIcon = IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_off : Icons.visibility,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      );
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: activeSuffixIcon,
      ),
    );
  }
}
