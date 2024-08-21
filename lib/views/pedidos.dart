import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    print(widget.param);
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
        child: Column(
          children: [
            DatosCliente(context, widget.param),
            _selectedService == ''
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(
                            () {
                              _selectedService = 'En RUTA';
                            },
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.tertiaryContainer),
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
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.tertiaryContainer),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.onPrimaryFixed),
                        ),
                        child: const Text('En PROGRAMACION',
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
            if (_selectedService == 'En RUTA')
              Container(
                width: MediaQuery.sizeOf(context).width,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    WidgetDatos(context),
                    Divider(),
                    WidgetRuta(context),
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
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).colorScheme.onPrimaryFixed),
                          ),
                          child: Text(
                            "Cambio Contacto",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // _showExitConfirmationDialog('Gestión Pedidos');
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
                          child: const Text(
                            "Anular Pedido",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Navigator.of(context).pop();
                          _selectedService = '';
                        });
                      },
                      child: const Text(
                        "Atras",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            if (_selectedService == 'En PROGRAMACION')
              Container(
                width: MediaQuery.sizeOf(context).width,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    WidgetDatos(context),
                    SizedBox(height: 5),
                    WidgetRuta2(context),
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
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).colorScheme.onPrimaryFixed),
                          ),
                          child: const Text(
                            "Cambio Contacto",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).colorScheme.onPrimaryFixed),
                          ),
                          child: const Text(
                            "Anular Pedido",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(
                          () {
                            // Navigator.of(context).pop();
                            _selectedService = '';
                          },
                        );
                      },
                      child: const Text(
                        "Atras",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
