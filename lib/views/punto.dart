
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:microcash_cliente/views/pedidos.dart';
import 'package:microcash_cliente/views/tripulacion.dart';
import 'home.dart';

class Punto extends StatefulWidget {
  final Map<String,dynamic> param;


  Punto({super.key, required this.param});

  @override
  State<Punto> createState() => _PuntoState();
}

class _PuntoState extends State<Punto> {

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
        child:

        Column(
          children: [
            DatosCliente(context,widget.param),
            Text("${widget.param['pedidos']}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print(widget.param['pedidos']);
                    return;
                    // revisar
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Tripulacion(param: widget.param),
                      ),
                    );
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Pedidos(param: widget.param),
                      ),
                    );
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
            ),

          ],
        ),
      ),
    );
  }
}
