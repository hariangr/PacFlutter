import 'package:flutter/material.dart';
import 'package:panflutter/main.dart';
import 'package:provider/provider.dart';

class SettingDialog extends StatefulWidget {
  final String currentDeviceName;

  SettingDialog({@required this.currentDeviceName});

  @override
  _SettingDialogState createState() => _SettingDialogState(deviceName: currentDeviceName);
}

class _SettingDialogState extends State<SettingDialog> {
  String ipServ;
  String deviceName;
  var formKey = GlobalKey<FormState>();

  initState() {
    super.initState();
    deviceName = widget.currentDeviceName;
    print(deviceName);
  }

  _SettingDialogState({@required this.deviceName});

  @override
  Widget build(BuildContext context) {
    final pacaProvider = Provider.of<PacameraProvider>(context);

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
