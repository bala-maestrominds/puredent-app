import '../models/payment.dart';
import 'api_client.dart';

class PaymentsService {
  PaymentsService._();
  static final PaymentsService instance = PaymentsService._();

  Future<List<Payment>> list() async {
    final data = await ApiClient.instance.get('/appointments');
    return (data as List)
        .map((e) => Payment.fromAppointmentJson(e as Map<String, dynamic>))
        .toList();
  }
}
