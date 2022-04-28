// @dart=2.9
import 'package:flutter/material.dart';
import 'package:etiquetainteligente/naviigation_drawer.dart';
import 'package:camera/camera.dart';
import 'package:etiquetainteligente/MySplashPage.dart';

List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'cronos deteccion de objetos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MySplashPage(),
    );
  }
}

/*class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}*/

/*class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'cronos deteccion de objetos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MySplashPage(),
    );
  }
  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: AppBar(
        title: const Text('Bandidos del paramo'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          color: Colors.transparent,
          child: Container(
              margin: EdgeInsets.all(5.0),
              //color: Colors.blue,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                    color: Colors.black,
                    width: 5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 2,
                      offset: Offset(15, 15),
                    )
                  ]),
              child: Image.asset(
                'assets/perfil.jpg',
              )),
        ),
        //child: Column(
        // mainAxisSize: MainAxisSize.max,
        // crossAxisAlignment: CrossAxisAlignment.center,
        // children: [
        /* Container(
              margin: EdgeInsets.all(5.0),
              color: Colors.blue,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            )*/
        // ],
        //),
      ),
    );
    //body:
    /* Builder(builder: (context) {
          return Center(
            child: SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width - 100,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.open_in_new, color: Colors.white),
                label: const Text(
                  'Open Navigation Drawer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }));*/
  }*/
}*/
