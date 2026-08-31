import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? errorText;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      style: TextStyle(color: colors.inputText),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(color: colors.textMuted),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        errorText: widget.errorText,
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colors.inputBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.inputBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        // Antes usava inputBorder: focar o campo não mudava nada na tela.
        // Alinhado com appInputDecoration, que usa primary no foco.
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: colors.textMuted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    ));
  }
}
