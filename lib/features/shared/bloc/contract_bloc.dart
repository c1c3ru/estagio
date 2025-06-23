import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/contract_entity.dart';
import '../../../domain/usecases/contract/get_contracts_by_student_usecase.dart';
import '../../../domain/usecases/contract/get_contracts_by_supervisor_usecase.dart';
import '../../../domain/usecases/contract/get_active_contract_by_student_usecase.dart';
import '../../../domain/usecases/contract/create_contract_usecase.dart';
import '../../../domain/usecases/contract/update_contract_usecase.dart';
import '../../../domain/usecases/contract/delete_contract_usecase.dart';
import '../../../domain/usecases/contract/get_contract_statistics_usecase.dart';

// Events
abstract class ContractEvent extends Equatable {
  const ContractEvent();

  @override
  List<Object?> get props => [];
}

class ContractLoadByStudentRequested extends ContractEvent {
  final String studentId;

  const ContractLoadByStudentRequested({required this.studentId});

  @override
  List<Object> get props => [studentId];
}

class ContractLoadBySupervisorRequested extends ContractEvent {
  final String supervisorId;

  const ContractLoadBySupervisorRequested({required this.supervisorId});

  @override
  List<Object> get props => [supervisorId];
}

class ContractGetActiveByStudentRequested extends ContractEvent {
  final String studentId;

  const ContractGetActiveByStudentRequested({required this.studentId});

  @override
  List<Object> get props => [studentId];
}

class ContractCreateRequested extends ContractEvent {
  final ContractEntity contract;

  const ContractCreateRequested({required this.contract});

  @override
  List<Object> get props => [contract];
}

class ContractUpdateRequested extends ContractEvent {
  final ContractEntity contract;

  const ContractUpdateRequested({required this.contract});

  @override
  List<Object> get props => [contract];
}

class ContractDeleteRequested extends ContractEvent {
  final String id;

  const ContractDeleteRequested({required this.id});

  @override
  List<Object> get props => [id];
}

class ContractGetStatisticsRequested extends ContractEvent {}

// States
abstract class ContractState extends Equatable {
  const ContractState();

  @override
  List<Object?> get props => [];
}

class ContractInitial extends ContractState {}

// Loading States
class ContractLoading extends ContractState {}

class ContractSelecting extends ContractState {}

class ContractInserting extends ContractState {}

class ContractUpdating extends ContractState {}

class ContractDeleting extends ContractState {}

// Success States
class ContractLoadByStudentSuccess extends ContractState {
  final List<ContractEntity> contracts;

  const ContractLoadByStudentSuccess({required this.contracts});

  @override
  List<Object> get props => [contracts];
}

class ContractLoadBySupervisorSuccess extends ContractState {
  final List<ContractEntity> contracts;

  const ContractLoadBySupervisorSuccess({required this.contracts});

  @override
  List<Object> get props => [contracts];
}

class ContractGetActiveByStudentSuccess extends ContractState {
  final ContractEntity? contract;

  const ContractGetActiveByStudentSuccess({required this.contract});

  @override
  List<Object?> get props => [contract];
}

class ContractCreateSuccess extends ContractState {
  final ContractEntity contract;

  const ContractCreateSuccess({required this.contract});

  @override
  List<Object> get props => [contract];
}

class ContractUpdateSuccess extends ContractState {
  final ContractEntity contract;

  const ContractUpdateSuccess({required this.contract});

  @override
  List<Object> get props => [contract];
}

class ContractDeleteSuccess extends ContractState {
  final String deletedId;

  const ContractDeleteSuccess({required this.deletedId});

  @override
  List<Object> get props => [deletedId];
}

class ContractGetStatisticsSuccess extends ContractState {
  final Map<String, dynamic> statistics;

  const ContractGetStatisticsSuccess({required this.statistics});

  @override
  List<Object> get props => [statistics];
}

// Error States
class ContractSelectError extends ContractState {
  final String message;

  const ContractSelectError({required this.message});

  @override
  List<Object> get props => [message];
}

class ContractInsertError extends ContractState {
  final String message;

  const ContractInsertError({required this.message});

  @override
  List<Object> get props => [message];
}

class ContractUpdateError extends ContractState {
  final String message;

  const ContractUpdateError({required this.message});

  @override
  List<Object> get props => [message];
}

class ContractDeleteError extends ContractState {
  final String message;

