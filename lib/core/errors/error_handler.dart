// lib/core/errors/error_handler.dart
import 'package:flutter/material.dart';
import 'package:gestao_de_estagio/core/errors/app_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;
import '../utils/logger_utils.dart';

import 'package:postgrest/postgrest.dart';
import '../constants/app_strings.dart';

class ErrorHandler {
  static void handle(
    dynamic error, {
    StackTrace? stackTrace,
    String? userFriendlyMessage,
    BuildContext? context,
  }) {
    logger.e(
      userFriendlyMessage ?? 'Erro não tratado',
      error,
      stackTrace,
    );

    if (context != null && userFriendlyMessage != null) {
      _showErrorFeedback(context, userFriendlyMessage);
    }
  }

  /// Converte uma exceção genérica ou específica da fonte de dados para um AppFailure.
  static AppFailure convertToAppFailure(dynamic error,
      {String? defaultMessage}) {
    if (error is AppFailure) {
      return error;
    } else if (error is supabase_auth.AuthException) {
      return AuthFailure(error.message);
    } else if (error is PostgrestException) {
      // Exceção do banco de dados Supabase
      return ServerFailure(
        message: error.message,
        originalException: error,
      );
    }
    // Adicione outros tipos de exceção específicos aqui (ex: DioError, SocketException)
    else {
      return ServerFailure(
        message: defaultMessage ?? AppStrings.error,
        originalException: error,
      );
    }
  }

  /// Mostra um feedback de erro ao utilizador (ex: SnackBar).
  static void _showErrorFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Retorna uma mensagem de erro amigável baseada no AppFailure.
  static String getUserFriendlyMessage(AppFailure failure) {
    // Você pode ter lógicas mais específicas aqui baseadas no tipo de AppFailure
    // ou no originalException, se necessário.
    return failure.message;
  }

  // Previne instanciação
  ErrorHandler._();
}
