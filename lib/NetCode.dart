import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http_parser/http_parser.dart' as http_parser;

const serverUrl = "http://newrx.enchor.tech/";
//const serverUrl = "http://192.168.1.2:3000/";

Future<bool> attach(String payload, String address) async {
  try {
    var response = await http.post(
        "${serverUrl}attach",
        body: json.encode({"payload": payload, "address": address}), headers: {
      'Content-Type': 'application/json',
      "Accept": "application/json",
    });

    Map content = json.decode(utf8.decode(response.bodyBytes));

    if (content.containsKey("address")) {
      return true;
    }

    return false;
  }
  catch (ex){
    return false;
  }

}

Future<Map> fetch(String root, String sideKey) async{
  try{

    String url = Uri.encodeFull("${serverUrl}fullFetch?root=$root&sideKey=$sideKey");

    print("url: $url");


    var response = await http.get(url);
    var content = json.decode(UTF8.decode(response.bodyBytes));

    return content;
  }
  catch (ex){
    return null;
  }
}