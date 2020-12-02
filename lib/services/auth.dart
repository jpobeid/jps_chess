import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Sign-in Anon
  Future<User> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  //Sign-out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
