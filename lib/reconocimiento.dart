// @dart=2.9
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:etiquetainteligente/main.dart';
import 'package:tflite/tflite.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:get_mac/get_mac.dart';
import 'package:flutter/services.dart';
import 'package:etiquetainteligente/informacion.dart';

class reconocimiento extends StatefulWidget {
  @override
  _reconocimiento createState() => _reconocimiento();
}

class _reconocimiento extends State<reconocimiento> {
  //localizacion
  Location location = new Location();
  bool seractivo = false;
  PermissionStatus permiso;
  LocationData datolocal;
  bool escucharlocal = false;
  //bool consegloc = false;
  // reconocimiento
  String result = "";
  String res = "";
  bool isWorking = false;
  CameraController cameraController;
  CameraImage imgCamera;
  String _mac = "desconocido";
  String apik = '';
  String lat = '';
  String lon = '';
  String _respserv = '';
  bool habilitarcam = false;
  bool habilitarbot = true;
  String fras = '';
  String tipocerveza = '';
  bool _isButtonUnavailable = true;
  String entro = 'no';
  String verurl = '';

  // video

  loadModel() async {
    Tflite.close();
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  //localizacion gps

  /*initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          cameraController!.startImageStream((imagFromStream) => {
                if (!isWorking)
                  {
                    isWorking = true,
                    imgCamera = imagFromStream,
                    runModelOnStreamFrames(),
                  }
              });
        });
      }
    });
  }*/
  initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          cameraController.startImageStream((streamimg) {
            if (isWorking == false) {
              isWorking = true;
              imgCamera = streamimg;
              runModelOnStreamFrames();
            }
          });
        });
      }
    });
  }

  Future<void> mac() async {
    String mac = '';
    try {
      mac = await GetMac.macAddress;
    } on PlatformException {
      mac = "fallo la mac";
    }
    if (!mounted) return;
    setState(() {
      _mac = mac;
      // print(mac);
    });
  }

  Future<void> localizacion() async {
    seractivo = await location.serviceEnabled();
    if (!seractivo) {
      seractivo = await location.requestService();
      if (seractivo) {
        return;
      }
    }
    permiso = await location.hasPermission();
    if (permiso == PermissionStatus.denied) {
      permiso = await location.requestPermission();
      if (permiso != PermissionStatus.granted) {
        return;
      }
    }
    datolocal = await location.getLocation();
    lat = datolocal.latitude.toString();
    lon = datolocal.longitude.toString();
    /*print(url);
    var respuesta = await http.get(url);
    print(respuesta.body);
    print('maldicion');*/

    /* setState(() {
      consegloc = true;
    });*/
  }

  //http://m2mlight.com/iot/read_sensor_description?api_key=CtOU1njcsg

  Future<void> peticion() async {
    //entro = 'si';
    Uri url = Uri.http('m2mlight.com', '/iot/send_sensor_location.php',
        {'api_key': apik, 'imei': _mac, 'latitude': lat, 'longitude': lon});
    Uri url1 = Uri.http(
        'm2mlight.com', '/iot/read_sensor_description.php', {'api_key': apik});
    /* Uri url1 = Uri.http('m2mlight.com', '/iot/read_sensor_description.php',
        {'api_key': 'CtOU1njcsg'});*/
    //print(url);
    //verurl = url.toString();
    var respuesta = await http.get(url);
    var respserv = await http.get(url1);
    _respserv = respserv.body;
    String response = '';
    response = respuesta.body;
    //if()
    //verurl = respuesta.body;
    //print(respuesta.body);
    //print('maldicion');
    setState(() {
      verurl;
      _respserv;
      if (response != '') {
        habilitarcam = false;
      }
      // entro;
    });
  }

  runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var recognition = await Tflite.runModelOnFrame(
        bytesList: imgCamera.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera.height,
        imageWidth: imgCamera.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        //numResultsPerClass: 3,
        numResults: 2,
        threshold: 0.1,
        //0.1
        asynch: true,
      );
      result = "";
      String verificador = 'desconocido';
      recognition.forEach((response) {
        result = response["label"] +
            "  " +
            (response["confidence"] as double).toStringAsFixed(2) +
            "\n\n";
        //  result = response['label'] + " " + response['confidence'];
        if (response["confidence"] as double >= 0.99) {
          if (verificador != response["label"]) {
            res = response["label"];
            //print(res);
            if (res == '0 bandolero') {
              apik = 'CtOU1njcsg';
              tipocerveza = 'bandolero';
            }
            if (res == '1 hop') {
              apik = 'LrnX1njcsl';
              tipocerveza = 'hop';
            }
            peticion();
            // res = _respserv;
            //fras = _respserv;
            _isButtonUnavailable = false;
            // prueba();
          }
          verificador = response["label"];
        }

        /*setState(() {
          //result;
          result = result + " hola";
        });*/
      });
      setState(() {
        //result;
        result = result;
        //if (fras != "") {
        // prueba();
        _isButtonUnavailable;
        // }
      });
      isWorking = false;
    }
  }

  /*apagar() {
    //await Tflite.close();
    Tflite.close();
    cameraController!.stopImageStream();
    cameraController?.dispose();
  }*/

  /*runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var prediccion = await Tflite.runModelOnFrame(
        bytesList: imgCamera!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera!.height,
        imageWidth: imgCamera!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );
      // result = "";
      prediccion!.forEach((respuesta) {
        /*  result += response["label"] +
            "  " +
            (response["confidence"] as double).toStringAsFixed(2) +
            "\n\n";*/
        setState(() {
          result = respuesta['label'];
        });
      });
      /* setState(() {
        //result;
        result = result + " hola";
      });
      isWorking = false;*/
    }
  }*/
  Future<void> prueba() async {
    /*setState(() {
      prub = true;
    });*/
    //Navigator.of(context).pushNamed('/video');
    // Navigator.pushNamed(context, '/video', arguments: parametro("hola"));
    /*Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return new vervid(fras);
    }));
    print(fras);*/
    //cameraController?.stopImageStream();
    //cameraController?.dispose();
    // await Tflite.close();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return new informacion("hola");
    }));
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    mac();
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //MaterialApp(
    //debugShowCheckedModeBanner: false,

    // home: SafeArea(

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Reconocimiento'),
          actions: [
            IconButton(
                onPressed: _isButtonUnavailable ? null : prueba,
                icon: Icon(Icons.info))
          ],
        ),
        body: Container(
          /*  decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/jarvis.jpg")),
          ),*/
          child: Column(
            children: [
              Stack(
                children: [
                  /*Center(
                    child: Container(
                      color: Colors.black,
                      height: 320,
                      width: 360,
                      // child: Image.asset("assets/camera.jpg"),
                    ),
                  ),*/
                  Center(
                    child: TextButton(
                      onPressed: habilitarbot
                          ? () {
                              initCamera();
                              localizacion();
                              setState(() {
                                habilitarbot = false;
                              });
                              //mac();
                              //peticion();
                              //prueba();
                              //  habilitarcam = true;
                            }
                          : null,
                      child: Container(
                        margin: EdgeInsets.all(5.0),
                        //color: Colors.red,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 300,
                        child: imgCamera == null
                            ? Container(
                                height: 270,
                                width: 360,
                                child: Icon(
                                  Icons.photo_camera_front,
                                  color: Colors.black,
                                  size: 40,
                                ),
                              )
                            : AspectRatio(
                                aspectRatio: cameraController.value.aspectRatio,
                                child: CameraPreview(cameraController),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: SingleChildScrollView(
                    child: Text(
                      result + _respserv,
                      //verurl + _respserv + entro + res,
                      style: TextStyle(
                        backgroundColor: Colors.black87,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              /* Center(
                child: FloatingActionButton(
                  child: Text('video'),
                  onPressed: _isButtonUnavailable ? null : prueba,
                ),
              )*/

              // Center(

              /*prub != false
                    ? BetterPlayer.network(
                        "https://m2mlight.com/iot/Bandido_Brewing_ReOpening_MASTER.mp4",
                        betterPlayerConfiguration: BetterPlayerConfiguration(
                          aspectRatio: 1,
                          looping: true,
                          autoPlay: true,
                        ),
                      )
                    : Column(
                        children: [Text("no funciona")],
                      ),*/
              // )
            ],
          ),
        ));
    //),
    // );
  }
}







/*import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:etiquetainteligente/main.dart';
import 'package:tflite/tflite.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:get_mac/get_mac.dart';
import 'package:flutter/services.dart';
import 'package:etiquetainteligente/informacion.dart';

class reconocimiento extends StatefulWidget {
  @override
  _reconocimientoState createState() => _reconocimientoState();
}

class _reconocimientoState extends State<reconocimiento> {
  CameraController cameraController;
  CameraImage imgCamera;
  bool isWorking = false;
  bool camoff = false;
  String result = "no funciona";
  String res = "";
  int a = 0;
  //localizacion
  Location location = new Location();
  bool seractivo = false;
  PermissionStatus permiso;
  LocationData datolocal;
  bool escucharlocal = false;
  String _mac = "desconocido";
  String apik = 'desconcocido';
  String lat = 'desconocido';
  String lon = 'desconocido';
  String _respserv = 'no response';
  String tipocerveza = '';
  String entrar = "no";
  double coincidencia = 0.0;
  String verificador = 'desconocido';
  String nombrecerveza = "";
  String fras = '';
  bool _isButtonUnavailable = true;
  bool entrarcam = false;
  //--------------------
  String _url = 'desconocido';

  @override
  void initState() {
    super.initState();
    loadModel();
    mac();
    // initCamera();
    // localizacion();
  }

  void apagarcam() {
    setState(() {
      camoff = false;
    });
  }

  Future<void> mac() async {
    String maca = '';
    try {
      maca = await GetMac.macAddress;
    } on PlatformException {
      maca = "fallo la mac";
    }
    if (!mounted) return;
    setState(() {
      _mac = maca;
      print(_mac);
    });
  }

  Future<void> localizacion() async {
    seractivo = await location.serviceEnabled();
    if (!seractivo) {
      seractivo = await location.requestService();
      if (seractivo) {
        return;
      }
    }
    permiso = await location.hasPermission();
    if (permiso == PermissionStatus.denied) {
      permiso = await location.requestPermission();
      if (permiso != PermissionStatus.granted) {
        return;
      }
    }
    datolocal = await location.getLocation();
   /*setState(() {
      lat = datolocal.latitude.toString();
      lon = datolocal.longitude.toString();
    });*/

    /*print(url);
    var respuesta = await http.get(url);
    print(respuesta.body);
    print('maldicion');*/

    /* setState(() {
      consegloc = true;
    });*/
  }

  //http://m2mlight.com/iot/read_sensor_description?api_key=CtOU1njcsg

  Future<void> peticion() async {
    Uri url = Uri.http('m2mlight.com', '/iot/send_sensor_location.php',
        {'api_key': apik, 'imei': _mac, 'latitude': lat, 'longitude': lon});
    Uri url1 = Uri.http(
        'm2mlight.com', '/iot/read_sensor_description.php', {'api_key': apik});
    print(url);
    var respuesta = await http.get(url);

    var respserv = await http.get(url1);
    _respserv = respserv.body;
    print(respuesta.body);
    print('maldicion');
    /*setState(() {
      _url = url.toString();
      _respserv;
    });*/
  }

  Future<String> contar = Future.delayed(Duration(seconds: 5), () => 'data');

  loadModel() async {
    Tflite.close();
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var recognition = await Tflite.runModelOnFrame(
        bytesList: imgCamera.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera.height,
        imageWidth: imgCamera.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        //numResultsPerClass: 3,
        numResults: 2,
        threshold: 0.1,
        //0.1
        asynch: true,
      );
      result = "";
      String verificador = 'desconocido';
      recognition.forEach((response) {
        result += response["label"] +
            "  " +
            (response["confidence"] as double).toStringAsFixed(2) +
            "\n\n";
        if (response["confidence"] as double >= 0.99) {
          if (verificador != response["label"]) {
            res = response["label"];
            print(res);
            if (res == '0 bandolero') {
              apik = 'CtOU1njcsg';
              tipocerveza = 'bandolero';
            }
            if (res == '1 hop') {
              apik = 'LrnX1njcsl';
              tipocerveza = 'hop';
            }
            peticion();
            res = _respserv;
            fras = _respserv;
            // prueba();
          }
          verificador = response["label"];
        }

        /*setState(() {
          //result;
          result = result + " hola";
        });*/
      });
      setState(() {
        //result;
        result = result;
        if (fras != "") {
          // prueba();
          _isButtonUnavailable = false;
        }
      });
      entrarcam = true;
      isWorking = false;
    }
  }

  /* runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var recognition = await Tflite.runModelOnFrame(
        bytesList: imgCamera.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera.height,
        imageWidth: imgCamera.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        //numResultsPerClass: 3,
        numResults: 2,
        threshold: 0.1,
        //0.1
        asynch: true,
      );
      result = "";

      recognition.forEach((response) {
        nombrecerveza = response["label"];
        coincidencia = response['confidence'];
        result += response["label"] +
            "  " +
            (response["confidence"] as double).toStringAsFixed(2) +
            "\n\n";
        /* if (response["confidence"] as double == 0.99) {
          entrar = 'si';
          if (verificador != response["label"]) {
            res = response["label"];
            print(res);
            if (res == '0 bandolero') {
              apik = 'CtOU1njcsg';
              tipocerveza = 'bandolero';
            }
            if (res == '1 hop') {
              apik = 'LrnX1njcsl';
              tipocerveza = 'hop';
            }
            peticion();
            res = _respserv;
            // fras = _respserv;
            // prueba();
          }
          verificador = response["label"];
        }*/

        /*setState(() {
          //result;
          result = result + " hola";
        });*/
      });
      setState(() {
        //result;
        nombrecerveza;
        entrar;
        coincidencia;
        result = result;
        /* if (res != "") {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return new informacion(res);
          }));
          if (coincidencia >= 0.99) {
            setState(() {
              entrar = 'si';
            });
          }
          // prueba();
          //_isButtonUnavailable = false;
        }*/
      });
      isWorking = false;
    }
  }*/

  entrarpeticio() {
    // if (coincidencia >= 0.99) {
    /*setState(() {
      entrar = 'si';
    });*/
    //   }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return new informacion(res);
    }));
  }

  initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          cameraController.startImageStream((streamimg) {
            if (isWorking == false) {
              isWorking = true;
              imgCamera = streamimg;
              runModelOnStreamFrames();
              // localizacion();
              // mac();
            }
          });
        });
      }
    });
  }

  /* @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('prueba camara'),
      ),
      body: Center(
        child: Column(children: [
          Container(
            margin: EdgeInsets.all(5.0),
            //color: Colors.red,
            //width: MediaQuery.of(context).size.width,
            //height: MediaQuery.of(context).size.height,
            height: 600,
            width: 360,
            child: FutureBuilder(
              future: contar,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5.0),
                          //color: Colors.red,
                          width: MediaQuery.of(context).size.width,
                          //height: MediaQuery.of(context).size.height,
                          height: 400,
                          child: AspectRatio(
                            aspectRatio: cameraController.value.aspectRatio,
                            child: CameraPreview(cameraController),
                          ),
                        ),
                        Container(
                          height: 300,
                          child: Text(result +
                              // res +
                              // _mac +
                              // lat +
                              // lon +
                              _url +
                              "\n\n" +
                              // _respserv +
                              apik +
                              "\n\n" +
                              // entrar +
                              coincidencia.toString() +
                              "\n\n" +
                              _respserv),
                        )
                      ],
                    ),
                  );

                  /*Center(
                    child: Container(
                      margin: EdgeInsets.all(5.0),
                      //color: Colors.red,
                      width: MediaQuery.of(context).size.width,
                      //height: MediaQuery.of(context).size.height,
                      height: 300,
                      child: AspectRatio(
                        aspectRatio: cameraController.value.aspectRatio,
                        child: CameraPreview(cameraController),
                      ),
                    ),
                  );*/
                } else {
                  return Center(
                    child: Container(
                      child: Text('Cargando'),
                    ),
                  );
                }
              },
            ),

            /* camoff == false
              ? AspectRatio(
                  aspectRatio: cameraController.value.aspectRatio,
                  child: CameraPreview(cameraController),
                )
              : Text("no camara"),*/
          ),
          Container(
            height: 50,
            child: coincidencia >= 0.99 ? entrarpeticio() : Text('no funciono'),
          ),
        ]),
      ),
    );
  }*/
