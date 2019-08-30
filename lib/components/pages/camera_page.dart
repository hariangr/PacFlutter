import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:panflutter/components/pages/setting_dialog.dart';
import 'package:panflutter/main.dart';
import 'package:panflutter/models/paca_protocol.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
// import 'package:web_socket_channel/status.dart' as status;

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  IOWebSocketChannel channel;
  CameraController controller;
  List<CameraDescription> cameras;
  int curCamera = 0;
  bool isConnected;
  bool pingOk;
  Directory appDir;
  PacameraProvider pacameraProvider;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    pacameraProvider = Provider.of<PacameraProvider>(context);
    await loadCameras();
    loadCameraController();
    initWebsocket();
  }

  void onWebsocketData(data) {
    print(data);
    var res = PacaProtocolModel.fromJson(json.decode(data));

    switch (res.event) {
      case "cheese":
        capturePicture();
        break;
      case "ping":
        setState(() {
          pingOk = true;
          isConnected = true;
          print('X yeap trues');
        });
        break;
      default:
        print(data);
    }
  }

  void initWebsocket() {
    channel = IOWebSocketChannel.connect(pacameraProvider.ipAddressServer);
    pingOk = true;
    isConnected = true;
    schedulePing();
    channel.stream.listen(onWebsocketData);
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

  void capturePicture() async {
    print('menyimpan');

    String date = DateTime.now().millisecondsSinceEpoch.toString();
    String tempDir = (await getTemporaryDirectory()).path;

    try {
      var path = '$tempDir/$date.jpg';
      await controller.takePicture(path);
      File f = File(path);
      String encoded = base64Encode(f.readAsBytesSync());

      String fileName = pacameraProvider.deviceName;
      channel.sink.add(json.encode({
        "event": "save",
        "data": {
          "filename": '$fileName',
          "encoded": encoded,
        }
      }));
    } catch (e) {
      print(e);
      showDialog(context: context, builder: (_) => Text('Something is wrong'));
      loadCameras();
      loadCameraController();
    }
  }

  Future<void> loadCameras() async {
    cameras = await availableCameras();
    // loadCameraController();
  }

  void loadCameraController() {
    // Untuk pilih kamera
    var camIndex = curCamera % cameras.length;

    controller =
        CameraController(cameras[camIndex], pacameraProvider.cameraResolution);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget buildCamPreview() {
      if (controller == null || controller.value == null) {
        return Container(child: Center(child: CircularProgressIndicator()));
      }

      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }

    Widget buildControl({
      Widget child,
      double iconSize: 30,
      Color foregroundColor: Colors.transparent,
      Function() onTap,
    }) {
      return ClipOval(
        child: Material(
          color: foregroundColor,
          child: IconButton(
            icon: child,
            splashColor: Colors.blue,
            color: Colors.white,
            iconSize: iconSize,
            onPressed: onTap,
          ),
        ),
      );
    }

    Widget buildSettingButton() {
      return buildControl(
        child: Icon(Icons.settings,
            color: isConnected ? Colors.grey : Colors.white),
        onTap: isConnected
            ? () {}
            : () {
                showDialog(
                    context: context, builder: (context) => SettingDialog());
              },
      );
    }

    Widget buildConnectButton() {
      return buildControl(
        child: Icon(isConnected ? Icons.not_interested : Icons.check),
        onTap: () {
          if (isConnected) {
            channel.sink.close();
            setState(() {
              pingOk = false;
              isConnected = false;
            });
          } else {
            initWebsocket();
          }
        },
      );
    }

    Widget buildCameraSwitcher() {
      return buildControl(
        child: Icon(Icons.switch_camera),
        onTap: () {
          curCamera = curCamera + 1;
          loadCameraController();
        },
      );
    }

    Widget buildCaptureButton() {
      return buildControl(
        child: Icon(Icons.camera),
        iconSize: 50,
        foregroundColor: Theme.of(context).primaryColor.withOpacity(0.70),
        onTap: () {
          channel.sink.add(
              json.encode({"event": "new", "data": DateTime.now().toString()}));

          channel.sink.add(json
              .encode({"event": "cheese", "data": DateTime.now().toString()}));
        },
      );
    }

    Widget buildTimer() {
      return buildControl(
        child: Icon(Icons.timer),
        onTap: () {},
      );
    }

    Widget shadowButtonControl(Widget child) {
      return Container(
        child: child,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(50), boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 25,
            spreadRadius: 10,
          )
        ]),
      );
    }

    Widget padButtonControl(Widget child) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Center(child: buildCamPreview()),
          Positioned.fill(
            top: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        shadowButtonControl(buildConnectButton()),
                        Text(
                          isConnected
                              ? 'CAM ${pacameraProvider.deviceName}'
                              : 'DISCONNECTED',
                          style: Theme.of(context)
                              .textTheme
                              .title
                              .copyWith(color: Colors.white),
                        ),
                        shadowButtonControl(buildSettingButton()),
                      ],
                    ),
                    Container(
                      // color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          padButtonControl(
                              shadowButtonControl(buildCameraSwitcher())),
                          padButtonControl(
                              shadowButtonControl(buildCaptureButton())),
                          padButtonControl(shadowButtonControl(buildTimer())),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
