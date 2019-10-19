
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

class RxPage extends StatelessWidget{

  final Rx rx;

  RxPage(this.rx);

  @override
  Widget build(BuildContext context) {

    bool verified = false;

    final Map<String, Object> _map = {
      "content": {
        "patient_name": rx.name,
        "patient_dob": rx.dob,
        "patient_add": rx.add,
        "med": rx.medName,
        "dosage": rx.medDose,
        "quantity": rx.medQuan,
        "issued_on": rx.issuedOn.millisecondsSinceEpoch ~/ 1000,
        "expire_by": rx.expireBy.millisecondsSinceEpoch ~/ 1000,
        "doctor_id": 533,
      }
    };
    var _strippedMapStr = json.encode(_map);
    _strippedMapStr = _strippedMapStr.replaceAll("\r", "").replaceAll("\n", "");

    verified = Crypto.verify(rx.dsign, _strippedMapStr);


    return new Scaffold(
      appBar: new AppBar(
        title: new Text("${rx.medName}, ${rx.medDose} ${rx.medQuan}"),
        backgroundColor: Colors.blue,
      ),
      body: new SingleChildScrollView(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            new ListTile(
              leading: const Icon(Icons.person),
              title: new Text(rx.name),
              subtitle: new Text("Patient Name"),
            ),
            new ListTile(
              leading: const Icon(Icons.cake),
              title: new Text(rx.dob),
              subtitle: new Text("Patient Date of Birth"),
            ),
            new ListTile(
              leading: const Icon(Icons.home),
              title: new Text(rx.add),
              subtitle: new Text("Patient Address"),
            ),
            new Divider(),
            new ListTile(
              leading: const Icon(Icons.trip_origin),
              title: new Text(rx.medName),
              subtitle: new Text("Medication Name"),
            ),
            new ListTile(
              leading: const Icon(Icons.donut_small),
              title: new Text(rx.medDose),
              subtitle: new Text("Medication Dosage"),
            ),
            new ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: new Text(rx.medQuan),
              subtitle: new Text("Medication Quantity"),
            ),
            new ListTile(
              leading: const Icon(Icons.calendar_today),
              title: new Text(getDTRep(rx.issuedOn)),
              subtitle: new Text("Isssued on"),
            ),
            new ListTile(
              leading: const Icon(Icons.date_range),
              title: new Text(getDTRep(rx.expireBy)),
              subtitle: new Text("Expire by"),
            ),
            new Divider(),
            new ListTile(
              leading: const Icon(Icons.local_hospital),
              title: new Text(rx.doctor),
              subtitle: new Text("Doctor's name and ID"),
            ),
            new ListTile(
              leading: verified ? const Icon(Icons.beenhere, color: Colors.green) : const Icon(Icons.cancel, color: Colors.red),
              title: new Text(verified ? "Doctor's signature verified (ed25519)" : "Unable to verify signature!"),
              subtitle: new Text("${rx.dsign.substring(0,15)}..."),
            ),
          ]
        )
      )
    );
  }
}