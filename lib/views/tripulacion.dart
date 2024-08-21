import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'package:image/image.dart' as ima;

class Tripulacion extends StatefulWidget {
  final dynamic param;

  Tripulacion({super.key, required this.param});

  @override
  State<Tripulacion> createState() => _TripulacionState();
}

class _TripulacionState extends State<Tripulacion> {
  String link = dotenv.env['LINK'] ?? "http://localhost:8000";

  final Dio _dio = Dio();

  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  bool verDetalle = false;
  late final TextEditingController _controllercodigo = TextEditingController();
  late final TextEditingController _controllerdni = TextEditingController();

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
            Container(
              alignment: Alignment.center,
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[400],
              child: Text(
                "Verificar Tripulación",
                textScaleFactor: 1,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    !verDetalle
                        ? Column(
                            children: [
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
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        verDetalle = true;
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
                                      Navigator.of(context).pop();
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : SizedBox(),
                    verDetalle ? Center(child: WidgetDatosUser()) : SizedBox()
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget WidgetDatosUser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width * 0.5,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'UNIDAD:',
                  textAlign: TextAlign.start,
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
                'XYZ',
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
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, top: 14),
          child: Text(
            'COLABORADOR:',
            textAlign: TextAlign.start,
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
        Center(
          child: Image.network(
            'https://www.freepsdking.com/wp-content/uploads/2023/03/20X30-Album-Design-PSD-Free-Download-Freepsdking.com-1.webp',
            height: MediaQuery.sizeOf(context).height*0.2,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              }
            },
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return Text('No se pudo cargar la imagen');
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, top: 14),
          child: Text(
            'FIRMA:',
            textAlign: TextAlign.start,
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
        Center(
          child: Image.network(
            'https://www.freepsdking.com/wp-content/uploads/2023/03/20X30-Album-Design-PSD-Free-Download-Freepsdking.com-1.webp',
            height: MediaQuery.sizeOf(context).height*0.15,
            width: MediaQuery.sizeOf(context).width*0.5,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              }
            },
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return Text('No se pudo cargar la imagen');
            },
          ),
        ),
        SizedBox(height: 12),
        Center(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                verDetalle = false;
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.tertiaryContainer),
              foregroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.onPrimaryFixed),
            ),
            child: Text("Salir", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
