import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/pages/profile.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:face_net_authentication/pages/widgets/app_text_field.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glassmorphism/glassmorphism.dart';

class SignInSheet extends StatelessWidget {
  SignInSheet({Key? key, required this.user}) : super(key: key);
  final User user;

  final _passwordController = TextEditingController();
  final _cameraService = locator<CameraService>();

  Future _signIn(context, user) async {
    if (user.password == _passwordController.text) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Profile(
                    user.user,
                    imagePath: _cameraService.imagePath!,
                  )));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: GlassmorphicContainer(
              width: MediaQuery.of(context).size.width * 0.8,
              alignment: Alignment.center,
              height: 120,
              borderRadius: 10,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFffffff).withOpacity(0.1),
                    Color(0xFFFFFFFF).withOpacity(0.05),
                  ],
                  stops: [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFffffff).withOpacity(0.5),
                  Color((0xFFFFFFFF)).withOpacity(0.5),
                ],
              ),
              blur: 7,
              border: 0.1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.warning_rounded,
                      color: Color.fromARGB(255, 255, 0, 0),
                      size: 30,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Contraseña incorrecta!',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFFe0e0e0),
          borderRadius: BorderRadius.horizontal(
              left: Radius.circular(30), right: Radius.circular(30))),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              'Bienvenido de nuevo, ' + user.user + '.',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            child: Column(
              children: [
                SizedBox(height: 10),
                Neumorphic(
                  child: AppTextField(
                    controller: _passwordController,
                    labelText: "Contraseña",
                    isPassword: true,
                  ),
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.convex,
                    color: Color(0xFFe0e0e0),
                    shadowDarkColor: Color(0xFFbebebe),
                    shadowLightColor: Color(0xFFFFFFFF),
                    intensity: 0.8,
                    depth: -6,
                  ),
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                NeumorphicButton(
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
                        'Inicio de sesión',
                        style: TextStyle(color: Color(0xFF120C34)),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.login, color: Color(0xFF120C34))
                    ],
                  ),
                  onPressed: () async {
                    _signIn(context, user);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
