import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/reception.dart';
import '../controllers/reception_catalog_controller.dart';
import '../widgets/reception_general_section.dart';
import '../widgets/reception_photos_field.dart';
import '../widgets/reception_reasons_section.dart';
import '../../data/repositories/firestore_reception_repository.dart';
import '../../data/services/firebase_reception_photo_storage.dart';
import '../controllers/reception_controller.dart';

class NewReceptionPage extends StatefulWidget {
  const NewReceptionPage({super.key});

  @override
  State<NewReceptionPage> createState() => _NewReceptionPageState();
}

class _NewReceptionPageState extends State<NewReceptionPage> {
  final _formKey = GlobalKey<FormState>();

  late final ReceptionCatalogController _catalogController;

  late final ReceptionController _receptionController;

  bool _saving = false;

  final _receivedByController = TextEditingController();

  final _expectedMaintenanceController = TextEditingController();

  final _reportedFaultController = TextEditingController();

  final _expectedRepairController = TextEditingController();

  final _expectedModernizationController = TextEditingController();

  final _observationsController = TextEditingController();

  final DateTime _receivedAt = DateTime.now();

  final Set<ReceptionReason> _selectedReasons = {};

  final Set<CompressorFaultType> _selectedFaultTypes = {};

  List<XFile> _selectedPhotos = [];

  String? _selectedClientId;
  String? _selectedCompressorId;

  List<ReceptionSelectOption> get _clients {
    return _catalogController.clients
        .map(
          (client) => ReceptionSelectOption(
            id: client.id,
            label: client.name,
            subtitle: client.subtitle,
          ),
        )
        .toList(growable: false);
  }

  List<ReceptionSelectOption> get _compressors {
    return _catalogController.compressors
        .map(
          (compressor) => ReceptionSelectOption(
            id: compressor.id,
            label: compressor.name,
            subtitle: compressor.subtitle,
          ),
        )
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();

    _catalogController = ReceptionCatalogController(
      FirebaseFirestore.instance,
      companyId: 'extincendios',
    );

    _receptionController = ReceptionController(
      repository: FirestoreReceptionRepository(),
      photoStorage: FirebaseReceptionPhotoStorage(),
    );

    _catalogController.loadClients();
  }

  @override
  void dispose() {
    _catalogController.dispose();

    _receivedByController.dispose();
    _expectedMaintenanceController.dispose();
    _reportedFaultController.dispose();
    _expectedRepairController.dispose();
    _expectedModernizationController.dispose();
    _observationsController.dispose();

    super.dispose();
  }

  Future<void> _handleClientChanged(
    String? clientId,
  ) async {
    setState(() {
      _selectedClientId = clientId;
      _selectedCompressorId = null;
    });

    if (clientId == null || clientId.trim().isEmpty) {
      _catalogController.clearCompressors();
      return;
    }

    await _catalogController.loadCompressors(
      clientId,
    );
  }

  void _handleCompressorChanged(
    String? compressorId,
  ) {
    setState(() {
      _selectedCompressorId = compressorId;
    });
  }

  void _handleReasonChanged(
    ReceptionReason reason,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        _selectedReasons.add(reason);
        return;
      }

      _selectedReasons.remove(reason);

