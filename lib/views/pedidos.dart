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

  @override
  Widget build(BuildContext context) {
    DateTime hoy = DateTime.now();
    hoy = DateTime(hoy.year, hoy.month, hoy.day);
    List pedidosRuta = widget.param['pedidos'].where((pedido) {
      try {
        if (pedido['fecha_atencion'] == null || pedido['fecha_atencion'].isEmpty) {
          return false;
        }
        DateTime fechaAtencion = DateTime.parse(pedido['fecha_atencion']);

        return pedido['key_estado_plan_id'] == 22 && (fechaAtencion.isAtSameMomentAs(hoy) || fechaAtencion.isAfter(hoy));
      } catch (e) {
        print('Error al procesar el pedido: $e');
        return false;
      }
    }).toList();
    List pedidosProg = widget.param['pedidos'].where((pedido) {
      try {
        if (pedido['fecha_atencion'] == null || pedido['fecha_atencion'].isEmpty) {
          return false;
        }
        DateTime fechaAtencion = DateTime.parse(pedido['fecha_atencion']);

        return pedido['key_estado_plan_id'] == 4 && (fechaAtencion.isAtSameMomentAs(hoy) || fechaAtencion.isAfter(hoy));
      } catch (e) {
        print('Error al procesar el pedido: $e');
        return false;
      }
    }).toList();
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
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white),
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          child: Column(
            children: [
              DatosCliente(context, widget.param),
              _selectedService == ''
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(

                          onPressed: () {
                            if(pedidosRuta.length>0){
                            setState(
                              () {
                                _selectedService = 'En RUTA';
                              },
                            );
                            }else{
                              Fluttertoast.showToast(msg: "No existen pedidos en RUTA");
                            }
                          },
                          style: pedidosRuta.length>0?ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                            foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                          ):null,
                          child: const Text('En RUTA', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if(pedidosProg.length>0){
                            setState(() {
                              _selectedService = 'En PROGRAMACION';
                            });
                            }else{
                              Fluttertoast.showToast(msg: "No existen pedidos en PROGRAMACIÓN");
                            }
                          },
                          style: pedidosProg.length>0?ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                            foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                          ):null,
                          child: const Text('En PROGRAMACION', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
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
                    child: WidgetDatos(context, widget.param['pedidos'], 22),
                  ),
                ),
              if (_selectedService == 'En PROGRAMACION')
                Expanded(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    padding: const EdgeInsets.all(16),
                    child: WidgetDatos(context, widget.param['pedidos'], 4),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget WidgetDatos(BuildContext context, dynamic pedidos, int idEstado) {
    DateTime hoy = DateTime.now();
    hoy = DateTime(hoy.year, hoy.month, hoy.day);

    var pedidosFiltrados = pedidos.where((pedido) {
      try {
        if (pedido['fecha_atencion'] == null || pedido['fecha_atencion'].isEmpty) {
          return false;
        }
        DateTime fechaAtencion = DateTime.parse(pedido['fecha_atencion']);

        return pedido['key_estado_plan_id'] == idEstado && (fechaAtencion.isAtSameMomentAs(hoy) || fechaAtencion.isAfter(hoy));
      } catch (e) {
        print('Error al procesar el pedido: $e');
        return false;
      }
    }).toList();

    return pedidosFiltrados.length > 0
        ? ListView.builder(
            itemCount: pedidosFiltrados.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Column(
                    children: [
                      buildDataRow(context, 'FECHA', pedidosFiltrados[index]['fecha_atencion'] ?? '', false),
                      buildDataRow(context, 'DIRECCION', pedidosFiltrados[index]['punto_direccion'] ?? '', false),
                      buildDataRow(context, 'DISTRITO', pedidosFiltrados[index]['distrito'] ?? '', false),
                      buildDataRow(context, 'PROVINCIA', pedidosFiltrados[index]['provincia'] ?? '', false),
                      buildDataRow(context, 'TIPO DE FDS', pedidosFiltrados[index]["tipo_fds"], false),
                      buildDataRow(context, 'CONTACTO 1', pedidosFiltrados[index]['punto_nombre_contacto_ope'] ?? '', false),
                      buildDataRow(context, 'CONTACTO 2', pedidosFiltrados[index]['punto_nombre_contacto_ope2'] ?? '', false),
                      buildDataRow(context, 'FRECUENCIA', pedidosFiltrados[index]['categoria_frecuencia'], false),
                      buildDataRow(context, 'VALOR FRECUENCIA', pedidosFiltrados[index]['frecuencia'], false),
                    ],
                  ),
                  const Divider(),
                  WidgetRuta(context, pedidosFiltrados[index], idEstado),
                  const SizedBox(height: 20),
                  editContacto == 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  editContacto = int.parse(pedidosFiltrados[index]['key_punto'].toString()) ?? 0;
                                  idPedido = int.parse(pedidosFiltrados[index]['key_plan_diario'].toString()) ?? 0;

                                  nom1.text = pedidosFiltrados[index]['punto_nombre_contacto_ope'];
                                  num1.text = pedidosFiltrados[index]['punto_telefono_contacto_ope'];
                                  nom2.text = pedidosFiltrados[index]['punto_nombre_contacto_ope2'];
                                  num2.text = pedidosFiltrados[index]['punto_telefono_contacto_ope2'];
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
                                int idUsuario = pedidosFiltrados[index]['user_id'];
                                int key = pedidosFiltrados[index]['key_plan_diario'];
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
                                              Navigator.of(context).pop(); // Cerrar el diálogo
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Confirmar'),
                                            onPressed: () {
                                              setState(() {
                                                pedidosFiltrados[index]['key_estado_plan_id'] = -1;
                                                _showExitConfirmationDialog(idUsuario, key);
                                              });
                                              Navigator.of(context).pop(); // Cerrar el diálogo
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
                      : SizedBox(),
                  editContacto == 0
                      ? SizedBox()
                      : pedidosFiltrados[index]['key_plan_diario'] == idPedido
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
                                            "key_user_event": pedidosFiltrados[index]['user_id']
                                          });
                                          var dio = Dio();
                                          var response = await dio.request(
                                            'http://armadillo-microcash.com/etarma_backend/tablas/punto_asociado/modificar_contactos_apk/21',
                                            options: Options(
                                              method: 'PATCH',
                                              headers: headers,
                                            ),
                                            data: data,
                                          );
                                          pedidosFiltrados[index]['punto_nombre_contacto_ope'] = nom1.text;
                                          pedidosFiltrados[index]['punto_telefono_contacto_ope'] = num1.text;
                                          pedidosFiltrados[index]['punto_nombre_contacto_ope2'] = nom2.text;
                                          pedidosFiltrados[index]['punto_telefono_contacto_ope2'] = num2.text;
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
      'http://armadillo-microcash.com/etarma_backend/solped/plan_diario/anular_cliente_apk/$key_pedido',
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
