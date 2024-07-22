import 'dart:io';
import 'package:simple_shadow/simple_shadow.dart';
import 'home.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:starsview/config/MeteoriteConfig.dart';
import 'package:starsview/config/StarsConfig.dart';
import 'package:starsview/starsview.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:ui';

class Profile extends StatefulWidget {
  const Profile(this.username, {Key? key, required this.imagePath})
      : super(key: key);
  final String username;
  final String imagePath;

  @override
  _ProfileState createState() => _ProfileState();
}

class GlassMorphism extends StatelessWidget {
  const GlassMorphism(
      {Key? key,
      required this.child,
      required this.blur,
      required this.opacity,
      required this.color,
      this.borderRadius})
      : super(key: key);
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius? borderRadius;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
              color: color.withOpacity(opacity), borderRadius: borderRadius),
          child: child,
        ),
      ),
    );
  }
}

class _ProfileState extends State<Profile> {
  BluetoothConnection? connection;
  bool isConnected = false;
  bool isOn = false;
  bool isOpen = false;
  Timer? _timer;
  double temperature = 0;
  String selectedDevice = "ESP32";
  List<String> rooms = ["Sala", "Cuarto", "Cocina", "Baño"];
  String selectedRoom = "sala";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startConnectionCheck();
  }

  Future<void> _requestPermissions() async {
    var status = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location
    ].request();

    if (status[Permission.bluetooth]!.isGranted &&
        status[Permission.bluetoothConnect]!.isGranted &&
        status[Permission.bluetoothScan]!.isGranted &&
        status[Permission.location]!.isGranted) {
      // Permisos concedidos
    } else {
      print("Permisos no concedidos");
    }
  }

  Future<void> _connectToDevice() async {
    try {
      var devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      for (var device in devices) {
        if (device.name == selectedDevice) {
          connection = await BluetoothConnection.toAddress(device.address);
          setState(() {
            isConnected = true;
          });
          connection!.input!.listen(_onDataReceived).onDone(() {
            setState(() {
              isConnected = false;
            });
          });
          break;
        }
      }
      if (!isConnected) {
        print("No se encontró el dispositivo");
      }
    } catch (e) {
      print("Error connecting to device: $e");
    }
  }

  void _onDataReceived(Uint8List data) {
    String dataString = utf8.decode(data);
    List<String> dataList = dataString.split("\n");
    for (String dataElement in dataList) {
      if (dataElement.isNotEmpty) {
        double? newTemperature = double.tryParse(dataElement.trim());
        if (newTemperature != null) {
          setState(() {
            temperature = newTemperature;
          });
        }
      }
    }
  }

  void _sendData(String command) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(utf8.encode(command)));
    }
  }

  void _toggleLed(bool value) {
    if (isOn) {
      _sendData("OFF\n");
    } else {
      _sendData("ON\n");
    }
    setState(() {
      isOn = !isOn;
    });
  }

  void _toggleDoor(bool value) {
    if (isOpen) {
      _sendData("CLOSE\n");
    } else {
      _sendData("OPEN\n");
    }
    setState(() {
      isOpen = !isOpen;
    });
  }

  void _startConnectionCheck() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (connection != null) {
        setState(() {
          isConnected = connection!.isConnected;
        });
      } else {
        setState(() {
          isConnected = false;
        });
      }
    });
  }

  Future<void> _showRoomSelectionDialog() async {
    String? selectedRoom = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Text(
            "Selecciona una sección",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: GlassMorphism(
            blur: 10,
            color: Colors.black,
            opacity: 0.2,
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              child: ListBody(
                children: rooms.map((room) {
                  return ListTile(
                    textColor: Colors.white,
                    title: Text(room),
                    onTap: () {
                      Navigator.pop(context, room.toLowerCase());
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );

    if (selectedRoom != null) {
      setState(() {
        this.selectedRoom = selectedRoom;
      });
    }
  }

  Future<void> _showDeviceSelectionDialog() async {
    List<BluetoothDevice> devices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    String? selectedDevice = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Text(
            "Selecciona un dispositivo",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: GlassMorphism(
            blur: 10,
            color: Colors.black,
            opacity: 0.2,
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              child: ListBody(
                children: devices.map((device) {
                  return ListTile(
                    textColor: Colors.white,
                    title: Text(device.name ?? "Desconocido"),
                    onTap: () {
                      Navigator.pop(context, device.name);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );

    if (selectedDevice != null) {
      setState(() {
        this.selectedDevice = selectedDevice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 18, 12, 52),
              ),
            ),
            FractionallySizedBox(
              heightFactor: 1,
              child: StarsView(
                fps: 60,
                starsConfig: StarsConfig(minStarSize: 0, maxStarSize: 2),
                meteoriteConfig: MeteoriteConfig(enabled: true),
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.black,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(File(widget.imagePath)),
                        ),
                      ),
                      margin: EdgeInsets.all(20),
                      width: 50,
                      height: 50,
                    ),
                    Text(
                      'Hola ' + widget.username + '!',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    Spacer(),
                    Container(
                      margin: EdgeInsets.all(20),
                      child: NeumorphicButton(
                        child: Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()),
                          );
                        },
                        style: NeumorphicStyle(
                            color: Color(0xFF120C34),
                            shadowDarkColor: Color.fromARGB(255, 11, 7, 31),
                            shadowLightColor: Color.fromARGB(255, 25, 17, 73)),
                      ),
                    )
                  ],
                ),
                SimpleShadow(
                  opacity: isOn ? 1 : 0,
                  color: Color.fromARGB(255, 159, 194, 255),
                  offset: Offset(0, 0),
                  sigma: 25,
                  child: InnerShadow(
                    child: Transform.translate(
                      offset: Offset(0, 0),
                      child: IconButton(
                        icon: Image.asset(
                          "assets/images/$selectedRoom.png",
                          height: 300,
                        ),
                        onPressed: _showRoomSelectionDialog,
                      ),
                    ),
                    shadows: [
                      Shadow(
                          color: isOn
                              ? Color.fromARGB(255, 159, 194, 255)
                              : Color.fromARGB(255, 0, 27, 74),
                          blurRadius: isOn ? 80 : 120,
                          offset: const Offset(2, 5))
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFe0e0e0),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                    ),
                    child: isConnected
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Neumorphic(
                                    child: isOn
                                        ? Icon(
                                            Icons.lightbulb,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            size: 30,
                                          )
                                        : Icon(
                                            Icons.lightbulb_outline,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            size: 30,
                                          ),
                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.circle(),
                                      color: Color(0xFF120C34),
                                      shadowDarkColor: Color(0xFFbebebe),
                                      shadowLightColor: Color(0xFFFFFFFF),
                                      intensity: 0.8,
                                      depth: 3,
                                    ),
                                    padding: EdgeInsets.all(10),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Luz",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF120C34),
                                    ),
                                  ),
                                  Spacer(),
                                  isOn
                                      ? Text(
                                          "ON",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF120C34),
                                          ),
                                        )
                                      : Text(
                                          "OFF",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF120C34),
                                          ),
                                        ),
                                  SizedBox(width: 15),
                                  Switch(
                                    value: isOn,
                                    onChanged: _toggleLed,
                                    activeTrackColor:
                                        Color.fromARGB(255, 177, 177, 177),
                                    inactiveTrackColor:
                                        Color.fromARGB(255, 177, 177, 177),
                                    activeColor:
                                        Color.fromARGB(255, 25, 17, 73),
                                    inactiveThumbColor: Colors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: 25),
                              Row(
                                children: [
                                  Neumorphic(
                                    child: isOpen
                                        ? Icon(
                                            Icons.door_front_door_outlined,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            size: 30,
                                          )
                                        : Icon(
                                            Icons.door_front_door,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            size: 30,
                                          ),
                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.circle(),
                                      color: Color(0xFF120C34),
                                      shadowDarkColor: Color(0xFFbebebe),
                                      shadowLightColor: Color(0xFFFFFFFF),
                                      intensity: 0.8,
                                      depth: 3,
                                    ),
                                    padding: EdgeInsets.all(10),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Puerta",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF120C34),
                                    ),
                                  ),
                                  Spacer(),
                                  isOpen
                                      ? Text(
                                          "OPEN",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF120C34),
                                          ),
                                        )
                                      : Text(
                                          "CLOSE",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF120C34),
                                          ),
                                        ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Switch(
                                    value: isOpen,
                                    onChanged: _toggleDoor,
                                    activeTrackColor: Color(0xFFB1B1B1),
                                    inactiveTrackColor:
                                        Color.fromARGB(255, 177, 177, 177),
                                    activeColor:
                                        Color.fromARGB(255, 25, 17, 73),
                                    inactiveThumbColor: Colors.white,
                                  ),
                                ],
                              ),
                              Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Neumorphic(
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      height: 150,
                                      width: MediaQuery.of(context).size.width *
                                          0.38,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.bluetooth,
                                            color: Color(0xFF120C34),
                                            size: 60,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            selectedDevice,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300),
                                          ),
                                          SizedBox(height: 5),
                                          NeumorphicButton(
                                            onPressed: _connectToDevice,
                                            style: NeumorphicStyle(
                                              boxShape:
                                                  NeumorphicBoxShape.stadium(),
                                              color: Color(0xFFe0e0e0),
                                              shadowDarkColor:
                                                  Color(0xFFbebebe),
                                              shadowLightColor:
                                                  Color(0xFFFFFFFF),
                                              intensity: 0.8,
                                              depth: 3,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Desconectar',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF120C34),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    style: NeumorphicStyle(
                                      color: Color(0xFFe0e0e0),
                                      shadowDarkColor: Color(0xFFbebebe),
                                      shadowLightColor: Color(0xFFFFFFFF),
                                      intensity: 0.8,
                                      depth: 5,
                                      disableDepth: true,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.38,
                                    height: 150,
                                    child: SfRadialGauge(
                                      enableLoadingAnimation: true,
                                      axes: <RadialAxis>[
                                        RadialAxis(
                                          endAngle: 360,
                                          startAngle: 180,
                                          minimum: 0,
                                          maximum: 60,
                                          showLabels: true,
                                          showLastLabel: true,
                                          labelOffset: 15,
                                          ranges: <GaugeRange>[
                                            GaugeRange(
                                              startValue: 0,
                                              endValue: 60,
                                              color: Color(0xFFB1B1B1),
                                              startWidth: 0,
                                              endWidth: 20,
                                              gradient: SweepGradient(
                                                colors: <Color>[
                                                  Colors.cyan,
                                                  Colors.blue,
                                                  Colors.orange,
                                                  Colors.red
                                                ],
                                              ),
                                            ),
                                          ],
                                          pointers: <GaugePointer>[
                                            MarkerPointer(
                                              color: Color(0xFF120C34),
                                              markerType: MarkerType.triangle,
                                              textStyle: GaugeTextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 20),
                                              value: temperature,
                                              animationType:
                                                  AnimationType.easeOutBack,
                                              elevation: 5,
                                              markerOffset: 5,
                                              markerHeight: 15,
                                              markerWidth: 5,
                                            )
                                          ],
                                          annotations: <GaugeAnnotation>[
                                            GaugeAnnotation(
                                              widget: Icon(
                                                Icons.thermostat,
                                                color: Color(0xFF120C34),
                                                size: 30,
                                              ),
                                              angle: 90,
                                              positionFactor: 0,
                                            ),
                                            GaugeAnnotation(
                                              widget: Text(
                                                temperature.toString() + "°",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w200),
                                              ),
                                              angle: 90,
                                              positionFactor: 0.5,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Container(
                            width: MediaQuery.sizeOf(context).width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bluetooth_disabled,
                                  color: Color(0xFF120C34),
                                  size: 80,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Conexión no disponible",
                                  style: TextStyle(
                                      color: Color(0xFF120C34),
                                      fontWeight: FontWeight.w200,
                                      fontSize: 17),
                                ),
                                SizedBox(height: 20),
                                SizedBox(
                                  child: NeumorphicButton(
                                    onPressed: _showDeviceSelectionDialog,
                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.stadium(),
                                      color: Color(0xFFe0e0e0),
                                      shadowDarkColor: Color(0xFFbebebe),
                                      shadowLightColor: Color(0xFFFFFFFF),
                                      intensity: 0.8,
                                      depth: 3,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Cambiar dispositivo',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF120C34),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.devices,
                                          color: Color(0xFF120C34),
                                          size: 20,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                SizedBox(
                                  child: NeumorphicButton(
                                    onPressed: _connectToDevice,
                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.stadium(),
                                      color: Color(0xFFe0e0e0),
                                      shadowDarkColor: Color(0xFFbebebe),
                                      shadowLightColor: Color(0xFFFFFFFF),
                                      intensity: 0.8,
                                      depth: 3,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Conectar a ' + selectedDevice,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF120C34),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.bluetooth,
                                          color: Color(0xFF120C34),
                                          size: 20,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
