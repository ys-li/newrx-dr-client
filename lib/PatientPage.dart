import 'package:flutter/material.dart';
import 'Loader.dart';
import 'dart:async';
import "utils/crypto.dart";
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';
import 'main.dart';
import 'Patient.dart';
import 'Themes.dart';
import 'DoctorPage.dart';
import 'Drawer.dart';

class PatientPage extends StatelessWidget{

  final List<Patient> patients = [
    const Patient("John Doe", "09/12/77", "Captopril", "50mg", "30tabs", "30", "Aberdeen"),
    const Patient("Bob Jones", "09/12/77", "Sitagliptin", "25mg", "30tabs", "30", "Kennedy Town"),
    const Patient("Mark Smith", "09/12/77", "Metformin", "500mg", "30tabs", "30", "Mongkok"),
    const Patient("Jane Smith", "09/12/77", "Rosuvastatin", "5mg", "30tabs", "30", "Sheung Shui"),
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text("Your patients"),
      ),
      drawer: new NewRxDrawer(),
      body: new ListView.builder(
        itemCount: patients.length + 1,
        itemBuilder: (bc, i){

          if (i == patients.length){
            return new InkWell(
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (bc){
                return new DoctorPage(title: "NewRx - New Patient");
              })),
              child: new Padding(
                padding: const EdgeInsets.all(15.0),
                child: new Row(
                    children:[
                      new Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: new Icon(Icons.person_add, color: Colors.red.shade100, size: 30.0)
                      ),
                      new Container(width: 30.0),
                      new Expanded(
                          child: new Column(

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                new Text("Add a new patient...", style: HeaderStyle),
                              ]
                          )
                      )

                    ]
                )
            )
            );
          }

          return new InkWell(
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (bc){
              return new DoctorPage(title: "NewRx - ${patients[i].name}", patient: patients[i]);
            })),
            child: new Padding(
                padding: const EdgeInsets.all(15.0),
                child: new Row(
                    children:[
                      new Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: const Icon(Icons.person, color: Colors.red, size: 30.0)
                      ),
                      new Container(width: 30.0),
                      new Expanded(
                          child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                new Text(patients[i].name, style: HeaderStyle),
                                new Container(height: 5.0),
                                new Text("${patients[i].medName}, ${patients[i].medDose}", style: LightStyle.copyWith(color: Colors.black54, fontSize: 20.0),)
                              ]
                          )
                      )

                    ]
                )
            )
          );
        }
      )
    );
  }
}