import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  runApp(const MyAuth());

}

// authentication

class MyAuth extends StatelessWidget {
  const MyAuth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Inicio de Sesión'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message = '';
  String _signal = "";
  final String _email = 'dmaster@uninorte.edu.co';
  final String _pswd = 'Sup3rS3cr3tP@ssw0rd';

  void _createUser() async {
    String msg = "";
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _pswd);
      msg = 'User created!';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        msg = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'The account already exists for that email.';
      }
    } catch (e) {
      msg = 'error caught: $e';
    } finally {
      setState(() {
        message = msg;
      });
    }
  }

  // Retornar tipo de señal en ese instante
  Future<ConnectivityResult> _getSignalType() {
    return (Connectivity().checkConnectivity());
  }

  void _verifyUser() async {
    String msg = "";
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _pswd);
      msg = 'User Authenticated!';
      runApp(const MyApp());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        msg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        msg = 'Wrong password provided for that user.';
      }
    } catch (e) {
      msg = 'error caught: $e';
    } finally {
      setState(() {
        message = msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
              ],
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _createUser();
            },
            tooltip: 'Create',
            child: const Icon(Icons.supervisor_account),
          ),
          const SizedBox(
            height: 4,
          ),
          FloatingActionButton(
            onPressed: () {
              _verifyUser();
            },
            tooltip: 'Verify',
            child: const Icon(Icons.verified_user),
          ),
          FloatingActionButton(
            onPressed: () async {
              // Verficar tipo de señal
              var connectivityResult = await _getSignalType();
              setState(() {
                // Validar si es Wifi
                if (connectivityResult == ConnectivityResult.wifi) {
                  _signal = "Wifi";
                  // Validar si es Movil
                } else if (connectivityResult == ConnectivityResult.mobile) {
                  _signal = "Mobile";
                } else {
                  // No hay señal
                  _signal = "No Signal";
                }
                message = _signal;
              });
            },
            tooltip: 'Check',
            child: const Icon(Icons.wifi_rounded),
          )
        ],
      ),
    );
  }
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
          title: const Text("Captura de Coordenadas"),
        ),
        body: const PeopleWidget(),
      ),
    );
  }
}