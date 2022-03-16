// @dart=2.9
import 'package:flutter/material.dart';
import 'package:etiquetainteligente/main.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:etiquetainteligente/principal.dart';

class MySplashPage extends StatefulWidget {
  @override
  _MySplashPageState createState() => _MySplashPageState();
}

class _MySplashPageState extends State<MySplashPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 1,
      navigateAfterSeconds: principal(),
      imageBackground: Image.asset("assets/minkafap.jpg").image,
      useLoader: true,
      photoSize: 50,
      loaderColor: Colors.blue,
      loadingText: Text(
        "cargando...",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
