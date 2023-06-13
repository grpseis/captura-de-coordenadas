import 'package:demo_app/domain/geo_controller.dart';
import 'package:demo_app/domain/people_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/people.dart';

class PeopleWidget extends StatefulWidget {
  const PeopleWidget({Key? key}) : super(key: key);

  @override
  State<PeopleWidget> createState() => _PeopleWidgetState();
}

class _PeopleWidgetState extends State<PeopleWidget> {
  // Controladores Get
  PeopleController plpCtrl = Get.find();
  GeoController geoCtrl = Get.find();
  // Controladores Widgets
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  late String lat = '0';
  late String long = '0';

  // Metodo para iniciar la instancia de los listeners
  @override
  void initState() {
    super.initState();
    plpCtrl.init();
  }

  // Metodo para detener la instancia de los listeners
  @override
  void dispose() {
    plpCtrl.destroy();
    super.dispose();
  }

  // Widget encargado de mostrar los mensajes que se encuentren
  // registrados en la base de datos
  Widget _messageCard(People msg, int index) {
    return Card(
      margin: const EdgeInsets.only(left: 50, top: 10, bottom: 10, right: 10),
      color: Colors.blue[100],
      child: ListTile(
        title: Text(
          msg.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text("${msg.latitude}, ${msg.longitude}"),
        onTap: () async {
          String googleUrl =
              'https://www.google.com/maps/search/?api=1&query=${msg.latitude},${msg.longitude}';
          if (await canLaunch(googleUrl)) {
            await launch(googleUrl);
          }
        },
      ),
    );
  }

  // Widget encargado de mostrar el listado de mensajes en la}
  // base de datos
  Widget _messageList() {
    return GetX<PeopleController>(
      builder: ((controller) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
        return ListView.builder(
          itemCount: plpCtrl.peoples.length,
          controller: _scrollCtrl,
          itemBuilder: ((context, index) {
            var msg = plpCtrl.peoples[index];
            return _messageCard(msg, index);
          }),
        );
      }),
    );
  }

  // Widget para el input de texto
  Widget _messageInput() {
    return Container(
      margin: const EdgeInsets.all(5),
      child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Nombre",
        ),
        controller: _msgCtrl,
        onSubmitted: (value) async {
          await _add();
          _msgCtrl.clear();
        },
      ),
    );
  }

  // Hacer scroll de los mensajes nuevos
  _scrollToEnd() async {
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _openSettings() async {
    var status = await geoCtrl.getStatusGpsPermission();
    if (status.isPermanentlyDenied || status.isDenied) {
      openAppSettings();
    }
  }

  void _getPosition() async {
    try {
      var status = await geoCtrl.getStatusGpsPermission();
      if (!status.isGranted) {
        status = await geoCtrl.requestGpsPermission();
      }
      if (status.isGranted) {
        var pst = await geoCtrl.getCurrentPosition();
        lat = pst.latitude.toString();
        long = pst.longitude.toString();
      } else {
        lat = "0";
        long = "0";
      }
    } catch (e) {
      lat = "0";
      long = "0";
    }
  }

  // Metodo para enviar mensajes
  Future<void> _add() async {
    _getPosition();
    await plpCtrl
        .add(People(name: _msgCtrl.text, latitude: lat, longitude: long));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: _messageList(),
        ),
        _messageInput(),
      ],
    );
  }
}