  const ContractDeleteError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class ContractBloc extends Bloc<ContractEvent, ContractState> {
  final GetContractsByStudentUsecase _getContractsByStudentUsecase;
  final GetContractsBySupervisorUsecase _getContractsBySupervisorUsecase;
  final GetActiveContractByStudentUsecase _getActiveContractByStudentUsecase;
  final CreateContractUsecase _createContractUsecase;
  final UpdateContractUsecase _updateContractUsecase;
  final DeleteContractUsecase _deleteContractUsecase;
  final GetContractStatisticsUsecase _getContractStatisticsUsecase;

  ContractBloc({
    required GetContractsByStudentUsecase getContractsByStudentUsecase,
    required GetContractsBySupervisorUsecase getContractsBySupervisorUsecase,
    required GetActiveContractByStudentUsecase
        getActiveContractByStudentUsecase,
    required CreateContractUsecase createContractUsecase,
    required UpdateContractUsecase updateContractUsecase,
    required DeleteContractUsecase deleteContractUsecase,
    required GetContractStatisticsUsecase getContractStatisticsUsecase,
  })  : _getContractsByStudentUsecase = getContractsByStudentUsecase,
        _getContractsBySupervisorUsecase = getContractsBySupervisorUsecase,
        _getActiveContractByStudentUsecase = getActiveContractByStudentUsecase,
        _createContractUsecase = createContractUsecase,
        _updateContractUsecase = updateContractUsecase,
        _deleteContractUsecase = deleteContractUsecase,
        _getContractStatisticsUsecase = getContractStatisticsUsecase,
        super(ContractInitial()) {
    on<ContractLoadByStudentRequested>(_onContractLoadByStudentRequested);
    on<ContractLoadBySupervisorRequested>(_onContractLoadBySupervisorRequested);
    on<ContractGetActiveByStudentRequested>(
        _onContractGetActiveByStudentRequested);
    on<ContractCreateRequested>(_onContractCreateRequested);
    on<ContractUpdateRequested>(_onContractUpdateRequested);
    on<ContractDeleteRequested>(_onContractDeleteRequested);
    on<ContractGetStatisticsRequested>(_onContractGetStatisticsRequested);
  }

  Future<void> _onContractLoadByStudentRequested(
    ContractLoadByStudentRequested event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractSelecting());
    final result = await _getContractsByStudentUsecase(event.studentId);
    result.fold(
      (failure) => emit(ContractSelectError(message: failure.message)),
      (contracts) => emit(ContractLoadByStudentSuccess(contracts: contracts)),
    );
  }

  Future<void> _onContractLoadBySupervisorRequested(
    ContractLoadBySupervisorRequested event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractSelecting());
    final result = await _getContractsBySupervisorUsecase(event.supervisorId);
    result.fold(
      (failure) => emit(ContractSelectError(message: failure.message)),
      (contracts) =>
          emit(ContractLoadBySupervisorSuccess(contracts: contracts)),
    );
  }

  Future<void> _onContractGetActiveByStudentRequested(
    ContractGetActiveByStudentRequested event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractSelecting());
    final result = await _getActiveContractByStudentUsecase(event.studentId);
    result.fold(
      (failure) => emit(ContractSelectError(message: failure.message)),
      (contract) => emit(ContractGetActiveByStudentSuccess(contract: contract)),
    );
  }

  Future<void> _onContractCreateRequested(
    ContractCreateRequested event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractInserting());
    final result = await _createContractUsecase(event.contract);
    result.fold(
      (failure) => emit(ContractInsertError(message: failure.message)),
      (contract) => emit(ContractCreateSuccess(contract: contract)),
    );
  }

  Future<void> _onContractUpdateRequested(
    ContractUpdateRequested event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractUpdating());
    final result = await _updateContractUsecase(event.contract);
    result.fold(
      (failure) => emit(ContractUpdateError(message: failure.message)),
      (contract) => emit(ContractUpdateSuccess(contract: contract)),
    );
  }

  Future<void> _onContractDeleteRequested(
    ContractDeleteRequested event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractDeleting());
    try {
      await _deleteContractUsecase(event.id);
      emit(ContractDeleteSuccess(deletedId: event.id));
    } catch (e) {
      emit(ContractDeleteError(message: e.toString()));
    }
  }

  Future<void> _onContractGetStatisticsRequested(
    ContractGetStatisticsRequested event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractSelecting());
    final result = await _getContractStatisticsUsecase();
    result.fold(
      (failure) => emit(ContractSelectError(message: failure.message)),
      (statistics) =>
          emit(ContractGetStatisticsSuccess(statistics: statistics)),
    );
  }
}
