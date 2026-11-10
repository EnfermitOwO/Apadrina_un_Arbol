import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/amigo_model.dart';
import '../services/amigos_service.dart';

class NotificacionesView extends StatefulWidget {
  const NotificacionesView({super.key});

  @override
  State<NotificacionesView> createState() => _NotificacionesViewState();
}

class _NotificacionesViewState extends State<NotificacionesView> {
  String _emailUsuario = '';
  List<AmigoModel> _solicitudes = [];

  bool _cargando = true;
  final Set<String> _procesando = {};

  @override
  void initState() {
    super.initState();

    _emailUsuario = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).currentUser?['email']?.toString().toLowerCase().trim() ?? '';

    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    if (_emailUsuario.isEmpty) {
      if (mounted) setState(() => _cargando = false);
      return;
    }

    try {
      final solicitudes =
          await AmigosService.obtenerSolicitudesRecibidas(
        emailUsuario: _emailUsuario,
      );

      if (!mounted) return;

      setState(() {
        _solicitudes = solicitudes;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error cargando notificaciones: $e');

      if (mounted) {
        setState(() => _cargando = false);
        _mensaje('No se pudieron cargar las notificaciones.');
      }
    }
  }

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
        throw Exception('No se pudo procesar la solicitud.');
      }

      if (!mounted) return;

      setState(() {
        _solicitudes.removeWhere(
          (solicitud) =>
              solicitud.email.toLowerCase().trim() == email,
        );
      });

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
        content: Text(texto, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF407B30),
      ),
    );
  }

  Widget _avatar(AmigoModel usuario) {
    final foto = usuario.fotoPerfil;

    return CircleAvatar(
      radius: 25,
      backgroundColor: const Color(0xFFE4EFDF),
      backgroundImage:
          foto != null && foto.isNotEmpty ? NetworkImage(foto) : null,
      child: foto == null || foto.isEmpty
          ? const Icon(
              Icons.person,
              color: Color(0xFF407B30),
              size: 28,
            )
          : null,
    );
  }

  Widget _tarjetaNotificacion(AmigoModel usuario) {
    final email = usuario.email.toLowerCase().trim();
    final procesando = _procesando.contains(email);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(usuario),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF555555),
                    ),
                    children: [
                      TextSpan(
                        text: usuario.nombreUsuario,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const TextSpan(
                        text: ' te ha enviado una solicitud de amistad',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (procesando)
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF529740),
                    ),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            _responderSolicitud(usuario, 'aceptar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF529740),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Aceptar',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            _responderSolicitud(usuario, 'rechazar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF407B30),
                          side: const BorderSide(
                            color: Color(0xFF75B364),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Rechazar',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF407B30),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notificaciones',
          style: GoogleFonts.poppins(
            color: const Color(0xFF407B30),
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.notifications,
              color: Color(0xFF407B30),
              size: 25,
            ),
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF529740),
              ),
            )
          : _solicitudes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 65,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No tienes notificaciones pendientes.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF529740),
                  onRefresh: _cargarSolicitudes,
                  child: ListView.builder(
                    itemCount: _solicitudes.length,
                    itemBuilder: (context, index) =>
                        _tarjetaNotificacion(_solicitudes[index]),
                  ),
                ),
    );
  }
}