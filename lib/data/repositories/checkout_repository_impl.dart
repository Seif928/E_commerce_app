import 'package:e_commerce_app/data/datasources/api_paths.dart';
import 'package:e_commerce_app/data/datasources/firestore_services.dart';
import 'package:e_commerce_app/data/models/payment_card_model.dart';
import 'package:e_commerce_app/domain/entities/payment_card.dart';
import 'package:e_commerce_app/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final firestoreServices = FirestoreServices.instance;

  @override
  Future<void> setNewCard(String userId, PaymentCard paymentCard) async {
    final cardModel = paymentCard is PaymentCardModel
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
  Future<List<PaymentCard>> fetchPaymentMethods(String userId) async =>
      await firestoreServices.getCollection<PaymentCardModel>(
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
}