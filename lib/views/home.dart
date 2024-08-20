import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:microcash_cliente/views/login.dart';
import 'package:nb_utils/nb_utils.dart';

class MyHomePage extends StatefulWidget {
  final List<dynamic> trabajador;

  const MyHomePage({super.key, required this.trabajador});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String link = dotenv.env['LINK'] ?? "http://localhost:8000";

  final Dio _dio = Dio();

  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  List<bool> estadoO = [];
  String _selectedService = '';

  late final TextEditingController _controllercodigo = TextEditingController();
  late final TextEditingController _controllerdni = TextEditingController();
  late final TextEditingController _controllerunidad = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
    for (var a in widget.trabajador) {
      estadoO.add(false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _showExitConfirmationDialog(String select, int ind) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alerta'),
          content: Text('¿Está seguro que desea salir?'),
          actions: <Widget>[
            TextButton(
              child: Text('Salir'),
              onPressed: () {
                setState(
                  () {
                    _selectedService = select;
                    estadoO[ind]=false;
                  },
                );
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
            Text(
              DateFormat('dd MMM yyyy hh:mma', 'es_ES')
                  .format(_currentDateTime),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 13),
            )
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.logout_rounded,
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()));
          },
        ),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white),
        child: ListView.builder(
          itemCount: widget.trabajador.length,
          itemBuilder: (context, index) {
            return widget.trabajador[index]['id_tipo_usuario'] != 1
                ? PuntoCliente(widget.trabajador[index], index)
                : SizedBox();
          },
        ),
      ),
    );
  }

  Widget PuntoCliente(dynamic arr, int index) {
    print(arr);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Cliente: ",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
              Text(arr['cliente_razon_social'] ?? ""),
            ],
          ),
          Row(
            children: [
              Text(
                "Punto: ",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
              Text(arr['cliente_direccion'] ?? arr['punto_razon_social']),
            ],
          ),
          Row(
            children: [
              Text(
                "Usuario: ",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
              Text(arr['username'] ?? ""),
            ],
          ),
          const SizedBox(height: 10),
          _selectedService == ''
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedService = 'Verificar Tripulación';
                          estadoO[index] = true;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.tertiaryContainer),
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.onPrimaryFixed),
                      ),
                      child: const Text('Verificar Tripulación',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedService = 'Gestión Pedidos';
                          estadoO[index] = true;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.tertiaryContainer),
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.onPrimaryFixed),
                      ),
                      child: const Text('Gestión Pedidos',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              : _selectedService == 'Gestión Pedidos'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedService = 'En RUTA';
                              estadoO[index] = true;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).colorScheme.onPrimaryFixed),
                          ),
                          child: const Text('En RUTA',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedService = 'En PROGRAMACION';
                              estadoO[index] = true;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).colorScheme.onPrimaryFixed),
                          ),
                          child: const Text('En PROGRAMACION',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  : estadoO[index]
                      ? Container(
                          alignment: Alignment.center,
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.all(16),
                          color: Colors.grey[400],
                          child: Text(
                            _selectedService,
                            textScaleFactor: 1,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        )
                      : SizedBox(),
          estadoO[index]
              ? Column(
                  children: [
                    const SizedBox(height: 5),
                    if (_selectedService.isNotEmpty)
                      _selectedService == 'Verificar Tripulación'
                          ? Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: _controllercodigo,
                                      decoration: const InputDecoration(
                                        labelText: 'CÓDIGO',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        // data['num_serial'] = value;
                                      },
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: _controllerdni,
                                      decoration: const InputDecoration(
                                        labelText: 'DNI',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        // data['num_serial'] = value;
                                      },
                                      textInputAction: TextInputAction.next,
                                    ),
                                    // const SizedBox(height: 15),
                                    // TextFormField(
                                    //   controller: _controllerunidad,
                                    //   decoration: const InputDecoration(
                                    //     labelText: 'UNIDAD',
                                    //     border: OutlineInputBorder(),
                                    //   ),
                                    //   onChanged: (value) {
                                    //     // data['num_serial'] = value;
                                    //   },
                                    //   textInputAction: TextInputAction.next,
                                    // ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              //Buscar
                                            });
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .tertiaryContainer),
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryFixed),
                                          ),
                                          child: Text("Consultar",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _showExitConfirmationDialog('',index);
                                            });
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .tertiaryContainer),
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryFixed),
                                          ),
                                          child: const Text(
                                            "Salir",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            )
                          : _selectedService == 'Gestión Pedidos'
                              ? Container(
                                  width: MediaQuery.sizeOf(context).width,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(
                                            () {
                                              _selectedService = '';
                                            },
                                          );
                                        },
                                        child: const Text(
                                          "Atras",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _selectedService == 'En RUTA'
                                  ? Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          WidgetDatos(context),
                                          Divider(),
                                          WidgetRuta(context),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    //Buscar
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Theme.of(
                                                              context)
                                                          .colorScheme
                                                          .tertiaryContainer),
                                                  foregroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onPrimaryFixed),
                                                ),
                                                child: Text(
                                                  "Cambio Contacto",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    // _showExitConfirmationDialog('Gestión Pedidos');
                                                    // _showExitConfirmationDialog('');
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Theme.of(
                                                              context)
                                                          .colorScheme
                                                          .tertiaryContainer),
                                                  foregroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onPrimaryFixed),
                                                ),
                                                child: const Text(
                                                  "Anular Pedido",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _showExitConfirmationDialog(
                                                    'Gestión Pedidos',index);
                                                // _showExitConfirmationDialog('');
                                              });
                                            },
                                            child: const Text(
                                              "Atras",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          WidgetDatos(context),
                                          SizedBox(height: 5),
                                          WidgetRuta2(context),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    //Buscar
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Theme.of(
                                                              context)
                                                          .colorScheme
                                                          .tertiaryContainer),
                                                  foregroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onPrimaryFixed),
                                                ),
                                                child: const Text(
                                                  "Cambio Contacto",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    // _showExitConfirmationDialog('Gestión Pedidos');
                                                    // _showExitConfirmationDialog('');
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Theme.of(
                                                              context)
                                                          .colorScheme
                                                          .tertiaryContainer),
                                                  foregroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onPrimaryFixed),
                                                ),
                                                child: const Text(
                                                  "Anular Pedido",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(
                                                () {
                                                  _showExitConfirmationDialog(
                                                      'Gestión Pedidos',index);
                                                  // _showExitConfirmationDialog('');
                                                },
                                              );
                                            },
                                            child: const Text(
                                              "Atras",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                  ],
                )
              : SizedBox()
        ],
      ),
    );
  }
}

