// lib/features/student/presentation/bloc/student_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gestao_de_estagio/core/enums/class_shift.dart'; // Para TimeOfDay
import 'package:gestao_de_estagio/core/enums/internship_shift.dart';
// Importe o enum ClassShift se for permitir a edição dele

// Parâmetros para atualizar perfil do estudante, específicos para o evento
class UpdateStudentProfileEventParams extends Equatable {
  // Adicionado Equatable
  final String? fullName;
  final String? registrationNumber;
  final String? course;
  final String? advisorName;
  final bool? isMandatoryInternship;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final DateTime? birthDate; // Adicionado
  final ClassShift? classShift; // Adicionado
  final InternshipShift? internshipShift; // Adicionado
  // Adicione mais campos conforme necessário

  const UpdateStudentProfileEventParams({
    this.fullName,
    this.registrationNumber,
    this.course,
    this.advisorName,
    this.isMandatoryInternship,
    this.profilePictureUrl,
    this.phoneNumber,
    this.birthDate, // Adicionado
    this.classShift, // Adicionado
    this.internshipShift, // Adicionado
  });

  @override
  List<Object?> get props => [
        // Adicionado props
        fullName,
        registrationNumber,
        course,
        advisorName,
        isMandatoryInternship,
        profilePictureUrl,
        phoneNumber,
        birthDate,
        classShift,
        internshipShift, // Adicionado
      ];
}

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para carregar os dados iniciais do dashboard do estudante
/// (perfil, estatísticas de tempo, etc.)
class LoadStudentDashboardDataEvent extends StudentEvent {
  final String userId; // ID do usuário logado (que é o studentId)
  const LoadStudentDashboardDataEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para atualizar os dados do perfil do estudante.
class UpdateStudentProfileInfoEvent extends StudentEvent {
  final String userId; // ID do estudante cujo perfil está a ser atualizado
  final UpdateStudentProfileEventParams params;

  const UpdateStudentProfileInfoEvent(
      {required this.userId, required this.params});

  @override
  List<Object?> get props => [userId, params];
}

/// Evento para realizar check-in.
class StudentCheckInEvent extends StudentEvent {
  final String userId;
  final String? notes;

  const StudentCheckInEvent({required this.userId, this.notes});

  @override
  List<Object?> get props => [userId, notes];
}

/// Evento para realizar check-out.
class StudentCheckOutEvent extends StudentEvent {
  final String userId;
  final String?
      activeTimeLogId; // ID do log de tempo que foi iniciado no check-in
  final String? description;
  final String? notes;

  const StudentCheckOutEvent({
    required this.userId,
    this.activeTimeLogId,
    this.description,
    this.notes,
  });

  @override
  List<Object?> get props => [userId, activeTimeLogId, description, notes];
}

/// Evento para carregar os registos de tempo do estudante (com paginação/filtros).
class LoadStudentTimeLogsEvent extends StudentEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;
  // Adicione parâmetros de paginação se necessário (page, pageSize)

  const LoadStudentTimeLogsEvent({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

/// Evento para criar um novo registo de tempo manual.
class CreateManualTimeLogEvent extends StudentEvent {
  final String userId;
  final DateTime logDate;
  final TimeOfDay checkInTime;
  final TimeOfDay? checkOutTime;
  final String? description;

  const CreateManualTimeLogEvent({
    required this.userId,
    required this.logDate,
    required this.checkInTime,
    this.checkOutTime,
    this.description,
  });

  @override
  List<Object?> get props =>
      [userId, logDate, checkInTime, checkOutTime, description];
}

/// Evento para atualizar um registo de tempo manual existente.
class UpdateManualTimeLogEvent extends StudentEvent {
  final String timeLogId;
  final DateTime? logDate;
  final TimeOfDay? checkInTime;
  final TimeOfDay? checkOutTime;
  final String? description;

  const UpdateManualTimeLogEvent({
    required this.timeLogId,
    this.logDate,
    this.checkInTime,
    this.checkOutTime,
    this.description,
  });

  @override
  List<Object?> get props =>
      [timeLogId, logDate, checkInTime, checkOutTime, description];
}

/// Evento para remover um registo de tempo.
class DeleteTimeLogRequestedEvent extends StudentEvent {
  final String timeLogId;

  const DeleteTimeLogRequestedEvent({required this.timeLogId});

  @override
  List<Object?> get props => [timeLogId];
}

/// Evento para buscar o log de tempo ativo (se houver um check-in não finalizado)
class FetchActiveTimeLogEvent extends StudentEvent {
  final String userId;
  const FetchActiveTimeLogEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
