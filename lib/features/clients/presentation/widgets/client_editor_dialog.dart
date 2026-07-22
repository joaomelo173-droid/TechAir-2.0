import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/client.dart';

class ClientEditorDialog extends StatefulWidget {
  const ClientEditorDialog({
    super.key,
    required this.companyId,
    this.client,
  });

  final String companyId;
  final Client? client;

  @override
  State<ClientEditorDialog> createState() => _ClientEditorDialogState();
}

class _ClientEditorDialogState extends State<ClientEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _responsible;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _postalCode;
  late final TextEditingController _city;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    _name = TextEditingController(text: client?.name ?? '');
    _responsible = TextEditingController(text: client?.responsible ?? '');
    _phone = TextEditingController(text: client?.phone ?? '');
    _email = TextEditingController(text: client?.email ?? '');
    _address = TextEditingController(text: client?.address ?? '');
    _postalCode = TextEditingController(text: client?.postalCode ?? '');
    _city = TextEditingController(text: client?.city ?? '');
    _notes = TextEditingController(text: client?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _responsible.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _postalCode.dispose();
    _city.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.client != null;
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.apartment_rounded, color: AppColors.orange),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            editing ? 'Editar cliente' : 'Novo cliente',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const Text('Contacto principal e localização'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _field(_name, 'Nome / designação', required: true),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _field(_responsible, 'Responsável')),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _field(
                        _phone,
                        'Telefone',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _field(_email, 'Email', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _field(_address, 'Morada'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _field(_postalCode, 'Código postal')),
                    const SizedBox(width: 14),
                    Expanded(child: _field(_city, 'Localidade')),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Observações'),
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(editing ? 'Guardar alterações' : 'Criar cliente'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) => value == null || value.trim().isEmpty ? 'Campo obrigatório' : null
          : null,
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final now = DateTime.now();
    final existing = widget.client;
    Navigator.pop(
      context,
      Client(
        id: existing?.id ?? '',
        companyId: widget.companyId,
        name: _name.text.trim(),
        responsible: _responsible.text.trim(),
        taxNumber: existing?.taxNumber ?? '',
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
        postalCode: _postalCode.text.trim(),
        city: _city.text.trim(),
        notes: _notes.text.trim(),
        compressorCount: existing?.compressorCount ?? 0,
        isActive: existing?.isActive ?? true,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}
