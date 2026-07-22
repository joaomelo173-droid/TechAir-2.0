import '../entities/reception.dart';

abstract interface class ReceptionRepository {
  /// Lista todas as receções da empresa em tempo real.
  Stream<List<Reception>> watchReceptions({
    required String companyId,
  });

  /// Lista as receções associadas a um cliente.
  Stream<List<Reception>> watchClientReceptions({
    required String companyId,
    required String clientId,
  });

  /// Lista as receções associadas a um compressor.
  Stream<List<Reception>> watchCompressorReceptions({
    required String companyId,
    required String compressorId,
  });

  /// Obtém uma receção pelo identificador.
  Future<Reception?> getReception({
    required String companyId,
    required String receptionId,
  });

  /// Cria uma nova receção e devolve o ID gerado.
  Future<String> createReception({
    required Reception reception,
  });

  /// Atualiza uma receção existente.
  Future<void> updateReception({
    required Reception reception,
  });

  /// Cancela uma receção sem a apagar definitivamente.
  Future<void> cancelReception({
    required String companyId,
    required String receptionId,
  });

  /// Elimina definitivamente uma receção.
  ///
  /// Deve ser utilizado apenas quando for mesmo necessário,
  /// porque normalmente uma receção deve ser cancelada para
  /// manter o histórico.
  Future<void> deleteReception({
    required String companyId,
    required String receptionId,
  });
}