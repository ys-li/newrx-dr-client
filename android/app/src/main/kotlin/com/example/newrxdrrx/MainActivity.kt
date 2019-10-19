package com.example.newrxdrrx

import android.os.Bundle
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import android.util.Log
import io.flutter.plugin.common.MethodChannel


class MainActivity(): FlutterActivity(), NfcAdapter.ReaderCallback {


    private var nfcAdapter: NfcAdapter? = null
    private var cardMode: CardMode? = null
    private var contentForNFC: String? = null
    private var channelResult: io.flutter.plugin.common.MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        nfcAdapter = NfcAdapter.getDefaultAdapter(this);

        MethodChannel(flutterView, "newrx/nfc").setMethodCallHandler { call, result ->
            when (call.method){
                "sign" -> {
                    channelResult = result
                    contentForNFC = call.argument("content")
                    Log.d("channel", "signing - $contentForNFC")
                    enableNFC(CardMode.SIGN)
                }
                "getNewest" -> {
                    channelResult = result
                    contentForNFC = call.argument("pin")
                    Log.d("channel", "newest: pin is $contentForNFC")
                    enableNFC(CardMode.GET_NEWEST)
                }
                "getFirst" -> {
                    channelResult = result
                    contentForNFC = call.argument("pin")
                    Log.d("channel", "full: pin is $contentForNFC")
                    enableNFC(CardMode.GET_FIRST)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        GeneratedPluginRegistrant.registerWith(this)
    }

    fun enableNFC(mode: CardMode){

        cardMode = mode
        nfcAdapter?.enableReaderMode(this, this,
                NfcAdapter.FLAG_READER_NFC_A or NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK,
                null)
    }

    override fun onTagDiscovered(tag: Tag?) {
        val isoDep = IsoDep.get(tag)
        isoDep.timeout = 5000
        isoDep.connect()
        Log.d("READER", "Tag detected, extended: ${isoDep.isExtendedLengthApduSupported}, max: ${isoDep.maxTransceiveLength}")
        val message : ByteArray

        Log.d("READER", "contentForNFC: $contentForNFC")

        when(cardMode){
            CardMode.SIGN -> {
                message = getFullMsg(INS.CRYPTO, P1.FIRST_ROOT, contentForNFC!!)
            }
            CardMode.GET_FIRST -> {
                message = getFullMsg(INS.GET_KEY_ROOT, P1.FIRST_ROOT, contentForNFC!!)
            }
            CardMode.GET_NEWEST -> {
                message = getFullMsg(INS.GET_KEY_ROOT, P1.NEWEST_ROOT, contentForNFC!!)
            }
            else -> {
                message = getFullMsg(INS.CRYPTO, P1.FIRST_ROOT, contentForNFC!!)
            }
        }

        Log.d("SENDING", Utils.toHex(message))

        val response = isoDep.transceive(Utils.hexStringToByteArray( "00A4040007A0000002471001"))

        //runOnUiThread { textView.append("\nCard Response: " + Utils.toHex(response)) }

        if (Utils.toHex(response) == "9000") {
            isoDep.timeout = 5000
            val response = isoDep.transceive(message)
            nfcAdapter?.disableReaderMode(this)
            contentForNFC = null
            cardMode = null
            Log.d("nfc-resp", "${response.toString(Charsets.US_ASCII).length}")
            channelResult?.success(response.toString(Charsets.US_ASCII))
            channelResult = null
//            if (Utils.toHex(response).length > 4){
//
////                runOnUiThread {
////                    textView.append("\nMAM SIGNED: ${ response.toString(Charsets.US_ASCII).substring(0,50)}...")
////                    textView.append("\nMAM LENGTH: ${ response.toString(Charsets.US_ASCII).length}...")
////                }
//            } else {
//                channelResult?.error("BAD RESPONSE", "bad response", null)
//                channelResult = null
//                //runOnUiThread { textView.append("\nCard Response: " + Utils.toHex(response)) }
//            }

        }



        isoDep.close()
    }

    enum class CardMode{
        SIGN,
        GET_NEWEST,
        GET_FIRST
    }


    fun getFullMsg(ins: INS, p1: P1, content: String, encodeContent: Boolean = true) : ByteArray{

        val insStr = when (ins){
            INS.SELECT -> "A4"
            INS.CRYPTO -> "AE"
            INS.GET_KEY_ROOT -> "C0"
        }

        val p1Str = when (p1){
            P1.NEWEST_ROOT -> "97"
            P1.SUBSCRIPTIVE -> "98"
            P1.FIRST_ROOT -> "99"
        }

        val cmds = "00${insStr}${p1Str}00"

        var lc : String

        if (content.length == 0){
            lc = "00"
        }
        else if (content.length in 1..256) {
            lc = content.length.toString(16).toUpperCase().padStart(2, '0')
        }
        else {
            lc = "00" + content.length.toString(16).toUpperCase().padStart(4, '0')
        }

        val headerArr = Utils.hexStringToByteArray(cmds+lc)

        val contentArr = content.toByteArray(Charsets.US_ASCII)

        val le = Utils.hexStringToByteArray("FFFF")

        return headerArr + contentArr + le

    }

    enum class INS{
        SELECT,
        CRYPTO, //AE - GENERATE AUTHORISATION CRYPTOGRAM
        GET_KEY_ROOT //C0 - GET RESPONSE
    }

    enum class P1 {
        SUBSCRIPTIVE, NEWEST_ROOT, FIRST_ROOT
    }
}
