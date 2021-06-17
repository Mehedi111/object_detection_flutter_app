import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection_app/main.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isWorking = false;
  String result = "";
  CameraController? _cameraController;
  CameraImage? _cameraImage;

  Future _loadModel() async {
    await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/mobilenet_v1_1.0_224.txt");
  }

  initCamera() {
    _cameraController = CameraController(cameras?[0], ResolutionPreset.medium);
    _cameraController?.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cameraController?.startImageStream((image) => {
              if (!isWorking)
                {
                  isWorking = true,
                  _cameraImage = image,
                  runModelOnStreamFrame()
                }
            });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
    _cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
          child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(image: AssetImage("assets/jarvis.jpg"))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      height: 320,
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset(
                        "assets/camera.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        initCamera();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 35),
                        height: 270,
                        width: MediaQuery.of(context).size.width,
                        child: _cameraImage == null
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
                                aspectRatio:
                                    _cameraController!.value.aspectRatio,
                                child: CameraPreview(_cameraController),
                              ),
                      ),
                    ),
                  )
                ],
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 55),
                  child: SingleChildScrollView(
                    child: Text(
                      result,
                      style: TextStyle(
                        backgroundColor: Colors.black87,
                        fontSize: 30,
                        color: Colors.white
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  runModelOnStreamFrame() async{
    if(_cameraImage != null){
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: _cameraImage!.planes.map((e){
            return e.bytes;
          }).toList(),

        imageHeight: _cameraImage!.height,
        imageWidth: _cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true
      );

      result = "";

      recognitions?.forEach((element){
        result += element["label"] + " "+ (element["confidence"] as double).toStringAsFixed(2) + "\n\n";
      });

      setState(() {
        result;
      });

      isWorking = false;

    }
  }
}
