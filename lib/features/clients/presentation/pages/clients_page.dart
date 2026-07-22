import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import '../../../../core/constants/app_colors.dart';
import '../../data/repositories/firestore_client_repository.dart';
import '../../domain/entities/client.dart';
import '../controllers/clients_controller.dart';
import '../widgets/client_card.dart';
import '../widgets/client_editor_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/import/client_excel_reader.dart';
import '../../data/import/client_excel_importer.dart';
import '../../../compressors/presentation/pages/compressors_page.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  late final ClientsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ClientsController(
      repository: FirestoreClientRepository(FirebaseFirestore.instance),
      companyId: 'extincendios',
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
  onCreate: () => _openEditor(),
  onImport: _importExcel,
),
              const SizedBox(height: 22),
              _Toolbar(
                count: _controller.clients.length,
                onSearch: _controller.search,
                onRefresh: _controller.load,
              ),
              const SizedBox(height: 18),
              Expanded(child: _body()),
            ],
          ),
        );
      },
    );
  }

  Widget _body() {
    if (_controller.loading && _controller.clients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error case final error?) {
      return Center(child: Text(error));
    }
    if (_controller.clients.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _controller.clients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final client = _controller.clients[index];
          return ClientCard(
  client: client,
  onOpenDetails: () => _openCompressors(client),
  onEdit: () => _openEditor(client),
  onDelete: () => _confirmDelete(client),
  onOpenCompressors: () => _openCompressors(client),
);
        },
      ),
    );
  }

  Future<void> _importExcel() async {
  try {
    final pickerResult = await file_picker.FilePicker.pickFiles(
      dialogTitle: 'Selecionar ficheiro Excel',
      type: file_picker.FileType.custom,
      allowedExtensions: const ['xlsx'],
      allowMultiple: false,
      withData: true,
    );

    if (!mounted ||
        pickerResult == null ||
        pickerResult.files.isEmpty) {
      return;
    }

    final file = pickerResult.files.single;
    final bytes = file.bytes;

    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível ler o ficheiro.'),
        ),
      );
      return;
    }

    final importResult = const ClientExcelReader().read(
      fileName: file.name,
      bytes: bytes,
    );

    final summary = await ClientExcelImporter(
      firestore: FirebaseFirestore.instance,
      companyId: _controller.companyId,
    ).import(importResult);

    await _controller.load();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Importação concluída. '
          '${summary.createdClients} clientes criados • '
          '${summary.updatedClients} atualizados • '
          '${summary.processedRows} linhas processadas.',
        ),
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao importar o Excel: $error'),
      ),
    );
  }
}

  Future<void> _openEditor([Client? client]) async {
    final result = await showDialog<Client>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ClientEditorDialog(
        companyId: _controller.companyId,
        client: client,
      ),
    );
    if (result == null) return;
    final saved = await _controller.save(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? (client == null ? 'Cliente criado.' : 'Cliente atualizado.')
              : (_controller.error ?? 'Não foi possível guardar o cliente.'),
        ),
      ),
    );
    if (!saved) _controller.clearError();
  }

  Future<void> _confirmDelete(Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cliente?'),
        content: Text('O cliente “${client.name}” será eliminado permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed != true) return;
    final deleted = await _controller.delete(client);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Cliente eliminado.'
              : (_controller.error ?? 'Não foi possível eliminar o cliente.'),
        ),
      ),
    );
    if (!deleted) _controller.clearError();
  }

  void _openCompressors(Client client) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CompressorsPage(
        client: client,
      ),
    ),
  );
}
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onCreate,
    required this.onImport,
  });

  final VoidCallback onCreate;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clientes', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('Contactos, moradas, equipamentos e histórico documental.'),
            ],
          ),
        ),
        Wrap(
  spacing: 12,
  children: [
    OutlinedButton.icon(
      onPressed: onImport,
      icon: const Icon(Icons.upload_file_rounded),
      label: const Text('Importar Excel'),
    ),
    FilledButton.icon(
      onPressed: onCreate,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Novo cliente'),
    ),
  ],
),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.count, required this.onSearch, required this.onRefresh});

  final int count;
  final ValueChanged<String> onSearch;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'Pesquisar por nome, responsável, telefone, email ou localidade…',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count clientes', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: onRefresh, tooltip: 'Atualizar', icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_search_rounded, size: 54, color: AppColors.textSecondary),
          const SizedBox(height: 14),
          Text('Nenhum cliente encontrado', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text('Altera a pesquisa ou cria um novo cliente.'),
        ],
      ),
    );
  }
}
