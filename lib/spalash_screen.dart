import 'package:flutter/material.dart';
import 'package:object_detection_app/home_page.dart';
import 'package:splashscreen/splashscreen.dart';

class MySplashPage extends StatefulWidget {
  const MySplashPage({Key? key}) : super(key: key);

  @override
  _MySplashPageState createState() => _MySplashPageState();
}

class _MySplashPageState extends State<MySplashPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds: HomePage(),
      imageBackground: Image.asset("assets/back.jpg").image,
      useLoader: true,
      loadingText: Text(
        "Loading...",
        style: TextStyle(color: Colors.white),
      ),
      loaderColor: Colors.red,
    );
  }
}
