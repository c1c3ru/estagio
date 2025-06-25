// lib/features/student/presentation/widgets/time_tracker_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart'; // Para obter o AuthBloc
import 'package:intl/intl.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_state.dart'
    as auth_state;

import '../../../../core/widgets/app_button.dart';
import '../../../../domain/entities/time_log_entity.dart';

import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../core/utils/feedback_service.dart';

class TimeTrackerWidget extends StatefulWidget {
  // Pode receber o activeTimeLog diretamente ou buscar através do BLoC
  final TimeLogEntity? activeTimeLogInitial;
  final String? currentUserId; // Opcional, pode ser obtido do AuthBloc

  const TimeTrackerWidget({
    super.key,
    this.activeTimeLogInitial,
    this.currentUserId,
  });

  @override
  State<TimeTrackerWidget> createState() => _TimeTrackerWidgetState();
}

class _TimeTrackerWidgetState extends State<TimeTrackerWidget> {
  late StudentBloc _studentBloc;
  late AuthBloc _authBloc;
  String? _userId;
  TimeLogEntity? _activeTimeLog;

  @override
  void initState() {
    super.initState();
    _studentBloc = Modular.get<StudentBloc>();
    _authBloc = Modular.get<AuthBloc>();
    _activeTimeLog = widget.activeTimeLogInitial;

    _userId = widget.currentUserId;
    if (_userId == null) {
      final currentAuthState = _authBloc.state;
      if (currentAuthState is auth_state.AuthSuccess) {
        _userId = currentAuthState.user.id;
      }
    }

    if (_userId != null && _activeTimeLog == null) {
      // Se não recebeu um log ativo inicial, tenta buscar
      _studentBloc.add(FetchActiveTimeLogEvent(userId: _userId!));
    }
  }

  void _performCheckIn() {
    if (_userId != null) {
      // Pode adicionar um diálogo para notas aqui
      _studentBloc.add(StudentCheckInEvent(userId: _userId!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ID do utilizador não disponível para check-in.')),
      );
    }
  }

  void _performCheckOut() {
    if (_userId != null && _activeTimeLog != null) {
      // Pode adicionar um diálogo para descrição aqui
      _studentBloc.add(StudentCheckOutEvent(
        userId: _userId!,
        activeTimeLogId: _activeTimeLog!.id,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nenhum check-in ativo encontrado para finalizar.')),
      );
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<StudentBloc, StudentState>(
      bloc: _studentBloc,
      listener: (context, state) {
        if (state is ActiveTimeLogFetched) {
          setState(() {
            _activeTimeLog = state.activeTimeLog;
          });
        } else if (state is StudentTimeLogOperationSuccess) {
          if (_userId != null) {
            _studentBloc.add(FetchActiveTimeLogEvent(userId: _userId!));
          }
          FeedbackService.showSuccess(context, state.message);
        } else if (state is StudentOperationFailure) {
          FeedbackService.showError(context, state.message);
        }
      },
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Registro de Horas',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (_activeTimeLog != null) ...[
                Text(
                  'Check-in: ${_formatTimeOfDay(_parseTimeOfDay(_activeTimeLog!.checkInTime))}',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                AppButton(
                  text: 'Finalizar Registro',
                  onPressed: _performCheckOut,
                  type: AppButtonType.outlined,
                  icon: Icons.logout,
                ),
              ] else
                AppButton(
                  text: 'Iniciar Registro',
                  onPressed: _performCheckIn,
                  icon: Icons.login,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
