import 'package:e_commerce_app/domain/entities/payment_card.dart';

abstract class CheckoutRepository {
  Future<void> setNewCard(String userId, PaymentCard paymentCard);
  Future<List<PaymentCard>> fetchPaymentMethods(String userId);
  Future<PaymentCard> fetchSinglePaymentMethod(
    String userId,
    String paymentId,
  );
}