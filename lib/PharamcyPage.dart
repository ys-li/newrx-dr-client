
import 'package:flutter/material.dart';
import 'Loader.dart';
import 'dart:async';
import "utils/crypto.dart";
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';
import 'Themes.dart';
import 'main.dart';
import 'NetCode.dart';
import 'Patient.dart';
import 'Drawer.dart';
import 'RxsPage.dart';
import 'Selector.dart';

class PharmacyPage extends StatefulWidget {

  @override
  State createState() {
    return new PharmacyPageState();
  }
}

enum FetchMode{
  NEWEST,
  BRANCH,
  FULL,
}

class PharmacyPageState extends State<PharmacyPage> with TickerProviderStateMixin{

  var fetchMode = FetchMode.NEWEST;
  var pinController = new TextEditingController();
  bool sendable = true;
  TabController tabc;


  @override
  void initState() {
    tabc = new TabController(length: 2, vsync: this);
    tabc.addListener(() {
      setState((){
        sendable = tabc.index == 0;
      });
    });
    super.initState();
  }

  Icon getIconByMode(){
    switch (fetchMode){
      case FetchMode.BRANCH:
        return const Icon(Icons.filter_center_focus, color: Colors.blue, size: 30.0);
      case FetchMode.FULL:
        return const Icon(Icons.linear_scale, color: Colors.red, size: 30.0);
      case FetchMode.NEWEST:
        return const Icon(Icons.call_split, color: Colors.green, size: 30.0);
    }
    return const Icon(Icons.linear_scale, color: Colors.red, size: 30.0);
  }

  Widget buildModeSelector(){

    Widget main = new Row(
      children:[
        new Expanded(child: new Text("Mode of access", style: HeaderStyle.copyWith(fontSize: 20.0))),
        new Container(width: 20.0),
        new Selector(
          [
            "Subscriptive",
            "Limited (newest)",
            "Full",
          ],
          (i){
            setState(() => fetchMode = FetchMode.values[i]);
          },
          selectedIndex: fetchMode.index,
        ),
        new Container(width: 20.0),
        new Padding(
          padding: const EdgeInsets.all(5.0),
          child: getIconByMode(),
        ),
      ]
    );

    return new Padding(
      padding: const EdgeInsets.all(10.0),
      child: main
    );

  }

  Widget buildPINSelector(){

    Widget main = new Column(
      children:[
        new Text("Enter your PIN here.", style: HeaderStyle),
        new Text("PIN for full and limited access are different!", style: LightStyle),
        new Container(height: 20.0),
        new Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0), child:
          new TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: HeaderStyle.copyWith(color: Colors.black),
            textAlign: TextAlign.center,
          )
        )
      ]
    );

    return new Padding(
      padding: const EdgeInsets.all(10.0),
      child: main
    );

  }

  @override
  Widget build(BuildContext context) {
    var rootKeysWidgets = new List<Widget>();

    for (var rk in rootKeys){
      rootKeysWidgets.add(
        new InkWell(
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (bc){
              return new RxsPage(rk.root, rk.sideKey);
            })),
            child: new Padding(
                padding: const EdgeInsets.all(15.0),
                child: new Row(
                    children:[
                      new Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: const Icon(Icons.person, color: Colors.blue, size: 25.0)
                      ),
                      new Container(width: 30.0),
                      new Expanded(
                          child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                new Text("${rk.name} (${rk.root.substring(0,5)}...)", style: HeaderStyle.copyWith(fontSize: 25.0)),
                                new Container(height: 5.0),
                              ]
                          )
                      )

                    ]
                )
            )
        )
      );
    }

    var content = [
      new Container(height: 20.0),
      new Text("Patient parameters", style: HeaderStyle),
      buildModeSelector(),
      new Divider(),
      buildPINSelector(),
      new Container(height: 20.0),
      new Divider(),
    ];

    List<Widget> content2 = [
      new Padding(padding: const EdgeInsets.all(20.0), child: new Text("Access-allowed patients", style: HeaderStyle)),
      new Container(height: 10.0),
    ];
    content2.addAll(rootKeysWidgets);

    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text("Pharmacy"),
        backgroundColor: Colors.lightBlue,
        bottom: new TabBar(
          controller: tabc,
          tabs: [
            new Tab(icon: new Icon(Icons.open_in_new), text: "NEW"),
            new Tab(icon: new Icon(Icons.history), text: "ALLOWED-ACCESS")
          ],
        )
      ),
      drawer: new NewRxDrawer(),
      body: new TabBarView(
        controller: tabc,
        children:[
          new SingleChildScrollView(
            child:new Column(
                children: content
            ),
          ),
          new ListView(
            children: content2
          ),

        ]
      ),
      floatingActionButton: !sendable ? null : new Builder(
          builder: (bc) {
            return new FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () => fetchRx(bc),
              tooltip: 'Read card',
              child: new Icon(Icons.send),
            ); // This trailing comma makes auto-formatting nicer for build methods.
          }
      )
    );
  }

  Future<bool> fetchRx(BuildContext context) async {

    showModalBottomSheet(context: context, builder: (b) {
      return new Container(
        height: 300.0,
        child: new Center(
            child: new Column(
                children: [
                  new Expanded(child: new Container()),
                  new Icon(Icons.card_membership, size: 35.0),
                  new Container(height: 20.0),
                  new Container(width: 35.0, height: 35.0, child: new SquareLoader()),
                  new Container(height: 20.0),
                  new Text("Put patient's smart card on the back of this device..."),
                  new Expanded(child: new Container()),
                ]
            )
        ),
      );
    });

    final mode = fetchMode == FetchMode.NEWEST ? 'getNewest' : 'getFirst';

    NFCUtils.platform.invokeMethod(mode, {"pin": pinController.text}).then((String nfcReturn){

      // !!! nfcReturn includes first 81 bytes address, then message, then 9000

      print("nfcReturn ${nfcReturn.length}");

      var statusCode = nfcReturn.substring(nfcReturn.length - 2, nfcReturn.length);

      if (statusCode != NFCUtils.SUCCESS_CODE){

        Navigator.of(context).pop();

        if (statusCode == NFCUtils.PIN_WRONG_CODE)
          wrongPin();
        else
          nfcOrAttachFail();

        return;
      }



      setState(() => pinController.text = "");

      final root = nfcReturn.substring(0,81);
      final sideKey = nfcReturn.substring(81,nfcReturn.length-2);




      Navigator.of(context).pop();

      Navigator.of(context).push(new MaterialPageRoute(builder: (bc){
        return new RxsPage(root ,sideKey);
      }));





    });



    return true;


  }

  void wrongPin() {

    showDialog(context: context, child: new AlertDialog(
        title: new Text("Oops"),
        content: new Text("The PIN is incorrect, please try again."),
        actions: [
          new FlatButton(onPressed: () => Navigator.of(context).pop(), child: new Text("OK"))
        ]
    ));
  }

  void nfcOrAttachFail(){
    showDialog(context: context, child: new AlertDialog(
        title: new Text("Oops"),
        content: new Text("Unidentified error, please try again."),
        actions: [
          new FlatButton(onPressed: () => Navigator.of(context).pop(), child: new Text("OK"))
        ]
    ));
  }
}

