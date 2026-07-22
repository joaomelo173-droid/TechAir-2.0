abstract interface class ReceptionPhotoStorage {
  /// Envia uma fotografia e devolve o URL público.
  Future<String> uploadPhoto({
    required String companyId,
    required String receptionId,
    required String localFilePath,
  });

  /// Apaga uma fotografia através do URL guardado.
  Future<void> deletePhoto({
    required String photoUrl,
  });
}
