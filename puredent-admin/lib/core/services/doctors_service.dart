import '../models/doctor.dart';
import 'api_client.dart';

class DoctorsService {
  DoctorsService._();
  static final DoctorsService instance = DoctorsService._();

  Future<List<Doctor>> list({String? specialty}) async {
    final data = await ApiClient.instance.get('/doctors', query: {'specialty': specialty});
    return (data as List).map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Doctor> getById(String id) async {
    final data = await ApiClient.instance.get('/doctors/$id');
    return Doctor.fromJson(data as Map<String, dynamic>);
  }

  /// Creates a doctor. If [photoPath] is provided, uploads it as multipart;
  /// otherwise sends a plain JSON-ish (but still multipart, since the field
  /// list still needs to hit the same endpoint that expects `multipart/form-data`).
  Future<Doctor> create({
    required String name,
    required String specialty,
    required String email,
    required String phone,
    required int experienceYears,
    required num consultationFee,
    required String bio,
    required List<Map<String, String>> workingHours, // [{day, startTime, endTime}]
    String? photoPath,
  }) async {
    final fields = <String, String>{
      'name': name,
      'specialty': specialty,
      'email': email,
      'phone': phone,
      'experienceYears': experienceYears.toString(),
      'consultationFee': consultationFee.toString(),
      'bio': bio,
    };
    // multer + the JSON body validator both need workingHours; send it as a
    // JSON string field since this is a multipart request.
    fields['workingHours'] = _encodeWorkingHours(workingHours);

    final data = await ApiClient.instance.multipart(
      '/doctors',
      method: 'POST',
      fields: fields,
      fileField: photoPath != null ? 'photo' : null,
      filePath: photoPath,
    );
    return Doctor.fromJson(data as Map<String, dynamic>);
  }

  Future<Doctor> update(String id, Map<String, dynamic> updates) async {
    final data = await ApiClient.instance.patch('/doctors/$id', body: updates);
    return Doctor.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deactivate(String id) async {
    await ApiClient.instance.delete('/doctors/$id');
  }

  String _encodeWorkingHours(List<Map<String, String>> hours) {
    final items = hours.map((h) => '{"day":"${h['day']}","startTime":"${h['startTime']}","endTime":"${h['endTime']}"}');
    return '[${items.join(',')}]';
  }
}
