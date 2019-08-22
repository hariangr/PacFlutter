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
  int _counter = 0;
  IOWebSocketChannel channel;
  CameraController controller;
  List<CameraDescription> cameras;
  int curCamera = 0;
  Directory appDir;

  @override
  void initState() {
    super.initState();

    channel = IOWebSocketChannel.connect("ws://192.168.1.6:3000");
    loadCameras();
    // channel = IOWebSocketChannel.connect("ws://demos.kaazing.com/echo");
    channel.stream.listen((data) {
      if (data == "cheese") {
        print('suuus');
        onShutterPressed();
      }
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
    channel.sink.add(json.encode({"event": "save", "data": {
      "filename": 'file$fileName',
      "encoded": encoded,
    }}));

    print(path);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller)),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            StreamBuilder(
              stream: channel.stream,
              initialData: "Empty",
              builder: (context, snap) {
                return Text(snap.data);
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          channel.sink.add(json
              .encode({"event": "new", "data": DateTime.now().toString()}));

          channel.sink.add(json
              .encode({"event": "cheese", "data": DateTime.now().toString()}));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