/*
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('prueba camara'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(5.0),
              color: Colors.blue,
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: ElevatedButton(
                onPressed: () {
                  apagarcam();
                },
                child: Text("apagar cam"),
              ),
              //child: CameraPreview(cameraController!),
            ),
            /*Container(
              margin: EdgeInsets.all(5.0),
              //color: Colors.red,
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
                child: CameraPreview(cameraController),
              ),
            ),*/
            Center(
              child: FlatButton(
                onPressed: () {
                  initCamera();

                  //prueba();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 35),
                  height: 270,
                  width: 360,
                  child: camoff == false
                      ? Container(
                          height: 270,
                          width: 360,
                          child: Icon(
                            Icons.photo_camera_front,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: cameraController.value.aspectRatio,
                          child: CameraPreview(cameraController),
                        ),
                ),
              ),
            ),
            /*Container(
              margin: EdgeInsets.all(5.0),
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              height: 200,
            ),*/
          ],
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
            body: Container(
          /*  decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/jarvis.jpg")),
          ),*/
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      color: Colors.black,
                      height: 320,
                      width: 360,
                      //child: Image.asset("assets/camera.jpg"),
                    ),
                  ),
                  Center(
                    child: FlatButton(
                      onPressed: () {
                        initCamera();
                        localizacion();
                        //mac();
                        //prueba();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 35),
                        height: 270,
                        width: 360,
                        child: entrarcam == false
                            ? Container(
                                height: 270,
                                width: 360,
                                child: Icon(
                                  Icons.photo_camera_front,
                                  color: Colors.blueAccent,
                                  size: 40,
                                ),
                              )
                            : AspectRatio(
                                aspectRatio: cameraController.value.aspectRatio,
                                child: CameraPreview(cameraController),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 55.0),
                  child: SingleChildScrollView(
                    child: Text(
                      res + result,
                      style: TextStyle(
                        backgroundColor: Colors.black87,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Center(
                child: FloatingActionButton(
                  child: Text('video'),
                  onPressed: _isButtonUnavailable ? null : entrarpeticio(),
                ),
              )

              // Center(

              /*prub != false
                    ? BetterPlayer.network(
                        "https://m2mlight.com/iot/Bandido_Brewing_ReOpening_MASTER.mp4",
                        betterPlayerConfiguration: BetterPlayerConfiguration(
                          aspectRatio: 1,
                          looping: true,
                          autoPlay: true,
                        ),
                      )
                    : Column(
                        children: [Text("no funciona")],
                      ),*/
              // )
            ],
          ),
        )),
      ),
    );
  }
}

