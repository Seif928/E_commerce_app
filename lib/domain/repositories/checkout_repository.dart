import 'package:e_commerce_app/domain/entities/cart_item.dart';
import 'package:e_commerce_app/domain/entities/location.dart';
import 'package:e_commerce_app/domain/entities/payment_card.dart';

abstract class CheckoutRepository {
  Future<void> setNewCard(String userId, PaymentCard paymentCard);
  Future<void> deletePaymentCard(String userId, String paymentId);
  Future<List<PaymentCard>> fetchPaymentMethods(String userId);
  Future<PaymentCard> fetchSinglePaymentMethod(
    String userId,
    String paymentId,
  );
  Future<List<Map<String, dynamic>>> fetchOrders(String userId);
  Future<void> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double subtotal,
    required double shipping,
    required double totalAmount,
    required Location address,
    PaymentCard? paymentCard,
    bool isCashOnDelivery = false,
  });
}
