import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/usuario_model.dart';

/// Único punto de contacto con Firebase Auth + Firestore para el feature auth.
class AuthFirebaseDataSource {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthFirebaseDataSource({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore.collection(FirestorePaths.usuarios);

  Future<UsuarioModel> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _obtenerPerfil(credential.user!.uid);
  }

  Future<UsuarioModel> register({
    required String nombre,
    required String cedula,
    required String telefono,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final modelo = UsuarioModel(
      uid: uid,
      nombre: nombre,
      cedula: cedula,
      telefono: telefono,
      email: email,
      fechaRegistro: DateTime.now(),
    );
    await _usuarios.doc(uid).set(modelo.toMap());
    return modelo;
  }

  /// Inicia sesión con Google. Si es la primera vez (no hay perfil en
  /// Firestore), crea el documento de usuario con los datos de la cuenta
  /// Google; los campos que Google no provee (cédula, teléfono) quedan vacíos
  /// para completar luego en Editar perfil.
  Future<UsuarioModel> loginConGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw fb.FirebaseAuthException(
        code: 'cancelado-por-usuario',
        message: 'Inicio de sesión con Google cancelado.',
      );
    }
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    final docRef = _usuarios.doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      final modelo = UsuarioModel(
        uid: user.uid,
        nombre: user.displayName ?? googleUser.displayName ?? 'Agricultor',
        cedula: '',
        telefono: '',
        email: user.email ?? googleUser.email,
        fotoUrl: user.photoURL,
        fechaRegistro: DateTime.now(),
      );
      await docRef.set(modelo.toMap());
      return modelo;
    }
    return UsuarioModel.fromMap(user.uid, doc.data()!);
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<UsuarioModel?> usuarioActual() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _obtenerPerfil(user.uid);
  }

  Future<UsuarioModel> actualizarPerfil({
    required String uid,
    required String nombre,
    required String cedula,
    required String telefono,
    String? fotoUrl,
  }) async {
    final datos = <String, dynamic>{
      'nombre': nombre,
      'cedula': cedula,
      'telefono': telefono,
    };
    if (fotoUrl != null) {
      datos['fotoUrl'] = fotoUrl;
    }
    await _usuarios.doc(uid).update(datos);
    return _obtenerPerfil(uid);
  }

  Stream<UsuarioModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _obtenerPerfil(user.uid);
    });
  }

  Future<UsuarioModel> _obtenerPerfil(String uid) async {
    final doc = await _usuarios.doc(uid).get();
    if (!doc.exists) {
      throw fb.FirebaseAuthException(
        code: 'perfil-no-encontrado',
        message: 'No se encontró el perfil del agricultor.',
      );
    }
    return UsuarioModel.fromMap(uid, doc.data()!);
  }
}
