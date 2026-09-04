import 'package:e_commerce_app/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce_app/data/repositories/checkout_repository_impl.dart';
import 'package:e_commerce_app/domain/entities/payment_card.dart';
import 'package:e_commerce_app/domain/repositories/auth_repository.dart';
import 'package:e_commerce_app/domain/repositories/checkout_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'payment_methods_state.dart';

class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  PaymentMethodsCubit({
    CheckoutRepository? checkoutRepository,
    AuthRepository? authRepository,
  }) : _checkoutRepository = checkoutRepository ?? CheckoutRepositoryImpl(),
       _authRepository = authRepository ?? AuthRepositoryImpl(),
       super(PaymntMethodsInitial());

  String? selectedPaymentId;
  final CheckoutRepository _checkoutRepository;
  final AuthRepository _authRepository;

  Future<void> addNewCard(
    String cardNumber,
    String cardHolderName,
    String expiryDate,
    String cvv,
  ) async {
    emit(AddNewCardLoading());
    try {
      final newCard = PaymentCard(
        id: DateTime.now().toIso8601String(),
        cardNumber: cardNumber,
        cardHolderName: cardHolderName,
        expiryDate: expiryDate,
        cvv: cvv,
      );
      final currentUserId = _authRepository.currentUserId!;
      await _checkoutRepository.setNewCard(currentUserId, newCard);
      emit(AddNewCardSuccess());
    } catch (e) {
      emit(AddNewCardFailure(e.toString()));
    }
  }

  Future<void> fetchPaymentMethods() async {
    emit(FetchingPaymentMethods());
    try {
      final currentUserId = _authRepository.currentUserId!;
      final paymentCards = await _checkoutRepository.fetchPaymentMethods(
        currentUserId,
      );
      emit(FetchedPaymentMethods(paymentCards));
      if (paymentCards.isNotEmpty) {
        final chosenPaymentMethod = paymentCards.firstWhere(
          (element) => element.isChosen,
          orElse: () => paymentCards.first,
        );
        selectedPaymentId = chosenPaymentMethod.id;
        emit(PaymentMethodChosen(chosenPaymentMethod));
      }
    } catch (e) {
      emit(FetchPaymentMethodsError(e.toString()));
    }
  }

  Future<void> changePaymentMethod(String id) async {
    selectedPaymentId = id;
    try {
      final currentUserId = _authRepository.currentUserId!;
      final tempChosenPaymentMethod = await _checkoutRepository
          .fetchSinglePaymentMethod(currentUserId, selectedPaymentId!);
      emit(PaymentMethodChosen(tempChosenPaymentMethod));
    } catch (e) {
      emit(FetchPaymentMethodsError(e.toString()));
    }
  }

  Future<void> confirmPaymentMethod() async {
    emit(ConfirmPaymentLoading());
    try {
      final currentUserId = _authRepository.currentUserId;
      final previousChosenPayment = await _checkoutRepository
          .fetchPaymentMethods(currentUserId!);
      final previousChosenPaymentMethod = previousChosenPayment.first.copyWith(
        isChosen: false,
      );
      var chosenPaymentMethod = await _checkoutRepository
          .fetchSinglePaymentMethod(currentUserId, selectedPaymentId!);
      chosenPaymentMethod = chosenPaymentMethod.copyWith(isChosen: true);
      await _checkoutRepository.setNewCard(
        currentUserId,
        previousChosenPaymentMethod,
      );
      await _checkoutRepository.setNewCard(currentUserId, chosenPaymentMethod);
      emit(ConfirmPaymentSuccess());
    } catch (e) {
      emit(ConfirmPaymentFailure(e.toString()));
    }
  }
}