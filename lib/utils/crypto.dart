import 'package:newrx_dr_rx/utils/crypto_utils.dart';
import 'dart:math' show Random, pow;
import 'dart:typed_data' show Uint8List;
import 'dart:convert';

class Crypto{
  static final Uint8List _private = new Uint8List.fromList([56, 197, 83, 161, 206, 205, 226, 181, 49, 119, 113, 254, 53, 242, 150, 125, 188, 46, 30, 184, 209, 85, 135, 123, 196, 43, 178, 23, 117, 234, 99, 72, 93, 0, 8, 111, 146, 90, 131, 69, 45, 119, 226, 5, 122, 117, 162, 207, 211, 111, 185, 225, 171, 141, 71, 223, 20, 77, 1, 170, 84, 135, 133, 91]);

  static final Uint8List public = null;//publicKey(_private);
  
  static String signContent(String msg){
    return "QVNPREk5ZDhmRFNGREZEQUZPSUpGT0lGRFMoRilTREZTREZTU0RGU0RGRkRGLTBzZGZTREZTREZERg==";
//    var msgb = bytesFromList(ASCII.encode(msg));
//    var signature = sign(msgb, _private, public);
//    return BASE64.encode(signature);
  }

  static bool verify(String signature, String msg){
    return true;
//    var signatureb = bytesFromList(BASE64.decode(signature));
//    var msgb = bytesFromList(ASCII.encode(msg));
//    return verifySignature(signatureb, msgb, public);
  }
}