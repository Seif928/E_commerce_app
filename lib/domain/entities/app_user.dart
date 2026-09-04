class AppUser {
  final String id;
  final String username;
  final String email;
  final String password;
  final String createdAt;
  final String providerId;

  const AppUser({
    required this.id,
    required this.password,
    required this.username,
    required this.email,
    required this.createdAt,
    this.providerId = 'password',
  });
}