Widget WidgetRuta(BuildContext context) {
  return Column(
    children: [
      buildDataRow(context, 'RUTA', "001 - CENTRO", true),
      buildDataRow(context, 'SECUENCIA', "10", true),
      buildDataRow(context, 'ARCO HORARIO', "09:00 - 11:00", true),
      buildDataRow(context, 'ESTADO', "", true),
    ],
  );
}

Widget WidgetRuta2(BuildContext context) {
  return Column(
    children: [
      buildDataRow(context, 'RUTA', "", true),
      buildDataRow(context, 'SECUENCIA', "", true),
      buildDataRow(context, 'ARCO HORARIO', "09:00 - 11:00", true),
      buildDataRow(context, 'ESTADO', "", true),
    ],
  );
}

Widget WidgetDatos(BuildContext context) {
  return Column(
    children: [
      buildDataRow(context, 'FECHA', "10/08/2024", false),
      buildDataRow(
          context, 'DIRECCION', "Av. alfredo benavides n° 2192", false),
      buildDataRow(context, 'DISTRITO', "Miraflores", false),
      buildDataRow(context, 'PROVINCIA', "Lima", false),
      buildDataRow(context, 'TIPO DE FDS', "1 Fondo de 500 soles", false),
      buildDataRow(context, 'CONTACTO 1', "CNT 1 PR-014 LA MERCED", false),
      buildDataRow(context, 'CONTACTO 2', "CNT 1 PR-014 LA MERCED", false),
      buildDataRow(context, 'FRECUENCIA', "DIARIA", false),
      buildDataRow(context, 'VALOR FRECUENCIA', "", false),
    ],
  );
}

Widget buildDataRow(
    BuildContext context, String label, String value, bool col) {
  return Row(
    children: [
      Container(
        width: MediaQuery.sizeOf(context).width * 0.3,
        color: col ? Colors.grey : null,
        child: Padding(
          padding: EdgeInsets.only(right: 9),
          child: Text(
            label,
            textAlign: TextAlign.end,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: 1,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      Flexible(
        child: Text(
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: 1,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      )
    ],
  );
}
