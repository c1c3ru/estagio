// lib/core/utils/date_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Adicione intl ao pubspec.yaml

class DateUtil {
  /// Formata DateTime para uma string 'dd/MM/yyyy'.
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formata DateTime para uma string 'dd/MM/yyyy HH:mm'.
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Formata DateTime para uma string 'HH:mm'.
  static String formatTime(DateTime? time) {
    if (time == null) return '';
    return DateFormat('HH:mm').format(time);
  }

  /// Formata TimeOfDay para uma string 'HH:mm'.
  static String formatTimeOfDay(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) return '';
    final now = DateTime.now();
    final dt = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('HH:mm').format(dt);
  }

  /// Converte uma string 'HH:mm' ou 'HH:mm:ss' para TimeOfDay.
  static TimeOfDay? timeOfDayFromString(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    final parts = timeString.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

  /// Retorna a diferença de dias entre duas datas, ignorando a hora.
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Verifica se uma data é hoje.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Retorna o início da semana (Domingo ou Segunda, dependendo da localidade).
  /// Aqui, vamos considerar Segunda como início da semana.
  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Retorna o fim da semana (Sábado ou Domingo).
  static DateTime endOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
  }

  // Previne instanciação
  DateUtil._();
}

/// Utilitários para formatação e manipulação de datas
class AppDateUtils {
  static const String _defaultDateFormat = 'dd/MM/yyyy';
  static const String _defaultTimeFormat = 'HH:mm';
  static const String _defaultDateTimeFormat = 'dd/MM/yyyy HH:mm';

  /// Formata uma data para string no formato padrão brasileiro
  static String formatDate(DateTime date) {
    return DateFormat(_defaultDateFormat).format(date);
  }

  /// Formata uma hora para string no formato padrão
  static String formatTime(DateTime time) {
    return DateFormat(_defaultTimeFormat).format(time);
  }

  /// Formata uma data e hora para string no formato padrão
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(_defaultDateTimeFormat).format(dateTime);
  }

  /// Formata uma data com formato customizado
  static String formatDateCustom(DateTime date, String format) {
    return DateFormat(format).format(date);
  }

  /// Converte string para DateTime
  static DateTime? parseDate(String dateString, [String? format]) {
    try {
      final formatter = DateFormat(format ?? _defaultDateFormat);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Retorna a data de hoje sem horário
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Retorna o início do dia para uma data
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Retorna o fim do dia para uma data
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Verifica se duas datas são do mesmo dia
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Calcula a diferença em dias entre duas datas
  static int daysBetween(DateTime from, DateTime to) {
    from = startOfDay(from);
    to = startOfDay(to);
    return to.difference(from).inDays;
  }

  /// Adiciona dias a uma data
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Subtrai dias de uma data
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// Retorna o primeiro dia da semana
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Retorna o último dia da semana
  static DateTime endOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }

  /// Retorna o primeiro dia do mês
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Retorna o último dia do mês
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = date.month == 12 
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return endOfDay(nextMonth.subtract(const Duration(days: 1)));
  }

  /// Formata duração em horas e minutos
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
    } else {
      return '${minutes}min';
    }
  }

  /// Calcula horas trabalhadas entre check-in e check-out
  static Duration calculateWorkedHours(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn);
  }

  /// Verifica se é fim de semana
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// Verifica se é dia útil
  static bool isWeekday(DateTime date) {
    return !isWeekend(date);
  }

  /// Retorna nome do dia da semana em português
  static String getDayName(DateTime date) {
    const dayNames = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];
    return dayNames[date.weekday - 1];
  }

  /// Retorna nome do mês em português
  static String getMonthName(DateTime date) {
    const monthNames = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril',
      'Maio', 'Junho', 'Julho', 'Agosto',
      'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return monthNames[date.month - 1];
  }

  /// Formata data em português (ex: "15 de Janeiro de 2024")
  static String formatDatePortuguese(DateTime date) {
    return '${date.day} de ${getMonthName(date)} de ${date.year}';
  }

  /// Formata data relativa (ex: "hoje", "ontem", "há 3 dias")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = daysBetween(date, now);

    if (difference == 0) {
      return 'hoje';
    } else if (difference == 1) {
      return 'ontem';
    } else if (difference == -1) {
      return 'amanhã';
    } else if (difference > 0 && difference <= 7) {
      return 'há $difference ${difference == 1 ? 'dia' : 'dias'}';
    } else if (difference < 0 && difference >= -7) {
      final days = difference.abs();
      return 'em $days ${days == 1 ? 'dia' : 'dias'}';
    } else {
      return formatDate(date);
    }
  }
}
