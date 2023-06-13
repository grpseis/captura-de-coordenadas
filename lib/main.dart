import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'domain/geo_controller.dart';
import 'domain/people_controller.dart';
import 'ui/people_widget.dart';

void main() async {
  // Esto es obligatorio
  WidgetsFlutterBinding.ensureInitialized();

  // Iniciar instancia de Loggy
  Loggy.initLoggy(
      logPrinter: const PrettyPrinter(
    showColors: true,
  ));

  // Iniciar Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Inyectar el controlador
    Get.put(PeopleController());
    Get.put(GeoController());

    return GetMaterialApp(
      title: 'Flutter Cloud Database',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Cloud Database"),
        ),
        body: const PeopleWidget(),
      ),
    );
  }
}