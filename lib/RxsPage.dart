
import 'package:flutter/material.dart';
import 'Loader.dart';
import 'dart:async';
import "utils/crypto.dart";
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';
import 'Themes.dart';
import 'main.dart';
import 'RxPage.dart';
import 'NetCode.dart';
import 'Patient.dart';

class RxsPage extends StatefulWidget{

  final String root;
  final String sideKey;

  RxsPage(this.root, this.sideKey);

  @override
  State createState() {
    return new RxsPageState();
  }
}

class RxsPageState extends State<RxsPage>{

  var loading = true;
  Map fetchedMap;
  var rxs = new List<Rx>();

  @override
  void initState() {
    super.initState();
    if (fetchedMap == null){
      fetch(widget.root, widget.sideKey).then((m){
        if (m != null) {


          fetchedMap = m;
          setState(() => loading = false);
        } else {
          showDialog(context: context, child: new AlertDialog(
            title: const Text("Oops"),
            content: const Text("Unable to fetch prescriptions. Please try again."),
            actions: [
              new FlatButton(onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); }, child: const Text("OK"))
            ]
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading){
      return new Scaffold(
          appBar: new AppBar(
              title: new Text("Getting prescriptions..."),
            backgroundColor: Colors.blue,
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
                                  "Loading the prescription...\nThis might take up to a minute.",
                                  textAlign: TextAlign.center,
                                  style: LightStyle.copyWith(fontSize: 25.0)
                              ),
                              new Container(
                                  height: 20.0
                              )
                            ]
                        )
                    )
                ),
                new Expanded(child: new Container()),
              ]
          )
      );
    } else {

      Widget content;

      rxs.clear();

      for(String s in fetchedMap["messages"]){
        var rx = json.decode(s);
        var dsign = rx["d_sign"];
        rx = rx["content"];
        rxs.add(new Rx(
          rx["patient_name"],
          rx["patient_dob"],
          rx["med"],
          rx["dosage"],
          rx["quantity"],
          new DateTime.fromMillisecondsSinceEpoch(rx["issued_on"]*1000),
          new DateTime.fromMillisecondsSinceEpoch(rx["expire_by"]*1000),
          rx["patient_add"],
          dsign
        ));
      }

      rxs.sort((rx1, rx2) => rx2.issuedOn.millisecondsSinceEpoch - rx1.issuedOn.millisecondsSinceEpoch);

      if (!(rootKeys.any((rk) => rk.root == widget.root))) {
        rootKeys.add(new RootKey(widget.root, widget.sideKey, rxs[0].name));
      }



      content = new ListView.builder(itemCount: rxs.length,itemBuilder: (bc, i){
        return new InkWell(
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (bc){
              return new RxPage(rxs[i]);
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
                                new Text(rxs[i].name, style: HeaderStyle),
                                new Container(height: 5.0),
                                new Text("${rxs[i].medName}, expire by ${getDTRep(rxs[i].expireBy)}", style: LightStyle.copyWith(color: Colors.black54, fontSize: 20.0),)
                              ]
                          )
                      )

                    ]
                )
            )
        );
      });


      return new Scaffold(
          appBar: new AppBar(
            title: new Text("Prescriptions for ${rxs[0].name}"),
            backgroundColor: Colors.blue,
          ),
          body: content
      );

    }


  }
}