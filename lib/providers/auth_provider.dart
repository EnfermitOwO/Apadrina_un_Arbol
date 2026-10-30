import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import '../mongodb/mongo_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;

  AuthProvider() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  /// Inicia sesión buscando por nombre_usuario o email y verificando bcrypt
  Future<bool> login(String usuarioOrEmail, String passwordPlano) async {
    try {
      final usuariosColl = MongoService.getCollection('usuarios');

      final user = await usuariosColl.findOne({
        '\$or': [
          {'nombre_usuario': usuarioOrEmail},
          {'email': usuarioOrEmail},
        ]
      });

      if (user != null) {
        String hashedPassword = user['password'] ?? '';

        bool passwordValida = false;
        try {
          passwordValida = BCrypt.checkpw(passwordPlano, hashedPassword);
        } catch (_) {
          passwordValida = (passwordPlano == hashedPassword);
        }

        if (passwordValida) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('nombre_usuario', user['nombre_usuario'] ?? '');

          _currentUser = user;
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error en login MongoDB: $e");
      return false;
    }
  }

  /// Registra un nuevo usuario indicando el motivo en caso de duplicados
  Future<String?> register(String nombreUsuario, String email, String passwordPlano) async {
    try {
      final usuariosColl = MongoService.getCollection('usuarios');

      // 1. Revisa específicamente si el correo ya existe
      final existingEmail = await usuariosColl.findOne({'email': email});
      if (existingEmail != null) {
        return 'CORREO_DUPLICADO'; // Detiene el registro
      }

      // 2. Revisa específicamente si el nombre de usuario ya existe
      final existingUsername = await usuariosColl.findOne({'nombre_usuario': nombreUsuario});
      if (existingUsername != null) {
        return 'USUARIO_DUPLICADO'; // Detiene el registro
      }

      // 3. Si ambos están libres, procede con la inserción
      String hashedPassword = BCrypt.hashpw(passwordPlano, BCrypt.gensalt());
      int customId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await usuariosColl.insertOne({
        'id': customId,
        'nombre_usuario': nombreUsuario,
        'nombre': nombreUsuario,
        'email': email,
        'password': hashedPassword,
        'verificado': 1,
        'id_rol': 2,
        'fecha_registro': DateTime.now().toIso8601String(),
      });

      // Autentica automáticamente tras insertar
      await login(nombreUsuario, passwordPlano);
      return null; // Retorna null cuando NO HUBO ERRORES
    } catch (e) {
      debugPrint("Error en registro MongoDB: $e");
      return 'ERROR_CONEXION';
    }
  }

  /// Actualiza el perfil (nombre, bio, fotos de perfil y portada) en MongoDB
  Future<bool> actualizarPerfil({
    required String nombreUsuarioActual,
    required String nuevoNombre,
    required String nuevaBio,
    String? fotoPerfilUrl,
    String? fotoPortadaUrl,
  }) async {
    try {
      final usuariosColl = MongoService.getCollection('usuarios');

      final Map<String, dynamic> datosActualizados = {
        'nombre_usuario': nuevoNombre,
        'bio': nuevaBio,
      };

      if (fotoPerfilUrl != null) datosActualizados['foto_perfil'] = fotoPerfilUrl;
      if (fotoPortadaUrl != null) datosActualizados['foto_portada'] = fotoPortadaUrl;

      // Actualiza en MongoDB pasando el filtro directamente como un Map
      await usuariosColl.update(
        {'nombre_usuario': nombreUsuarioActual},
        {'\$set': datosActualizados},
      );

      // Actualizar SharedPreferences si cambió el nombre de usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nombre_usuario', nuevoNombre);

      // Actualiza la sesión local en memoria
      if (_currentUser != null) {
        _currentUser!['nombre_usuario'] = nuevoNombre;
        _currentUser!['bio'] = nuevaBio;
        if (fotoPerfilUrl != null) _currentUser!['foto_perfil'] = fotoPerfilUrl;
        if (fotoPortadaUrl != null) _currentUser!['foto_portada'] = fotoPortadaUrl;
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint("Error al actualizar perfil en MongoDB: $e");
      return false;
    }
  }

  /// Fuerza el inicio de sesión directo (Ideal para Biometría)
  Future<void> forceLogin(String nombreUsuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('nombre_usuario', nombreUsuario);

    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('nombre_usuario');

    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}