/*class reconocimiento extends StatefulWidget {
   CameraController cameraController;
    CameraImage imgCamera;
    bool isWorking = false;
    bool camoff = false;
    String result = "";
    String res = "";
  
   initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          cameraController.startImageStream((streamimg) {
            if (isWorking == false) {
              isWorking = true;
              imgCamera = streamimg;
              runModelOnStreamFrames();
            }
          });
        });
      }
    });
    camoff = true;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('prueba camara'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(5.0),
              color: Colors.blue,
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: ElevatedButton(
                onPressed: () {
                  apagarcam();
                },
                child: Text("apagar cam"),
              ),
              //child: CameraPreview(cameraController!),
            ),
            /*Container(
              margin: EdgeInsets.all(5.0),
              //color: Colors.red,
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
                child: CameraPreview(cameraController),
              ),
            ),*/
            Center(
              child: FlatButton(
                onPressed: () {
                  initCamera();

                  //prueba();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 35),
                  height: 270,
                  width: 360,
                  child: camoff == false
                      ? Container(
                          height: 270,
                          width: 360,
                          child: Icon(
                            Icons.photo_camera_front,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: cameraController.value.aspectRatio,
                          child: CameraPreview(cameraController),
                        ),
                ),
              ),
            ),
            /*Container(
              margin: EdgeInsets.all(5.0),
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              height: 200,
            ),*/
          ],
        ),
      ),
    );
  }
}*/
*/