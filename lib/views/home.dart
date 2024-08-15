import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:microcash_cliente/views/login.dart';
import 'package:nb_utils/nb_utils.dart';

class MyHomePage extends StatefulWidget {
  final Map<String, dynamic> trabajador;

  const MyHomePage({super.key, required this.trabajador});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String link = dotenv.env['LINK'] ?? "http://localhost:8000";

  final Dio _dio = Dio();

  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
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
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _showExitConfirmationDialog() {
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
                    _selectedService = '';
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
                Text("TELEPIZZA"),
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
                Text("PD-014 LA MERCED"),
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
                Text("USRLAMERCED"),
              ],
            ),
            const SizedBox(height: 16),
            _selectedService == ''
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedService = 'Verificar Tripulación';
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
                : Container(
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
                  ),
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
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _controllerunidad,
                              decoration: const InputDecoration(
                                labelText: 'UNIDAD',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                // data['num_serial'] = value;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      //Buscar
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
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
                                      _showExitConfirmationDialog();
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimaryFixed),
                                  ),
                                  child: const Text(
                                    "Salir",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    )
                  : Container(
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text("xxxx"),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    //Buscar
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer),
                                  foregroundColor:
                                  MaterialStateProperty.all<Color>(
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
                                    _showExitConfirmationDialog();
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer),
                                  foregroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Theme.of(context)
                                          .colorScheme
                                          .onPrimaryFixed),
                                ),
                                child: const Text(
                                  "Salir",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButtonFormField({
    required String hint,
    required int? value,
    required List<dynamic> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      iconEnabledColor: Theme.of(context).colorScheme.onPrimaryFixed,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondaryFixed,
        contentPadding:
            const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0),
            width: 1.5,
          ),
        ),
      ),
      hint: Text(hint),
      value: value,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<int>>((dynamic item) {
        return DropdownMenuItem<int>(
          value: item['id'],
          child: Text(
            item['razon_social'] ?? item['razon_social_punto'],
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryFixed),
          ),
        );
      }).toList(),
    );
  }
}
