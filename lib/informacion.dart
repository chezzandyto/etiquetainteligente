// @dart=2.9
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

// String usu;
// vervid(this.usu);
class informacion extends StatefulWidget {
  // const informacion({Key key, this.res}) : super(key: key);
  //final String res;
  String res;
  informacion(this.res);
  @override
  _informacionState createState() => _informacionState();
}

class _informacionState extends State<informacion> {
  Future<String> contar = Future.delayed(Duration(seconds: 4), () => 'data');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('informacion'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.all(5.0),
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
                        child: BetterPlayer.network(
                          "https://m2mlight.com/iot/Bandido_Brewing_ReOpening_MASTER.mp4",
                          betterPlayerConfiguration: BetterPlayerConfiguration(
                            aspectRatio: 1,
                            looping: false,
                            autoPlay: true,
                          ),
                        )),
                    /* Container(
                      child: Text("cargardo video"),
                    )*/
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
                  child: //CircularProgressIndicator(),

                      Text('Cargando'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
