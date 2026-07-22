import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/client.dart';

class ClientFirestoreMapper {
  static Client fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Client(
      id: doc.id,
      companyId: doc.reference.parent.parent?.id ?? '',
      name: data['name'] as String? ?? '',
      responsible: data['responsible'] as String? ?? '',
      taxNumber: data['taxNumber'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      address: data['address'] as String? ?? '',
      postalCode: data['postalCode'] as String? ?? '',
      city: data['city'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      compressorCount: (data['compressorCount'] ?? 0) as int,
      isActive: (data['isActive'] ?? true) as bool,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toFirestore(Client client) {
    return {
      'name': client.name,
      'responsible': client.responsible,
      'taxNumber': client.taxNumber,
      'phone': client.phone,
      'email': client.email,
      'address': client.address,
      'postalCode': client.postalCode,
      'city': client.city,
      'notes': client.notes,
      'compressorCount': client.compressorCount,
      'isActive': client.isActive,
      'createdAt': Timestamp.fromDate(client.createdAt),
      'updatedAt': Timestamp.fromDate(client.updatedAt),
    };
  }
}
