// lib/core/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart'; // Para cores, se necessário

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? minLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: theme.textTheme.bodyLarge, // Estilo do texto de entrada
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        // Aplicando o estilo do tema, mas permitindo override se necessário
        labelStyle: theme.inputDecorationTheme.labelStyle,
        hintStyle: theme.inputDecorationTheme.hintStyle,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon,
                color: theme.inputDecorationTheme.prefixIconColor)
            : null,
        suffixIcon: widget
                .obscureText // Se for campo de senha, mostra ícone para alternar visibilidade
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: theme.inputDecorationTheme
                      .prefixIconColor, // Reutilizando cor do prefixo
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : (widget.suffixIcon != null
                ? IconButton(
                    icon: Icon(widget.suffixIcon,
                        color: theme.inputDecorationTheme.prefixIconColor),
                    onPressed: widget.onSuffixIconPressed,
                  )
                : null),
        border: theme.inputDecorationTheme.border,
        enabledBorder: theme.inputDecorationTheme.enabledBorder,
        focusedBorder: theme.inputDecorationTheme.focusedBorder,
        errorBorder: theme.inputDecorationTheme.errorBorder,
        focusedErrorBorder: theme.inputDecorationTheme.focusedErrorBorder,
        disabledBorder: theme.inputDecorationTheme.disabledBorder,
        filled: true, // Para que a fillColor tenha efeito
        fillColor: widget.enabled
            ? theme.inputDecorationTheme.fillColor
            : AppColors.greyLight.withOpacity(0.3),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      ),
    );
  }
}
