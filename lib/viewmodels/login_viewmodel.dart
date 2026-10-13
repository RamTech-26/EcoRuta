import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _logueado = false;
  bool _cargando = false;
  String? _error;

  bool get logueado => _logueado;
  bool get cargando => _cargando;
  String? get error => _error;

  bool _ocultarContrasena = true;
  bool get ocultarContrasena => _ocultarContrasena;

  void alternarVisibilidadContrasena() {
    _ocultarContrasena = !_ocultarContrasena;
    notifyListeners();
  }

  Future<void> login(String email, String pass) async {
    if (email.trim().isEmpty || pass.trim().isEmpty) {
      _error = 'Completá email y contraseña';
      notifyListeners();
      return;
    }
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: pass.trim(),
      );
      _logueado = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _error = 'No existe una cuenta con ese email';
      } else if (e.code == 'wrong-password') {
        _error = 'Contraseña incorrecta';
      } else {
        _error = 'Error al iniciar sesión';
      }
    } catch (_) {
      _error = 'Error al iniciar sesión';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }


  Future<void> loginConGoogle() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // El usuario canceló el login
        _cargando = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _logueado = true;
    } on FirebaseAuthException catch (e) {
      _error = 'Error al iniciar sesión con Google';
    } catch (_) {
      _error = 'Error al iniciar sesión con Google';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}