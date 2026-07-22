import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReceptionPhotosField extends StatefulWidget {
  const ReceptionPhotosField({
    super.key,
    required this.onPhotosChanged,
    this.initialPhotos = const [],
    this.enabled = true,
  });

  final List<XFile> initialPhotos;
  final ValueChanged<List<XFile>> onPhotosChanged;
  final bool enabled;

  @override
  State<ReceptionPhotosField> createState() =>
      _ReceptionPhotosFieldState();
}

class _ReceptionPhotosFieldState
    extends State<ReceptionPhotosField> {
  final ImagePicker _imagePicker = ImagePicker();

  late final List<XFile> _photos;

  bool _openingCamera = false;

  @override
  void initState() {
    super.initState();

    _photos = List<XFile>.from(
      widget.initialPhotos,
    );
  }

  Future<void> _takePhoto() async {
    if (!widget.enabled || _openingCamera) {
      return;
    }

    setState(() {
      _openingCamera = true;
    });

    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 2000,
      );

      if (photo == null || !mounted) {
        return;
      }

      setState(() {
        _photos.add(photo);
      });

      widget.onPhotosChanged(
        List<XFile>.unmodifiable(_photos),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível abrir a câmara: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingCamera = false;
        });
      }
    }
  }

  void _removePhoto(XFile photo) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _photos.remove(photo);
    });

    widget.onPhotosChanged(
      List<XFile>.unmodifiable(_photos),
    );
  }

  Future<void> _showPhoto(XFile photo) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 5,
                child: Image.file(
                  File(photo.path),
                  fit: BoxFit.contain,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          'Não foi possível mostrar a fotografia.',
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filled(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotografias da receção',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Fotografe o compressor, a chapa, o contador de horas, '
          'danos visíveis e acessórios entregues.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final photo in _photos)
              _PhotoPreview(
                photo: photo,
                enabled: widget.enabled,
                onTap: () => _showPhoto(photo),
                onRemove: () => _removePhoto(photo),
              ),
            _AddPhotoButton(
              loading: _openingCamera,
              enabled: widget.enabled,
              onPressed: _takePhoto,
            ),
          ],
        ),
        if (_photos.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            '${_photos.length} '
            '${_photos.length == 1 ? 'fotografia' : 'fotografias'}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.photo,
    required this.enabled,
    required this.onTap,
    required this.onRemove,
  });

  final XFile photo;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onTap,
                child: Image.file(
                  File(photo.path),
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const ColoredBox(
                      color: Colors.black12,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (enabled)
            Positioned(
              top: -8,
              right: -8,
              child: IconButton.filled(
                tooltip: 'Remover fotografia',
                onPressed: onRemove,
                icon: const Icon(
                  Icons.close,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: OutlinedButton(
        onPressed:
            enabled && !loading ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const CircularProgressIndicator()
            : const Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Adicionar foto',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}