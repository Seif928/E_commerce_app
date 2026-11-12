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
  List<PaymentCard> _cachedCards = const [];
  List<PaymentCard> get cachedCards => List.unmodifiable(_cachedCards);
  final CheckoutRepository _checkoutRepository;
  final AuthRepository _authRepository;

  String _normalizeExpiry(String raw) {
    final trimmed = raw.trim();
    final slashFourYear = RegExp(r'^(0[1-9]|1[0-2])/20(\d{2})$').firstMatch(
      trimmed,
    );
    if (slashFourYear != null) {
      return '${slashFourYear.group(1)}/${slashFourYear.group(2)}';
    }
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length == 4) {
      return '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2, 4)}';
    }
    if (digitsOnly.length == 6 && digitsOnly.substring(2, 4) == '20') {
      return '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(4, 6)}';
    }
    return trimmed;
  }

  Future<void> addNewCard(
    String cardNumber,
    String cardHolderName,
    String expiryDate,
    String cvv,
  ) async {
    emit(AddNewCardLoading());
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(AddNewCardFailure('User is not logged in'));
        return;
      }
      final existingCards = await _checkoutRepository.fetchPaymentMethods(
        currentUserId,
      );
      for (final card in existingCards) {
        if (card.isChosen) {
          await _checkoutRepository.setNewCard(
            currentUserId,
            card.copyWith(isChosen: false),
          );
        }
      }

      final cleanedDigits = cardNumber.replaceAll(RegExp(r'[\s-]+'), '');
      final newCard = PaymentCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardNumber: cleanedDigits,
        cardHolderName: cardHolderName.trim(),
        expiryDate: _normalizeExpiry(expiryDate),
        cvv: cvv.trim(),
        isChosen: true,
      );
      await _checkoutRepository.setNewCard(currentUserId, newCard);
      _cachedCards = [
        for (final c in _cachedCards) c.copyWith(isChosen: false),
        newCard,
      ];
      selectedPaymentId = newCard.id;
      if (isClosed) return;
      emit(AddNewCardSuccess());
    } catch (e) {
      if (isClosed) return;
      emit(AddNewCardFailure(e.toString()));
    }
  }

  Future<void> fetchPaymentMethods() async {
    emit(FetchingPaymentMethods());
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(FetchPaymentMethodsError('User is not logged in'));
        return;
      }
      final paymentCards = await _checkoutRepository.fetchPaymentMethods(
        currentUserId,
      );
      _cachedCards = paymentCards;
      PaymentCard? chosenPaymentMethod;
      for (final card in paymentCards) {
        if (card.isChosen) {
          chosenPaymentMethod = card;
          break;
        }
      }
      chosenPaymentMethod ??=
          paymentCards.isNotEmpty ? paymentCards.first : null;
      selectedPaymentId = chosenPaymentMethod?.id;
      if (isClosed) return;
      emit(
        FetchedPaymentMethods(
          paymentCards,
          selectedPaymentId: selectedPaymentId,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(FetchPaymentMethodsError(e.toString()));
    }
  }

  Future<void> changePaymentMethod(String id) async {
    selectedPaymentId = id;
    _cachedCards = _cachedCards
        .map((c) => c.copyWith(isChosen: c.id == id))
        .toList();
    emit(FetchedPaymentMethods(_cachedCards, selectedPaymentId: id));

    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(FetchPaymentMethodsError('User is not logged in'));
        return;
      }

      // Persist active choice immediately so closing a bottom sheet preserves it.
      final allPaymentMethods = await _checkoutRepository.fetchPaymentMethods(
        currentUserId,
      );
      for (final card in allPaymentMethods) {
        if (card.id == id && !card.isChosen) {
          await _checkoutRepository.setNewCard(
            currentUserId,
            card.copyWith(isChosen: true),
          );
        } else if (card.id != id && card.isChosen) {
          await _checkoutRepository.setNewCard(
            currentUserId,
            card.copyWith(isChosen: false),
          );
        }
      }
    } catch (e) {
      if (isClosed) return;
      emit(FetchPaymentMethodsError(e.toString()));
    }
  }

  Future<void> deletePaymentMethod(String id) async {
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(FetchPaymentMethodsError('User is not logged in'));
        return;
      }
      await _checkoutRepository.deletePaymentCard(currentUserId, id);
      final remaining = await _checkoutRepository.fetchPaymentMethods(
        currentUserId,
      );
      if (remaining.isNotEmpty && !remaining.any((c) => c.isChosen)) {
        await _checkoutRepository.setNewCard(
          currentUserId,
          remaining.first.copyWith(isChosen: true),
        );
      }
      if (selectedPaymentId == id) {
        selectedPaymentId = null;
      }
      await fetchPaymentMethods();
    } catch (e) {
      if (isClosed) return;
      emit(FetchPaymentMethodsError(e.toString()));
    }
  }

  Future<void> confirmPaymentMethod() async {
    emit(ConfirmPaymentLoading());
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null || selectedPaymentId == null) {
        emit(ConfirmPaymentFailure('Please select or add a payment card first'));
        return;
      }
      final allPaymentMethods = await _checkoutRepository.fetchPaymentMethods(
        currentUserId,
      );
      if (allPaymentMethods.isEmpty) {
        emit(ConfirmPaymentFailure('Please add a payment card first'));
        return;
      }
      for (final card in allPaymentMethods) {
        if (card.isChosen && card.id != selectedPaymentId) {
          await _checkoutRepository.setNewCard(
            currentUserId,
            card.copyWith(isChosen: false),
          );
        }
      }
      var chosenPaymentMethod = await _checkoutRepository
          .fetchSinglePaymentMethod(currentUserId, selectedPaymentId!);
      chosenPaymentMethod = chosenPaymentMethod.copyWith(isChosen: true);
      await _checkoutRepository.setNewCard(currentUserId, chosenPaymentMethod);
      if (isClosed) return;
      emit(ConfirmPaymentSuccess());
    } catch (e) {
      if (isClosed) return;
      emit(ConfirmPaymentFailure(e.toString()));
    }
  }
}
