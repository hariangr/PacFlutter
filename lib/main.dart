import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IOWebSocketChannel channel;
  CameraController controller;
  List<CameraDescription> cameras;
  int curCamera = 0;
  bool isConnected;
  bool pingOk;
  Directory appDir;

  @override
  void initState() {
    super.initState();

    loadCameras();
    initWebsocket();
  }

  void initWebsocket() {
    channel = IOWebSocketChannel.connect("ws://192.168.1.4:3000");
    pingOk = true;
    isConnected = true;
    schedulePing();
    channel.stream.listen((data) {
      switch (data) {
        case "cheese":
          onShutterPressed();
          break;
        case "ping":
          pingOk = true;
          isConnected = true;
          print('X yeap trues');
          break;
        default:
          print(data);
      }
    });
  }

  void schedulePing() {
    print('schedulePing');
    pingOk = false;
    Future.delayed(Duration(milliseconds: 1000), () {
      print('X ping run');
      channel.sink.add(json.encode({"event": "ping", "data": "null"}));

      Future.delayed(Duration(milliseconds: 500), () {
        print('X cek ping');

        if (pingOk == false) {
          setState(() {
            isConnected = false;
          });
        }

        print('ping is ' + isConnected.toString());

        if (isConnected) {
          print('X is connect');
          schedulePing();
        }
      });
    });
  }

  void onShutterPressed() async {
    print('menyimpan');

    String date = DateTime.now().millisecondsSinceEpoch.toString();
    String tempDir = (await getTemporaryDirectory()).path;

    var path = '$tempDir/$date.jpg';
    await controller.takePicture(path);
    File f = File(path);
    String encoded = base64Encode(f.readAsBytesSync());

    String fileName = Random.secure().nextInt(20).toString();
    channel.sink.add(json.encode({
      "event": "save",
      "data": {
        "filename": 'file$fileName',
        "encoded": encoded,
      }
    }));
  }

  Future<void> loadCameras() async {
    cameras = await availableCameras();
    loadCameraController();
  }

  void loadCameraController() {
    // Untuk pilih kamera
    var camIndex = curCamera % cameras.length;

    controller = CameraController(cameras[camIndex], ResolutionPreset.low);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    buildCamPreview() {
      if (controller == null || controller.value == null) {
        return Container(child: Center(child: CircularProgressIndicator()));
      }

      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isConnected ? 'Connected' : 'Disconnected'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                  context: context, builder: (context) => SettingDialog());
            },
          )
        ],
      ),
      body: Center(child: buildCamPreview()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          channel.sink.add(
              json.encode({"event": "new", "data": DateTime.now().toString()}));

          channel.sink.add(json
              .encode({"event": "cheese", "data": DateTime.now().toString()}));
        },
        tooltip: 'Increment',
        child: Icon(Icons.camera),
      ),
    );
  }
}

class SettingDialog extends StatelessWidget {
  final TextEditingController ipController =
      new TextEditingController(text: '192.168.1.1:3000');
  final TextEditingController deviceLabelController =
      new TextEditingController(text: 'Cam1');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration:
                    InputDecoration(labelText: 'IP Address Pacamera Server'),
                controller: ipController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Name for this camera'),
                controller: deviceLabelController,
              ),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    child: Text('Batal'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  RaisedButton(
                    child: Text('OK'),
                    onPressed: () {},
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
