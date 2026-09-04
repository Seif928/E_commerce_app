import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/Presentation/views/widgets/empty_list_tile.dart';
import 'package:e_commerce_app/core/utils/image.dart';
import 'package:flutter/material.dart';

class ProfileBody extends StatelessWidget {
  final String username;
  final String email;
  final Size size;

  final void Function(String newUsername)? onEditUserNameProfile;
  final void Function(String newEmail)? onEditEmailProfile;
  final String? providerId;

  const ProfileBody({
    super.key,
    required this.username,
    required this.email,
    required this.size,
    this.onEditUserNameProfile,
    this.onEditEmailProfile,
    this.providerId,
  });
  Future<void> _showEditUsernameDialog(BuildContext context) async {
    final usernameController = TextEditingController(text: username);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Username'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 12),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onEditUserNameProfile!(usernameController.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditEmailDialog(BuildContext context) async {
    final emailController = TextEditingController(text: email);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onEditEmailProfile!(emailController.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: size.width * 0.2,
                backgroundImage: NetworkImage(ImageUtils.userImgUrl),
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint('Failed to load profile image: $exception');
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Username'),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: size.width * 0.02,
                  left: size.width * 0.02,
                ),
                child: InkWell(
                  onTap:
                      onEditUserNameProfile == null
                          ? null
                          : () => _showEditUsernameDialog(context),
                  borderRadius: BorderRadius.circular(8),
                  child: EmptyListTile(
                    leadingIcon: const Icon(Icons.person),
                    title: username,
                  ),
                ),
              ),
              const Text('Email'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap:
                      onEditEmailProfile == null
                          ? null
                          : () => _showEditEmailDialog(context),
                  borderRadius: BorderRadius.circular(8),
                  child: EmptyListTile(
                    leadingIcon: const Icon(Icons.email_outlined),
                    title: email,
                  ),
                ),
              ),
              const Text('Account Linked With'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildLinkedAccountTile(size),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedAccountTile(Size size) {
    Widget leading;
    String title;

    switch (providerId) {
      case 'google.com':
        leading = ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: ImageUtils.googleImgUrl,
            height: size.width * 0.09,
            width: size.width * 0.09,
            errorWidget:
                (context, url, error) => const Icon(Icons.error_outline),
            placeholder:
                (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
          ),
        );
        title = 'Google';
        break;
      case 'facebook.com':
        leading = ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: ImageUtils.faceBookImgUrl,
            height: size.width * 0.09,
            width: size.width * 0.09,
            errorWidget:
                (context, url, error) => const Icon(Icons.error_outline),
            placeholder:
                (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
          ),
        );
        title = 'Facebook';
        break;
      case 'password':
      default:
        leading = Icon(Icons.email_outlined, size: size.width * 0.08);
        title = 'Email / Password';
        break;
    }

    return EmptyListTile(
      leadingIcon: leading,
      title: title,
      trailingIcon: Icon(Icons.link_rounded),
    );
  }
}
