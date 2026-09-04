import 'package:e_commerce_app/data/datasources/api_paths.dart';
import 'package:e_commerce_app/data/datasources/firestore_services.dart';
import 'package:e_commerce_app/data/models/user_data.dart';
import 'package:e_commerce_app/domain/entities/app_user.dart';
import 'package:e_commerce_app/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  Future<void> _initGoogleSignIn() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  @override
  Future<bool> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null;
    } on FirebaseAuthException {
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null;
    } on FirebaseAuthException {
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithGoogle() async {
    try {
      await _initGoogleSignIn();

      final GoogleSignInAccount gUser = await _googleSignIn.authenticate();

      final idToken = gUser.authentication.idToken;

      final authorization = await gUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: authorization.accessToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return userCredential.user != null;
    } on GoogleSignInException {
      return false;
    } on FirebaseAuthException {
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithFacebook() async {
    try {
      final loginResult = await FacebookAuth.instance.login();
      if (loginResult.status != LoginStatus.success) {
        return false;
      }

      final accessToken = loginResult.accessToken;
      if (accessToken == null) {
        return false;
      }

      final credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return userCredential.user != null;
    } on FirebaseAuthException {
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
  }

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Future<void> saveUserData(AppUser user) async {
    final currentUser = _firebaseAuth.currentUser;
    final providerId =
        currentUser?.providerData.isNotEmpty == true
            ? currentUser!.providerData.first.providerId
            : 'password';
    final userData = UserData(
      id: user.id,
      username: user.username,
      password: user.password,
      email: user.email,
      createdAt: user.createdAt,
      providerId: providerId,
    );
    await FirestoreServices.instance.setData(
      path: ApiPaths.user(user.id),
      data: userData.toMap(),
    );
  }
}