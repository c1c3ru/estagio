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
