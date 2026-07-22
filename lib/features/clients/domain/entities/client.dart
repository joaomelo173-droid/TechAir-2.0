class Client {
  const Client({
    required this.id,
    required this.companyId,
    required this.name,
    required this.responsible,
    required this.taxNumber,
    required this.phone,
    required this.email,
    required this.address,
    required this.postalCode,
    required this.city,
    required this.notes,
    required this.compressorCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;

  final String name;
  final String responsible;
  final String taxNumber;

  final String phone;
  final String email;

  final String address;
  final String postalCode;
  final String city;

  final String notes;

  final int compressorCount;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  String get locationLabel {
    if (postalCode.isEmpty && city.isEmpty) {
      return '';
    }

    return '$postalCode $city'.trim();
  }

  Client copyWith({
    String? id,
    String? companyId,
    String? name,
    String? responsible,
    String? taxNumber,
    String? phone,
    String? email,
    String? address,
    String? postalCode,
    String? city,
    String? notes,
    int? compressorCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      responsible: responsible ?? this.responsible,
      taxNumber: taxNumber ?? this.taxNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      compressorCount: compressorCount ?? this.compressorCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
