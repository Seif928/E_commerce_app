import 'package:e_commerce_app/data/datasources/api_paths.dart';
import 'package:e_commerce_app/data/datasources/firestore_services.dart';
import 'package:e_commerce_app/data/models/add_to_cart_model.dart';
import 'package:e_commerce_app/data/models/payment_card_model.dart';
import 'package:e_commerce_app/domain/entities/cart_item.dart';
import 'package:e_commerce_app/domain/entities/location.dart';
import 'package:e_commerce_app/domain/entities/payment_card.dart';
import 'package:e_commerce_app/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final firestoreServices = FirestoreServices.instance;

  @override
  Future<void> setNewCard(String userId, PaymentCard paymentCard) async {
    final cardModel =
        paymentCard is PaymentCardModel
            ? paymentCard
            : PaymentCardModel(
              id: paymentCard.id,
              cardNumber: paymentCard.cardNumber,
              cardHolderName: paymentCard.cardHolderName,
              expiryDate: paymentCard.expiryDate,
              cvv: paymentCard.cvv,
              isChosen: paymentCard.isChosen,
            );
    await firestoreServices.setData(
      path: ApiPaths.paymentCard(userId, paymentCard.id),
      data: cardModel.toMap(),
    );
  }

  @override
  Future<void> deletePaymentCard(String userId, String paymentId) async =>
      await firestoreServices.deleteData(
        path: ApiPaths.paymentCard(userId, paymentId),
      );

  @override
  Future<List<PaymentCard>> fetchPaymentMethods(String userId) async =>
      await firestoreServices.getCollection<PaymentCard>(
        path: ApiPaths.paymentCards(userId),
        builder: (data, documentId) => PaymentCardModel.fromMap(data),
      );

  @override
  Future<PaymentCard> fetchSinglePaymentMethod(
    String userId,
    String paymentId,
  ) async => await firestoreServices.getDocument<PaymentCard>(
    path: ApiPaths.paymentCard(userId, paymentId),
    builder: (data, documentId) => PaymentCardModel.fromMap(data),
  );

  @override
  Future<List<Map<String, dynamic>>> fetchOrders(String userId) async {
    return await firestoreServices.getCollection<Map<String, dynamic>>(
      path: ApiPaths.orders(userId),
      builder: (data, documentId) => data,
      queryBuilder: (query) => query.orderBy('createdAt', descending: true),
    );
  }

  @override
  Future<void> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double subtotal,
    required double shipping,
    required double totalAmount,
    required Location address,
    PaymentCard? paymentCard,
    bool isCashOnDelivery = false,
  }) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    String paymentLabel = 'Cash on Delivery';
    if (!isCashOnDelivery && paymentCard != null) {
      final digits = paymentCard.cardNumber.replaceAll(RegExp(r'\s+'), '');
      final maskedLast4 =
          digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
      paymentLabel = 'Card ending in $maskedLast4';
    }

    final orderItems =
        items
            .map(
              (item) =>
                  (item is AddToCartModel
                          ? item
                          : AddToCartModel(
                            id: item.id,
                            product: item.product,
                            size: item.size,
                            quantity: item.quantity,
                          ))
                      .toMap(),
            )
            .toList();

    await firestoreServices.setData(
      path: ApiPaths.order(userId, orderId),
      data: {
        'id': orderId,
        'userId': userId,
        'items': orderItems,
        'subtotal': subtotal,
        'shipping': shipping,
        'totalAmount': totalAmount,
        'shippingAddress': '${address.city}, ${address.country}',
        'paymentMethod': paymentLabel,
        'status': 'pending',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      },
    );

    for (final item in items) {
      await firestoreServices.deleteData(
        path: ApiPaths.cartItem(userId, item.id),
      );
    }
  }
}
