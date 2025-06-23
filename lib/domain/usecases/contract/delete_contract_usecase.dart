import '../../repositories/i_contract_repository.dart';

class DeleteContractUsecase {
  final IContractRepository _contractRepository;

  DeleteContractUsecase(this._contractRepository);

  Future<void> call(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID do contrato não pode estar vazio');
      }
      
      await _contractRepository.deleteContract(id);
    } catch (e) {
      throw Exception('Erro ao excluir contrato: $e');
    }
  }
}

