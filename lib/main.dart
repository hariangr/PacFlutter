import 'package:flutter/material.dart';
import 'package:panflutter/components/pages/camera_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class PacameraProvider extends ChangeNotifier {
  String _ipAddressServer = "ws://192.168.1.4:3000";
  String _deviceName = "0";

  String get ipAddressServer => _ipAddressServer;
  void setIpAddressServer(String ip) {
    _ipAddressServer = ip;
    notifyListeners();
  }

  String get deviceName => _deviceName;
  void setDeviceName(String name) {
    _deviceName = name;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(builder: (_) => PacameraProvider())],
      child: MaterialApp(
        title: 'Pacamera',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CameraPage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}
