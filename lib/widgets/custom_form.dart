import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomFormField extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final bool centerHint; // ✅ الخيار الجديد
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  // New properties
  final bool readOnly; // لو true يمنع الكتابة ويخلي الحقل للقراءة فقط
  final VoidCallback? onTap; // تتنفذ لما المستخدم يضغط على الحقل

  const CustomFormField({
    super.key,
    required this.hint,
    this.controller,
    this.isPassword = false,
    this.centerHint = false, // ✅ القيمة الافتراضية false
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      textAlign: widget.centerHint ? TextAlign.center : TextAlign.start, // ✅ تحكم في مكان النص
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:  BorderSide(
            color: AppColorsDark.strokColor,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color:AppColorsDark.mainColor,
            width: 2,
          ),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
        )
            : null,
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
