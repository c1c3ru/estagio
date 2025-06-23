// lib/features/student/presentation/widgets/time_tracker_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart'; // Para obter o AuthBloc
import 'package:intl/intl.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_state.dart'
    as auth_state;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../domain/entities/time_log_entity.dart';

import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';

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
          // Após check-in ou check-out, o evento FetchActiveTimeLogEvent
          // deve ser disparado pela página ou pelo BLoC para atualizar o estado.
          // Se este widget for independente, ele precisa buscar o novo estado.
          if (_userId != null) {
            _studentBloc.add(FetchActiveTimeLogEvent(userId: _userId!));
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
        } else if (state is StudentOperationFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize
                .min, // Para que o Card não ocupe todo o espaço vertical
            children: [
              Text(
                _activeTimeLog != null
                    ? 'Check-in ativo desde:'
                    : 'Pronto para começar?',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (_activeTimeLog != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _formatTimeOfDay(_activeTimeLog!.checkInTime),
                    style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              BlocBuilder<StudentBloc, StudentState>(
                bloc: _studentBloc,
                builder: (context, state) {
                  bool isLoading = state
                      is StudentLoading; // Verifica se está a carregar uma operação de log
                  bool isCheckedIn = _activeTimeLog != null;

                  return AppButton(
                    text:
                        isCheckedIn ? AppStrings.checkOut : AppStrings.checkIn,
                    onPressed: isLoading
                        ? null
                        : (isCheckedIn ? _performCheckOut : _performCheckIn),
                    isLoading: isLoading,
                    backgroundColor:
                        isCheckedIn ? AppColors.warning : AppColors.success,
                    icon: isCheckedIn
                        ? Icons.logout_outlined
                        : Icons.login_outlined,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
