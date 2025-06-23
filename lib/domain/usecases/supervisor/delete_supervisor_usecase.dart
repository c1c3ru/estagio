import '../../repositories/i_supervisor_repository.dart';

class DeleteSupervisorUsecase {
  final ISupervisorRepository _supervisorRepository;

  DeleteSupervisorUsecase(this._supervisorRepository);

  Future<void> call(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID do supervisor não pode estar vazio');
      }
      
      await _supervisorRepository.deleteSupervisor(id);
    } catch (e) {
      throw Exception('Erro ao excluir supervisor: $e');
    }
  }
}

