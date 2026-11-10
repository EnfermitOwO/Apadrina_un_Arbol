import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/amigo_model.dart';
import '../services/amigos_service.dart';

class BuscarAmigosView extends StatefulWidget {
  const BuscarAmigosView({super.key});

  @override
  State<BuscarAmigosView> createState() => _BuscarAmigosViewState();
}

class _BuscarAmigosViewState extends State<BuscarAmigosView> {
  final TextEditingController _busquedaController =
      TextEditingController();

  Timer? _temporizador;

  String _emailUsuario = '';

  List<AmigoModel> _amigos = [];
  List<AmigoModel> _resultados = [];
  List<AmigoModel> _solicitudesRecibidas = [];

  Set<String> _solicitudesEnviadas = {};
  final Set<String> _procesando = {};

  bool _cargando = true;
  bool _buscando = false;

  @override
  void initState() {
    super.initState();

    _emailUsuario = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).currentUser?['email']?.toString().toLowerCase().trim() ?? '';

    _cargarDatos();
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    if (_emailUsuario.isEmpty) {
      if (mounted) setState(() => _cargando = false);
      return;
    }

    try {
      final resultados = await Future.wait([
        AmigosService.obtenerAmigos(emailUsuario: _emailUsuario),
        AmigosService.obtenerSolicitudesRecibidas(
          emailUsuario: _emailUsuario,
        ),
        AmigosService.obtenerSolicitudesEnviadas(
          emailUsuario: _emailUsuario,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _amigos = resultados[0] as List<AmigoModel>;
        _solicitudesRecibidas = resultados[1] as List<AmigoModel>;

        final enviadas = resultados[2] as List<AmigoModel>;

        _solicitudesEnviadas = enviadas
            .map((usuario) => usuario.email.toLowerCase().trim())
            .toSet();

        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error cargando datos: $e');

      if (mounted) setState(() => _cargando = false);
    }
  }

  void _alCambiarBusqueda(String texto) {
    _temporizador?.cancel();

    if (texto.trim().isEmpty) {
      setState(() {
        _resultados = [];
        _buscando = false;
      });
      return;
    }

    _temporizador = Timer(
      const Duration(milliseconds: 400),
      () => _buscarUsuarios(texto.trim()),
    );
  }

  Future<void> _buscarUsuarios(String texto) async {
    if (_emailUsuario.isEmpty) return;

    setState(() => _buscando = true);

    try {
      final usuarios = await AmigosService.buscarUsuarios(
        busqueda: texto,
        emailUsuario: _emailUsuario,
      );

      if (!mounted) return;

      setState(() {
        _resultados = usuarios;
        _buscando = false;
      });
    } catch (e) {
      debugPrint('Error buscando usuarios: $e');

      if (!mounted) return;

      setState(() {
        _resultados = [];
        _buscando = false;
      });
    }
  }

  String _estadoUsuario(AmigoModel usuario) {
    final email = usuario.email.toLowerCase().trim();

    if (_amigos.any(
      (amigo) => amigo.email.toLowerCase().trim() == email,
    )) {
      return 'amigo';
    }

    if (_solicitudesRecibidas.any(
      (solicitud) =>
          solicitud.email.toLowerCase().trim() == email,
    )) {
      return 'recibida';
    }

    if (_solicitudesEnviadas.contains(email)) {
      return 'enviada';
    }

    return 'nuevo';
  }

  Future<void> _enviarSolicitud(AmigoModel usuario) async {
    final email = usuario.email.toLowerCase().trim();

    if (_procesando.contains(email)) return;

    setState(() => _procesando.add(email));

    try {
      final enviada = await AmigosService.enviarSolicitud(
        emailUsuario: _emailUsuario,
        emailAmigo: email,
      );

      if (!enviada) {
        throw Exception('No se pudo enviar la solicitud.');
      }

      if (!mounted) return;

      setState(() => _solicitudesEnviadas.add(email));

      _mostrarMensaje('Solicitud enviada correctamente.');
    } catch (e) {
      debugPrint('Error enviando solicitud: $e');

      if (mounted) {
        _mostrarMensaje('No se pudo enviar la solicitud.');
      }
    } finally {
      if (mounted) {
        setState(() => _procesando.remove(email));
      }
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF388E3C),
      ),
    );
  }

  Widget _avatar(AmigoModel usuario) {
    final foto = usuario.fotoPerfil;

    return CircleAvatar(
      radius: 25,
      backgroundColor: const Color(0xFFE8F5E9),
      backgroundImage:
          foto != null && foto.isNotEmpty ? NetworkImage(foto) : null,
      child: foto == null || foto.isEmpty
          ? const Icon(
              Icons.person,
              color: Color(0xFF388E3C),
            )
          : null,
    );
  }

  Widget _tarjetaUsuario(AmigoModel usuario) {
    final estado = _estadoUsuario(usuario);
    final email = usuario.email.toLowerCase().trim();
    final procesando = _procesando.contains(email);

    Widget accion;

    if (estado == 'amigo') {
      accion = _etiqueta('Amigos', Icons.people, Colors.green);
    } else if (estado == 'enviada') {
      accion = _etiqueta('Enviada', Icons.schedule, Colors.orange);
    } else if (estado == 'recibida') {
      accion = _etiqueta(
        'Solicitud recibida',
        Icons.notifications_active_outlined,
        const Color(0xFF407B30),
      );
    } else {
      accion = ElevatedButton(
        onPressed: procesando ? null : () => _enviarSolicitud(usuario),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF388E3C),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: procesando
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Agregar',
                style: GoogleFonts.poppins(fontSize: 11),
              ),
      );
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: _avatar(usuario),
        title: Text(
          usuario.nombreUsuario,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          usuario.bio.isNotEmpty ? usuario.bio : usuario.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: accion,
      ),
    );
  }

  Widget _etiqueta(String texto, IconData icono, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          texto,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _contenidoBusqueda() {
    if (_busquedaController.text.trim().isEmpty) {
      return Center(
        child: Text(
          'Busca personas por su nombre de usuario o correo.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      );
    }

    if (_buscando) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF388E3C),
        ),
      );
    }

    if (_resultados.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron usuarios.',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _resultados.length,
      itemBuilder: (context, index) =>
          _tarjetaUsuario(_resultados[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_emailUsuario.isEmpty) {
      return Center(
        child: Text(
          'Inicia sesión para buscar personas.',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF388E3C),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: _busquedaController,
              onChanged: _alCambiarBusqueda,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar personas',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                prefixIcon: const Icon(
                  Icons.person_search,
                  color: Color(0xFF388E3C),
                ),
                suffixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF388E3C),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(child: _contenidoBusqueda()),
        ],
      ),
    );
  }
}