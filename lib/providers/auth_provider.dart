
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

  // Recuperar la sesión y los datos del usuario
  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();

    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      final email = prefs.getString('email');

      if (email != null && email.isNotEmpty) {
        try {
          await MongoService.connect();

          final usuariosColl =
              MongoService.getCollection('usuarios');

          final user = await usuariosColl.findOne({
            'email': email,
          });

          if (user != null) {
            _currentUser = user;
          } else {
            _isLoggedIn = false;
          }
        } catch (e) {
          debugPrint('Error recuperando usuario: $e');
        }
      }
    }

    notifyListeners();
  }

  /// Inicia sesión buscando por nombre_usuario o email
  /// y verificando bcrypt
  Future<bool> login(
    String usuarioOrEmail,
    String passwordPlano,
  ) async {
    try {
      await MongoService.connect();

      final usuariosColl =
          MongoService.getCollection('usuarios');

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
          passwordValida =
              BCrypt.checkpw(passwordPlano, hashedPassword);
        } catch (_) {
          passwordValida = (passwordPlano == hashedPassword);
        }

        if (passwordValida) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setBool('isLoggedIn', true);
          await prefs.setString(
            'nombre_usuario',
            user['nombre_usuario'] ?? '',
          );
          await prefs.setString(
            'email',
            user['email'] ?? '',
          );

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

  /// Registra un nuevo usuario
  Future<String?> register(
    String nombreUsuario,
    String email,
    String passwordPlano,
  ) async {
    try {
      await MongoService.connect();

      final usuariosColl =
          MongoService.getCollection('usuarios');

      final existingEmail =
          await usuariosColl.findOne({'email': email});

      if (existingEmail != null) {
        return 'CORREO_DUPLICADO';
      }

      final existingUsername =
          await usuariosColl.findOne({
        'nombre_usuario': nombreUsuario,
      });

      if (existingUsername != null) {
        return 'USUARIO_DUPLICADO';
      }

      String hashedPassword = BCrypt.hashpw(
        passwordPlano,
        BCrypt.gensalt(),
      );

      int customId =
          DateTime.now().millisecondsSinceEpoch ~/ 1000;

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

      await login(nombreUsuario, passwordPlano);

      return null;
    } catch (e) {
      debugPrint("Error en registro MongoDB: $e");
      return 'ERROR_CONEXION';
    }
  }

  /// Actualiza el perfil
  Future<bool> actualizarPerfil({
    required String nombreUsuarioActual,
    required String nuevoNombre,
    required String nuevaBio,
    String? fotoPerfilUrl,
    String? fotoPortadaUrl,
  }) async {
    try {
      await MongoService.connect();

      final usuariosColl =
          MongoService.getCollection('usuarios');

      final Map<String, dynamic> datosActualizados = {
        'nombre_usuario': nuevoNombre,
        'bio': nuevaBio,
      };

      if (fotoPerfilUrl != null) {
        datosActualizados['foto_perfil'] = fotoPerfilUrl;
      }

      if (fotoPortadaUrl != null) {
        datosActualizados['foto_portada'] = fotoPortadaUrl;
      }

      await usuariosColl.update(
        {'nombre_usuario': nombreUsuarioActual},
        {'\$set': datosActualizados},
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nombre_usuario', nuevoNombre);

      if (_currentUser != null) {
        _currentUser!['nombre_usuario'] = nuevoNombre;
        _currentUser!['bio'] = nuevaBio;

        if (fotoPerfilUrl != null) {
          _currentUser!['foto_perfil'] = fotoPerfilUrl;
        }

        if (fotoPortadaUrl != null) {
          _currentUser!['foto_portada'] = fotoPortadaUrl;
        }

        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint("Error al actualizar perfil en MongoDB: $e");
      return false;
    }
  }

  /// Inicio de sesión biométrico
  Future<void> forceLogin(String nombreUsuario) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('nombre_usuario', nombreUsuario);

    _isLoggedIn = true;
    notifyListeners();
  }

  /// Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('isLoggedIn');
    await prefs.remove('nombre_usuario');
    await prefs.remove('email');

    _isLoggedIn = false;
    _currentUser = null;

    notifyListeners();
  }
}
