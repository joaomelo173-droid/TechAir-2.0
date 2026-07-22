import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/services/reception_photo_storage.dart';

class FirebaseReceptionPhotoStorage implements ReceptionPhotoStorage {
  FirebaseReceptionPhotoStorage({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<String> uploadPhoto({
    required String companyId,
    required String receptionId,
    required String localFilePath,
  }) async {
    if (companyId.trim().isEmpty) {
      throw ArgumentError(
        'O ID da empresa é obrigatório.',
      );
    }

    if (receptionId.trim().isEmpty) {
      throw ArgumentError(
        'O ID da receção é obrigatório.',
      );
    }

    if (localFilePath.trim().isEmpty) {
      throw ArgumentError(
        'O caminho da fotografia é obrigatório.',
      );
    }

    final file = File(localFilePath);

    if (!await file.exists()) {
      throw StateError(
        'A fotografia não existe no dispositivo.',
      );
    }

    final fileName = _createFileName(localFilePath);

    final reference = _storage
        .ref()
        .child('empresas')
        .child(companyId)
        .child('rececoes')
        .child(receptionId)
        .child('fotos')
        .child(fileName);

    final metadata = SettableMetadata(
      contentType: _contentTypeFromPath(localFilePath),
      customMetadata: {
        'companyId': companyId,
        'receptionId': receptionId,
      },
    );

    final uploadTask = await reference.putFile(
      file,
      metadata,
    );

    return uploadTask.ref.getDownloadURL();
  }

  @override
  Future<void> deletePhoto({
    required String photoUrl,
  }) async {
    if (photoUrl.trim().isEmpty) {
      return;
    }

    try {
      final reference = _storage.refFromURL(photoUrl);
      await reference.delete();
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found') {
        return;
      }

      rethrow;
    }
  }

  String _createFileName(String localFilePath) {
    final extension = _extensionFromPath(localFilePath);
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    return 'rececao_$timestamp$extension';
  }

  String _extensionFromPath(String path) {
    final normalizedPath = path.toLowerCase();

    if (normalizedPath.endsWith('.png')) {
      return '.png';
    }

    if (normalizedPath.endsWith('.heic')) {
      return '.heic';
    }

    if (normalizedPath.endsWith('.webp')) {
      return '.webp';
    }

    return '.jpg';
  }

  String _contentTypeFromPath(String path) {
    final normalizedPath = path.toLowerCase();

    if (normalizedPath.endsWith('.png')) {
      return 'image/png';
    }

    if (normalizedPath.endsWith('.heic')) {
      return 'image/heic';
    }

    if (normalizedPath.endsWith('.webp')) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }
}
