import 'package:flutter/material.dart';
import 'Loader.dart';
import 'dart:async';
import "package:newrx_dr_rx/utils/crypto.dart";
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';
import 'DoctorPage.dart';
import 'PatientPage.dart';
import 'Themes.dart';
import 'PharamcyPage.dart';

void main() => runApp(new MyApp());


String getDTRep(DateTime dt){
  return "${dt.year}/${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
}

class NFCUtils {
  static var SUCCESS_CODE = ascii.decode([0x90, 0x00], allowInvalid: true);
  static var PIN_WRONG_CODE = ascii.decode([0x90, 0x04], allowInvalid: true);
  static const platform = const MethodChannel('newrx/nfc');
}

class RootKey{
  final String root;
  final String sideKey;
  final String name;
  RootKey(this.root, this.sideKey, this.name);
}

List<RootKey> rootKeys = new List<RootKey>();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
//    var content = "HELLO BABY{}{}";
//    print("content: $content");
//    print("signed: ${Crypto.signContent(content)}");
//    print("verify: ${Crypto.verify(Crypto.signContent(content), content)}");
    return new MaterialApp(
      title: 'NewRx - Prototype App',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.red,
      ),
      home: new SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    Stack mainStack = new Stack(
        fit: StackFit.expand,
        textDirection: TextDirection.ltr,
        children:[
          new Container(
            constraints: new BoxConstraints.expand(),
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                begin: const FractionalOffset(0.5, 0.0),
                end: const FractionalOffset(0.5, 0.8),
                colors: <Color>[
                  const Color(0xff056EB9),
                  const Color(0xff25a1f9)
                ],
              ),
            ),
          ),
          new Center(
              child: new Column(
                  textDirection: TextDirection.ltr,
                  children: [
                    new Expanded(child: new Container()),
                    new Container(
                      child: new Image.asset('assets/images/logo.png',width: 240.0),
                      padding: const EdgeInsets.all(20.0),
                    ),
                    new Text("Welcome to NewRx\nPlease select your demo unit.", textDirection: TextDirection.ltr, textAlign: TextAlign.center ,style: HeaderStyle.copyWith(color: Colors.white, fontSize: 18.0)),
                    new Container(height: 10.0),
                    new Container(height: 10.0),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new FlatButton(
                          child: const Icon(Icons.local_hospital, color: Colors.red, size: 70.0),
                          onPressed: () => Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (bc) => new PatientPage())),
                        ),
                        new Container(width: 50.0),
                        new FlatButton(
                          child: new Icon(Icons.local_pharmacy, color: Colors.blue.shade900, size: 70.0),
                          onPressed: () => Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (bc) => new PharmacyPage())),
                        ),
                      ]
                    ),
                    new Expanded(child: new Container()),
                    new Text("(Prototype, demo) b7", textDirection: TextDirection.ltr, style: HeaderStyle.copyWith(color: Colors.white, fontSize: 14.0)),
                    new Container(height: 5.0)
                  ]
              )
          ),
        ]
    );
    return new Scaffold(body: mainStack);
  }
}
