
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

class DoctorPage extends StatefulWidget {
  final Patient patient;
  DoctorPage({Key key, this.title, this.patient}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  DoctorPageState createState() => new DoctorPageState();
}

enum RxPageState{
  FILLING,
  ATTACHING,
  ATTACHED
}

class DoctorPageState extends State<DoctorPage> {
  var nameCtrl = new TextEditingController(text: "");
  var dobCtrl = new TextEditingController(text: "");
  var medNameCtrl = new TextEditingController(text: "Captopril");
  var medDoseCtrl = new TextEditingController(text: "50mg");
  var medQuanCtrl = new TextEditingController(text: "30 tabs");
  var medExpCtrl = new TextEditingController(text: "30");
  var addCtrl = new TextEditingController(text: "");
  DateTime issueDate;

  var pageState = RxPageState.FILLING;


  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      nameCtrl.text = widget.patient.name;
      dobCtrl.text = widget.patient.dob;
      medNameCtrl.text = widget.patient.medName;
      medDoseCtrl.text = widget.patient.medDose;
      medQuanCtrl.text = widget.patient.medQuan;
      medExpCtrl.text = widget.patient.medExp;
      addCtrl.text = widget.patient.add;
    }
  }

  Future<bool> submitPrescription(BuildContext context) async {

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

    NFCUtils.platform.invokeMethod('sign', {"content": getPrescriptionJSON()}).then((String nfcReturn){

      // !!! nfcReturn includes first 81 bytes address, then message, then 9000

      print("nfcReturn ${nfcReturn.length}");

      if (nfcReturn.substring(nfcReturn.length - 2, nfcReturn.length) != NFCUtils.SUCCESS_CODE){
        nfcOrAttachFail();
        return;
      }


      final address = nfcReturn.substring(0,81);
      final mamPayload = nfcReturn.substring(81,nfcReturn.length-2);



      Navigator.of(context).pop();

      setState(() => pageState = RxPageState.ATTACHING);

      attach(mamPayload, address).then((success){

        if (success){
          setState(() => pageState = RxPageState.ATTACHED);
          showDialog(context: context, child:
          new AlertDialog(
              title: new Text("Prescription submitted"),
              content: new Text("The prescription is signed by both you and the patient, and should be visible by dispensaries if allowed access. (POW delegated to node)\nFirst 25 chars: ${mamPayload.substring(0,25)}"),
              actions: [
                new FlatButton(onPressed: () => Navigator.of(context).pop(), child: new Text("OK"))
              ]
          )
          );
        } else {
          nfcOrAttachFail();
        }
      });


    });



    return true;


  }

  void nfcOrAttachFail(){
    setState(() => pageState = RxPageState.FILLING);
    showDialog(context: context, child: new AlertDialog(
      title: new Text("Oops"),
      content: new Text("Something went wrong and the prescription is not sent! Please try again."),
      actions: [
        new FlatButton(onPressed: () => Navigator.of(context).pop(), child: new Text("OK"))
      ]
    ));
  }



  String getPrescriptionJSON(){
    issueDate = new DateTime.now();
    final Map<String, Object> _map = {
      "content": {
        "patient_name": nameCtrl.text,
        "patient_dob": dobCtrl.text,
        "patient_add": addCtrl.text,
        "med": medNameCtrl.text,
        "dosage": medDoseCtrl.text,
        "quantity": medQuanCtrl.text,
        "issued_on": new DateTime.now().millisecondsSinceEpoch ~/ 1000,
        "expire_by": new DateTime.now()
            .add(new Duration(days: int.parse(medExpCtrl.text)))
            .millisecondsSinceEpoch ~/ 1000,
        "doctor_id": 533,
      }
    };
    var _strippedMapStr = json.encode(_map);
    _strippedMapStr = _strippedMapStr.replaceAll("\r", "").replaceAll("\n", "");
    final dSign = Crypto.signContent(_strippedMapStr);
    _map["d_sign"] = dSign;

    return json.encode(
      _map
    );
  }


  @override
  Widget build(BuildContext context) {

    // attaching

    if (pageState == RxPageState.ATTACHING){
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Attaching...")
        ),
        body: new Column(
          children:[
            new Expanded(child: new Container()),
            new Center(
              child: new Padding(
                padding: const EdgeInsets.all(20.0),
                child: new Column(
                  children:[
                    new Container(
                        width: 50.0,
                        height: 50.0,
                        child: new SquareLoader()
                    ),
                    new Container(
                        height: 20.0
                    ),
                    new Text(
                        "Sending the prescription...\nThis might take up to 2 minutes.",
                        textAlign: TextAlign.center,
                        style: LightStyle.copyWith(fontSize: 25.0)
                    ),
                    new Container(
                        height: 20.0
                    ),
                    new Text(
                        "This will be done in the background in the final version -> No waiting in the UI.",
                        textAlign: TextAlign.center,
                        style: LightStyle.copyWith(fontSize: 20.0)
                    )
                  ]
                )
              )
            ),
            new Expanded(child: new Container()),
          ]
        )
      );
    }

    //attached

    if (pageState == RxPageState.ATTACHED){

      Widget getReceipt(){

        return new Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            new ListTile(
              leading: const Icon(Icons.person),
              title: new Text(nameCtrl.text),
              subtitle: new Text("Patient Name"),
            ),
            new ListTile(
              leading: const Icon(Icons.cake),
              title: new Text(dobCtrl.text),
              subtitle: new Text("Patient Date of Birth"),
            ),
            new ListTile(
              leading: const Icon(Icons.home),
              title: new Text(addCtrl.text),
              subtitle: new Text("Patient Address"),
            ),
            new Divider(),
            new ListTile(
              leading: const Icon(Icons.trip_origin),
              title: new Text(medNameCtrl.text),
              subtitle: new Text("Medication Name"),
            ),
            new ListTile(
              leading: const Icon(Icons.donut_small),
              title: new Text(medDoseCtrl.text),
              subtitle: new Text("Medication Dosage"),
            ),
            new ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: new Text(medQuanCtrl.text),
              subtitle: new Text("Medication Quantity"),
            ),
            new ListTile(
              leading: const Icon(Icons.calendar_today),
              title: new Text(getDTRep(issueDate.toLocal())),
              subtitle: new Text("Isssued on"),
            ),
            new ListTile(
              leading: const Icon(Icons.date_range),
              title: new Text(getDTRep(new DateTime.now()
                  .add(new Duration(days: int.parse(medExpCtrl.text))).toLocal())),
              subtitle: new Text("Expire by"),
            ),
          ]
        );
      }

      return new Scaffold(
        appBar: new AppBar(
            title: new Text("Attached!")
        ),
        body: new ListView(
          children:[
            new Container(
                height: 20.0
            ),
            new CircleAvatar(
              radius: 40.0,
              child: new Icon(Icons.done_outline, size: 32.0, color: Colors.white),
              backgroundColor: Colors.lightGreen,
            ),
            new Container(
                height: 20.0
            ),
            new Center(child: new Text(
                "Prescription sent!",
                style: LightStyle.copyWith(fontSize: 32.0)
            )),
            new Container(
                height: 20.0
            ),
            new Text(
                "  Receipt",
              style: HeaderStyle,
            ),
            new Divider(),
            new Padding(
              padding: const EdgeInsets.all(20.0),
              child: getReceipt()
            )
          ]
        )
      );
    }


    //filling

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Container(
            padding: const EdgeInsets.all(20.0),
            child: new SingleChildScrollView(
              child: new Column(children: <Widget>[
                new Row(
                    children: [
                      new Icon(Icons.local_hospital),
                      new Container(width: 20.0),
                      new Text("Signing with: #533 Dr. LEE SAM"),
                    ]),
                new Row(
                    children: [
                      new Icon(Icons.cast_connected),
                      new Container(width: 20.0),
                      new Text("Mainnet online"),
                    ]),
                new Divider(color: Colors.black),
                new Text("Patient particulars"),
                new TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: "Patient Name",
                        icon: const Icon(Icons.person)
                    )
                ),
                new TextField(
                    controller: dobCtrl,
                    decoration: const InputDecoration(
                        labelText: "Patient Date of Birth",
                        icon: const Icon(Icons.cake)
                    )
                ),
                new TextField(
                    controller: addCtrl,
                    decoration: const InputDecoration(
                        labelText: "Patient Address",
                        icon: const Icon(Icons.home)
                    )
                ),
                new Container(height: 10.0),
                new Divider(color: Colors.black),
                new Text("Medication details"),
                new TextField(
                    controller: medNameCtrl,
                    decoration: const InputDecoration(
                        labelText: "Medication name",
                        icon: const Icon(Icons.trip_origin)
                    )
                ),
                new TextField(
                    controller: medDoseCtrl,
                    decoration: const InputDecoration(
                        labelText: "Medication Dosage",
                        icon: const Icon(Icons.donut_small)
                    )
                ),
                new TextField(
                    controller: medQuanCtrl,
                    decoration: const InputDecoration(
                        labelText: "Medication Quantity",
                        icon: const Icon(Icons.format_list_numbered)
                    )
                ),
                new TextField(
                    controller: medExpCtrl,
                    decoration: const InputDecoration(
                        labelText: "Expire in (in days)",
                        icon: const Icon(Icons.date_range)
                    )
                ),
                new Container(
                  height: 100.0,
                )
              ],
              ),
            )),
        floatingActionButton: new Builder(
            builder: (bc) {
              return new FloatingActionButton(
                onPressed: () => submitPrescription(bc),
                tooltip: 'Sign and broadcast',
                child: new Icon(Icons.send),
              ); // This trailing comma makes auto-formatting nicer for build methods.
            }
        )
    );
  }
}