      switch (reason) {
        case ReceptionReason.maintenance:
          _expectedMaintenanceController.clear();

        case ReceptionReason.breakdown:
          _selectedFaultTypes.clear();
          _reportedFaultController.clear();
          _expectedRepairController.clear();

        case ReceptionReason.modernization:
          _expectedModernizationController.clear();
      }
    });
  }

  void _handleFaultTypeChanged(
    CompressorFaultType faultType,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        _selectedFaultTypes.add(faultType);
      } else {
        _selectedFaultTypes.remove(faultType);
      }
    });
  }

  void _handlePhotosChanged(
    List<XFile> photos,
  ) {
    setState(() {
      _selectedPhotos = List<XFile>.from(
        photos,
      );
    });
  }

  Future<void> _saveReception() async {
    FocusScope.of(context).unfocus();

    if (_saving) {
      return;
    }

    final clientId = _selectedClientId;
    final compressorId = _selectedCompressorId;

    if (clientId == null || clientId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o cliente.'),
        ),
      );

      return;
    }

    if (compressorId == null || compressorId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o compressor.'),
        ),
      );

      return;
    }

    if (_selectedReasons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione pelo menos um motivo de entrada.',
          ),
        ),
      );

      return;
    }

    final hasBreakdown = _selectedReasons.contains(
      ReceptionReason.breakdown,
    );

    if (hasBreakdown && _selectedFaultTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione pelo menos um tipo de avaria.',
          ),
        ),
      );

      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final selectedClient = _catalogController.clients
        .where((client) => client.id == clientId)
        .firstOrNull;

    final selectedCompressor = _catalogController.compressors
        .where(
          (compressor) => compressor.id == compressorId,
        )
        .firstOrNull;

    if (selectedClient == null || selectedCompressor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível obter os dados do cliente ou do compressor.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final now = DateTime.now();

      final reception = Reception(
        id: '',
        companyId: 'extincendios',
        clientId: clientId,
        compressorId: compressorId,
        clientName: selectedClient.name,
        compressorName: selectedCompressor.name,
        receivedAt: _receivedAt,
        receivedBy: _receivedByController.text.trim(),
        reasons: _selectedReasons.toList(),
        expectedMaintenance: _expectedMaintenanceController.text.trim(),
        faultTypes: _selectedFaultTypes.toList(),
        reportedFault: _reportedFaultController.text.trim(),
        expectedRepair: _expectedRepairController.text.trim(),
        expectedModernization: _expectedModernizationController.text.trim(),
        observations: _observationsController.text.trim(),
        photoUrls: const [],
        status: ReceptionStatus.received,
        workshopJobId: '',
        createdAt: now,
        updatedAt: now,
      );

      await _receptionController.createReception(
        reception: reception,
        localPhotoPaths: _selectedPhotos
            .map((photo) => photo.path)
            .where((path) => path.trim().isNotEmpty)
            .toList(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Receção guardada com sucesso.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível guardar a receção: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Receção'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _catalogController,
          builder: (context, _) {
            return Column(
              children: [
                if (_catalogController.loadingClients ||
                    _catalogController.loadingCompressors)
                  const LinearProgressIndicator(),
                if (_catalogController.error case final error?)
                  _ErrorBanner(
                    message: error,
                    onRetry: _retryCatalogLoading,
                    onClose: _catalogController.clearError,
                  ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ReceptionGeneralSection(
                          clients: _clients,
                          compressors: _compressors,
                          selectedClientId: _selectedClientId,
                          selectedCompressorId: _selectedCompressorId,
                          receivedAt: _receivedAt,
                          receivedByController: _receivedByController,
                          onClientChanged: _handleClientChanged,
                          onCompressorChanged: _handleCompressorChanged,
                        ),
                        const SizedBox(height: 16),
                        ReceptionReasonsSection(
                          selectedReasons: _selectedReasons,
                          onReasonChanged: _handleReasonChanged,
                          expectedMaintenanceController:
                              _expectedMaintenanceController,
                          reportedFaultController: _reportedFaultController,
                          expectedRepairController: _expectedRepairController,
                          expectedModernizationController:
                              _expectedModernizationController,
                          selectedFaultTypes: _selectedFaultTypes,
                          onFaultTypeChanged: _handleFaultTypeChanged,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(
                              16,
                            ),
                            child: ReceptionPhotosField(
                              initialPhotos: _selectedPhotos,
                              onPhotosChanged: _handlePhotosChanged,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextFormField(
                              controller: _observationsController,
                              minLines: 4,
                              maxLines: 8,
                              decoration: const InputDecoration(
                                labelText: 'Observações',
                                hintText:
                                    'Escreva aqui informações adicionais sobre a receção…',
                                alignLabelWithHint: true,
                                prefixIcon: Icon(
                                  Icons.notes_rounded,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: _catalogController.loadingClients ||
                                    _catalogController.loadingCompressors ||
                                    _saving
                                ? null
                                : _saveReception,
                            icon: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.save_outlined,
                                  ),
                            label: Text(
                              _saving ? 'A guardar...' : 'Guardar Receção',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _retryCatalogLoading() async {
    _catalogController.clearError();

    if (_selectedClientId != null) {
      await _catalogController.loadCompressors(
        _selectedClientId!,
      );

      return;
    }

    await _catalogController.loadClients();
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
    required this.onClose,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
            IconButton(
              onPressed: onClose,
              tooltip: 'Fechar',
              icon: const Icon(
                Icons.close_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
