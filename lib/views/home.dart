import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  List<dynamic> _clientes = [];
  List<dynamic> _puntosAsociados = [];
  List<dynamic> _tripulacion = [];
  int? _selectedClienteId;
  int? _selectedPuntoId;
  late final TextEditingController _controllercodTri = TextEditingController();
  late final TextEditingController _controllerDNI = TextEditingController();
  late final TextEditingController _controllerNumUnidad = TextEditingController();


  String _triDNI = '';
  String _triNombre = '';
  String _triFoto = '';
  String _triFirma = '';

  @override
  void initState() {
    super.initState();
    _fetchClientes();
  }

  Future<void> _fetchClientes() async {

    try {
      final response = await _dio.get("$link/tablas/cliente/listar/?key_status=1&id=0");
      setState(() {
        _clientes = response.data['resultSet'];
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchPuntosAsociados(int clienteId) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Obteniendo Datos...'),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        );
      },
    );

    try {
      final response = await _dio.get('$link/tablas/punto_asociado/listarAPK/?key_estado=1&key_cliente=0', queryParameters: {'id': clienteId});
      setState(() {
        _puntosAsociados = response.data['resultSet'];
        _selectedPuntoId = null;
      });
    } catch (e) {
      print(e);
    }

    Navigator.of(context).pop();
  }

  Future<void> _fetchTripulacion(String dni) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Obteniendo Datos...'),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        );
      },
    );

    try {
      final response = await _dio.get('$link/tablas/tripulacion/listar/?key_estado_id=1&tipo_oficial_id=0&id=0');
      setState(() {
        _tripulacion = response.data['resultSet'];

      });

      var resultado = _tripulacion.where((i) => i['dni'] == dni).toList();

      if(resultado.isNotEmpty){
        setState(() {
          _triDNI = resultado[0]['dni'];
          _triNombre = resultado[0]['nombre_oficial'];
          _triFoto = resultado[0]['url_foto'];
          _triFirma = resultado[0]['url_firma'];
        });


        print('_____________');


        Navigator.of(context).pop();

        showDialog<void>(
          context: context,
          builder: (context) => Dialog.fullscreen(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Tripulante', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryFixed, fontWeight: FontWeight.w600)),
                  centerTitle: true,
                  leading: const SizedBox(),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.close, size: 30, color: Theme.of(context).colorScheme.onPrimaryFixed,),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                body: ListView(
                  children: [
                    const SizedBox(height: 32),
                    Text('Nombres: $_triNombre', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
                    const SizedBox(height: 16),
                    Text('DNI: $_triDNI', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
                    const SizedBox(height: 16),
                    Text('Foto:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
                    const SizedBox(height: 16),
                    Image.network(
                      _triFoto,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('Failed to load image');
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Firma:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
                    const SizedBox(height: 16),
                    Image.network(
                      _triFirma,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('Failed to load image');
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                          foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                        ),
                        label: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold),),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );


      }
      else{
        toasty(context, "No se encontraron resultados.",
            bgColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.onPrimary,
            gravity: ToastGravity.CENTER);


        Navigator.of(context).pop();
      }

    } catch (e) {
      print(e);


      Navigator.of(context).pop();
    }
  }

  void openFullscreenDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Full-screen dialog'),
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
        title: Text('Microcash Cliente', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.tertiaryContainer, ),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
          },
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).colorScheme.onPrimary,
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
            const SizedBox(height: 8),
            _buildDropdownButtonFormField(
              hint: 'Seleccione un Cliente',
              value: _selectedClienteId,
              items: _clientes,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedClienteId = newValue;
                  _fetchPuntosAsociados(newValue!);
                });
              },
            ),
            const SizedBox(height: 32),
            Text('Punto', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
            const SizedBox(height: 8),
            _buildDropdownButtonFormField(
              hint: 'Seleccione un Punto',
              value: _selectedPuntoId,
              items: _puntosAsociados,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedPuntoId = newValue;
                });
              },
            ),
            const SizedBox(height: 32),
            const Divider(key: Key('divider')),
            const SizedBox(height: 32),
            TextFormField(
              controller: _controllercodTri,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).nextFocus();
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary,),
                labelText: 'COD. TRIPULACIÓN',
                hintText: 'Ingrese cod. tripulación ',
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _controllerDNI,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_) {
                FocusScope.of(context).nextFocus();
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary,),
                labelText: 'DNI',
                hintText: 'Ingrese DNI ',
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _controllerNumUnidad,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_) {
                FocusScope.of(context).nextFocus();
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary,),
                labelText: 'NÚMERO DE UNIDAD',
                hintText: 'Ingrese número de unidad ',
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondaryFixed),
                          foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                        ),
                        label: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    )
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _fetchTripulacion(_controllerDNI.text);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.tertiaryContainer),
                        foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryFixed),
                      ),
                      label: const Text('  Mostrar', style: TextStyle(fontWeight: FontWeight.bold),),
                      icon: const Icon(Icons.remove_red_eye),
                    ),
                  ),
                )
              ],
            ),
          ],
        )
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
        contentPadding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 18),
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
            color:  Theme.of(context).colorScheme.primary.withOpacity(0),
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
          child: Text(item['razon_social'] ?? item['razon_social_punto'], style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryFixed),),
        );
      }).toList(),
    );
  }

}