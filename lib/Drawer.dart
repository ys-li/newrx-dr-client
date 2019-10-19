import 'package:flutter/material.dart';
import 'PatientPage.dart';
import 'PharamcyPage.dart';
import 'Themes.dart';

class NewRxDrawer extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    var content = new Column(children: [
      new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('assets/images/bg.jpg'), fit: BoxFit.cover),
          ),
          height: 200.0,
          child: new Align(
            alignment: FractionalOffset.bottomRight,
            child: new Container(
                child: new Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: new Image.asset('assets/images/logo.png', height: 50.0,)
                ),
            )
          )
      ),
      new ListTile(
          leading: new Icon(
            Icons.local_hospital,
          ),
          title: new Text("[DOCTOR]"),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(context, new MaterialPageRoute(builder: (bc) => new PatientPage()));
          }
      ),
      new ListTile(
          leading: new Icon(
            Icons.local_pharmacy,
            //color: hsbcColor,
          ),
          title: new Text("[PHARMACY]"),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(context, new MaterialPageRoute(builder: (bc) => new PharmacyPage()));
          }
        //onTap: (){setState(() => widget.buinessPage = false);
        //Navigator.of(context).pop();},
      ),

    ]);

    return new Drawer(
      child: content
    );
  }
}