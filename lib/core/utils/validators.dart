// lib/core/utils/validators.dart
import '../constants/app_strings.dart'; // Para mensagens de erro padrão
import '../enums/user_role.dart';
import '../enums/class_shift.dart';
import '../enums/internship_shift.dart';

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

  /// Validador para senha forte (com requisitos específicos).
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra minúscula.';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra maiúscula.';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'A senha deve conter pelo menos um número.';
    }
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

  /// Validador para nome completo (pelo menos 2 palavras).
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome completo é obrigatório.';
    }
    final trimmedValue = value.trim();
    if (trimmedValue.split(' ').length < 2) {
      return 'Digite o nome completo (nome e sobrenome).';
    }
    if (trimmedValue.length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres.';
    }
    return null;
  }

  /// Validador para curso.
  static String? course(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Curso é obrigatório.';
    }
    if (value.trim().length < 3) {
      return 'Nome do curso deve ter pelo menos 3 caracteres.';
    }
    return null;
  }

  /// Validador para departamento.
  static String? department(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Departamento é obrigatório.';
    }
    if (value.trim().length < 2) {
      return 'Nome do departamento deve ter pelo menos 2 caracteres.';
    }
    return null;
  }

  /// Validador para cargo/posição.
  static String? position(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cargo é obrigatório.';
    }
    if (value.trim().length < 2) {
      return 'Nome do cargo deve ter pelo menos 2 caracteres.';
    }
    return null;
  }

  /// Validador para ID não vazio.
  static String? nonEmptyId(String? value, {String fieldName = 'ID'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName não pode estar vazio.';
    }
    return null;
  }

  /// Validador para período de datas (data fim deve ser após data início).
  static String? dateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) {
      return 'Data de início é obrigatória.';
    }
    if (endDate == null) {
      return 'Data de fim é obrigatória.';
    }
    if (endDate.isBefore(startDate)) {
      return 'Data de fim deve ser posterior à data de início.';
    }
    return null;
  }

  /// Validador para duração mínima de contrato (em dias).
  static String? contractDuration(DateTime? startDate, DateTime? endDate, {int minDays = 30}) {
    final dateRangeError = dateRange(startDate, endDate);
    if (dateRangeError != null) return dateRangeError;

    final duration = endDate!.difference(startDate!).inDays;
    if (duration < minDays) {
      return 'Contrato deve ter duração mínima de $minDays dias.';
    }
    return null;
  }

  /// Validador para horas trabalhadas (entre 0 e 24).
  static String? hoursWorked(double? hours) {
    if (hours == null) {
      return 'Horas trabalhadas são obrigatórias.';
    }
    if (hours < 0) {
      return 'Horas trabalhadas não podem ser negativas.';
    }
    if (hours > 24) {
      return 'Horas trabalhadas não podem exceder 24 horas por dia.';
    }
    return null;
  }

  /// Validador para descrição/notas (comprimento máximo).
  static String? description(String? value, {int maxLength = 500}) {
    if (value != null && value.length > maxLength) {
      return 'Descrição deve ter no máximo $maxLength caracteres.';
    }
    return null;
  }

  /// Validador composto para registro de estudante.
  static Map<String, String?> validateStudentRegistration({
    required String? fullName,
    required String? email,
    required String? password,
    required String? confirmPassword,
    required String? registration,
    required String? course,
    DateTime? birthDate,
    DateTime? contractStartDate,
    DateTime? contractEndDate,
  }) {
    return {
      'fullName': Validators.fullName(fullName),
      'email': Validators.email(email),
      'password': Validators.strongPassword(password),
      'confirmPassword': Validators.confirmPassword(password, confirmPassword),
      'registration': Validators.studentRegistration(registration),
      'course': Validators.course(course),
      'birthDate': birthDate != null ? Validators.dateNotFuture(birthDate, fieldName: 'Data de nascimento') : null,
      'contractDuration': contractStartDate != null && contractEndDate != null 
          ? Validators.contractDuration(contractStartDate, contractEndDate) 
          : null,
    };
  }

  /// Validador composto para registro de supervisor.
  static Map<String, String?> validateSupervisorRegistration({
    required String? fullName,
    required String? email,
    required String? password,
    required String? confirmPassword,
    required String? siapeRegistration,
    String? phoneNumber,
    String? department,
    String? position,
  }) {
    return {
      'fullName': Validators.fullName(fullName),
      'email': Validators.email(email),
      'password': Validators.strongPassword(password),
      'confirmPassword': Validators.confirmPassword(password, confirmPassword),
      'siapeRegistration': Validators.siapeRegistration(siapeRegistration),
      'phoneNumber': phoneNumber != null && phoneNumber.isNotEmpty 
          ? Validators.phoneNumber(phoneNumber) 
          : null,
      'department': department != null && department.isNotEmpty 
          ? Validators.department(department) 
          : null,
      'position': position != null && position.isNotEmpty 
          ? Validators.position(position) 
          : null,
    };
  }

  /// Validador composto para check-in/check-out.
  static Map<String, String?> validateTimeLog({
    required String? studentId,
    String? description,
    DateTime? logDate,
  }) {
    return {
      'studentId': Validators.nonEmptyId(studentId, fieldName: 'ID do estudante'),
      'description': Validators.description(description),
      'logDate': logDate != null ? Validators.dateNotFuture(logDate, fieldName: 'Data do registro') : null,
    };
  }

  /// Validador composto para criação/atualização de contrato.
  static Map<String, String?> validateContract({
    required String? studentId,
    required String? supervisorId,
    required DateTime? startDate,
    required DateTime? endDate,
    String? description,
  }) {
    return {
      'studentId': Validators.nonEmptyId(studentId, fieldName: 'ID do estudante'),
      'supervisorId': Validators.nonEmptyId(supervisorId, fieldName: 'ID do supervisor'),
      'contractDuration': Validators.contractDuration(startDate, endDate),
      'description': Validators.description(description),
    };
  }

  /// Utilitário para verificar se um mapa de validações tem erros.
  static bool hasValidationErrors(Map<String, String?> validationResults) {
    return validationResults.values.any((error) => error != null);
  }

  /// Utilitário para obter apenas os erros de validação.
  static Map<String, String> getValidationErrors(Map<String, String?> validationResults) {
    final errors = <String, String>{};
    validationResults.forEach((key, value) {
      if (value != null) {
        errors[key] = value;
      }
    });
    return errors;
  }

  /// Utilitário para obter o primeiro erro de validação.
  static String? getFirstValidationError(Map<String, String?> validationResults) {
    for (final error in validationResults.values) {
      if (error != null) return error;
    }
    return null;
  }

  // Previne instanciação
  Validators._();
}
