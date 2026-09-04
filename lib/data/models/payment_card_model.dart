import 'package:e_commerce_app/domain/entities/payment_card.dart';

class PaymentCardModel extends PaymentCard {
  const PaymentCardModel({
    required super.id,
    required super.cardNumber,
    required super.cardHolderName,
    required super.expiryDate,
    required super.cvv,
    super.isChosen,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'cardNumber': cardNumber});
    result.addAll({'cardHolderName': cardHolderName});
    result.addAll({'expiryDate': expiryDate});
    result.addAll({'cvv': cvv});
    result.addAll({'isChosen': isChosen});

    return result;
  }

  factory PaymentCardModel.fromMap(Map<String, dynamic> map) {
    return PaymentCardModel(
      id: map['id'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      cardHolderName: map['cardHolderName'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      cvv: map['cvv'] ?? '',
      isChosen: map['isChosen'] ?? false,
    );
  }
}