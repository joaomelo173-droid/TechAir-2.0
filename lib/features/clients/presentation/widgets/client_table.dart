import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/client.dart';

class ClientTable extends StatelessWidget {
  const ClientTable({
    super.key,
    required this.clients,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenCompressors,
  });

  final List<Client> clients;
  final ValueChanged<Client> onEdit;
  final ValueChanged<Client> onDelete;
  final ValueChanged<Client> onOpenCompressors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppColors.surfaceElevated,
          ),
          columnSpacing: 24,
          horizontalMargin: 18,
          columns: const [
            DataColumn(label: Text("NIF")),
            DataColumn(label: Text("Cliente")),
            DataColumn(label: Text("Responsável")),
            DataColumn(label: Text("Telefone")),
            DataColumn(label: Text("Localidade")),
            DataColumn(label: Text("Compressores")),
            DataColumn(label: Text("Ações")),
          ],
          rows: clients.map((client) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    client.taxNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(Text(client.name)),
                DataCell(Text(client.responsible)),
                DataCell(Text(client.phone)),
                DataCell(Text(client.city)),
                DataCell(
                  InkWell(
                    onTap: () => onOpenCompressors(client),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        client.compressorCount.toString(),
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar',
                        onPressed: () => onEdit(client),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        tooltip: 'Eliminar',
                        onPressed: () => onDelete(client),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}