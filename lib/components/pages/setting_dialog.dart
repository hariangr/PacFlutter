import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:panflutter/main.dart';
import 'package:provider/provider.dart';

class SettingDialog extends StatefulWidget {
  @override
  _SettingDialogState createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog> {
  String ipServ;
  String deviceName;
  ResolutionPreset resPreset;
  var formKey = GlobalKey<FormState>();
  PacameraProvider pacaProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pacaProvider = Provider.of<PacameraProvider>(context);
    deviceName = pacaProvider.deviceName;
    resPreset = pacaProvider.cameraResolution;
    print(resPreset.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'IP Address Pacamera Server'),
                initialValue: pacaProvider.ipAddressServer,
                onSaved: (s) => ipServ = s,
              ),
              DropdownButtonFormField(
                value: deviceName,
                decoration: InputDecoration(labelText: 'Nomer kamera'),
                onChanged: (s) {
                  setState(() {
                    deviceName = s;
                  });
                },
                onSaved: (s) => deviceName = s,
                items: List.generate(
                    100,
                    (i) => DropdownMenuItem(
                          value: i.toString(),
                          child: Text(i.toString()),
                        )),
              ),
              DropdownButtonFormField(
                value: resPreset,
                decoration: InputDecoration(labelText: 'Resolusi kamera'),
                onChanged: (s) {
                  setState(() {
                    resPreset = s;
                  });
                },
                onSaved: (s) => resPreset = s,
                items: ResolutionPreset.values
                    .map((f) =>
                        DropdownMenuItem(value: f, child: Text(f.toString())))
                    .toList(),
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
                    color: Colors.blue,
                    child: Text('OK'),
                    onPressed: () {
                      formKey.currentState.save();

                      pacaProvider.setIpAddressServer(ipServ);
                      pacaProvider.setDeviceName(deviceName);
                      pacaProvider.setCameraResolution(resPreset);

                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
