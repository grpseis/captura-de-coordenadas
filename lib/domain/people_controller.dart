import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../model/people.dart';

class PeopleController extends GetxController {
  // Todas las personas de la base de datos
  final _peoples = <People>[].obs;

  // Configuracion de la db
  final db = FirebaseFirestore.instance.collection('peoples');
  final _events = FirebaseFirestore.instance.collection('peoples').snapshots();
  late StreamSubscription<Object?> _subs;

  // Getter
  List<People> get peoples => _peoples;

  // Metodo de Inicio
  init() {
    _subs = _events.listen((event) {
      _peoples.clear();
      for (var obj in event.docs) {
        _peoples.add(People.fromSnapshot(obj));
      }
    });
  }

  // Metodo para destruir
  destroy() {
    _subs.cancel();
  }

  // Metodo para creacion de Personas
  Future<void> add(People people) async {
    try {
      db
          .add(people.toJson())
          .then((value) => print('Dato Agregado.'))
          .catchError((error) => print('Error $error'));
    } catch (e) {
      return Future.error(e);
    }
  }
}
