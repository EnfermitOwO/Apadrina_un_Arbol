
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../widgets/custom_bottom_nav.dart';
import '../providers/auth_provider.dart';
import '../services/apadrinamiento_service.dart';

class DetalleArbolScreen extends StatelessWidget {
  final Map<String, dynamic> arbol;

  const DetalleArbolScreen({super.key, required this.arbol});

  static const Color verdePrincipal = Color(0xFF3B6B23);
  static const Color verdeBotonClaro = Color(0xFF7CB342);
  static const Color fondoVerdeClaro = Color(0xFFF1F8E9);

  @override
  Widget build(BuildContext context) {
    final String nombreComun =
        arbol['nombre_comun']?.toString() ?? 'Árbol sin nombre';
    final String nombreCientifico =
        arbol['nombre_cientifico']?.toString() ?? '';
    final String descripcion =
        arbol['descripcion_larga']?.toString() ??
        arbol['descripcion']?.toString() ??
        'Sin descripción disponible.';
    final String curiosidades =
        arbol['datos_interesantes']?.toString() ??
        'Sin información adicional.';
    final String altura = arbol['altura']?.toString() ?? 'No especificada';
    final String epoca = arbol['epoca']?.toString() ?? 'No especificada';
    final String imagenUrl = arbol['imagen']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE0E0E0),
            ),
            Expanded(
              child: Container(
                color: fondoVerdeClaro,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: imagenUrl.isNotEmpty
                              ? Image.network(
                                  imagenUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _imagenError();
                                  },
                                )
                              : _imagenError(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          nombreComun,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: verdePrincipal,
                          ),
                        ),
                        if (nombreCientifico.isNotEmpty) ...[
                          Text(
                            nombreCientifico,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            Chip(
                              avatar: const Icon(
                                Icons.straighten,
                                size: 16,
                                color: verdePrincipal,
                              ),
                              label: Text(
                                'Altura: $altura',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: fondoVerdeClaro,
                              side: BorderSide.none,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              avatar: const Icon(
                                Icons.eco,
                                size: 16,
                                color: verdePrincipal,
                              ),
                              label: Text(
                                'Época: $epoca',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: fondoVerdeClaro,
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _tituloSeccion('Descripción'),
                        const SizedBox(height: 4),
                        Text(
                          descripcion,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _tituloSeccion('Curiosidades'),
                        const SizedBox(height: 4),
                        Text(
                          curiosidades,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              _mostrarFormularioApadrinamiento(
                                context,
                                nombreComun,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: verdePrincipal,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Adoptar',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              _mostrarFormularioDonacion(
                                context,
                                nombreComun,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: verdeBotonClaro,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Donar',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }
        },
      ),
    );
  }

  // ==========================================
  // FORMULARIO DE APADRINAMIENTO
  // ==========================================

  void _mostrarFormularioApadrinamiento(
    BuildContext pageContext,
    String nombreComun,
  ) {
    final nombreController = TextEditingController(text: nombreComun);
    final montoController = TextEditingController(text: '500');
    final titularController = TextEditingController();
    final numeroTarjetaController = TextEditingController();
    final vencimientoController = TextEditingController();
    final cvvController = TextEditingController();

    String tipoAdopcion = 'Individual';
    String metodoPago = 'Tarjeta';
    bool procesando = false;

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Container(
              height: MediaQuery.of(dialogContext).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _barraSuperior(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 16, 15),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: fondoVerdeClaro,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.park,
                            color: verdePrincipal,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Apadrina un árbol',
                                style: GoogleFonts.poppins(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: verdePrincipal,
                                ),
                              ),
                              Text(
                                'Ayúdanos a cuidar nuestro planeta',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: procesando
                              ? null
                              : () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tituloFormulario('Personaliza tu árbol'),
                          const SizedBox(height: 15),
                          _campoFormulario(
                            controller: nombreController,
                            etiqueta: 'Nombre de tu árbol',
                            icono: Icons.park,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: tipoAdopcion,
                            decoration: _decoracionFormulario(
                              'Tipo de apadrinamiento',
                              Icons.groups_outlined,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Individual',
                                child: Text('Individual'),
                              ),
                              DropdownMenuItem(
                                value: 'Amigos',
                                child: Text('Amigos'),
                              ),
                              DropdownMenuItem(
                                value: 'Familia',
                                child: Text('Familia'),
                              ),
                            ],
                            onChanged: procesando
                                ? null
                                : (valor) {
                                    if (valor != null) {
                                      setDialogState(() {
                                        tipoAdopcion = valor;
                                      });
                                    }
                                  },
                          ),
                          const SizedBox(height: 16),
                          _campoFormulario(
                            controller: montoController,
                            etiqueta: 'Monto de apadrinamiento',
                            icono: Icons.attach_money,
                            tipo: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            formato: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}$'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          _tituloFormulario('Selecciona tu método de pago'),
                          const SizedBox(height: 14),
                          _selectorMetodosPago(
                            metodoPago: metodoPago,
                            onChanged: (valor) {
                              setDialogState(() {
                                metodoPago = valor;
                              });
                            },
                          ),
                          const SizedBox(height: 25),
                          if (metodoPago == 'Tarjeta')
                            _formularioTarjeta(
                              titularController: titularController,
                              numeroController: numeroTarjetaController,
                              vencimientoController: vencimientoController,
                              cvvController: cvvController,
                            ),
                          if (metodoPago == 'Oxxo')
                            _mensajeMetodoPago(
                              Icons.storefront,
                              'Pago en Oxxo',
                              'Esta opción es una demostración. '
                                  'No se realizará ningún cargo real.',
                            ),
                          if (metodoPago == 'PayPal')
                            _mensajeMetodoPago(
                              Icons.account_balance_wallet,
                              'Pago con PayPal',
                              'Esta opción es una demostración. '
                                  'No se realizará ningún cargo real.',
                            ),
                          const SizedBox(height: 18),
                          _avisoPago(),
                        ],
                      ),
                    ),
                  ),
                  _botonInferior(
                    context: dialogContext,
                    texto: 'Confirmar apadrinamiento',
                    procesando: procesando,
                    onPressed: () async {
                      final nombre = nombreController.text.trim();
                      final monto = double.tryParse(
                        montoController.text.trim(),
                      );

                      if (nombre.isEmpty || monto == null || monto <= 0) {
                        _mostrarMensaje(
                          pageContext,
                          'Ingresa un nombre y un monto válido.',
                        );
                        return;
                      }

                      Map<String, dynamic>? datosTarjeta;

                      if (metodoPago == 'Tarjeta') {
                        final titular = titularController.text.trim();
                        final numero = numeroTarjetaController.text.trim();
                        final vencimiento =
                            vencimientoController.text.trim();
                        final cvv = cvvController.text.trim();

                        if (!_tarjetaValida(
                          titular,
                          numero,
                          vencimiento,
                          cvv,
                        )) {
                          _mostrarMensaje(
                            pageContext,
                            'Completa correctamente los datos de la tarjeta.',
                          );
                          return;
                        }

                        datosTarjeta = {
                          'titular': titular,
                          'numero': numero,
                          'vencimiento': vencimiento,
                          'cvv': cvv,
                        };
                      }

                      final idArbol = _obtenerIdArbol();

                      if (idArbol == null) {
                        _mostrarMensaje(
                          pageContext,
                          'No se encontró el identificador del árbol.',
                        );
                        return;
                      }

                      final emailUsuario = _obtenerEmail(pageContext);

                      if (emailUsuario.isEmpty) {
                        _mostrarMensaje(
                          pageContext,
                          'Inicia sesión nuevamente.',
                        );
                        return;
                      }

                      setDialogState(() {
                        procesando = true;
                      });

                      try {
                        await ApadrinamientoService.crearApadrinamiento(
                          emailUsuario: emailUsuario,
                          idArbol: idArbol,
                          nombrePersonalizado: nombre,
                          tipoAdopcion: tipoAdopcion,
                          monto: monto,
                          metodoPago: metodoPago,
                          datosTarjeta: datosTarjeta,
                        );

                        if (!dialogContext.mounted) return;

                        Navigator.of(dialogContext).pop();

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!pageContext.mounted) return;

                          _mostrarMensaje(
                            pageContext,
                            '¡Felicidades! Has apadrinado $nombre.',
                            color: verdePrincipal,
                          );
                        });
                      } catch (e) {
                        if (!dialogContext.mounted) return;

                        setDialogState(() {
                          procesando = false;
                        });

                        if (!pageContext.mounted) return;

                        _mostrarMensaje(
                          pageContext,
                          'No se pudo completar: $e',
                          color: Colors.red,
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        nombreController.dispose();
        montoController.dispose();
        titularController.dispose();
        numeroTarjetaController.dispose();
        vencimientoController.dispose();
        cvvController.dispose();
      });
    });
  }

  // ==========================================
  // FORMULARIO DE DONACIÓN
  // ==========================================

  void _mostrarFormularioDonacion(
    BuildContext pageContext,
    String nombreComun,
  ) {
    final montoController = TextEditingController();
    final titularController = TextEditingController();
    final numeroController = TextEditingController();
    final vencimientoController = TextEditingController();
    final cvvController = TextEditingController();

    String metodoPago = 'Tarjeta';
    bool procesando = false;

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Container(
              height: MediaQuery.of(dialogContext).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _barraSuperior(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 16, 15),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: fondoVerdeClaro,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.volunteer_activism,
                            color: verdePrincipal,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Apoya con tu donación',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: verdePrincipal,
                                ),
                              ),
                              Text(
                                'Cada aportación ayuda a cuidar nuestros árboles',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: procesando
                              ? null
                              : () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tituloFormulario('Tu donación'),
                          const SizedBox(height: 10),
                          Text(
                            'Tu aportación ayudará al mantenimiento de:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: fondoVerdeClaro,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.park,
                                  color: verdePrincipal,
                                  size: 25,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    nombreComun,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: verdePrincipal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          _tituloFormulario('¿Cuánto deseas donar?'),
                          const SizedBox(height: 12),
                          TextField(
                            controller: montoController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}$'),
                              ),
                            ],
                            decoration: _decoracionFormulario(
                              'Monto de donación (MXN)',
                              Icons.attach_money,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            children: [50, 100, 200, 500].map((cantidad) {
                              return ActionChip(
                                label: Text('\$$cantidad'),
                                backgroundColor: fondoVerdeClaro,
                                side: BorderSide.none,
                                labelStyle: const TextStyle(
                                  color: verdePrincipal,
                                  fontWeight: FontWeight.bold,
                                ),
                                onPressed: procesando
                                    ? null
                                    : () {
                                        montoController.text =
                                            cantidad.toString();
                                      },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 28),
                          _tituloFormulario('Método de pago'),
                          const SizedBox(height: 14),
                          _selectorMetodosPago(
                            metodoPago: metodoPago,
                            onChanged: (valor) {
                              setDialogState(() {
                                metodoPago = valor;
                              });
                            },
                          ),
                          const SizedBox(height: 22),
                          if (metodoPago == 'Tarjeta')
                            _formularioTarjeta(
                              titularController: titularController,
                              numeroController: numeroController,
                              vencimientoController: vencimientoController,
                              cvvController: cvvController,
                            ),
                          if (metodoPago != 'Tarjeta')
                            _mensajeMetodoPago(
                              metodoPago == 'Oxxo'
                                  ? Icons.storefront
                                  : Icons.account_balance_wallet,
                              'Pago con $metodoPago',
                              'Esta opción es una demostración. '
                                  'No se realizará ningún cargo real.',
                            ),
                          const SizedBox(height: 18),
                          _avisoPago(),
                        ],
                      ),
                    ),
                  ),
                  _botonInferior(
                    context: dialogContext,
                    texto: 'Confirmar donación',
                    procesando: procesando,
                    onPressed: () async {
                      final monto = double.tryParse(
                        montoController.text.trim(),
                      );

                      if (monto == null || monto <= 0) {
                        _mostrarMensaje(
                          pageContext,
                          'Ingresa un monto válido para donar.',
                        );
                        return;
                      }

                      Map<String, dynamic>? datosTarjeta;

                      if (metodoPago == 'Tarjeta') {
                        final titular = titularController.text.trim();
                        final numero = numeroController.text.trim();
                        final vencimiento =
                            vencimientoController.text.trim();
                        final cvv = cvvController.text.trim();

                        if (!_tarjetaValida(
                          titular,
                          numero,
                          vencimiento,
                          cvv,
                        )) {
                          _mostrarMensaje(
                            pageContext,
                            'Completa correctamente los datos de la tarjeta.',
                          );
                          return;
                        }

                        datosTarjeta = {
                          'titular': titular,
                          'numero': numero,
                          'vencimiento': vencimiento,
                          'cvv': cvv,
                        };
                      }

                      final idArbol = _obtenerIdArbol();

                      if (idArbol == null) {
                        _mostrarMensaje(
                          pageContext,
                          'No se encontró el identificador del árbol.',
                        );
                        return;
                      }

                      final emailUsuario = _obtenerEmail(pageContext);

                      if (emailUsuario.isEmpty) {
                        _mostrarMensaje(
                          pageContext,
                          'Inicia sesión nuevamente.',
                        );
                        return;
                      }

                      setDialogState(() {
                        procesando = true;
                      });

                      try {
                        await ApadrinamientoService.crearApadrinamiento(
                          emailUsuario: emailUsuario,
                          idArbol: idArbol,
                          nombrePersonalizado: 'Aporte de Mantenimiento',
                          tipoAdopcion: 'Donación',
                          monto: monto,
                          metodoPago: metodoPago,
                          datosTarjeta: datosTarjeta,
                        );

                        if (!pageContext.mounted) return;

                        Navigator.of(sheetContext).pop();

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!pageContext.mounted) return;

                          _mostrarMensaje(
                            pageContext,
                            '¡Gracias por tu donación de '
                            '\$${monto.toStringAsFixed(2)}!',
                            color: verdePrincipal,
                          );
                        });
                      } catch (e) {
                        if (!dialogContext.mounted) return;

                        setDialogState(() {
                          procesando = false;
                        });

                        if (!pageContext.mounted) return;

                        _mostrarMensaje(
                          pageContext,
                          'No se pudo registrar la donación: $e',
                          color: Colors.red,
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        montoController.dispose();
        titularController.dispose();
        numeroController.dispose();
        vencimientoController.dispose();
        cvvController.dispose();
      });
    });
  }

  // ==========================================
  // FORMULARIO REUTILIZABLE DE TARJETA
  // ==========================================

  Widget _formularioTarjeta({
    required TextEditingController titularController,
    required TextEditingController numeroController,
    required TextEditingController vencimientoController,
    required TextEditingController cvvController,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fondoVerdeClaro,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFDCEBCF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.credit_card,
                color: verdePrincipal,
              ),
              const SizedBox(width: 8),
              Text(
                'Datos ficticios de tarjeta',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: verdePrincipal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _campoPago(
            'Número de tarjeta',
            '0000 0000 0000 0000',
            Icons.credit_card,
            controller: numeroController,
            tipo: TextInputType.number,
            formato: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
            ],
          ),
          const SizedBox(height: 16),
          _campoPago(
            'Nombre del titular',
            'Nombre completo',
            Icons.person_outline,
            controller: titularController,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _campoPago(
                  'Vencimiento',
                  'MM/AA',
                  Icons.calendar_month,
                  controller: vencimientoController,
                  tipo: TextInputType.number,
                  formato: [
                    ExpiracionFormatter(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _campoPago(
                  'CVV',
                  '123',
                  Icons.lock_outline,
                  controller: cvvController,
                  tipo: TextInputType.number,
                  ocultar: true,
                  formato: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VALIDAR TARJETA
  // ==========================================

  bool _tarjetaValida(
    String titular,
    String numero,
    String vencimiento,
    String cvv,
  ) {
    if (titular.isEmpty) return false;

    if (!RegExp(r'^[0-9]{13,19}$').hasMatch(numero)) {
      return false;
    }

    if (!RegExp(r'^(0[1-9]|1[0-2])/[0-9]{2}$')
        .hasMatch(vencimiento)) {
      return false;
    }

    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(cvv)) {
      return false;
    }

    final partes = vencimiento.split('/');
    final mes = int.parse(partes[0]);
    final anio = 2000 + int.parse(partes[1]);

    final ahora = DateTime.now();
    final fechaVencimiento = DateTime(anio, mes + 1, 0);

    if (fechaVencimiento.isBefore(
      DateTime(ahora.year, ahora.month, ahora.day),
    )) {
      return false;
    }

    return true;
  }

  // ==========================================
  // OBTENER USUARIO Y ÁRBOL
  // ==========================================

  int? _obtenerIdArbol() {
    return int.tryParse(arbol['id_arbol']?.toString() ?? '');
  }

  String _obtenerEmail(BuildContext context) {
    final usuario = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).currentUser;

    return usuario?['email']?.toString() ?? '';
  }

  // ==========================================
  // SELECTOR DE MÉTODOS DE PAGO
  // ==========================================

  Widget _selectorMetodosPago({
    required String metodoPago,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: _opcionPago(
            icono: Icons.credit_card,
            titulo: 'Tarjeta',
            seleccionado: metodoPago == 'Tarjeta',
            onTap: () => onChanged('Tarjeta'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _opcionPago(
            icono: Icons.storefront,
            titulo: 'Oxxo',
            seleccionado: metodoPago == 'Oxxo',
            onTap: () => onChanged('Oxxo'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _opcionPago(
            icono: Icons.account_balance_wallet,
            titulo: 'PayPal',
            seleccionado: metodoPago == 'PayPal',
            onTap: () => onChanged('PayPal'),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BOTÓN INFERIOR
  // ==========================================

  Widget _botonInferior({
    required BuildContext context,
    required String texto,
    required bool procesando,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: verdePrincipal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: procesando ? null : onPressed,
          child: procesando
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  texto,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }

  // ==========================================
  // BARRA SUPERIOR DEL MODAL
  // ==========================================

  Widget _barraSuperior() {
    return Container(
      height: 5,
      width: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // ==========================================
  // AVISO DE PAGO
  // ==========================================

  Widget _avisoPago() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade800,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Pago simulado. Utiliza únicamente datos ficticios. '
              'No se realizará ningún cargo real.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.brown.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TÍTULOS
  // ==========================================

  Widget _tituloFormulario(String titulo) {
    return Text(
      titulo,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: verdePrincipal,
      ),
    );
  }

  // ==========================================
  // DECORACIÓN DE CAMPOS
  // ==========================================

  InputDecoration _decoracionFormulario(
    String etiqueta,
    IconData icono,
  ) {
    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: Icon(icono, color: verdePrincipal),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: verdePrincipal,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _campoFormulario({
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    TextInputType tipo = TextInputType.text,
    List<TextInputFormatter>? formato,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      inputFormatters: formato,
      decoration: _decoracionFormulario(etiqueta, icono),
    );
  }

  // ==========================================
  // OPCIONES DE PAGO
  // ==========================================

  Widget _opcionPago({
    required IconData icono,
    required String titulo,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 95,
        decoration: BoxDecoration(
          color: seleccionado ? fondoVerdeClaro : Colors.white,
          border: Border.all(
            color: seleccionado
                ? verdePrincipal
                : Colors.grey.shade300,
            width: seleccionado ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              color: verdePrincipal,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: seleccionado ? verdePrincipal : Colors.black87,
              ),
            ),
            if (seleccionado)
              const Icon(
                Icons.check_circle,
                color: verdePrincipal,
                size: 15,
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CAMPOS DE TARJETA
  // ==========================================

  Widget _campoPago(
    String etiqueta,
    String ejemplo,
    IconData icono, {
    TextInputType tipo = TextInputType.text,
    bool ocultar = false,
    TextEditingController? controller,
    List<TextInputFormatter>? formato,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: tipo,
          obscureText: ocultar,
          inputFormatters: formato,
          decoration: InputDecoration(
            hintText: ejemplo,
            prefixIcon: Icon(
              icono,
              size: 19,
              color: verdePrincipal,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: verdePrincipal,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MENSAJE OXXO Y PAYPAL
  // ==========================================

  Widget _mensajeMetodoPago(
    IconData icono,
    String titulo,
    String mensaje,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: fondoVerdeClaro,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDCEBCF),
        ),
      ),
      child: Column(
        children: [
          Icon(icono, color: verdePrincipal, size: 40),
          const SizedBox(height: 10),
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: verdePrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MOSTRAR MENSAJES
  // ==========================================

  void _mostrarMensaje(
    BuildContext context,
    String mensaje, {
    Color color = Colors.black87,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
      ),
    );
  }

  // ==========================================
  // IMAGEN DE ERROR
  // ==========================================

  Widget _imagenError() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(
        Icons.park,
        size: 60,
        color: Colors.grey,
      ),
    );
  }

  // ==========================================
  // TÍTULOS DE SECCIÓN
  // ==========================================

  Widget _tituloSeccion(String titulo) {
    return Text(
      titulo,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
      ),
    );
  }

  // ==========================================
  // APP BAR
  // ==========================================

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: verdePrincipal,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.park,
                  color: verdePrincipal,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  'Apadrina un árbol',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: verdePrincipal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

// ==========================================
// FORMATO DE EXPIRACIÓN MM/AA
// ==========================================

class ExpiracionFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String numeros = newValue.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (numeros.length > 4) {
      numeros = numeros.substring(0, 4);
    }

    if (numeros.isNotEmpty) {
      final primerNumero = int.tryParse(numeros[0]);

      if (primerNumero != null && primerNumero > 1) {
        return oldValue;
      }
    }

    if (numeros.length >= 2) {
      final mes = int.tryParse(numeros.substring(0, 2));

      if (mes == null || mes < 1 || mes > 12) {
        return oldValue;
      }
    }

    String resultado = numeros;

    if (numeros.length > 2) {
      resultado =
          '${numeros.substring(0, 2)}/${numeros.substring(2)}';
    }

    return TextEditingValue(
      text: resultado,
      selection: TextSelection.collapsed(
        offset: resultado.length,
      ),
    );
  }
}
