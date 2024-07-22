// import 'package:face_net_authentication/constants/constants.dart';
import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/db/databse_helper.dart';
import 'package:face_net_authentication/pages/sign-in.dart';
import 'package:face_net_authentication/pages/sign-up.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:face_net_authentication/services/ml_service.dart';
import 'package:face_net_authentication/services/face_detector_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MLService _mlService = locator<MLService>();
  FaceDetectorService _mlKitService = locator<FaceDetectorService>();
  CameraService _cameraService = locator<CameraService>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  _initializeServices() async {
    setState(() => loading = true);
    await _cameraService.initialize();
    await _mlService.initialize();
    _mlKitService.initialize();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe0e0e0),
      appBar: AppBar(
        leading: Container(),
        elevation: 0,
        backgroundColor: Color(0xFFe0e0e0),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20, top: 20),
            child: PopupMenuButton<String>(
              color: Color(0xFFe0e0e0),
              child: Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'Limpiar DB':
                    DatabaseHelper _dataBaseHelper = DatabaseHelper.instance;
                    _dataBaseHelper.deleteAll();
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Limpiar BD'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: !loading
          ? SingleChildScrollView(
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/boy-front-color.png',
                        width: MediaQuery.of(context).size.width * 0.8,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          children: [
                            Text(
                              "Autenticación con reconocimiento facial",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 60,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 20,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Divider(
                              thickness: 2,
                            ),
                          ),
                          SizedBox(
                            child: NeumorphicButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => SignIn(),
                                  ),
                                );
                              },
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              style: NeumorphicStyle(
                                color: Color(0xFFe0e0e0),
                                shadowDarkColor: Color(0xFFbebebe),
                                shadowLightColor: Color(0xFFFFFFFF),
                                intensity: 0.8,
                                depth: 3,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Iniciar sesión',
                                    style: TextStyle(color: Color(0xFF120C34)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(Icons.login, color: Color(0xFF120C34))
                                ],
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.8,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: NeumorphicButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => SignUp(),
                                  ),
                                );
                              },
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              style: NeumorphicStyle(
                                color: Color.fromARGB(255, 25, 17, 73),
                                shadowDarkColor: Color(0xFFbebebe),
                                shadowLightColor: Color(0xFFFFFFFF),
                                intensity: 0.8,
                                depth: 3,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Registro',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(Icons.person_add, color: Colors.white)
                                ],
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.8,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
