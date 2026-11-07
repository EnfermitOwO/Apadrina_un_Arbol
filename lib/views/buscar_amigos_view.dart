
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

class _BuscarAmigosViewState extends State<BuscarAmigosView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _busquedaController =
      TextEditingController();

  Timer? _temporizador;

  String _emailUsuario = '';

  List<AmigoModel> _amigos = [];
  List<AmigoModel> _resultados = [];
  List<AmigoModel> _solicitudesRecibidas = [];

  Set<String> _solicitudesEnviadas = {};

  bool _cargandoDatos = true;
  bool _buscando = false;

  final Set<String> _procesando = {};

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

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
    _tabController.dispose();
    super.dispose();
  }

  // CARGAR AMIGOS Y SOLICITUDES
  Future<void> _cargarDatos() async {
    if (_emailUsuario.isEmpty) {
      if (mounted) {
        setState(() => _cargandoDatos = false);
      }
      return;
    }

    try {
      final resultados = await Future.wait([
        AmigosService.obtenerAmigos(
          emailUsuario: _emailUsuario,
        ),
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

        _cargandoDatos = false;
      });
    } catch (e) {
      debugPrint('Error cargando datos de amigos: $e');

      if (mounted) {
        setState(() => _cargandoDatos = false);
      }
    }
  }

  // BUSCAR USUARIOS
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

      // IMPORTANTE:
      // Ya no excluimos amigos ni solicitudes pendientes.
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

  // ENVIAR SOLICITUD
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

      setState(() {
        _solicitudesEnviadas.add(email);
      });

      _mensaje('Solicitud enviada correctamente.');
    } catch (e) {
      debugPrint('Error enviando solicitud: $e');

      if (mounted) {
        _mensaje('No se pudo enviar la solicitud.');
      }
    } finally {
      if (mounted) {
        setState(() => _procesando.remove(email));
      }
    }
  }

  // ACEPTAR O RECHAZAR SOLICITUD
  Future<void> _responderSolicitud(
    AmigoModel usuario,
    String respuesta,
  ) async {
    final email = usuario.email.toLowerCase().trim();

    if (_procesando.contains(email)) return;

    setState(() => _procesando.add(email));

    try {
      final correcto = await AmigosService.responderSolicitud(
        emailUsuario: _emailUsuario,
        emailSolicitante: email,
        respuesta: respuesta,
      );

      if (!correcto) {
        throw Exception('No se pudo responder la solicitud.');
      }

      if (!mounted) return;

      await _cargarDatos();

      if (!mounted) return;

      _mensaje(
        respuesta == 'aceptar'
            ? '¡Ahora son amigos!'
            : 'Solicitud rechazada.',
      );
    } catch (e) {
      debugPrint('Error respondiendo solicitud: $e');

      if (mounted) {
        _mensaje('No se pudo procesar la solicitud.');
      }
    } finally {
      if (mounted) {
        setState(() => _procesando.remove(email));
      }
    }
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          texto,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF388E3C),
      ),
    );
  }

  // ESTADO DEL USUARIO EN LA BÚSQUEDA
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

  // AVATAR
  Widget _avatar(AmigoModel usuario) {
    final tieneFoto = usuario.fotoPerfil != null &&
        usuario.fotoPerfil!.isNotEmpty;

    return CircleAvatar(
      radius: 25,
      backgroundColor: const Color(0xFFE8F5E9),
      backgroundImage:
          tieneFoto ? NetworkImage(usuario.fotoPerfil!) : null,
      child: !tieneFoto
          ? const Icon(
              Icons.person,
              color: Color(0xFF388E3C),
            )
          : null,
    );
  }

  // TARJETA DE USUARIO
  Widget _tarjetaUsuario(
    AmigoModel usuario, {
    bool mostrarAcciones = true,
  }) {
    final estado = _estadoUsuario(usuario);
    final procesando = _procesando.contains(usuario.email);

    Widget boton;

    if (!mostrarAcciones) {
      boton = const SizedBox.shrink();
    } else if (estado == 'amigo') {
      boton = _etiqueta(
        'Amigos',
        Icons.people,
        Colors.green,
      );
    } else if (estado == 'enviada') {
      boton = _etiqueta(
        'Enviada',
        Icons.schedule,
        Colors.orange,
      );
    } else if (estado == 'recibida') {
      boton = ElevatedButton(
        onPressed: procesando
            ? null
            : () => _responderSolicitud(usuario, 'aceptar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF388E3C),
          foregroundColor: Colors.white,
        ),
        child: const Text('Aceptar'),
      );
    } else {
      boton = ElevatedButton(
        onPressed: procesando
            ? null
            : () => _enviarSolicitud(usuario),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF388E3C),
          foregroundColor: Colors.white,
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
        trailing: procesando &&
                (estado == 'recibida' || estado == 'amigo')
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : boton,
      ),
    );
  }

  Widget _etiqueta(String texto, IconData icono, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          texto,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // PESTAÑA BUSCAR
  Widget _construirBusqueda() {
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
      itemBuilder: (context, index) {
        return _tarjetaUsuario(_resultados[index]);
      },
    );
  }

  // PESTAÑA SOLICITUDES
  Widget _construirSolicitudes() {
    if (_solicitudesRecibidas.isEmpty) {
      return Center(
        child: Text(
          'No tienes solicitudes pendientes.',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _solicitudesRecibidas.length,
      itemBuilder: (context, index) {
        final usuario = _solicitudesRecibidas[index];
        final procesando = _procesando.contains(usuario.email);

        return Card(
          color: Colors.white,
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _avatar(usuario),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.nombreUsuario,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Quiere agregarte como amigo',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (procesando)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Column(
                    children: [
                      IconButton(
                        tooltip: 'Aceptar',
                        onPressed: () => _responderSolicitud(
                          usuario,
                          'aceptar',
                        ),
                        icon: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Rechazar',
                        onPressed: () => _responderSolicitud(
                          usuario,
                          'rechazar',
                        ),
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // PESTAÑA MIS AMIGOS
  Widget _construirAmigos() {
    if (_amigos.isEmpty) {
      return Center(
        child: Text(
          'Todavía no tienes amigos.\n¡Busca personas y envíales una solicitud!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _amigos.length,
      itemBuilder: (context, index) {
        return _tarjetaUsuario(
          _amigos[index],
          mostrarAcciones: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_emailUsuario.isEmpty) {
      return Center(
        child: Text(
          'Inicia sesión para buscar amigos.',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    if (_cargandoDatos) {
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

          const SizedBox(height: 12),

          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2E7D32),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2E7D32),
            labelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Buscar'),
              Tab(text: 'Solicitudes'),
              Tab(text: 'Mis amigos'),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _construirBusqueda(),
                _construirSolicitudes(),
                _construirAmigos(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
