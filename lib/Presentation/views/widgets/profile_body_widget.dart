import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/views/widgets/empty_list_tile.dart';
import 'package:e_commerce_app/Presentation/views/widgets/user_avatar.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:e_commerce_app/core/utils/image.dart';
import 'package:e_commerce_app/data/repositories/checkout_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileBody extends StatelessWidget {
  final String username;
  final String email;
  final String photoUrl;
  final Size size;

  final void Function(String newUsername)? onEditUserNameProfile;
  final void Function(String newEmail)? onEditEmailProfile;
  final ValueChanged<String>? onEditPhoto;
  final String? providerId;

  const ProfileBody({
    super.key,
    required this.username,
    required this.email,
    required this.size,
    this.photoUrl = '',
    this.onEditUserNameProfile,
    this.onEditEmailProfile,
    this.onEditPhoto,
    this.providerId,
  });

  bool get _isEditMode =>
      onEditUserNameProfile != null || onEditEmailProfile != null;

  Future<void> _showEditUsernameDialog(BuildContext context) async {
    final usernameController = TextEditingController(text: username);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('edit_username')),
          content: TextField(
            controller: usernameController,
            decoration: InputDecoration(labelText: context.tr('username')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () {
                final trimmed = usernameController.text.trim();
                if (trimmed.isEmpty) return;
                Navigator.of(dialogContext).pop();
                onEditUserNameProfile?.call(trimmed);
              },
              child: Text(context.tr('save')),
            ),
          ],
        );
      },
    );
    usernameController.dispose();
  }

  Future<void> _showEditEmailDialog(BuildContext context) async {
    final emailController = TextEditingController(text: email);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('edit_email')),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: context.tr('email')),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () {
                final trimmed = emailController.text.trim();
                if (trimmed.isEmpty) return;
                Navigator.of(dialogContext).pop();
                onEditEmailProfile?.call(trimmed);
              },
              child: Text(context.tr('save')),
            ),
          ],
        );
      },
    );
    emailController.dispose();
  }

  void _showOrdersBottomSheet(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('my_orders'),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: CheckoutRepositoryImpl().fetchOrders(uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              context.isArabic
                                  ? 'فشل تحميل الطلبات: ${snapshot.error}'
                                  : 'Failed to load orders: ${snapshot.error}',
                            ),
                          );
                        }
                        final orders = snapshot.data ?? const [];
                        if (orders.isEmpty) {
                          return Center(
                            child: Text(
                              context.tr('no_orders_yet'),
                              style: const TextStyle(color: AppColors.grey1),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final items = (order['items'] as List?)?.length ?? 0;
                            final total =
                                (order['totalAmount'] as num?)?.toDouble() ??
                                0.0;
                            final status =
                                (order['status'] ?? 'pending').toString();
                            final address =
                                (order['shippingAddress'] ?? '').toString();
                            return Card(
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentSoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.local_shipping_outlined,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                                title: Text(
                                  context.isArabic
                                      ? 'طلب #${order['id']}'
                                      : 'Order #${order['id']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  context.isArabic
                                      ? '$items منتجات • $address\nالحالة: $status'
                                      : '$items item(s) • $address\nStatus: ${status.toUpperCase()}',
                                ),
                                isThreeLine: true,
                                trailing: Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [AppColors.primaryColor, Color(0xFF283044)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                UserAvatar(
                  username: username,
                  photoUrl: photoUrl,
                  radius: 34,
                  showEditBadge: onEditPhoto != null,
                  onTap:
                      onEditPhoto == null
                          ? null
                          : () => showProfilePhotoPickerSheet(
                            context,
                            currentPhotoUrl: photoUrl,
                            onPhotoSelected: onEditPhoto!,
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white1,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white1.withValues(alpha: 0.78),
                          fontSize: 13,
                        ),
                      ),
                      if (onEditPhoto != null) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap:
                              () => showProfilePhotoPickerSheet(
                                context,
                                currentPhotoUrl: photoUrl,
                                onPhotoSelected: onEditPhoto!,
                              ),
                          child: Text(
                            photoUrl.trim().isEmpty
                                ? context.tr('tap_photo_to_add')
                                : context.tr('change_photo'),
                            style: TextStyle(
                              color: AppColors.white1.withValues(alpha: 0.9),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.white1.withValues(
                                alpha: 0.65,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            context.tr('account_details'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          EmptyListTile(
            ontap:
                onEditUserNameProfile == null
                    ? null
                    : () => _showEditUsernameDialog(context),
            leadingIcon: const Icon(Icons.person_outline_rounded),
            title: username,
            subtitle: context.tr('username'),
            trailingIcon:
                onEditUserNameProfile != null
                    ? const Icon(Icons.edit_outlined, size: 20)
                    : null,
          ),
          EmptyListTile(
            ontap:
                onEditEmailProfile == null
                    ? null
                    : () => _showEditEmailDialog(context),
            leadingIcon: const Icon(Icons.email_outlined),
            title: email,
            subtitle: context.tr('email'),
            trailingIcon:
                onEditEmailProfile != null
                    ? const Icon(Icons.edit_outlined, size: 20)
                    : null,
          ),
          _buildLinkedAccountTile(context, size),
          if (!_isEditMode) ...[
            const SizedBox(height: 18),
            Text(
              context.tr('shortcuts'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            EmptyListTile(
              ontap: () => _showOrdersBottomSheet(context),
              leadingIcon: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.accentColor,
              ),
              title: context.tr('my_orders'),
              subtitle: context.tr('order_history_sub'),
              trailingIcon: const Icon(Icons.chevron_right_rounded),
            ),
            EmptyListTile(
              ontap:
                  () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed(AppRoute.paymentMethodsRoute),
              leadingIcon: const Icon(Icons.credit_card_rounded),
              title: context.tr('payment_methods'),
              subtitle: context.tr('payment_methods_sub'),
              trailingIcon: const Icon(Icons.chevron_right_rounded),
            ),
            EmptyListTile(
              ontap:
                  () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed(AppRoute.chooseLocation),
              leadingIcon: const Icon(Icons.location_on_outlined),
              title: context.tr('addresses'),
              subtitle: context.tr('saved_addresses_sub'),
              trailingIcon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkedAccountTile(BuildContext context, Size size) {
    Widget leading;
    String title;

    switch (providerId) {
      case 'google.com':
        leading = CachedNetworkImage(
          fit: BoxFit.contain,
          imageUrl: ImageUtils.googleImgUrl,
          height: 22,
          width: 22,
          errorWidget:
              (_, __, ___) => const Icon(Icons.g_mobiledata_rounded, size: 24),
        );
        title = context.isArabic ? 'حساب Google' : 'Google Account';
        break;
      case 'facebook.com':
        leading = CachedNetworkImage(
          fit: BoxFit.contain,
          imageUrl: ImageUtils.faceBookImgUrl,
          height: 22,
          width: 22,
          errorWidget: (_, __, ___) => const Icon(Icons.facebook, size: 22),
        );
        title = context.isArabic ? 'حساب Facebook' : 'Facebook Account';
        break;
      case 'password':
      default:
        leading = const Icon(Icons.verified_user_outlined, size: 22);
        title =
            context.isArabic
                ? 'البريد الإلكتروني / كلمة المرور'
                : 'Email / Password';
        break;
    }

    return EmptyListTile(
      leadingIcon: leading,
      title: title,
      subtitle: context.tr('sign_in_provider'),
      trailingIcon: const Icon(Icons.link_rounded, color: AppColors.green),
    );
  }
}
