abstract interface class WorkshopJobNumberGenerator {
  Future<String> generate({
    required String companyId,
  });
}
