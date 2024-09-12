import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:microcash_cliente/views/login.dart';
import 'package:microcash_cliente/views/punto.dart';

class MyHomePage extends StatefulWidget {
   List<dynamic> trabajador;

  MyHomePage({super.key, required this.trabajador});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String link = dotenv.env['LINK'] ?? "http://localhost:8000";

  final Dio dio = Dio();

  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  List<bool> estadoO = [];

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
                    // _selectedService = select;
                    estadoO[ind] = false;
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
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.tertiaryContainer,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          ),
          centerTitle: true,
        ),
        body: Container(
            width: MediaQuery.sizeOf(context).width,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white),
            child: RefreshIndicator(
                onRefresh: () async {
                  int idUser = widget.trabajador[0]['pedidos'][0]['user_id'];
                  String fecha = "${DateTime.now().year.toString().padLeft(4, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
                  var response2 = await dio.request('$link/tablas/punto_asociado/listarAPKUsuario/?user_id=$idUser&fecha_atencion=$fecha', options: Options(method: 'GET'));
                  setState(() {
                    widget.trabajador = response2.data['resultSet'];
                  });
                },
                child: Column(children: [
                  WidgetCabecera(context, widget.trabajador[0]),
                  Divider(),
                  Flexible(
                      child: ListView.builder(
                          itemCount: widget.trabajador.length,
                          itemBuilder: (context, index) {
                            return widget.trabajador[index]['id_tipo_usuario'] != 1 ? PuntoCliente(widget.trabajador[index]) : SizedBox();
                          }))
                ]))));
  }

  Widget PuntoCliente(dynamic arr) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.07,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Punto: ",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      arr['cliente_punto_razon_social'] ?? arr['punto_razon_social'],
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Punto(param: arr),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget DatosCliente(BuildContext context, arr) {
  return Column(
    children: [
      Row(
        children: [
          Text(
            "Cliente: ",
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          Text(arr['cliente_razon_social'] ?? ""),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Punto: ",
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              arr['cliente_punto_razon_social'] ?? arr['punto_razon_social'],
              maxLines: 2,
            ),
          ),
        ],
      ),
      Row(
        children: [
          Text(
            "Usuario: ",
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          Text(arr['username'] ?? ""),
        ],
      ),
      const SizedBox(height: 10),
    ],
  );
}

Widget WidgetCabecera(BuildContext context, arr) {
  return Column(
    children: [
      Row(
        children: [
          Text(
            "Cliente: ",
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          Text(arr['cliente_razon_social'] ?? ""),
        ],
      ),
      Row(
        children: [
          Text(
            "Usuario: ",
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          Text(arr['username'] ?? ""),
        ],
      ),
      const SizedBox(height: 10),
    ],
  );
}

Widget buildDataRow(BuildContext context, String label, String value, bool col) {
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
