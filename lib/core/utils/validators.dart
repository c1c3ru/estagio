// lib/core/utils/validators.dart
import '../constants/app_strings.dart'; // Para mensagens de erro padrão

class Validators {
  /// Validador para campos obrigatórios.
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório.';
    }
    return null;
  }

  /// Validador para email.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (!emailRegExp.hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  /// Validador para senha (comprimento mínimo).
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }
    if (value.length < minLength) {
      return 'A senha deve ter pelo menos $minLength caracteres.';
    }
    // Você pode adicionar outras validações de senha aqui (ex: maiúsculas, números, especiais)
    return null;
  }

  /// Validador para confirmar senha.
  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return AppStrings.requiredField;
    }
    if (password != confirmPassword) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  /// Validador para números de telefone (exemplo simples).
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Número de telefone é obrigatório.';
    }
    // Exemplo simples: verifica se tem entre 10 e 15 dígitos (considerando códigos de país/área)
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(value.replaceAll(RegExp(r'[\s()-]'), ''))) {
      // Remove espaços, (), -
      return 'Número de telefone inválido.';
    }
    return null;
  }

  /// Validador para datas (ex: não pode ser no futuro).
  static String? dateNotFuture(DateTime? date, {String fieldName = 'Data'}) {
    if (date == null) {
      return '$fieldName é obrigatória.';
    }
    if (date.isAfter(DateTime.now())) {
      return '$fieldName não pode ser uma data futura.';
    }
    return null;
  }

  /// Validador para datas (ex: não pode ser no passado).
  static String? dateNotPast(DateTime? date, {String fieldName = 'Data'}) {
    if (date == null) {
      return '$fieldName é obrigatória.';
    }
    // Compara apenas a data, ignorando a hora, para evitar problemas com o momento exato.
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isBefore(today)) {
      return '$fieldName não pode ser uma data passada.';
    }
    return null;
  }

  /// Validador para matrícula SIAPE (exatamente 7 dígitos).
  static String? siapeRegistration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Matrícula SIAPE é obrigatória.';
    }
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.length != 7) {
      return 'Matrícula SIAPE deve ter exatamente 7 dígitos.';
    }
    if (!RegExp(r'^[0-9]{7}$').hasMatch(cleanValue)) {
      return 'Matrícula SIAPE deve conter apenas números.';
    }
    return null;
  }

  /// Validador para matrícula de aluno (exatamente 12 dígitos).
  static String? studentRegistration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Matrícula de aluno é obrigatória.';
    }
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.length != 12) {
      return 'Matrícula de aluno deve ter exatamente 12 dígitos.';
    }
    if (!RegExp(r'^[0-9]{12}$').hasMatch(cleanValue)) {
      return 'Matrícula de aluno deve conter apenas números.';
    }
    return null;
  }

  /// Validador para verificar se a matrícula SIAPE é única (usado com verificação no banco).
  static String? siapeRegistrationUnique(String? value,
      {bool isUnique = true}) {
    final basicValidation = siapeRegistration(value);
    if (basicValidation != null) return basicValidation;

    if (!isUnique) {
      return 'Esta matrícula SIAPE já está em uso.';
    }

    return null;
  }

  // Previne instanciação
  Validators._();
}
