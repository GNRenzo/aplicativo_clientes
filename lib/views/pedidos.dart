import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'home.dart';

class Pedidos extends StatefulWidget {
  final dynamic param;

  Pedidos({super.key, required this.param});

  @override
  State<Pedidos> createState() => _TripulacionState();
}

class _TripulacionState extends State<Pedidos> {
  String link = dotenv.env['LINK'] ?? "http://localhost:8000";

  final Dio _dio = Dio();

  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  String _selectedService = '';
  int editContacto = 0;
  int idPedido = 0;
  TextEditingController nom1 = TextEditingController();
  TextEditingController num1 = TextEditingController();
  TextEditingController nom2 = TextEditingController();
  TextEditingController num2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  List pedidosRuta = [];
  List pedidosProg = [];

  Future<void> retornarPedidos() async {
    DateTime hoy = DateTime.now();
    hoy = DateTime(hoy.year, hoy.month, hoy.day);
    var key_punto = widget.param['key_punto'];
    var dio = Dio();
    var response22 = await dio.request(
      '$link/api_mobile/apk_cliente/listar_pedidos/?pe_key_punto_asociado=$key_punto&pe_fecha_atencion=${hoy.toString().split(' ')[0]}&key_estado_plan_diario=22',
      options: Options(method: 'GET'),
    );
    pedidosRuta = await (response22.data['resultSet']);

    var response4 = await dio.request(
      '$link/api_mobile/apk_cliente/listar_pedidos/?pe_key_punto_asociado=$key_punto&pe_fecha_atencion=${hoy.toString().split(' ')[0]}&key_estado_plan_diario=4',
      options: Options(method: 'GET'),
    );
    pedidosProg = await (response4.data['resultSet']);
    print("Recarga");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MICROCASH',
              textScaleFactor: 1,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              DateFormat('dd MMM yyyy hh:mma', 'es_ES').format(_currentDateTime),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
            )
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            retornarPedidos();
          });
        },
        child: FutureBuilder<void>(
            future: retornarPedidos(),
            builder: (context, snapshot) {
              return Container(
                  width: MediaQuery.sizeOf(context).width,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(children: [
                    DatosCliente(context, widget.param),
                    _selectedService == ''
                        ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            ElevatedButton(
                              onPressed: () {
                                if (pedidosRuta.isNotEmpty) {
                                  setState(() {
                                    _selectedService = 'En RUTA';
                                  });
                                } else {
                                  Fluttertoast.showToast(msg: "No existen pedidos en RUTA");
                                }
                              },
                              style: pedidosRuta.isNotEmpty
                                  ? ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                      foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                                    )
                                  : null,
                              child: Text('En RUTA (${pedidosRuta.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (pedidosProg.isNotEmpty) {
                                  setState(() {
                                    _selectedService = 'En PROGRAMACION';
                                  });
                                } else {
                                  Fluttertoast.showToast(msg: "No existen pedidos en PROGRAMACIÓN");
                                }
                              },
                              style: pedidosProg.isNotEmpty
                                  ? ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                      foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed))
                                  : null,
                              child: Text('En PROGRAMACION (${pedidosProg.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ])
                        : Container(
                            alignment: Alignment.center,
                            width: MediaQuery.sizeOf(context).width,
                            padding: const EdgeInsets.all(16),
                            color: Colors.grey[400],
                            child: Text(
                              _selectedService,
                              textScaleFactor: 1,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                    if (_selectedService == 'En RUTA')
                      Expanded(
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.all(16),
                          child: WidgetDatos(context, pedidosRuta, 22),
                        ),
                      ),
                    if (_selectedService == 'En PROGRAMACION') Expanded(child: Container(width: MediaQuery.sizeOf(context).width, padding: const EdgeInsets.all(16), child: WidgetDatos(context, pedidosProg, 4)))
                  ]));
            }),
      ),
    );
  }

  Widget WidgetDatos(BuildContext context, dynamic pedidos, int idEstado) {
    DateTime hoy = DateTime.now();
    hoy = DateTime(hoy.year, hoy.month, hoy.day);

    return pedidos.length > 0
        ? ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Column(
                    children: [
                      buildDataRow(context, 'FECHA', pedidos[index]['fecha_atencion'] ?? '', false),
                      buildDataRow(context, 'DIRECCION', pedidos[index]['punto_direccion'] ?? '', false),
                      buildDataRow(context, 'DISTRITO', pedidos[index]['distrito'] ?? '', false),
                      buildDataRow(context, 'PROVINCIA', pedidos[index]['provincia'] ?? '', false),
                      buildDataRow(context, 'TIPO DE FDS', pedidos[index]["tipo_fds"], false),
                      buildDataRow(context, 'CONTACTO 1', pedidos[index]['punto_nombre_contacto_ope'] ?? '', false),
                      buildDataRow(context, 'CONTACTO 2', pedidos[index]['punto_nombre_contacto_ope2'] ?? '', false),
                      buildDataRow(context, 'FRECUENCIA ${pedidos[index]['categoria_frecuencia']}', pedidos[index]['frecuencia'], false),
                    ],
                  ),
                  const Divider(),
                  WidgetRuta(context, pedidos[index], idEstado),
                  const SizedBox(height: 20),
                  editContacto == 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                editContacto = int.parse(pedidos[index]['key_punto'].toString()) ?? 0;
                                idPedido = int.parse(pedidos[index]['key_plan_diario'].toString()) ?? 0;
                                setState(() {
                                  nom1.text = pedidos[index]['punto_nombre_contacto_ope'];
                                  num1.text = pedidos[index]['punto_telefono_contacto_ope'];
                                  nom2.text = pedidos[index]['punto_nombre_contacto_ope2'];
                                  num2.text = pedidos[index]['punto_telefono_contacto_ope2'];
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                              ),
                              child: const Text(
                                "Cambio Contacto",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                int idUsuario = widget.param['pedidos'][0]['user_id'];
                                int key = pedidos[index]['key_plan_diario'];
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirmación'),
                                        content: Text('¿Estás seguro que deseas anular el pedido?'),
                                        actions: [
                                          TextButton(
                                            child: Text('Cancelar'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Confirmar'),
                                            onPressed: () {
                                              setState(() {
                                                pedidos[index]['key_estado_plan_id'] = -1;
                                                _showExitConfirmationDialog(idUsuario, key);
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                              ),
                              child: const Text(
                                "Anular Pedido",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      : pedidos[index]['key_plan_diario'] == idPedido
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: TextFormField(
                                    controller: nom1,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre Contacto 1',
                                      border: OutlineInputBorder(),
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: TextFormField(
                                    controller: num1,
                                    decoration: const InputDecoration(
                                      labelText: 'Teléfono Contacto 1',
                                      border: OutlineInputBorder(),
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: TextFormField(
                                    controller: nom2,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre Contacto 2',
                                      border: OutlineInputBorder(),
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: TextFormField(
                                    controller: num2,
                                    decoration: const InputDecoration(
                                      labelText: 'Teléfono Contacto 2',
                                      border: OutlineInputBorder(),
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() async {
                                          var headers = {'Content-Type': 'application/json'};
                                          var data = json.encode({
                                            "nombre_contacto_ope": nom1.text,
                                            "telefono_contacto_ope": num1.text,
                                            "nombre_contacto_ope2": nom2.text,
                                            "telefono_contacto_ope2": num2.text,
                                            "key_user_event": pedidos[index]['user_id']
                                          });
                                          var dio = Dio();
                                          var response = await dio.request(
                                            '$link/tablas/punto_asociado/modificar_contactos_apk/21',
                                            options: Options(
                                              method: 'PATCH',
                                              headers: headers,
                                            ),
                                            data: data,
                                          );

                                          // pedidos[index]['punto_nombre_contacto_ope'] = nom1.text;
                                          // pedidos[index]['punto_telefono_contacto_ope'] = num1.text;
                                          // pedidos[index]['punto_nombre_contacto_ope2'] = nom2.text;
                                          // pedidos[index]['punto_telefono_contacto_ope2'] = num2.text;
                                          editContacto = 0;
                                          limpiar();
                                        });
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                        foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                                      ),
                                      child: const Text(
                                        "Guardar",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          editContacto = 0;
                                          limpiar();
                                        });
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                                        foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                                      ),
                                      child: const Text(
                                        "Cancelar",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          : SizedBox(),
                ],
              );
            },
          )
        : const SizedBox();
  }

  Widget WidgetRuta(BuildContext context, dynamic dato, int tipo) {
    return Column(
      children: [
        buildDataRow(context, 'RUTA', "  ${dato['ruta'] ?? ''}", true),
        buildDataRow(context, 'SECUENCIA', "  ${dato['secuencia'] ?? ''}", true),
        buildDataRow(context, 'ARCO HORARIO', "  ${dato['arco_horario'] ?? ''}", true),
        buildDataRow(context, 'ESTADO', "  ${dato['estado_plan'] ?? ''}", true),
      ],
    );
  }

  void _showExitConfirmationDialog(int idUser, int key_pedido) async {
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"key_user_event": idUser});
    var dio = Dio();
    var response = await dio.request(
      '$link/solped/plan_diario/anular_cliente_apk/$key_pedido',
      options: Options(
        method: 'PATCH',
        headers: headers,
      ),
      data: data,
    );
  }

  void limpiar() {
    nom1.text = '';
    num1.text = '';
    nom2.text = '';
    num2.text = '';
  }
}
